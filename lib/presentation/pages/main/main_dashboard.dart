import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/world_class_design_system.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/notification/notification_bloc.dart';
import '../../blocs/notification/notification_event.dart';
import '../../blocs/notification/notification_state.dart';
import '../../widgets/navigation/world_class_bottom_nav.dart';
import '../home/enhanced_home_page_v2.dart';
import '../explore/world_class_explore_page.dart';
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
  late final NotificationBloc _notificationBloc;
  String? _watchingUserId;
  int _lastKnownUnreadCount = 0;

  final List<Widget> _pages = [
    const EnhancedHomePageV2(),
    const WorldClassExplorePage(),
    const WorldClassAddItemPage(),
    const WorldClassMessagesPage(),
    const WorldClassProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _notificationBloc = getIt<NotificationBloc>();
    _initializeAnimations();
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
      _lastKnownUnreadCount = 0;
    }
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: WorldClassDesignSystem.animationNormal,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _notificationBloc.close();
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
    final body = FadeTransition(
      opacity: _fadeAnimation,
      child: IndexedStack(index: _currentIndex, children: _pages),
    );

    return BlocProvider.value(
      value: _notificationBloc,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) => _handleAuthStateChange(state),
        child: Scaffold(
          backgroundColor: WorldClassDesignSystem.primaryBackground,
          body: body,
          bottomNavigationBar: BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, notificationState) {
              final authState = context.watch<AuthBloc>().state;
              final isAuthenticated = authState is AuthAuthenticated;

              if (notificationState is UnreadCountLoaded) {
                _lastKnownUnreadCount = notificationState.count;
              } else if (notificationState is UnreadCountStreaming) {
                _lastKnownUnreadCount = notificationState.count;
              }

              final badgeCount = isAuthenticated && _lastKnownUnreadCount > 0
                  ? _lastKnownUnreadCount
                  : null;

              return WorldClassBottomNav(
                currentIndex: _currentIndex,
                onTap: _onTabTapped,
                messagesBadgeCount: badgeCount,
              );
            },
          ),
        ),
      ),
    );
  }
}
