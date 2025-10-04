import 'package:flutter/material.dart';

class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Logo ve başlık
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Admin Panel',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          // Navigasyon menüsü
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  isActive: true,
                  onTap: () {
                    // Navigate to dashboard
                  },
                ),
                _buildNavItem(
                  context,
                  icon: Icons.pending_actions,
                  title: 'Bekleyen İlanlar',
                  onTap: () {
                    // Navigate to pending items
                  },
                ),
                _buildNavItem(
                  context,
                  icon: Icons.people,
                  title: 'Kullanıcı Yönetimi',
                  onTap: () {
                    // Navigate to user management
                  },
                ),
                _buildNavItem(
                  context,
                  icon: Icons.report,
                  title: 'Raporlar',
                  onTap: () {
                    // Navigate to reports
                  },
                ),
                _buildNavItem(
                  context,
                  icon: Icons.analytics,
                  title: 'Analitik',
                  onTap: () {
                    // Navigate to analytics
                  },
                ),
              ],
            ),
          ),

          const Divider(),

          // Alt navigasyon
          Container(
            padding: const EdgeInsets.all(16),
            child: _buildNavItem(
              context,
              icon: Icons.settings,
              title: 'Ayarlar',
              onTap: () {
                // Navigate to settings
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      tileColor: isActive
          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
          : null,
    );
  }
}