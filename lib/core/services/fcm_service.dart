import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'dart:io' show Platform;
import 'package:barter_qween/core/routes/route_names.dart';
import 'package:barter_qween/main.dart' show navigatorKey;
import 'package:barter_qween/core/di/injection.dart';
import 'package:barter_qween/core/services/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:barter_qween/presentation/pages/messages/world_class_messages_page.dart';
import 'package:barter_qween/presentation/pages/chat/chat_deeplink_page.dart';
import 'package:barter_qween/presentation/blocs/chat/chat_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:barter_qween/presentation/pages/trades/trades_page.dart';
import 'package:barter_qween/presentation/pages/trades/trade_deeplink_page.dart';
import 'package:barter_qween/presentation/blocs/trade/trade_bloc.dart';
import 'package:barter_qween/core/routes/app_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service for handling Firebase Cloud Messaging
/// Manages FCM token lifecycle, local notifications, and deep linking
@lazySingleton
class FCMService {
  final FirebaseMessaging _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  FCMService(
    this._firebaseMessaging,
    this._localNotifications,
    this._firestore,
    this._auth,
  );

  /// Initialize FCM and request permissions
  Future<void> initialize() async {
    // Request permission for iOS
    await _requestPermission();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Get FCM token and save to Firestore
    _fcmToken = await _firebaseMessaging.getToken();
    if (_fcmToken != null) {
      await _saveFCMToken(_fcmToken!);
    }

    // Listen to token refresh and update Firestore
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      _fcmToken = newToken;
      await _saveFCMToken(newToken);
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from a notification
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  /// Save FCM token to Firestore under user's fcmTokens collection
  Future<void> _saveFCMToken(String token) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // Save token with metadata
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('fcmTokens')
          .doc(token)
          .set({
            'token': token,
            'platform': Platform.isAndroid ? 'android' : 'ios',
            'savedAt': FieldValue.serverTimestamp(),
            'deviceInfo': {
              'os': Platform.operatingSystem,
              'osVersion': Platform.operatingSystemVersion,
            },
          });

      debugPrint('✅ FCM Token saved to Firestore: $token');
    } catch (e) {
      debugPrint('❌ Error saving FCM token: $e');
    }
  }

  /// Delete FCM token from Firestore
  Future<void> _deleteFCMTokenFromFirestore(String token) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('fcmTokens')
          .doc(token)
          .delete();

      debugPrint('✅ FCM Token deleted from Firestore: $token');
    } catch (e) {
      debugPrint('❌ Error deleting FCM token: $e');
    }
  }

  /// Request notification permissions
  Future<void> _requestPermission() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    // DEBUG: print('📱 Permission status requested');
  }

  /// Initialize local notifications for foreground display
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'barter_qween_channel',
        'Barter Qween Notifications',
        description: 'Notifications for trades, messages, and updates',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    // DEBUG: print('📬 Foreground message received: ${message.notification?.title}');

    final notification = message.notification;
    if (notification != null) {
      _showLocalNotification(
        title: notification.title ?? 'Barter Qween',
        body: notification.body ?? '',
        data: message.data,
      );
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'barter_qween_channel',
      'Barter Qween Notifications',
      channelDescription: 'Notifications for trades, messages, and updates',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: data?.toString(),
    );
  }

  /// Handle notification tap - Deep linking to relevant screens
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('📲 Notification tapped: ${message.data}');
    final data = message.data;
    final type = data['type'] as String?;
    final entityId = data['entityId'] as String?;

    // Log analytics for notification open
    if (type != null) {
      try {
        getIt<AnalyticsService>().logNotificationOpened(
          notificationType: type,
          entityId: entityId,
        );
      } catch (_) {}
    }

    final nav = navigatorKey.currentState;
    if (nav == null) {
      debugPrint('⚠️ Navigator state not available for deep linking');
      return;
    }

    // Route based on notification type
    switch (type) {
      // MESSAGE NOTIFICATIONS
      case 'new_message':
      case 'new_chat_message':
        if (entityId != null && entityId.isNotEmpty) {
          nav.push(
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => getIt<ChatBloc>(),
                child: ChatDeepLinkPage(conversationId: entityId),
              ),
            ),
          );
        } else {
          nav.push(
            MaterialPageRoute(builder: (_) => const WorldClassMessagesPage()),
          );
        }
        debugPrint('✅ Deep linked to message/chat');
        break;

      // TRADE NOTIFICATIONS
      case 'new_trade_offer':
      case 'trade_accepted':
      case 'trade_rejected':
      case 'trade_cancelled':
      case 'trade_completed':
      case 'counter_offer_received':
        if (entityId != null && entityId.isNotEmpty) {
          nav.push(
            MaterialPageRoute(
              builder: (_) => TradeDeepLinkPage(tradeId: entityId),
            ),
          );
        } else {
          nav.push(
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => getIt<TradeBloc>(),
                child: const TradesPage(),
              ),
            ),
          );
        }
        debugPrint('✅ Deep linked to trade');
        break;

      // ITEM NOTIFICATIONS
      case 'new_item_from_vendor':
      case 'item_liked':
      case 'item_sold':
      case 'promotion_notification':
        if (entityId != null && entityId.isNotEmpty) {
          nav.pushNamed(AppRouter.itemDetail, arguments: entityId);
        } else {
          nav.pushNamed(RouteNames.dashboard);
        }
        debugPrint('✅ Deep linked to item');
        break;

      // BARTER MATCH NOTIFICATIONS
      case 'new_match':
      case 'price_drop_match':
        final sourceItemId = data['sourceItemId'] as String?;
        if (sourceItemId != null && sourceItemId.isNotEmpty) {
          nav.pushNamed(AppRouter.itemDetail, arguments: sourceItemId);
        } else if (entityId != null && entityId.isNotEmpty) {
          nav.pushNamed(AppRouter.itemDetail, arguments: entityId);
        } else {
          nav.pushNamed(RouteNames.dashboard);
        }
        debugPrint('✅ Deep linked to barter match');
        break;

      // SOCIAL NOTIFICATIONS
      case 'new_follow':
        final followerId = data['followerUserId'] as String?;
        if (followerId != null && followerId.isNotEmpty) {
          // TODO: Navigate to user profile page with followerId
          nav.pushNamed(RouteNames.dashboard);
        } else {
          nav.pushNamed(RouteNames.dashboard);
        }
        debugPrint('✅ Deep linked to follow notification');
        break;

      case 'new_rating':
        if (entityId != null && entityId.isNotEmpty) {
          // TODO: Navigate to ratings/reviews page for specific trade
          nav.pushNamed(RouteNames.dashboard);
        } else {
          nav.pushNamed(RouteNames.dashboard);
        }
        debugPrint('✅ Deep linked to rating notification');
        break;

      // CAMPAIGN & SYSTEM NOTIFICATIONS
      case 'campaign_notification':
        // Navigate to campaigns/offers page
        nav.pushNamed(RouteNames.dashboard);
        debugPrint('✅ Deep linked to campaign');
        break;

      case 'warning_notification':
        // Navigate to profile page to show warnings
        nav.pushNamed(RouteNames.dashboard);
        debugPrint('✅ Deep linked to warning');
        break;

      case 'system_notification':
        // Stay on current page or go to dashboard
        nav.pushNamed(RouteNames.dashboard);
        debugPrint('✅ Deep linked to system notification');
        break;

      // DEFAULT
      default:
        debugPrint('⚠️ Unknown notification type: $type, navigating to dashboard');
        nav.pushNamed(RouteNames.dashboard);
    }
  }

  /// Handle local notification tap
  void _onNotificationTap(NotificationResponse response) {
    // DEBUG: print('📲 Local notification tapped: ${response.payload}');
    final nav = navigatorKey.currentState;
    if (nav != null) {
      nav.pushNamedAndRemoveUntil(
        RouteNames.dashboard,
        (route) => route.isFirst,
      );
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    // DEBUG: print('📬 Subscribed to topic: $topic');
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    // DEBUG: print('📬 Unsubscribed from topic: $topic');
  }

  /// Delete FCM token from Firebase and Firestore
  Future<void> deleteToken() async {
    try {
      if (_fcmToken != null) {
        await _deleteFCMTokenFromFirestore(_fcmToken!);
      }
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      debugPrint('✅ FCM Token deleted');
    } catch (e) {
      debugPrint('❌ Error deleting token: $e');
    }
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // DEBUG: print('📬 Background message received: ${message.notification?.title}');
  // Handle background message
  // Note: Cannot show UI or access context here
}
