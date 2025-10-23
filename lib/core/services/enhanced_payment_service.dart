import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:pay/pay.dart' as pay;
import 'payment_security_service.dart';

class EnhancedPaymentService {
  EnhancedPaymentService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    PaymentSecurityService? securityService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _securityService = securityService ?? PaymentSecurityService();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final PaymentSecurityService _securityService;

  pay.Pay? _googlePayClient;
  bool _initialized = false;
  bool _canUseGooglePay = false;

  static const _googlePayAsset = 'assets/payments/google_pay.json';

  Future<void> initializePaymentServices() async {
    if (_initialized) return;

    try {
      final configString = await rootBundle.loadString(_googlePayAsset);
      final configuration =
          pay.PaymentConfiguration.fromJsonString(configString);

      _googlePayClient =
          pay.Pay({pay.PayProvider.google_pay: configuration});
      _canUseGooglePay = await _googlePayClient!
          .userCanPay(pay.PayProvider.google_pay);
      _initialized = true;
    } on PlatformException catch (e) {
      _initialized = true;
      _canUseGooglePay = false;
      throw PaymentException(
        'Google Pay cihazda desteklenmiyor: ${e.message ?? 'bilinmeyen hata'}',
      );
    } catch (e) {
      _initialized = true;
      _canUseGooglePay = false;
      throw PaymentException('Ödeme servisleri başlatılamadı: $e');
    }
  }

  Future<bool> isGooglePayAvailable() async {
    await initializePaymentServices();
    return _canUseGooglePay;
  }

  Future<PaymentResult> processGooglePay(PaymentRequest request) async {
    await initializePaymentServices();

    if (!_canUseGooglePay) {
      return PaymentResult(
        success: false,
        errorMessage: 'Bu cihazda Google Pay kullanılamıyor.',
      );
    }

    try {
      // Güvenlik validasyonları
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return PaymentResult(
          success: false,
          errorMessage: 'Kullanıcı kimlik doğrulaması gerekli.',
        );
      }

      // Şüpheli aktivite kontrolü
      final isNotSuspicious = await _securityService.checkSuspiciousActivity(userId);
      if (!isNotSuspicious) {
        return PaymentResult(
          success: false,
          errorMessage: 'Güvenlik kontrolü başarısız. Destek ekibiyle iletişime geçin.',
        );
      }

      // Risk skoru kontrolü
      final riskScore = await _securityService.calculatePaymentRiskScore(userId, request.amount);
      if (riskScore > 0.8) {
        return PaymentResult(
          success: false,
          errorMessage: 'Bu işlem yüksek riskli olarak değerlendirildi.',
        );
      }

      final paymentItems = <pay.PaymentItem>[
        pay.PaymentItem(
          label: request.description ?? 'BarterQween Ödemesi',
          amount: request.amount.toStringAsFixed(2),
          status: pay.PaymentItemStatus.final_price,
        ),
      ];
      final response = await _googlePayClient!.showPaymentSelector(
        pay.PayProvider.google_pay,
        paymentItems,
      );

      final docRef = _firestore.collection('payments').doc();
      final currentUserId = _auth.currentUser?.uid;

      final payload = _serializeGooglePayResponse(response);
      final transactionToken = _extractTransactionToken(payload);

      // Barter sistemi için gerekli ödeme bilgilerini kaydet
      await docRef.set({
        'id': docRef.id,
        'userId': currentUserId,
        'amount': request.amount,
        'currency': 'TRY',
        'paymentType': 'cashDifferential',
        'paymentMethod': 'google_pay',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'rawPayload': payload,
        'transactionToken': transactionToken,
        'recipientId': request.recipientId,
        'description': request.description ?? 'Barter para farkı ödemesi',
        // Barter sistemi için ek bilgiler
        'barterData': {
          'isBarterPayment': true,
          'recipientId': request.recipientId,
        }
      });

      return PaymentResult(
        success: true,
        paymentId: docRef.id,
        transactionId: transactionToken,
        message: 'Ödeme başarıyla başlatıldı. Doğrulama bekleniyor.',
      );
    } on PlatformException catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: 'Google Pay hatası: ${e.message ?? 'bilinmeyen hata'}',
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: 'Google Pay işleminde sorun oluştu: $e',
      );
    }
  }

  /// Barter sistemi için özel ödeme işleme
  Future<PaymentResult> processBarterPayment({
    required double amount,
    required String recipientId,
    String? description,
    String? tradeId,
    String? itemId,
  }) async {
    final request = PaymentRequest(
      amount: amount,
      description: description ?? 'Barter para farkı ödemesi',
      recipientId: recipientId,
    );

    final result = await processGooglePay(request);

    if (result.success && result.paymentId != null) {
      // Ödeme belgesini barter sistemi için güncelle
      await _firestore.collection('payments').doc(result.paymentId).update({
        'barterData': {
          'tradeId': tradeId,
          'itemId': itemId,
          'recipientId': recipientId,
          'isBarterPayment': true,
          'paymentPurpose': 'cashDifferential',
        }
      });
    }

    return result;
  }

  Map<String, dynamic> _serializeGooglePayResponse(
    Map<String, dynamic> response,
  ) {
    try {
      jsonEncode(response);
      return response;
    } catch (_) {
      return {'raw': response.toString()};
    }
  }

  String? _extractTransactionToken(Map<String, dynamic> payload) {
    try {
      return payload['paymentMethodData']?['tokenizationData']?['token']
          as String?;
    } catch (_) {
      return null;
    }
  }
}

class PaymentException implements Exception {
  PaymentException(this.message);
  final String message;

  @override
  String toString() => 'PaymentException: $message';
}

/// Payment request data class
class PaymentRequest {
  PaymentRequest({
    required this.amount,
    this.description,
    this.recipientId,
  });

  final double amount;
  final String? description;
  final String? recipientId;
}

class PaymentResult {
  PaymentResult({
    required this.success,
    this.paymentId,
    this.transactionId,
    this.errorMessage,
    this.message,
  });

  final bool success;
  final String? paymentId;
  final String? transactionId;
  final String? errorMessage;
  final String? message;
}
