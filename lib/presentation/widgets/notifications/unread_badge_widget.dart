import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../blocs/notification/notification_bloc.dart';
import '../../blocs/notification/notification_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';

/// Unread Notification Badge Widget (Sprint 3)
/// Displays count of unread notifications as a badge
class UnreadBadgeWidget extends StatelessWidget {
  final Widget child;
  final bool showZero;

  const UnreadBadgeWidget({
    super.key,
    required this.child,
    this.showZero = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return child; // No badge if not authenticated
        }

        return BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, notificationState) {
            int unreadCount = 0;

            if (notificationState is UnreadCountLoaded) {
              unreadCount = notificationState.count;
            } else if (notificationState is UnreadCountStreaming) {
              unreadCount = notificationState.count;
            }

            // Don't show badge if count is 0 and showZero is false
            if (unreadCount == 0 && !showZero) {
              return child;
            }

            return Stack(
              clipBehavior: Clip.none,
              children: [
                child,
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
