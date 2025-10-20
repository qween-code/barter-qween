import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/world_class_design_system.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/item/item_bloc.dart';
import '../../blocs/item/item_event.dart';
import '../../blocs/notification/notification_bloc.dart';
import '../../blocs/notification/notification_event.dart';
import '../../blocs/notification/notification_state.dart';
import '../../widgets/navigation/modern_nav_bar_pro.dart';
import '../home/enhanced_home_page_v2.dart';
import '../explore/world_class_explore_page.dart';
import '../add_item/world_class_add_item_page.dart';
import '../messages/world_class_messages_page.dart';
import '../profile/world_class_profile_page.dart';

/// 🌟 MODERN MAIN DASHBOARD with Trendy Navigation
/// Features:
/// - Modern bottom navigation with smooth transitions
/// - PageView for smooth page switching
/// - Real-time notifications
/// - Firebase integration
/// - Beautiful design system
class ModernMainDashboard extends StatefulWidget {
  const ModernMainDashboard({Key? key}) : super(key: key);

  @override
  State<ModernMainDashboard> createState() => _ModernMainDashboardState();
}

class _ModernMainDashboardState extends State<ModernMainDashboard> {
  late PageController _pageController;
  int _currentIndex = 0;
  late final NotificationBloc _notificationBloc;
  String? _watchingUserId;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _notificationBloc = getIt<NotificationBloc>();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authState = context.read<AuthBloc>().state;
      _handleAuthStateChange(authState);
    });
  }

  void _handleAuthStateChange(AuthState state) {
    if (state is AuthAuthenticated) {
      if (_watchingUserId != state.user.uid) {
        _notificationBloc.add(LoadUnreadCount(state.user.uid));
        _notificationBloc.add(WatchUnreadCount(state.user.uid));
        _watchingUserId = state.user.uid;
      }
    } else {
      _watchingUserId = null;
    }
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
        MaterialPageRoute(builder: (_) => const WorldClassAddItemPage()),
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
        _handleAuthStateChange(state);
        if (state is AuthUnauthenticated) {
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
            const EnhancedHomePageV2(),

            // Explore Page
            BlocProvider(
              create: (_) => getIt<ItemBloc>()..add(const LoadAllItems()),
              child: const WorldClassExplorePage(),
            ),

            // This page won't be shown (FAB action)
            const SizedBox.shrink(),

            // Messages Page
            const WorldClassMessagesPage(),

            // Profile Page
            const WorldClassProfilePage(),
          ],
        ),
        bottomNavigationBar: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, notificationState) {
            int? unreadCount;
            if (notificationState is UnreadCountLoaded) {
              unreadCount = notificationState.count > 0 ? notificationState.count : null;
            } else if (notificationState is UnreadCountStreaming) {
              unreadCount = notificationState.count > 0 ? notificationState.count : null;
            }
            
            return ModernNavBarPro(
              currentIndex: _currentIndex,
              onTap: _onNavTap,
              unreadCount: unreadCount,
            );
          },
        ),
      ),
    );
  }
}
