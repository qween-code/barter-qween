import 'package:flutter/material.dart';

/// Modern App Bar with Trendy Design
/// Features: Gradient background, smooth animations, best practices
class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool showGradient;
  final double elevation;

  const ModernAppBar({
    Key? key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.backgroundColor,
    this.showGradient = true,
    this.elevation = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: false,
      elevation: elevation,
      backgroundColor: backgroundColor,
      flexibleSpace: showGradient
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade600,
                    Colors.blue.shade400,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            )
          : null,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

/// Modern Sliver App Bar with Trendy Design
/// For pages with scrollable content
class ModernSliverAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool showGradient;
  final double expandedHeight;
  final Widget? flexibleSpace;

  const ModernSliverAppBar({
    Key? key,
    required this.title,
    this.subtitle,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.showGradient = true,
    this.expandedHeight = 160,
    this.flexibleSpace,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      actions: actions,
      title: const Text(
        'Detaylar',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: showGradient
            ? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade600,
                      Colors.blue.shade400,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              )
            : flexibleSpace,
      ),
    );
  }
}
