import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_functions/firebase_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Admin Notification Dashboard
/// View statistics, manage DLQ, send broadcasts
class NotificationDashboardPage extends StatefulWidget {
  const NotificationDashboardPage({Key? key}) : super(key: key);

  @override
  State<NotificationDashboardPage> createState() =>
      _NotificationDashboardPageState();
}

class _NotificationDashboardPageState extends State<NotificationDashboardPage> {
  late FirebaseFunctions _functions;
  late FirebaseAuth _auth;

  // Dashboard state
  Map<String, dynamic>? statistics;
  List<dynamic> dlqItems = [];
  bool isLoading = false;
  String? error;

  // Broadcast form
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _functions = FirebaseFunctions.instance;
    _auth = FirebaseAuth.instance;
    _checkAdminAndLoadData();
  }

  Future<void> _checkAdminAndLoadData() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        setState(() => error = 'Not authenticated');
        return;
      }

      final adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(userId)
          .get();

      if (!adminDoc.exists) {
        setState(() => error = 'Not an admin');
        return;
      }

      await _loadStatistics();
      await _loadDLQItems();
    } catch (e) {
      setState(() => error = 'Error: $e');
    }
  }

  Future<void> _loadStatistics() async {
    try {
      setState(() => isLoading = true);

      final result = await _functions
          .httpsCallable('getNotificationStatistics')
          .call({'daysBack': 7});

      setState(() {
        statistics = result.data['stats'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error loading statistics: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _loadDLQItems() async {
    try {
      final result = await _functions
          .httpsCallable('getDeadLetterQueueItems')
          .call({'status': 'pending'});

      setState(() {
        dlqItems = result.data['items'] ?? [];
      });
    } catch (e) {
      debugPrint('Error loading DLQ: $e');
    }
  }

  Future<void> _sendBroadcast() async {
    if (titleController.text.isEmpty || bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Başlık ve içerik gerekli')),
      );
      return;
    }

    try {
      setState(() => isLoading = true);

      await _functions.httpsCallable('broadcastNotification').call({
        'title': titleController.text,
        'body': bodyController.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Broadcast gönderildi')),
        );

        titleController.clear();
        bodyController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _resolveDLQItem(String dlqId) async {
    try {
      await _functions.httpsCallable('resolveDLQItem').call({
        'dlqId': dlqId,
        'notes': 'Admin resolved manually',
      });

      await _loadDLQItems();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ DLQ item resolved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (error != null && error != 'Not an admin') {
      return Scaffold(
        appBar: AppBar(title: const Text('Bildirim Kontrol Paneli')),
        body: Center(child: Text('❌ $error')),
      );
    }

    if (error == 'Not an admin') {
      return Scaffold(
        appBar: AppBar(title: const Text('Bildirim Kontrol Paneli')),
        body: const Center(
          child: Text('Admin erişimi gerekli'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirim Kontrol Paneli'),
        elevation: 0,
      ),
      body: isLoading && statistics == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics Cards
                  _buildStatisticsSection(),
                  const SizedBox(height: 32),

                  // Broadcast Section
                  _buildBroadcastSection(),
                  const SizedBox(height: 32),

                  // DLQ Section
                  _buildDLQSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatisticsSection() {
    if (statistics == null) {
      return const SizedBox.shrink();
    }

    final stats = statistics!;
    final dlq = stats['dlq'] as Map<String, dynamic>?;
    final notificationStats = statistics!['totalNotifications'] as int? ?? 0;
    final openRate = statistics!['averageOpenRate'] as int? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'İstatistikler (Son 7 Gün)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Gönderilen',
                value: notificationStats.toString(),
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                title: 'Açılma Oranı',
                value: '$openRate%',
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'DLQ Bekleme',
                value: dlq?['pending'].toString() ?? '0',
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                title: 'Başarısız',
                value: dlq?['failed'].toString() ?? '0',
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBroadcastSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Broadcast Bildirimi Gönder',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: 'Başlık',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: bodyController,
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: 'İçerik',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : _sendBroadcast,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Gönder',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDLQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Dead Letter Queue',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: _loadDLQItems,
              child: const Text('Yenile'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (dlqItems.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Bekleyen DLQ öğesi yok'),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dlqItems.length,
            itemBuilder: (context, index) {
              final item = dlqItems[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text('User: ${item['userId']}'),
                  subtitle: Text(
                    'Hata: ${item['failureReason']}\nRetry: ${item['retryCount']}/3',
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _resolveDLQItem(item['id']),
                    child: const Text('Çöz'),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
