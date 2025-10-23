import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Ödeme geçmişi sayfası - Kullanıcıların tüm ödemelerini gösterir
class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({Key? key}) : super(key: key);

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _selectedFilter = 'all';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Ödeme Geçmişi',
          style: TextStyle(
            color: Color(0xFF2D3142),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3142)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF2D3142)),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Özet kartı
          _buildSummaryCard(),

          const SizedBox(height: 16),

          // Ödeme listesi
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getPaymentsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Hata: ${snapshot.error}',
                      style: TextStyle(color: Colors.red[600]),
                    ),
                  );
                }

                final payments = snapshot.data?.docs ?? [];

                if (payments.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    final payment = payments[index];
                    return _buildPaymentCard(payment);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final userId = _auth.currentUser?.uid;

    return Container(
      margin: const EdgeInsets.all(16),
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
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('payments')
            .where('userId', isEqualTo: userId)
            .where('status', isEqualTo: 'completed')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          double totalAmount = 0;
          int totalPayments = 0;

          for (final doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            totalAmount += (data['amount'] as num?)?.toDouble() ?? 0;
            totalPayments++;
          }

          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Toplam Ödeme',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      '₺${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey[300],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'İşlem Sayısı',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      totalPayments.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPaymentCard(DocumentSnapshot payment) {
    final data = payment.data() as Map<String, dynamic>;
    final paymentId = payment.id;
    final amount = (data['amount'] as num?)?.toDouble() ?? 0;
    final status = data['status'] as String? ?? 'pending';
    final paymentType = data['paymentType'] as String? ?? 'unknown';
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    final isBarterPayment = data['barterData']?['isBarterPayment'] as bool? ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getPaymentTypeDisplayName(paymentType),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      createdAt != null
                          ? '${createdAt.day}/${createdAt.month}/${createdAt.year}'
                          : 'Tarih bilinmiyor',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₺${amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusDisplayName(status),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(status),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (isBarterPayment) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.swap_horiz,
                    color: Color(0xFF4CAF50),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Takas işlemi ödemesi',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4CAF50),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'İşlem No: $paymentId',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                  fontFamily: 'monospace',
                ),
              ),
              IconButton(
                onPressed: () => _showPaymentDetails(payment),
                icon: const Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Color(0xFFFF6B35),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.payment,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz ödeme bulunmuyor',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ödeme yaptığınızda burada görünecek',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrele'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Tümü'),
              leading: Radio<String>(
                value: 'all',
                groupValue: _selectedFilter,
                onChanged: (value) => setState(() => _selectedFilter = value!),
              ),
              onTap: () => setState(() => _selectedFilter = 'all'),
            ),
            ListTile(
              title: const Text('Başarılı'),
              leading: Radio<String>(
                value: 'completed',
                groupValue: _selectedFilter,
                onChanged: (value) => setState(() => _selectedFilter = value!),
              ),
              onTap: () => setState(() => _selectedFilter = 'completed'),
            ),
            ListTile(
              title: const Text('Başarısız'),
              leading: Radio<String>(
                value: 'failed',
                groupValue: _selectedFilter,
                onChanged: (value) => setState(() => _selectedFilter = value!),
              ),
              onTap: () => setState(() => _selectedFilter = 'failed'),
            ),
            ListTile(
              title: const Text('Bekleyen'),
              leading: Radio<String>(
                value: 'pending',
                groupValue: _selectedFilter,
                onChanged: (value) => setState(() => _selectedFilter = value!),
              ),
              onTap: () => setState(() => _selectedFilter = 'pending'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showPaymentDetails(DocumentSnapshot payment) {
    final data = payment.data() as Map<String, dynamic>;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ödeme Detayları'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('İşlem No', payment.id),
              _buildDetailRow('Tutar', '₺${(data['amount'] as num?)?.toStringAsFixed(2) ?? '0'}'),
              _buildDetailRow('Durum', _getStatusDisplayName(data['status'] ?? 'pending')),
              _buildDetailRow('Ödeme Türü', _getPaymentTypeDisplayName(data['paymentType'] ?? 'unknown')),
              _buildDetailRow('Ödeme Yöntemi', data['paymentMethod'] ?? 'Bilinmiyor'),
              if (data['createdAt'] != null)
                _buildDetailRow('Tarih', (data['createdAt'] as Timestamp).toDate().toString()),
              if (data['errorMessage'] != null)
                _buildDetailRow('Hata Mesajı', data['errorMessage']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF2D3142),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getPaymentsStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return const Stream.empty();

    Query query = _firestore
        .collection('payments')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true);

    if (_selectedFilter != 'all') {
      query = query.where('status', isEqualTo: _selectedFilter);
    }

    return query.snapshots();
  }

  String _getPaymentTypeDisplayName(String type) {
    switch (type) {
      case 'cashDifferential':
        return 'Para Farkı Ödemesi';
      case 'listingFee':
        return 'İlan Ücreti';
      case 'premiumListing':
        return 'Premium İlan';
      case 'subscription':
        return 'Abonelik';
      case 'tradeCommission':
        return 'Komisyon';
      case 'adRemoval':
        return 'Reklamsız';
      default:
        return 'Diğer';
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'completed':
        return 'Başarılı';
      case 'failed':
        return 'Başarısız';
      case 'pending':
        return 'Bekliyor';
      case 'refunded':
        return 'İade Edildi';
      case 'cancelled':
        return 'İptal';
      default:
        return 'Bilinmiyor';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF4CAF50);
      case 'failed':
        return const Color(0xFFF44336);
      case 'pending':
        return const Color(0xFFFF9800);
      case 'refunded':
        return const Color(0xFF9C27B0);
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}