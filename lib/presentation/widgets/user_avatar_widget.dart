import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class UserAvatarWidget extends StatelessWidget {
  final String? photoUrl;
  final String? displayName;
  final double size;
  final bool showEditButton;
  final VoidCallback? onEditPressed;

  const UserAvatarWidget({
    super.key,
    this.photoUrl,
    this.displayName,
    this.size = 100,
    this.showEditButton = false,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Avatar Circle
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: photoUrl == null ? AppColors.primaryGradient : null,
            border: Border.all(
              color: AppColors.surface,
              width: 3,
            ),
          ),
          child: ClipOval(
            child: photoUrl != null
                ? CachedNetworkImage(
                    imageUrl: photoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.surfaceVariant,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => _buildInitials(),
                  )
                : _buildInitials(),
          ),
        ),

        // Edit Button
        if (showEditButton)
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: onEditPressed,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  border: Border.all(
                    color: AppColors.surface,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: size * 0.15,
                  color: AppColors.surface,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitials() {
    final initials = _getInitials();
    return Container(
      color: AppColors.primary,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: AppColors.surface,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getInitials() {
    if (displayName == null || displayName!.isEmpty) {
      return 'U';
    }

    final parts = displayName!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return displayName![0].toUpperCase();
  }
}
