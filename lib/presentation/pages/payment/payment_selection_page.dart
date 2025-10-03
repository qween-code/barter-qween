import 'dart:io';
import 'package:flutter/material.dart';
import '../../../domain/entities/payment_entity.dart';
import '../../../domain/entities/subscription_entity.dart';

/// World-Class Payment Selection Page
/// 
/// Features:
/// - Modern payment method cards
/// - Platform-specific payment options (iOS/Android)
/// - Animated selection
/// - Secure payment indicators
/// - Order summary
/// 
/// Inspired by:
/// - Uber payment selection
/// - Airbnb checkout
/// - Apple Store checkout
class PaymentSelectionPage extends StatefulWidget {
  final double amount;
  final String? description;
  final PaymentType paymentType;
  final SubscriptionFeatures? subscriptionPlan;
  final bool? isYearly;
  
  const PaymentSelectionPage({
    Key? key,
    required this.amount,
    this.description,
    required this.paymentType,
    this.subscriptionPlan,
    this.isYearly,
  }) : super(key: key);

  @override
  State<PaymentSelectionPage> createState() => _PaymentSelectionPageState();
}

class _PaymentSelectionPageState extends State<PaymentSelectionPage> {
  PaymentMethod? _selectedMethod;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Ödeme Yöntemi',
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3142)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Order Summary
                  _buildOrderSummary(),
                  
                  const SizedBox(height: 24),
                  
                  // Payment Methods
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ödeme Yöntemi Seçin',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3142),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Show platform-specific payment methods
                        if (Platform.isIOS) ...[
                          _buildPaymentMethodCard(
                            PaymentMethod.applePay,
                            'Apple Pay',
                            'Güvenli ve hızlı ödeme',
                            Icons.apple,
                            Colors.black,
                          ),
                          const SizedBox(height: 12),
                        ],
                        
                        if (Platform.isAndroid) ...[
                          _buildPaymentMethodCard(
                            PaymentMethod.googlePay,
                            'Google Pay',
                            'Güvenli ve hızlı ödeme',
                            Icons.payment,
                            const Color(0xFF4285F4),
                          ),
                          const SizedBox(height: 12),
                        ],
                        
                        // In-App Purchase (available on both platforms)
                        _buildPaymentMethodCard(
                          PaymentMethod.inAppPurchase,
                          'Uygulama İçi Satın Alma',
                          'App Store / Play Store ile',
                          Icons.store,
                          const Color(0xFFFF6B35),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Credit Card (Coming Soon)
                        _buildPaymentMethodCard(
                          PaymentMethod.creditCard,
                          'Kredi Kartı',
                          'Yakında...',
                          Icons.credit_card,
                          Colors.grey,
                          isDisabled: true,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Security Badge
                  _buildSecurityBadge(),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          
          // Pay Button
          _buildPayButton(),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getPaymentTypeIcon(),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.paymentType.displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.description ?? widget.paymentType.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (widget.subscriptionPlan != null) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            _buildSummaryRow(
              'Plan',
              widget.subscriptionPlan!.displayName,
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Fatura Dönemi',
              widget.isYearly == true ? 'Yıllık' : 'Aylık',
            ),
            if (widget.isYearly == true) ...[
              const SizedBox(height: 12),
              _buildSummaryRow(
                'Tasarruf',
                '₺${widget.subscriptionPlan!.yearlySavings.toStringAsFixed(2)}',
                isHighlight: true,
              ),
            ],
          ],
          
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Toplam',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
              Text(
                '₺${widget.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B35),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isHighlight ? const Color(0xFFFF6B35) : const Color(0xFF2D3142),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(
    PaymentMethod method,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor, {
    bool isDisabled = false,
  }) {
    final isSelected = _selectedMethod == method;
    
    return GestureDetector(
      onTap: isDisabled
          ? null
          : () {
              setState(() {
                _selectedMethod = method;
              });
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF6B35)
                : isDisabled
                    ? Colors.grey[300]!
                    : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF6B35).withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDisabled
                    ? Colors.grey[200]
                    : iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDisabled ? Colors.grey[400] : iconColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDisabled
                          ? Colors.grey[400]
                          : const Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDisabled ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFFF6B35),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityBadge() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4285F4).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4285F4).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline,
              color: Color(0xFF4285F4),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Güvenli Ödeme',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tüm ödemeleriniz 256-bit SSL ile şifrelenir',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _selectedMethod == null || _isProcessing
              ? null
              : _handlePayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B35),
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            disabledBackgroundColor: Colors.grey[300],
          ),
          child: _isProcessing
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.payment,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Ödeme Yap (₺${widget.amount.toStringAsFixed(2)})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  IconData _getPaymentTypeIcon() {
    switch (widget.paymentType) {
      case PaymentType.listingFee:
        return Icons.post_add;
      case PaymentType.premiumListing:
        return Icons.star;
      case PaymentType.subscription:
        return Icons.workspace_premium;
      case PaymentType.tradeCommission:
        return Icons.percent;
      case PaymentType.cashDifferential:
        return Icons.payments;
      case PaymentType.adRemoval:
        return Icons.block;
    }
  }

  Future<void> _handlePayment() async {
    if (_selectedMethod == null) return;
    
    setState(() => _isProcessing = true);
    
    try {
      // TODO: Implement actual payment processing
      // await paymentService.processPayment(...)
      
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        // Navigate to success page
        Navigator.pushReplacementNamed(
          context,
          '/payment-success',
          arguments: {
            'amount': widget.amount,
            'method': _selectedMethod,
            'type': widget.paymentType,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ödeme işlemi başarısız: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isProcessing = false);
      }
    }
  }
}
