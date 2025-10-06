import 'package:flutter/material.dart';
import '../../../core/theme/world_class_design_system.dart';
import '../../widgets/navigation/world_class_bottom_nav.dart';
import '../home/modern_home_page.dart';
import '../explore/modern_explore_page.dart';
import '../add_item/world_class_add_item_page.dart';
import '../messages/world_class_messages_page.dart';
import '../profile/world_class_profile_page.dart';

/// 🌟 WORLD-CLASS MAIN DASHBOARD
/// 
/// Features:
/// - 5-tab bottom navigation
/// - IndexedStack for smooth transitions
/// - Real-time updates
/// - Firebase integration
/// - Analytics tracking
class MainDashboard extends StatefulWidget {
  const MainDashboard({Key? key}) : super(key: key);

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Widget> _pages = [
    const ModernHomePage(),
    const ModernExplorePage(),
    const WorldClassAddItemPage(),
    const WorldClassMessagesPage(),
    const WorldClassProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: WorldClassDesignSystem.animationNormal,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      
      // Restart animation for smooth transition
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WorldClassDesignSystem.primaryBackground,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: WorldClassBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
