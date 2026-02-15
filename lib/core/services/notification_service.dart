import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permission for iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        debugPrint('User granted permission for notifications');
      }
      
      // Get FCM token
      String? token = await _firebaseMessaging.getToken();
      if (kDebugMode) {
        debugPrint('FCM Token: $token');
      }
      
      // Save token to Firestore for this user
      // TODO: Implement saving token to user document
      
      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          debugPrint('Got a message whilst in the foreground!');
          debugPrint('Message data: ${message.data}');
        }

        if (message.notification != null) {
          if (kDebugMode) {
            debugPrint('Message also contained a notification: ${message.notification}');
          }
          // TODO: Show local notification
        }
      });

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          debugPrint('Notification tapped!');
        }
        // TODO: Navigate to appropriate screen
        _handleNotificationTap(message);
      });
      
      // Check if app was opened from a terminated state by tapping notification
      RemoteMessage? initialMessage = 
          await FirebaseMessaging.instance.getInitialMessage();
      
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }
    } else {
      if (kDebugMode) {
        debugPrint('User declined or has not accepted permission');
      }
    }
  }

  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Handle navigation based on notification type
    if (message.data.containsKey('type')) {
      final type = message.data['type'];
      switch (type) {
        case 'trade_offer':
          // Navigate to trades page
          break;
        case 'trade_accepted':
          // Navigate to trade detail
          break;
        case 'message':
          // Navigate to chat
          break;
        default:
          // Navigate to home
          break;
      }
    }
  }
}

// Background message handler
// This must be a top-level function
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    debugPrint('Handling a background message: ${message.messageId}');
  }
}
