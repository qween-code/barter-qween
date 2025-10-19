import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../home/modern_home_page.dart';
import '../explore/world_class_explore_page.dart';
import '../items/create_item_page.dart';
import '../favorites/favorites_page.dart';
import '../profile/world_class_profile_page.dart';
import '../notifications/notifications_page.dart';
import '../search/search_page.dart';
import '../messages/world_class_messages_page.dart';
import '../trades/trades_page.dart';
import '../admin/admin_dashboard_page.dart';
import '../../widgets/navigation/modern_bottom_nav.dart';

/// Modern Main Dashboard with Trendy Navigation
/// Uses PageView for smooth transitions between pages
class ModernMainDashboard extends StatefulWidget {
  const ModernMainDashboard({Key? key}) : super(key: key);

  @override
  State<ModernMainDashboard> createState() => _ModernMainDashboardState();
}

class _ModernMainDashboardState extends State<ModernMainDashboard> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == 2) {
      // Add item - FAB action
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CreateItemPage()),
      );
    } else {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          // Handle logout - navigate to login
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: [
            // Home Page
            const ModernHomePage(),

            // Explore Page
            BlocProvider(
              create: (_) => getIt<ItemBloc>()..add(const LoadAllItems()),
              child: const WorldClassExplorePage(),
            ),

            // This page won't be shown (FAB action)
            Container(),

            // Favorites Page
            const FavoritesPage(),

            // Profile Page
            BlocProvider(
              create: (_) => getIt<ProfileBloc>()..add(const LoadProfile()),
              child: const WorldClassProfilePage(),
            ),
          ],
        ),
        bottomNavigationBar: ModernBottomNav(
          currentIndex: _currentIndex,
          onTap: _onNavTap,
        ),
      ),
    );
  }
}
