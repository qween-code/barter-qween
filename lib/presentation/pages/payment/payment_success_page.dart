import 'package:flutter/material.dart';
import '../../../domain/entities/payment_entity.dart';

/// Ödeme başarı sayfası - Modern tasarım
class PaymentSuccessPage extends StatefulWidget {
  final double amount;
  final PaymentMethod? method;
  final PaymentType type;
  final String? paymentId;
  final String? tradeId;

  const PaymentSuccessPage({
    Key? key,
    required this.amount,
    this.method,
    required this.type,
    this.paymentId,
    this.tradeId,
  }) : super(key: key);

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();

    // 3 saniye sonra otomatik olarak trade sayfasına dön
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/trades',
          (route) => route.isFirst,
          arguments: {'highlightTradeId': widget.tradeId},
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F0),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Başarı animasyonu
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) => Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4CAF50).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: Color(0xFF4CAF50),
                            size: 80,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Başlık
                    const Text(
                      'Ödeme Başarılı!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Mesaj
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        '₺${widget.amount.toStringAsFixed(2)} tutarındaki ${widget.type.displayName.toLowerCase()} ödemeniz başarıyla gerçekleştirildi.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Ödeme detayları
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow('Tutar', '₺${widget.amount.toStringAsFixed(2)}'),
                          const SizedBox(height: 12),
                          _buildDetailRow('Ödeme Yöntemi', widget.method?.displayName ?? 'Bilinmiyor'),
                          const SizedBox(height: 12),
                          _buildDetailRow('Ödeme Türü', widget.type.displayName),
                          if (widget.paymentId != null) ...[
                            const SizedBox(height: 12),
                            _buildDetailRow('İşlem No', widget.paymentId!),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Güvenlik mesajı
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lock,
                            color: Color(0xFF4CAF50),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Ödemeniz 256-bit SSL şifreleme ile güvende',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Geri dön butonu
            Container(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/trades',
                      (route) => route.isFirst,
                      arguments: {'highlightTradeId': widget.tradeId},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Takas Sayfasına Dön',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3142),
          ),
        ),
      ],
    );
  }
}