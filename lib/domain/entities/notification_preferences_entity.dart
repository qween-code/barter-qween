import 'package:equatable/equatable.dart';

/// Notification preferences for a user
/// Kullanıcının bildirim tercihlerini yönetir
class NotificationPreferencesEntity extends Equatable {
  final String userId;
  
  // Match notifications (Sprint 3)
  final bool enableMatchNotifications;
  final bool enablePriceDropNotifications;
  
  // Existing notification types
  final bool enableTradeNotifications;
  final bool enableMessageNotifications;
  final bool enableItemNotifications;
  final bool enableFollowNotifications;
  final bool enableSystemNotifications;
  
  // Sound and vibration
  final bool enableSound;
  final bool enableVibration;
  
  // Quiet hours
  final bool enableQuietHours;
  final int? quietHoursStart; // Hour (0-23)
  final int? quietHoursEnd;   // Hour (0-23)
  
  final DateTime lastUpdated;

  const NotificationPreferencesEntity({
    required this.userId,
    this.enableMatchNotifications = true,
    this.enablePriceDropNotifications = true,
    this.enableTradeNotifications = true,
    this.enableMessageNotifications = true,
    this.enableItemNotifications = true,
    this.enableFollowNotifications = true,
    this.enableSystemNotifications = true,
    this.enableSound = true,
    this.enableVibration = true,
    this.enableQuietHours = false,
    this.quietHoursStart,
    this.quietHoursEnd,
    required this.lastUpdated,
  });

  /// Default preferences for new users
  factory NotificationPreferencesEntity.defaultPreferences(String userId) {
    return NotificationPreferencesEntity(
      userId: userId,
      lastUpdated: DateTime.now(),
    );
  }

  NotificationPreferencesEntity copyWith({
    String? userId,
    bool? enableMatchNotifications,
    bool? enablePriceDropNotifications,
    bool? enableTradeNotifications,
    bool? enableMessageNotifications,
    bool? enableItemNotifications,
    bool? enableFollowNotifications,
    bool? enableSystemNotifications,
    bool? enableSound,
    bool? enableVibration,
    bool? enableQuietHours,
    int? quietHoursStart,
    int? quietHoursEnd,
    DateTime? lastUpdated,
  }) {
    return NotificationPreferencesEntity(
      userId: userId ?? this.userId,
      enableMatchNotifications: enableMatchNotifications ?? this.enableMatchNotifications,
      enablePriceDropNotifications: enablePriceDropNotifications ?? this.enablePriceDropNotifications,
      enableTradeNotifications: enableTradeNotifications ?? this.enableTradeNotifications,
      enableMessageNotifications: enableMessageNotifications ?? this.enableMessageNotifications,
      enableItemNotifications: enableItemNotifications ?? this.enableItemNotifications,
      enableFollowNotifications: enableFollowNotifications ?? this.enableFollowNotifications,
      enableSystemNotifications: enableSystemNotifications ?? this.enableSystemNotifications,
      enableSound: enableSound ?? this.enableSound,
      enableVibration: enableVibration ?? this.enableVibration,
      enableQuietHours: enableQuietHours ?? this.enableQuietHours,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        enableMatchNotifications,
        enablePriceDropNotifications,
        enableTradeNotifications,
        enableMessageNotifications,
        enableItemNotifications,
        enableFollowNotifications,
        enableSystemNotifications,
        enableSound,
        enableVibration,
        enableQuietHours,
        quietHoursStart,
        quietHoursEnd,
        lastUpdated,
      ];
}
