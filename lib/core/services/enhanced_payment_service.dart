import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:pay/pay.dart' as pay;

class EnhancedPaymentService {
  EnhancedPaymentService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

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

    final paymentItems = <pay.PaymentItem>[
      pay.PaymentItem(
        label: request.description ?? 'BarterQween Ödemesi',
        amount: request.amount.toStringAsFixed(2),
        status: pay.PaymentItemStatus.final_price,
      ),
    ];

    try {
      final response = await _googlePayClient!.showPaymentSelector(
        pay.PayProvider.google_pay,
        paymentItems,
      );

      final docRef = _firestore.collection('payments').doc();
      final userId = _auth.currentUser?.uid;

      final payload = _serializeGooglePayResponse(response);
      final transactionToken = _extractTransactionToken(payload);

      await docRef.set({
        'id': docRef.id,
        'userId': userId,
        'amount': request.amount,
        'paymentType': 'google_pay',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'rawPayload': payload,
        'transactionToken': transactionToken,
      });

      return PaymentResult(
        success: true,
        paymentId: docRef.id,
        transactionId: transactionToken,
        message: 'Ödeme tokenı başarıyla alındı.',
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
