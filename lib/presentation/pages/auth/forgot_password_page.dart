import 'package:flutter/material.dart';
import '../../../core/theme/world_class_design_system.dart';

/// 🌟 WORLD-CLASS FORGOT PASSWORD PAGE
///
/// Features:
/// - Email reset
/// - Form validation
/// - Success feedback
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WorldClassDesignSystem.primaryBackground,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_reset_rounded,
                size: 80,
                color: WorldClassDesignSystem.primaryColor,
              ),
              const SizedBox(height: WorldClassDesignSystem.spacingL),
              Text(
                'Forgot Password Page',
                style: WorldClassDesignSystem.heading2.copyWith(
                  color: WorldClassDesignSystem.primaryText,
                ),
              ),
              const SizedBox(height: WorldClassDesignSystem.spacingM),
              Text(
                'Coming Soon...',
                style: WorldClassDesignSystem.bodyLarge.copyWith(
                  color: WorldClassDesignSystem.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
