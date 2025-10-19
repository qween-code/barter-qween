import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io' show Platform;
import 'core/di/injection.dart';
import 'core/providers/global_bloc_providers.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/fcm_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }
  
  // Note: Emulator connection removed for web compatibility
  // Use platform-specific debug configurations:
  // Android: Enable Connect via localhost with port 9099, 8080, 9199
  // iOS: Use 10.0.2.2:9099 for local development
  
  try {
    await configureDependencies();
  } catch (e) {
    debugPrint('DI configuration error: $e');
  }

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
        initialRoute: AppRouter.splash,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
