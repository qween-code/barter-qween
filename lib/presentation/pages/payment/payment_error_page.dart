import 'package:flutter/material.dart';
import '../../../domain/entities/payment_entity.dart';

/// Ödeme hata sayfası - Kullanıcı dostu hata yönetimi
class PaymentErrorPage extends StatefulWidget {
  final String error;
  final String? errorCode;
  final double? amount;
  final PaymentType? type;
  final VoidCallback? onRetry;

  const PaymentErrorPage({
    Key? key,
    required this.error,
    this.errorCode,
    this.amount,
    this.type,
    this.onRetry,
  }) : super(key: key);

  @override
  State<PaymentErrorPage> createState() => _PaymentErrorPageState();
}

class _PaymentErrorPageState extends State<PaymentErrorPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.bounceOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hata animasyonu
                    AnimatedBuilder(
                      animation: _bounceAnimation,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(0, -20 * (1 - _bounceAnimation.value)),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF44336).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.error_outline,
                            color: Color(0xFFF44336),
                            size: 60,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Başlık
                    const Text(
                      'Ödeme Başarısız',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Hata mesajı
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        _getErrorMessage(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Hata detayları
                    if (widget.amount != null || widget.type != null)
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
                            if (widget.amount != null)
                              _buildDetailRow('Tutar', '₺${widget.amount!.toStringAsFixed(2)}'),
                            if (widget.type != null) ...[
                              const SizedBox(height: 12),
                              _buildDetailRow('Ödeme Türü', widget.type!.displayName),
                            ],
                          ],
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Hata kodunu göster (geliştirici için)
                    if (widget.errorCode != null)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFF44336).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Color(0xFFF44336),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Hata Kodu: ${widget.errorCode}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFF44336),
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Destek mesajı
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFF9800).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.support_agent,
                            color: Color(0xFFFF9800),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Sorun devam ederse destek ekibimizle iletişime geçin',
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

            // Aksiyon butonları
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Tekrar dene butonu
                  if (widget.onRetry != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: widget.onRetry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Tekrar Dene',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Geri dön butonu
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFF6B35)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Geri Dön',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B35),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getErrorMessage() {
    // Hata mesajını kullanıcı dostu hale getir
    if (widget.error.toLowerCase().contains('network')) {
      return 'İnternet bağlantınızı kontrol edin ve tekrar deneyin.';
    } else if (widget.error.toLowerCase().contains('card')) {
      return 'Kart bilgilerinizde bir sorun var. Lütfen tekrar deneyin.';
    } else if (widget.error.toLowerCase().contains('insufficient')) {
      return 'Yetersiz bakiye. Lütfen farklı bir ödeme yöntemi deneyin.';
    } else if (widget.error.toLowerCase().contains('declined')) {
      return 'Ödeme reddedildi. Bankanızla iletişime geçin.';
    } else if (widget.error.toLowerCase().contains('timeout')) {
      return 'İşlem zaman aşımına uğradı. Lütfen tekrar deneyin.';
    } else {
      return 'Beklenmedik bir hata oluştu. Lütfen tekrar deneyin.';
    }
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