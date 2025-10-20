import 'package:flutter/material.dart';

/// 🎯 ULTRA MODERN NAVIGATION BAR - ELITE & ELEGANT
/// Inspired by: Spotify, Airbnb, Stripe, Figma
/// Smooth animations, modern icons, beautiful design
class ModernNavBarPro extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int? unreadCount;

  const ModernNavBarPro({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.unreadCount,
  }) : super(key: key);

  @override
  State<ModernNavBarPro> createState() => _ModernNavBarProState();
}

class _ModernNavBarProState extends State<ModernNavBarPro>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      5,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );
    _controllers[widget.currentIndex].forward();
  }

  @override
  void didUpdateWidget(ModernNavBarPro oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _controllers[oldWidget.currentIndex].reverse();
      _controllers[widget.currentIndex].forward();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Anasayfa',
                controller: _controllers[0],
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.explore_outlined,
                activeIcon: Icons.explore,
                label: 'Keşfet',
                controller: _controllers[1],
              ),
              _buildFabNavItem(),
              _buildNavItem(
                index: 3,
                icon: Icons.mail_outline_rounded,
                activeIcon: Icons.mail_rounded,
                label: 'Mesajlar',
                controller: _controllers[3],
                badgeCount: widget.unreadCount,
              ),
              _buildNavItem(
                index: 4,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profil',
                controller: _controllers[4],
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
    required IconData activeIcon,
    required String label,
    required AnimationController controller,
    int? badgeCount,
  }) {
    final isActive = widget.currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTap(index),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => widget.onTap(index),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: ScaleTransition(
                scale: Tween<double>(begin: 1.0, end: 1.12).animate(
                  CurvedAnimation(parent: controller, curve: Curves.elasticOut),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.blue.withOpacity(0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isActive ? activeIcon : icon,
                            color: isActive
                                ? Colors.blue.shade600
                                : Colors.grey.shade600,
                            size: 24,
                          ),
                        ),
                        if (badgeCount != null && badgeCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade500,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.3),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Text(
                                badgeCount > 99 ? '99+' : '$badgeCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    AnimatedOpacity(
                      opacity: isActive ? 1.0 : 0.65,
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                          color: isActive
                              ? Colors.blue.shade600
                              : Colors.grey.shade600,
                          letterSpacing: isActive ? 0.3 : 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFabNavItem() {
    return GestureDetector(
      onTap: () => widget.onTap(2),
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 1.15).animate(
          CurvedAnimation(parent: _controllers[2], curve: Curves.elasticOut),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => widget.onTap(2),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade600, Colors.blue.shade500],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade300.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ekle',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.blue.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
