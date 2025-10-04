import 'package:flutter/material.dart';
import '../../../domain/repositories/admin_repository.dart';

class DashboardContent extends StatelessWidget {
  final AdminDashboardStats stats;

  const DashboardContent({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Text(
            'Dashboard Özeti',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Admin paneli genel durumu',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),

          const SizedBox(height: 32),

          // İstatistik kartları
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(
                  context,
                  title: 'Bekleyen İlanlar',
                  value: stats.pendingItemsCount.toString(),
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                ),
                _buildStatCard(
                  context,
                  title: 'Bugün Onaylanan',
                  value: stats.approvedTodayCount.toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                _buildStatCard(
                  context,
                  title: 'Bugün Reddedilen',
                  value: stats.rejectedTodayCount.toString(),
                  icon: Icons.cancel,
                  color: Colors.red,
                ),
                _buildStatCard(
                  context,
                  title: 'Ortalama İnceleme Süresi',
                  value: '${stats.averageReviewTime.toStringAsFixed(1)} saat',
                  icon: Icons.timer,
                  color: Colors.blue,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Kullanıcı raporları özeti
          if (stats.userReportsCount > 0)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.report_problem,
                      color: Colors.amber,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${stats.userReportsCount} adet kullanıcı raporu bekliyor',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to user reports
                      },
                      child: const Text('Raporları İncele'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}