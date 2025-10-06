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
import 'core/theme/world_class_design_system.dart';
import 'core/utils/preferences_keys.dart';
import 'core/services/fcm_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';
import 'presentation/pages/splash/splash_page.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/main/main_dashboard.dart';
import 'presentation/pages/onboarding/onboarding_page.dart';
import 'presentation/pages/auth/register_page.dart';
import 'presentation/pages/auth/forgot_password_page.dart';

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
          case RouteNames.dashboard: return MaterialPageRoute(builder: (_) => const MainDashboard());
          default: return MaterialPageRoute(builder: (_) => const LoginPage());
        }
      },
      ),
    );
  }
}

