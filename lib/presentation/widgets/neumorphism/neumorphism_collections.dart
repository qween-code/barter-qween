import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/neumorphism_standards.dart';

/// Ultra gelişmiş nöromorfik koleksiyonlar
/// Pinterest seviyesi derinlik ve ışık efektleri

enum CardDepth {
  shallow,
  medium,
  deep,
  cinematic,
  ultra,
}

class NeumorphismCardCollection {
  /// Ultra derinlikli hero card
  static Widget heroCard({
    required Widget child,
    required VoidCallback onTap,
    CardDepth depth = CardDepth.medium,
    double? height,
    double? width,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusCinematic),
          gradient: _getCardGradient(depth),
          boxShadow: _getCardShadow(depth),
        ),
        child: child,
      ),
    );
  }

  static List<BoxShadow> _getCardShadow(CardDepth depth) {
    switch (depth) {
      case CardDepth.shallow:
        return NeumorphismStandards.neumorphismUltraOutsetShadow;
      case CardDepth.medium:
        return NeumorphismStandards.neumorphismHoverShadow;
      case CardDepth.deep:
        return NeumorphismStandards.neumorphismDeepShadow;
      case CardDepth.cinematic:
        return NeumorphismStandards.neumorphismCinematicShadow;
      case CardDepth.ultra:
        return NeumorphismStandards.neumorphismUltraShadow;
    }
  }

  static Gradient _getCardGradient(CardDepth depth) {
    switch (depth) {
      case CardDepth.shallow:
        return AppColors.ultraGlassGradient;
      case CardDepth.medium:
        return AppColors.cinematicGradient;
      case CardDepth.deep:
        return AppColors.ultraBackgroundGradient;
      case CardDepth.cinematic:
        return AppColors.cinematicGradient;
      case CardDepth.ultra:
        return AppColors.ultraShimmerGradient;
    }
  }
}

class NeumorphismButtonCollection {
  /// Ultra gelişmiş hero buton
  static Widget heroButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: AppDimensions.animation4,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radius24),
          gradient: AppColors.ultraPrimaryGradient,
          boxShadow: NeumorphismStandards.neumorphismUltraShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: AppColors.textOnPrimary,
                size: 24,
              ),
              const SizedBox(width: 12),
            ],
            Text(
              text,
              style: AppTextStyles.ultraButtonLarge.copyWith(
                color: AppColors.textOnPrimary,
                fontSize: 18,
                shadows: [
                  Shadow(
                    color: const Color(0x00000000).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NeumorphismSearchBarCollection {
  /// Ultra gelişmiş hero search bar
  static Widget heroSearchBar({
    required TextEditingController controller,
    required Function(String) onSearch,
    String? hintText,
  }) {
    return AnimatedContainer(
      duration: AppDimensions.animation6,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius32),
        boxShadow: NeumorphismStandards.neumorphismFloatingShadow,
      ),
      child: TextField(
        controller: controller,
        onChanged: onSearch,
        style: AppTextStyles.ultraBodyLarge,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.ultraBodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.primary,
            size: 28,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}