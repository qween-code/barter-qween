import 'dart:async';
import 'dart:convert';
import 'package:pay/pay.dart';
import '../../domain/entities/payment_entity.dart';

/// Payment Service - Google Pay & Apple Pay integration
class PaymentService {
  late final Pay _payClient;
  bool _isInitialized = false;

  /// Payment environment
  static const PaymentEnvironment _environment = PaymentEnvironment.test;

  /// Google Pay configuration
  static const String _googlePayMerchantId = 'MERCHANT_ID_HERE'; // TODO: Replace
  static const String _googlePayMerchantName = 'BarterQween';

  /// Apple Pay configuration
  static const String _applePayMerchantId = 'merchant.com.barterqween'; // TODO: Replace

  /// Supported payment networks
  static const List<String> _supportedNetworks = [
    'MASTERCARD',
    'VISA',
    'AMEX',
  ];

  /// Initialize payment service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _payClient = Pay({
        PayProvider.google_pay: _googlePayConfig,
        PayProvider.apple_pay: _applePayConfig,
      });
      _isInitialized = true;
    } catch (e) {
      throw PaymentException('Failed to initialize payment service: $e');
    }
  }

  /// Google Pay configuration JSON
  Map<String, dynamic> get _googlePayConfig => {
        'provider': 'google_pay',
        'data': {
          'environment': _environment == PaymentEnvironment.test ? 'TEST' : 'PRODUCTION',
          'apiVersion': 2,
          'apiVersionMinor': 0,
          'allowedPaymentMethods': [
            {
              'type': 'CARD',
              'tokenizationSpecification': {
                'type': 'PAYMENT_GATEWAY',
                'parameters': {
                  'gateway': 'example', // TODO: Replace with actual gateway
                  'gatewayMerchantId': _googlePayMerchantId,
                }
              },
              'parameters': {
                'allowedCardNetworks': _supportedNetworks,
                'allowedAuthMethods': ['PAN_ONLY', 'CRYPTOGRAM_3DS'],
                'billingAddressRequired': false,
              }
            }
          ],
          'merchantInfo': {
            'merchantId': _googlePayMerchantId,
            'merchantName': _googlePayMerchantName,
          },
          'transactionInfo': {
            'countryCode': 'TR',
            'currencyCode': 'TRY',
          }
        }
      };

  /// Apple Pay configuration JSON
  Map<String, dynamic> get _applePayConfig => {
        'provider': 'apple_pay',
        'data': {
          'merchantIdentifier': _applePayMerchantId,
          'displayName': _googlePayMerchantName,
          'merchantCapabilities': ['3DS', 'debit', 'credit'],
          'supportedNetworks': ['visa', 'mastercard', 'amex'],
          'countryCode': 'TR',
          'currencyCode': 'TRY',
        }
      };

  /// Check if Google Pay is available
  Future<bool> isGooglePayAvailable() async {
    if (!_isInitialized) await initialize();
    return await _payClient.userCanPay(PayProvider.google_pay);
  }

  /// Check if Apple Pay is available
  Future<bool> isApplePayAvailable() async {
    if (!_isInitialized) await initialize();
    return await _payClient.userCanPay(PayProvider.apple_pay);
  }

  /// Process payment with Google Pay
  Future<PaymentResult> processGooglePayPayment({
    required double amount,
    required String currency,
    required String description,
    required PaymentType paymentType,
  }) async {
    if (!_isInitialized) await initialize();

    if (!await isGooglePayAvailable()) {
      throw PaymentException('Google Pay is not available on this device');
    }

    try {
      final paymentItems = [
        PaymentItem(
          label: description,
          amount: amount.toStringAsFixed(2),
          status: PaymentItemStatus.final_price,
        ),
      ];

      final result = await _payClient.showPaymentSelector(
        PayProvider.google_pay,
        paymentItems,
      );

      // Parse payment result
      final paymentData = jsonDecode(result);
      final paymentToken = paymentData['paymentMethodData']['tokenizationData']['token'];

      return PaymentResult(
        success: true,
        transactionId: _generateTransactionId(),
        token: paymentToken,
        amount: amount,
        currency: currency,
        method: PaymentMethod.googlePay,
        type: paymentType,
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: e.toString(),
        amount: amount,
        currency: currency,
        method: PaymentMethod.googlePay,
        type: paymentType,
      );
    }
  }

  /// Process payment with Apple Pay
  Future<PaymentResult> processApplePayPayment({
    required double amount,
    required String currency,
    required String description,
    required PaymentType paymentType,
  }) async {
    if (!_isInitialized) await initialize();

    if (!await isApplePayAvailable()) {
      throw PaymentException('Apple Pay is not available on this device');
    }

    try {
      final paymentItems = [
        PaymentItem(
          label: description,
          amount: amount.toStringAsFixed(2),
          status: PaymentItemStatus.final_price,
        ),
      ];

      final result = await _payClient.showPaymentSelector(
        PayProvider.apple_pay,
        paymentItems,
      );

      // Parse payment result
      final paymentData = jsonDecode(result);
      final paymentToken = paymentData['token'];

      return PaymentResult(
        success: true,
        transactionId: _generateTransactionId(),
        token: paymentToken,
        amount: amount,
        currency: currency,
        method: PaymentMethod.applePay,
        type: paymentType,
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: e.toString(),
        amount: amount,
        currency: currency,
        method: PaymentMethod.applePay,
        type: paymentType,
      );
    }
  }

  /// Process listing fee payment
  Future<PaymentResult> payListingFee({
    required double amount,
    required String itemId,
    required bool isPremium,
    PaymentMethod method = PaymentMethod.googlePay,
  }) async {
    final description = isPremium ? 'Premium İlan Ücreti' : 'İlan Ücreti';

    if (method == PaymentMethod.googlePay) {
      return await processGooglePayPayment(
        amount: amount,
        currency: 'TRY',
        description: description,
        paymentType: isPremium ? PaymentType.premiumListing : PaymentType.listingFee,
      );
    } else if (method == PaymentMethod.applePay) {
      return await processApplePayPayment(
        amount: amount,
        currency: 'TRY',
        description: description,
        paymentType: isPremium ? PaymentType.premiumListing : PaymentType.listingFee,
      );
    }

    throw PaymentException('Unsupported payment method');
  }

  /// Process trade commission payment
  Future<PaymentResult> payTradeCommission({
    required double amount,
    required String tradeOfferId,
    PaymentMethod method = PaymentMethod.googlePay,
  }) async {
    final description = 'Trade Komisyonu';

    if (method == PaymentMethod.googlePay) {
      return await processGooglePayPayment(
        amount: amount,
        currency: 'TRY',
        description: description,
        paymentType: PaymentType.tradeCommission,
      );
    } else if (method == PaymentMethod.applePay) {
      return await processApplePayPayment(
        amount: amount,
        currency: 'TRY',
        description: description,
        paymentType: PaymentType.tradeCommission,
      );
    }

    throw PaymentException('Unsupported payment method');
  }

  /// Process cash differential payment for trades
  Future<PaymentResult> payCashDifferential({
    required double amount,
    required String tradeOfferId,
    required String fromUserId,
    required String toUserId,
    PaymentMethod method = PaymentMethod.googlePay,
  }) async {
    final description = 'Trade Para Farkı Ödemesi';

    if (method == PaymentMethod.googlePay) {
      return await processGooglePayPayment(
        amount: amount,
        currency: 'TRY',
        description: description,
        paymentType: PaymentType.cashDifferential,
      );
    } else if (method == PaymentMethod.applePay) {
      return await processApplePayPayment(
        amount: amount,
        currency: 'TRY',
        description: description,
        paymentType: PaymentType.cashDifferential,
      );
    }

    throw PaymentException('Unsupported payment method');
  }

  /// Generate transaction ID
  String _generateTransactionId() {
    return 'TXN_${DateTime.now().millisecondsSinceEpoch}_${_randomString(8)}';
  }

  /// Generate random string
  String _randomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt((random + _) % chars.length),
      ),
    );
  }

  /// Dispose
  void dispose() {
    _isInitialized = false;
  }
}

/// Payment Result Model
class PaymentResult {
  final bool success;
  final String? transactionId;
  final String? token;
  final double amount;
  final String currency;
  final PaymentMethod method;
  final PaymentType type;
  final String? errorMessage;

  PaymentResult({
    required this.success,
    this.transactionId,
    this.token,
    required this.amount,
    required this.currency,
    required this.method,
    required this.type,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() => {
        'success': success,
        'transactionId': transactionId,
        'token': token,
        'amount': amount,
        'currency': currency,
        'method': method.name,
        'type': type.name,
        'errorMessage': errorMessage,
      };
}

/// Payment Exception
class PaymentException implements Exception {
  final String message;
  PaymentException(this.message);

  @override
  String toString() => 'PaymentException: $message';
}
