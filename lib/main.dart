import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';
import 'core/di/injection.dart';
import 'core/providers/global_bloc_providers.dart';
import 'core/routes/route_names.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'core/utils/preferences_keys.dart';
import 'core/services/fcm_service.dart';
import 'core/services/analytics_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';
import 'presentation/pages/dashboard_page.dart';
import 'presentation/pages/notifications/notifications_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/onboarding/onboarding_page.dart';
import 'presentation/pages/register_page.dart';
import 'presentation/pages/forgot_password_page.dart';
import 'presentation/pages/items/create_item_page.dart';
import 'presentation/pages/items/edit_item_page.dart';
import 'presentation/blocs/item/item_bloc.dart';
import 'presentation/blocs/item/item_event.dart';
import 'presentation/blocs/item/item_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await configureDependencies();

  // Initialize Firebase Cloud Messaging and local notifications
  try {
    final fcm = getIt<FCMService>();
    await fcm.initialize();

    // Save FCM token for logged-in user (if any)
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && fcm.fcmToken != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('fcmTokens')
          .doc(fcm.fcmToken)
          .set({
        'token': fcm.fcmToken,
'platform': Platform.operatingSystem,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  } catch (e) {
    // Fail silently if FCM init fails; app should still start
    debugPrint('FCM init error: $e');
  }

  runApp(const BarterQweenApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class BarterQweenApp extends StatelessWidget {
  const BarterQweenApp({super.key});
  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(AppTheme.darkStatusBar);
    
return GlobalBlocProviders(
      child: MaterialApp(
        navigatorKey: navigatorKey,
        navigatorObservers: [getIt<FirebaseAnalyticsObserver>()],
        title: 'Barter Qween',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: RouteNames.splash,
        onGenerateRoute: (s) {
        switch (s.name) {
          case RouteNames.splash: return MaterialPageRoute(builder: (_) => const SplashPage());
          case RouteNames.login: return MaterialPageRoute(builder: (_) => const LoginPage());
          case RouteNames.register: return MaterialPageRoute(builder: (_) => const RegisterPage());
          case RouteNames.forgotPassword: return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
          case RouteNames.onboarding: return MaterialPageRoute(builder: (_) => const OnboardingPage());
case RouteNames.dashboard: return MaterialPageRoute(builder: (_) => const DashboardPage());
          case RouteNames.notifications: return MaterialPageRoute(builder: (_) => const NotificationsPage());
          case RouteNames.createItem: 
            return MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (_) => getIt<ItemBloc>(),
                child: const CreateItemPage(),
              ),
            );
          case RouteNames.editItem:
            if (s.arguments is String) {
              final itemId = s.arguments as String;
              return MaterialPageRoute(
                builder: (context) {
                  final itemBloc = getIt<ItemBloc>();
                  itemBloc.add(LoadItem(itemId));
                  
                  return BlocProvider.value(
                    value: itemBloc,
                    child: BlocBuilder<ItemBloc, ItemState>(
                      builder: (context, state) {
                        if (state is ItemLoaded) {
                          return EditItemPage(item: state.item);
                        }
                        return Scaffold(
                          appBar: AppBar(title: const Text('Loading...')),
                          body: const Center(child: CircularProgressIndicator()),
                        );
                      },
                    ),
                  );
                },
              );
            }
            return MaterialPageRoute(builder: (_) => const LoginPage());
          default: return MaterialPageRoute(builder: (_) => const LoginPage());
        }
      },
      ),
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) return;
    
    // Check Firebase auth state
    final firebaseUser = FirebaseAuth.instance.currentUser;
    
    if (firebaseUser != null) {
      // User is logged in, go to dashboard
      Navigator.of(context).pushReplacementNamed(RouteNames.dashboard);
    } else {
      // User is not logged in, check onboarding
      final prefs = getIt<SharedPreferences>();
      final onboardingCompleted = prefs.getBool(PreferencesKeys.onboardingCompleted) ?? false;
      
      if (onboardingCompleted) {
        Navigator.of(context).pushReplacementNamed(RouteNames.login);
      } else {
        Navigator.of(context).pushReplacementNamed(RouteNames.onboarding);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Brand icon with subtle animation potential
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.swap_horiz_rounded,
                  size: 60,
                  color: AppColors.textOnPrimary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Barter Qween',
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Trade with Confidence',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
