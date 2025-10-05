import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/neuromorphic_effects.dart';

/// Ultra-Deep Neuromorphic Icon Wrapper
/// Pinterest-level 4-6 layer icon shadows with interactive effects

enum IconStyle {
  standard,    // Standard neuromorphic
  circular,    // Circular background with glow
  floating,    // Floating effect
  embedded,    // Embedded/inset effect
  morphing,    // Interactive morphing
}

enum IconSize {
  tiny(16),
  small(20),
  medium(24),
  large(32),
  huge(40),
  mega(48);

  const IconSize(this.size);
  final double size;
}

/// Neuromorphic Icon Widget with ultra-deep shadows
class NeuromorphicIcon extends StatefulWidget {
  final IconData icon;
  final IconSize size;
  final IconStyle style;
  final Color? color;
  final Color? backgroundColor;
  final Color? glowColor;
  final bool isActive;
  final VoidCallback? onTap;
  final bool enableAnimation;

  const NeuromorphicIcon({
    super.key,
    required this.icon,
    this.size = IconSize.medium,
    this.style = IconStyle.standard,
    this.color,
    this.backgroundColor,
    this.glowColor,
    this.isActive = false,
    this.onTap,
    this.enableAnimation = true,
  });

  @override
  State<NeuromorphicIcon> createState() => _NeuromorphicIconState();
}

