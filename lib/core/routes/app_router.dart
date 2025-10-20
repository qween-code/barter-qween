// 🗺️ APP ROUTER
// Centralized routing with type-safe navigation

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection.dart';
import '../../presentation/blocs/item/item_bloc.dart';
import '../../presentation/pages/splash/splash_page.dart';
import '../../presentation/pages/onboarding/onboarding_page.dart';
import '../../presentation/pages/main/modern_main_dashboard.dart';
import '../../presentation/pages/items/enhanced_item_detail_page_v2.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/auth/forgot_password_page.dart';
import '../../presentation/pages/add_item/world_class_add_item_page.dart';
import '../../presentation/pages/explore/world_class_explore_page.dart';
import '../../presentation/pages/messages/world_class_messages_page.dart';
import '../../presentation/pages/profile/world_class_profile_page.dart';
import '../../presentation/pages/profile/user_profile_page.dart';
import '../../presentation/pages/favorites/favorites_page.dart';
import '../../presentation/pages/barter/barter_matches_page.dart';
import '../../presentation/pages/notifications/notifications_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String explore = '/explore';
  static const String addItem = '/add-item';
  static const String itemDetail = '/item-detail';
  static const String messages = '/messages';
  static const String profile = '/profile';
  static const String userProfile = '/user-profile';
  static const String favorites = '/favorites';
  static const String barterMatches = '/barter-matches';
  static const String notifications = '/notifications';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());

      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());

      case home:
      case dashboard:
        return MaterialPageRoute(builder: (_) => const ModernMainDashboard());

      case explore:
        final initialCategory = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) =>
              WorldClassExplorePage(initialCategory: initialCategory),
        );

      case addItem:
        return MaterialPageRoute(builder: (_) => const WorldClassAddItemPage());

      case itemDetail:
        final itemId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => BlocProvider<ItemBloc>(
            create: (_) => getIt<ItemBloc>(),
            child: EnhancedItemDetailPageV2(itemId: itemId ?? ''),
          ),
        );

      case messages:
        return MaterialPageRoute(
          builder: (_) => const WorldClassMessagesPage(),
        );

      case profile:
        return MaterialPageRoute(builder: (_) => const WorldClassProfilePage());

      case userProfile:
        final userId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => UserProfilePage(userId: userId ?? ''),
        );

      case favorites:
        return MaterialPageRoute(builder: (_) => const FavoritesPage());

      case barterMatches:
        return MaterialPageRoute(builder: (_) => const BarterMatchesPage());

      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsPage());

      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }

  // Helper methods for type-safe navigation
  static void toHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(dashboard);
  }

  static void toLogin(BuildContext context) {
    Navigator.of(context).pushNamed(login);
  }

  static void toRegister(BuildContext context) {
    Navigator.of(context).pushNamed(register);
  }

  static void toItemDetail(BuildContext context, String itemId) {
    Navigator.of(context).pushNamed(itemDetail, arguments: itemId);
  }

  static void toAddItem(BuildContext context) {
    Navigator.of(context).pushNamed(addItem);
  }

  static void toExplore(BuildContext context, {String? category}) {
    Navigator.of(context).pushNamed(explore, arguments: category);
  }

  static void toMessages(BuildContext context) {
    Navigator.of(context).pushNamed(messages);
  }

  static void toNotifications(BuildContext context) {
    Navigator.of(context).pushNamed(notifications);
  }

  static void toProfile(BuildContext context) {
    Navigator.of(context).pushNamed(profile);
  }

  static void toUserProfile(BuildContext context, String userId) {
    Navigator.of(context).pushNamed(userProfile, arguments: userId);
  }

  static void toFavorites(BuildContext context) {
    Navigator.of(context).pushNamed(favorites);
  }

  static void toBarterMatches(BuildContext context) {
    Navigator.of(context).pushNamed(barterMatches);
  }
}
