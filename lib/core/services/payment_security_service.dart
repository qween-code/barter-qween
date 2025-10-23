import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Ödeme güvenliği için gelişmiş güvenlik servisi
class PaymentSecurityService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  PaymentSecurityService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Ödeme verilerini şifrele
  String encryptPaymentData(Map<String, dynamic> data) {
    try {
      final jsonString = json.encode(data);
      final bytes = utf8.encode(jsonString);
      final hash = sha256.convert(bytes);
      return hash.toString();
    } catch (e) {
      throw PaymentSecurityException('Data encryption failed: $e');
    }
  }

  /// Ödeme verilerini doğrula
  Future<bool> validatePaymentRequest(PaymentValidationRequest request) async {
    try {
      // 1. Kullanıcı kimlik doğrulaması
      if (!await _validateUserAuthentication()) {
        throw PaymentSecurityException('User authentication failed');
      }

      // 2. Tutar validation
      if (!await _validatePaymentAmount(request.amount)) {
        throw PaymentSecurityException('Invalid payment amount');
      }

      // 3. Rate limiting kontrolü
      if (!await _checkRateLimiting(request.userId)) {
        throw PaymentSecurityException('Rate limit exceeded');
      }

      // 4. Çift işlem kontrolü
      if (await _isDuplicatePayment(request)) {
        throw PaymentSecurityException('Duplicate payment detected');
      }

      // 5. Güvenlik hash kontrolü
      if (!await _validateSecurityHash(request)) {
        throw PaymentSecurityException('Security validation failed');
      }

      return true;
    } catch (e) {
      await _logSecurityEvent('validation_failed', {
        'userId': request.userId,
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      });
      return false;
    }
  }

  /// Ödeme risk skorunu hesapla
  Future<double> calculatePaymentRiskScore(String userId, double amount) async {
    try {
      double riskScore = 0.0;

      // Kullanıcı geçmişi kontrolü
      final userPayments = await _firestore
          .collection('payments')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .get();

      // Yeni kullanıcı riski
      if (userPayments.docs.length < 3) {
        riskScore += 0.3;
      }

      // Yüksek tutar riski
      if (amount > 1000) {
        riskScore += 0.4;
      } else if (amount > 500) {
        riskScore += 0.2;
      }

      // Başarısız ödeme geçmişi
      final failedPayments = await _firestore
          .collection('payments')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'failed')
          .get();

      if (failedPayments.docs.length > 0) {
        riskScore += 0.2 * failedPayments.docs.length;
      }

      // Hesap yaşı kontrolü
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final createdAt = userDoc.get('createdAt') as Timestamp?;
        if (createdAt != null) {
          final accountAge = DateTime.now().difference(createdAt.toDate());
          if (accountAge.inDays < 7) {
            riskScore += 0.3;
          }
        }
      }

      return riskScore.clamp(0.0, 1.0);
    } catch (e) {
      return 1.0; // High risk if we can't calculate
    }
  }

  /// Güvenlik olayını kaydet
  Future<void> _logSecurityEvent(String eventType, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('security_events').add({
        'eventType': eventType,
        'data': data,
        'timestamp': FieldValue.serverTimestamp(),
        'userAgent': await _getUserAgent(),
      });
    } catch (e) {
      // Silent fail for security logging
    }
  }

  /// Rate limiting kontrolü
  Future<bool> _checkRateLimiting(String userId) async {
    try {
      final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));

      final recentPayments = await _firestore
          .collection('payments')
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThan: Timestamp.fromDate(oneHourAgo))
          .get();

      // Saat başına maksimum 10 ödeme
      return recentPayments.docs.length < 10;
    } catch (e) {
      return false;
    }
  }

  /// Çift işlem kontrolü
  Future<bool> _isDuplicatePayment(PaymentValidationRequest request) async {
    try {
      final fiveMinutesAgo = DateTime.now().subtract(const Duration(minutes: 5));

      final duplicateCheck = await _firestore
          .collection('payments')
          .where('userId', isEqualTo: request.userId)
          .where('amount', isEqualTo: request.amount)
          .where('paymentType', isEqualTo: request.paymentType)
          .where('createdAt', isGreaterThan: Timestamp.fromDate(fiveMinutesAgo))
          .limit(1)
          .get();

      return duplicateCheck.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Güvenlik hash doğrulaması
  Future<bool> _validateSecurityHash(PaymentValidationRequest request) async {
    try {
      final expectedHash = _generateSecurityHash(request);
      return request.securityHash == expectedHash;
    } catch (e) {
      return false;
    }
  }

  /// Güvenlik hash oluştur
  String _generateSecurityHash(PaymentValidationRequest request) {
    final data = '${request.userId}_${request.amount}_${request.paymentType}_${request.timestamp}';
    final bytes = utf8.encode(data);
    final hash = sha256.convert(bytes);
    return hash.toString().substring(0, 16);
  }

  /// Kullanıcı kimlik doğrulaması
  Future<bool> _validateUserAuthentication() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Email doğrulaması kontrolü
      if (!user.emailVerified) {
        await _logSecurityEvent('unverified_email_payment_attempt', {
          'userId': user.uid,
        });
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Tutar validation
  Future<bool> _validatePaymentAmount(double amount) async {
    try {
      // Pozitif tutar kontrolü
      if (amount <= 0) return false;

      // Maksimum tutar kontrolü (₺10,000)
      if (amount > 10000) return false;

      // Ondalık hassasiyet kontrolü
      final decimalPlaces = ((amount * 100) % 100).toInt();
      if (decimalPlaces > 0) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// User agent bilgisi al
  Future<String> _getUserAgent() async {
    try {
      return 'Flutter-App'; // In production, get actual user agent
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Şüpheli aktivite kontrolü
  Future<bool> checkSuspiciousActivity(String userId) async {
    try {
      final riskScore = await calculatePaymentRiskScore(userId, 0);

      if (riskScore > 0.7) {
        await _logSecurityEvent('high_risk_user_detected', {
          'userId': userId,
          'riskScore': riskScore,
        });

        // Çok yüksek riskli kullanıcılar için ek doğrulama
        if (riskScore > 0.9) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Ödeme validation request modeli
class PaymentValidationRequest {
  final String userId;
  final double amount;
  final String paymentType;
  final String securityHash;
  final String timestamp;

  PaymentValidationRequest({
    required this.userId,
    required this.amount,
    required this.paymentType,
    required this.securityHash,
    required this.timestamp,
  });
}

/// Ödeme güvenlik exception'ı
class PaymentSecurityException implements Exception {
  final String message;
  PaymentSecurityException(this.message);

  @override
  String toString() => 'PaymentSecurityException: $message';
}