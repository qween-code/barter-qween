import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/di/injection.dart';
import 'core/providers/global_bloc_providers.dart';
import 'core/routes/route_names.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'core/utils/preferences_keys.dart';
import 'firebase_options.dart';
import 'presentation/pages/dashboard_page.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/onboarding/onboarding_page.dart';
import 'presentation/pages/auth/register_page.dart';
import 'presentation/pages/auth/forgot_password_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await configureDependencies();
  runApp(const BarterQweenApp());
}

class BarterQweenApp extends StatelessWidget {
  const BarterQweenApp({super.key});
  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(AppTheme.darkStatusBar);
    
    return GlobalBlocProviders(
      child: MaterialApp(
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
