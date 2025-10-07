// 🗺️ APP ROUTER
// Centralized routing with type-safe navigation

import 'package:flutter/material.dart';
import '../../presentation/pages/splash/splash_screen.dart';
import '../../presentation/pages/onboarding/enhanced_onboarding_flow.dart';
import '../../presentation/pages/home/enhanced_home_page_v2.dart';
import '../../presentation/pages/items/enhanced_item_detail_page_v2.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/add_item/world_class_add_item_page.dart';
import '../../presentation/pages/explore/world_class_explore_page.dart';
import '../../presentation/pages/messages/world_class_messages_page.dart';
import '../../presentation/pages/profile/world_class_profile_page.dart';
import '../../presentation/pages/favorites/favorites_page.dart';
import '../../presentation/pages/barter/barter_matches_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String explore = '/explore';
  static const String addItem = '/add-item';
  static const String itemDetail = '/item-detail';
  static const String messages = '/messages';
  static const String profile = '/profile';
  static const String favorites = '/favorites';
  static const String barterMatches = '/barter-matches';
  static const String notifications = '/notifications';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case onboarding:
        return MaterialPageRoute(builder: (_) => const EnhancedOnboardingFlow());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());

      case home:
        return MaterialPageRoute(builder: (_) => const EnhancedHomePageV2());

      case explore:
        return MaterialPageRoute(builder: (_) => const WorldClassExplorePage());

      case addItem:
        return MaterialPageRoute(builder: (_) => const WorldClassAddItemPage());

      case itemDetail:
        final itemId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => EnhancedItemDetailPageV2(itemId: itemId ?? ''),
        );

      case messages:
        return MaterialPageRoute(builder: (_) => const WorldClassMessagesPage());

      case profile:
        return MaterialPageRoute(builder: (_) => const WorldClassProfilePage());

      case favorites:
        return MaterialPageRoute(builder: (_) => const FavoritesPage());

      case barterMatches:
        return MaterialPageRoute(builder: (_) => const BarterMatchesPage());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
        );
    }
  }

  // Helper methods for type-safe navigation
  static void toHome(BuildContext context) {
    Navigator.of(context).pushReplacementNamed(home);
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

  static void toExplore(BuildContext context) {
    Navigator.of(context).pushNamed(explore);
  }

  static void toMessages(BuildContext context) {
    Navigator.of(context).pushNamed(messages);
  }

  static void toProfile(BuildContext context) {
    Navigator.of(context).pushNamed(profile);
  }

  static void toFavorites(BuildContext context) {
    Navigator.of(context).pushNamed(favorites);
  }

  static void toBarterMatches(BuildContext context) {
    Navigator.of(context).pushNamed(barterMatches);
  }
}
