import 'package:flutter/material.dart';

/// Modern Trendy Bottom Navigation
/// Features: Smooth animations, modern design, best practices
/// Inspired by: Airbnb, Trendyol, Spotify
class ModernBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const ModernBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                label: 'Anasayfa',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.explore_outlined,
                label: 'Keşfet',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.add_circle_outline,
                label: 'Ekle',
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
                isFab: true,
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.favorite_outline,
                label: 'Favoriler',
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
              ),
              _buildNavItem(
                index: 4,
                icon: Icons.person_outline,
                label: 'Profil',
                isActive: currentIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    bool isFab = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: isFab
          ? _buildFabNavItem(icon, label)
          : _buildRegularNavItem(icon, label, isActive),
    );
  }

  Widget _buildRegularNavItem(
    IconData icon,
    String label,
    bool isActive,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        horizontal: isActive ? 20 : 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? Colors.blue : Colors.grey.shade600,
            size: 24,
          ),
          const SizedBox(height: 4),
          AnimatedOpacity(
            opacity: isActive ? 1.0 : 0.7,
            duration: const Duration(milliseconds: 300),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? Colors.blue : Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFabNavItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade600,
          ),
        ),
      ],
    );
  }
}
