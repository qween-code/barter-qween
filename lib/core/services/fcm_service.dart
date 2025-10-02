import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'dart:io' show Platform;
import 'package:barter_qween/core/routes/route_names.dart';
import 'package:barter_qween/main.dart' show navigatorKey;
import 'package:barter_qween/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:barter_qween/presentation/pages/chat/conversations_list_page.dart';
import 'package:barter_qween/presentation/blocs/chat/chat_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:barter_qween/presentation/pages/trades/trades_page.dart';
import 'package:barter_qween/presentation/blocs/trade/trade_bloc.dart';
import 'package:barter_qween/presentation/pages/items/item_detail_page.dart';
import 'package:barter_qween/presentation/blocs/item/item_bloc.dart';
import 'package:barter_qween/presentation/blocs/favorite/favorite_bloc.dart';

/// Service for handling Firebase Cloud Messaging
@lazySingleton
class FCMService {
  final FirebaseMessaging _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _localNotifications;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  FCMService(
    this._firebaseMessaging,
    this._localNotifications,
  );

  /// Initialize FCM and request permissions
  Future<void> initialize() async {
    // Request permission for iOS
    await _requestPermission();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Get FCM token
    _fcmToken = await _firebaseMessaging.getToken();
    print('📱 FCM Token: $_fcmToken');

    // Listen to token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      print('📱 FCM Token refreshed: $newToken');
      // TODO: Update token in Firestore
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

  /// Request notification permissions
  Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    print('📱 Permission status: ${settings.authorizationStatus}');
  }

  /// Initialize local notifications for foreground display
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('📬 Foreground message received: ${message.notification?.title}');

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

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    print('📲 Notification tapped: ${message.data}');
    final data = message.data;
    final type = data['type'] as String?;
    final entityId = data['entityId'] as String?;

    final nav = navigatorKey.currentState;
    if (nav == null) return;

    // Route based on type
    switch (type) {
      case 'new_message':
        nav.push(MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<ChatBloc>(),
            child: const ConversationsListPage(),
          ),
        ));
        break;
      case 'new_trade_offer':
      case 'trade_accepted':
      case 'trade_rejected':
      case 'trade_completed':
        nav.push(MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<TradeBloc>(),
            child: const TradesPage(),
          ),
        ));
        break;
      case 'item_liked':
      case 'item_sold':
        if (entityId != null && entityId.isNotEmpty) {
          nav.push(MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => getIt<ItemBloc>()),
                BlocProvider(create: (_) => getIt<FavoriteBloc>()),
              ],
              child: ItemDetailPage(itemId: entityId),
            ),
          ));
        } else {
          nav.pushNamed(RouteNames.dashboard);
        }
        break;
      default:
        nav.pushNamed(RouteNames.dashboard);
    }
  }

  /// Handle local notification tap
  void _onNotificationTap(NotificationResponse response) {
    print('📲 Local notification tapped: ${response.payload}');
    final nav = navigatorKey.currentState;
    if (nav != null) {
      nav.pushNamedAndRemoveUntil(RouteNames.dashboard, (route) => route.isFirst);
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('📬 Subscribed to topic: $topic');
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('📬 Unsubscribed from topic: $topic');
  }

  /// Delete FCM token
  Future<void> deleteToken() async {
    await _firebaseMessaging.deleteToken();
    _fcmToken = null;
    print('📱 FCM Token deleted');
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📬 Background message received: ${message.notification?.title}');
  // Handle background message
  // Note: Cannot show UI or access context here
}