class _NeuromorphicIconState extends State<NeuromorphicIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null && widget.enableAnimation) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.style) {
      case IconStyle.circular:
        return _buildCircularIcon();
      case IconStyle.floating:
        return _buildFloatingIcon();
      case IconStyle.embedded:
        return _buildEmbeddedIcon();
      case IconStyle.morphing:
        return _buildMorphingIcon();
      case IconStyle.standard:
      default:
        return _buildStandardIcon();
    }
  }

  Widget _buildStandardIcon() {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.enableAnimation ? _scaleAnimation.value : 1.0,
            child: child,
          );
        },
        child: Container(
          padding: EdgeInsets.all(widget.size.size * 0.3),
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? AppColors.surface,
            borderRadius: BorderRadius.circular(widget.size.size * 0.3),
            boxShadow: NeuromorphicPresets.IconPresets.standard(
              isActive: widget.isActive,
            ),
          ),
          child: Icon(
            widget.icon,
            size: widget.size.size,
            color: widget.color ?? (widget.isActive ? AppColors.primary : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildCircularIcon() {
    final containerSize = widget.size.size * 2.5;
    
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.enableAnimation ? _scaleAnimation.value : 1.0,
            child: child,
          );
        },
        child: Container(
          width: containerSize,
          height: containerSize,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? AppColors.surface,
            shape: BoxShape.circle,
            boxShadow: NeuromorphicPresets.IconPresets.circular(
              isActive: widget.isActive,
              glowColor: widget.glowColor ?? AppColors.primary,
            ),
          ),
          child: Center(
            child: Icon(
              widget.icon,
              size: widget.size.size,
              color: widget.color ?? (widget.isActive ? AppColors.primary : AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingIcon() {
    final containerSize = widget.size.size * 2.2;
    
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.enableAnimation ? _scaleAnimation.value : 1.0,
            child: child,
          );
        },
        child: Container(
          width: containerSize,
          height: containerSize,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? AppColors.surface,
            borderRadius: BorderRadius.circular(widget.size.size * 0.4),
            boxShadow: [
              ...NeuromorphicEffects.depth.createDepthAwareShadows(
                depth: 3.0,
                isPressed: _isPressed,
                isHovered: widget.isActive,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 8),
                blurRadius: 20,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              widget.icon,
              size: widget.size.size,
              color: widget.color ?? (widget.isActive ? AppColors.primary : AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmbeddedIcon() {
    final containerSize = widget.size.size * 2.2;
    
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.enableAnimation ? _scaleAnimation.value : 1.0,
            child: child,
          );
        },
        child: Container(
          width: containerSize,
          height: containerSize,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? AppColors.surface,
            borderRadius: BorderRadius.circular(widget.size.size * 0.4),
            boxShadow: [
              // Inset shadows
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(2, 2),
                blurRadius: 6,
                spreadRadius: -2,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.7),
                offset: const Offset(-2, -2),
                blurRadius: 6,
                spreadRadius: -2,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              widget.icon,
              size: widget.size.size,
              color: widget.color ?? (widget.isActive ? AppColors.primary : AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMorphingIcon() {
    final containerSize = widget.size.size * 2.3;
    
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.enableAnimation ? _scaleAnimation.value : 1.0,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: containerSize,
          height: containerSize,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? AppColors.surface,
            borderRadius: BorderRadius.circular(
              widget.isActive ? containerSize / 2 : widget.size.size * 0.35,
            ),
            boxShadow: NeuromorphicEffects.animator.createMorphingShadows(
              stateShadows: NeuromorphicPresets.IconPresets.standard(),
              targetShadows: NeuromorphicPresets.IconPresets.circular(
                isActive: true,
                glowColor: widget.glowColor ?? AppColors.primary,
              ),
              progress: widget.isActive ? 1.0 : 0.0,
            ),
          ),
          child: Center(
            child: Icon(
              widget.icon,
              size: widget.size.size,
              color: widget.color ?? (widget.isActive ? AppColors.primary : AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

/// Neuromorphic Icon Button Collection
class NeuromorphicIconCollection {
  /// Standard neuromorphic icon button
  static Widget standardButton({
    required IconData icon,
    required VoidCallback onTap,
    IconSize size = IconSize.medium,
    bool isActive = false,
  }) {
    return NeuromorphicIcon(
      icon: icon,
      size: size,
      style: IconStyle.standard,
      isActive: isActive,
      onTap: onTap,
    );
  }

  /// Circular icon button with glow
  static Widget circularButton({
    required IconData icon,
    required VoidCallback onTap,
    IconSize size = IconSize.medium,
    bool isActive = false,
    Color? glowColor,
  }) {
    return NeuromorphicIcon(
      icon: icon,
      size: size,
      style: IconStyle.circular,
      isActive: isActive,
      onTap: onTap,
      glowColor: glowColor,
    );
  }

  /// Floating action icon
  static Widget floatingButton({
    required IconData icon,
    required VoidCallback onTap,
    IconSize size = IconSize.large,
    Color? color,
    Color? backgroundColor,
  }) {
    return NeuromorphicIcon(
      icon: icon,
      size: size,
      style: IconStyle.floating,
      onTap: onTap,
      color: color,
      backgroundColor: backgroundColor,
    );
  }

  /// Embedded icon (pressed look)
  static Widget embeddedButton({
    required IconData icon,
    required VoidCallback onTap,
    IconSize size = IconSize.medium,
    bool isActive = false,
  }) {
    return NeuromorphicIcon(
      icon: icon,
      size: size,
      style: IconStyle.embedded,
      isActive: isActive,
      onTap: onTap,
    );
  }

  /// Morphing icon (shape-shifts on active)
  static Widget morphingButton({
    required IconData icon,
    required VoidCallback onTap,
    IconSize size = IconSize.medium,
    required bool isActive,
    Color? glowColor,
  }) {
    return NeuromorphicIcon(
      icon: icon,
      size: size,
      style: IconStyle.morphing,
      isActive: isActive,
      onTap: onTap,
      glowColor: glowColor,
    );
  }

  /// Navigation icon button
  static Widget navigationButton({
    required IconData icon,
    required IconData activeIcon,
    required VoidCallback onTap,
    required bool isActive,
    String? label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NeuromorphicIcon(
          icon: isActive ? activeIcon : icon,
          size: IconSize.large,
          style: IconStyle.circular,
          isActive: isActive,
          onTap: onTap,
        ),
        if (label != null) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }

  /// Notification icon with badge
  static Widget notificationButton({
    required IconData icon,
    required VoidCallback onTap,
    int? badgeCount,
    bool showBadge = false,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        NeuromorphicIcon(
          icon: icon,
          size: IconSize.medium,
          style: IconStyle.circular,
          isActive: showBadge,
          onTap: onTap,
        ),
        if (showBadge && badgeCount != null && badgeCount > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Center(
                child: Text(
                  badgeCount > 99 ? '99+' : badgeCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Social media icon button
  static Widget socialButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color brandColor,
    IconSize size = IconSize.medium,
  }) {
    return NeuromorphicIcon(
      icon: icon,
      size: size,
      style: IconStyle.circular,
      onTap: onTap,
      color: brandColor,
      glowColor: brandColor,
      isActive: true,
    );
  }
}
