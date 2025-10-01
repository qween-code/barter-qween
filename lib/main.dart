import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/di/injection.dart';
import 'core/routes/route_names.dart';
import 'core/utils/preferences_keys.dart';
import 'firebase_options.dart';
import 'presentation/pages/dashboard_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/onboarding_page.dart';
import 'presentation/pages/register_page.dart';

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
    return MaterialApp(
      title: 'Barter Qween',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)), useMaterial3: true),
      initialRoute: RouteNames.splash,
      onGenerateRoute: (s) {
        switch (s.name) {
          case RouteNames.splash: return MaterialPageRoute(builder: (_) => const SplashPage());
          case RouteNames.login: return MaterialPageRoute(builder: (_) => const LoginPage());
          case RouteNames.register: return MaterialPageRoute(builder: (_) => const RegisterPage());
          case RouteNames.onboarding: return MaterialPageRoute(builder: (_) => const OnboardingPage());
          case RouteNames.dashboard: return MaterialPageRoute(builder: (_) => const DashboardPage());
          default: return MaterialPageRoute(builder: (_) => const LoginPage());
        }
      },
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
    await Future.delayed(const Duration(seconds: 1));
    final prefs = getIt<SharedPreferences>();
    final onboardingCompleted = prefs.getBool(PreferencesKeys.onboardingCompleted) ?? false;
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(onboardingCompleted ? RouteNames.dashboard : RouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swap_horiz_rounded, size: 100, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24),
            Text('Barter Qween', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
