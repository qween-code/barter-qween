import 'package:flutter/material.dart';

/// Get context helper for media query access
class Get {
  static BuildContext? _context;
  
  static void setContext(BuildContext context) {
    _context = context;
  }
  
  static BuildContext get context {
    if (_context == null) {
      throw Exception('Context not set. Call Get.setContext() first.');
    }
    return _context!;
  }
}

/// Overflow detector widget that detects and handles overflow
class _OverflowDetector extends StatefulWidget {
  final Widget child;
  final Axis direction;
  final VoidCallback? onOverflow;

  const _OverflowDetector({
    required this.child,
    required this.direction,
    this.onOverflow,
  });

  @override
  State<_OverflowDetector> createState() => _OverflowDetectorState();
}

class _OverflowDetectorState extends State<_OverflowDetector> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_checkForOverflow);
  }

  void _checkForOverflow(_) {
    if (mounted) {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final size = renderBox.size;
        final parentData = renderBox.parentData;

        // Simple overflow detection - in real implementation, this would be more sophisticated
        bool hasOverflow = false;
        
        if (widget.direction == Axis.vertical) {
          hasOverflow = _checkVerticalOverflow(renderBox);
        } else {
          hasOverflow = _checkHorizontalOverflow(renderBox);
        }

        if (hasOverflow && widget.onOverflow != null) {
          widget.onOverflow!();
        }
      }
    }
  }

  bool _checkVerticalOverflow(RenderBox renderBox) {
    // Check if content exceeds parent constraints
    final parent = renderBox.parent;
    if (parent is RenderBox) {
      final parentSize = parent.size;
      final childSize = renderBox.size;
      return childSize.height > parentSize.height;
    }
    return false;
  }

  bool _checkHorizontalOverflow(RenderBox renderBox) {
    // Check if content exceeds parent constraints
    final parent = renderBox.parent;
    if (parent is RenderBox) {
      final parentSize = parent.size;
      final childSize = renderBox.size;
      return childSize.width > parentSize.width;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Safe Card Widget that prevents overflow issues
/// Wrapper for Column/Row to ensure content doesn't overflow
class SafeColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final EdgeInsetsGeometry padding;
  final double? minHeight;
  final double? maxHeight;
  final bool enableOverflowDetection;
  final Widget? fallbackChild;
  final VoidCallback? onOverflow;

  const SafeColumn({
    Key? key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.min,
    this.padding = EdgeInsets.zero,
    this.minHeight,
    this.maxHeight,
    this.enableOverflowDetection = true,
    this.fallbackChild,
    this.onOverflow,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: minHeight ?? 0,
              maxHeight: _calculateMaxHeight(constraints),
            ),
            child: enableOverflowDetection
                ? _OverflowDetector(
                    direction: Axis.vertical,
                    onOverflow: onOverflow,
                    child: Column(
                      mainAxisAlignment: mainAxisAlignment,
                      crossAxisAlignment: crossAxisAlignment,
                      mainAxisSize: mainAxisSize,
                      children: _processChildren(constraints),
                    ),
                  )
                : Column(
                    mainAxisAlignment: mainAxisAlignment,
                    crossAxisAlignment: crossAxisAlignment,
                    mainAxisSize: mainAxisSize,
                    children: children,
                  ),
          ),
        );
      },
    );
  }

  List<Widget> _processChildren(BoxConstraints constraints) {
    // Always wrap in Flexible to prevent overflow
    return children.map((child) => 
      Flexible(child: child, fit: FlexFit.loose)
    ).toList();
  }

  double _calculateMaxHeight(BoxConstraints constraints) {
    if (maxHeight != null) return maxHeight!;
    
    // If no explicit max height, try to calculate from parent
    if (constraints.maxHeight < double.infinity) {
      return constraints.maxHeight * 0.95; // 95% of available to prevent edge overflow
    }
    
    // Default safe height based on screen
    return MediaQuery.of(Get.context as BuildContext).size.height * 0.75;
  }
}

/// Safe Row Widget that prevents overflow issues
class SafeRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final EdgeInsetsGeometry padding;
  final double? minWidth;
  final double? maxWidth;
  final bool enableOverflowDetection;
  final VoidCallback? onOverflow;

  const SafeRow({
    Key? key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.min,
    this.padding = EdgeInsets.zero,
    this.minWidth,
    this.maxWidth,
    this.enableOverflowDetection = true,
    this.onOverflow,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: minWidth ?? 0,
              maxWidth: _calculateMaxWidth(constraints),
            ),
            child: enableOverflowDetection
                ? _OverflowDetector(
                    direction: Axis.horizontal,
                    onOverflow: onOverflow,
                    child: Row(
                      mainAxisAlignment: mainAxisAlignment,
                      crossAxisAlignment: crossAxisAlignment,
                      mainAxisSize: mainAxisSize,
                      children: _processChildren(constraints),
                    ),
                  )
                : Row(
                    mainAxisAlignment: mainAxisAlignment,
                    crossAxisAlignment: crossAxisAlignment,
                    mainAxisSize: mainAxisSize,
                    children: children,
                  ),
          ),
        );
      },
    );
  }

  List<Widget> _processChildren(BoxConstraints constraints) {
    // Always wrap in Flexible for horizontal overflow prevention
    return children.map((child) => 
      Flexible(child: child, fit: FlexFit.loose)
    ).toList();
  }

  double _calculateMaxWidth(BoxConstraints constraints) {
    if (maxWidth != null) return maxWidth!;
    
    // If no explicit max width, try to calculate from parent
    if (constraints.maxWidth < double.infinity) {
      return constraints.maxWidth * 0.98; // 98% to prevent edge overflow
    }
    
    // Default safe width based on screen
    return MediaQuery.of(Get.context as BuildContext).size.width * 0.95;
  }
}

/// Safe Expanded Widget that prevents overflow in Row/Column
class SafeExpanded extends StatelessWidget {
  final Widget child;
  final int flex;
  final bool isRow;
  final double? maxWidth;
  final double? maxHeight;

  const SafeExpanded({
    Key? key,
    required this.child,
    this.flex = 1,
    this.isRow = false,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Expanded(
          flex: flex,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth ?? _calculateMaxWidth(constraints, isRow),
              maxHeight: maxHeight ?? _calculateMaxHeight(constraints, isRow),
            ),
            child: OverflowBox(
              maxWidth: maxWidth ?? _calculateMaxWidth(constraints, isRow),
              maxHeight: maxHeight ?? _calculateMaxHeight(constraints, isRow),
              child: child,
            ),
          ),
        );
      },
    );
  }

  double _calculateMaxWidth(BoxConstraints constraints, bool isRow) {
    if (isRow && maxWidth == null) {
      // Calculate reasonable max width for expanded widgets in rows
      final screenWidth = MediaQuery.of(Get.context).size.width;
      return (constraints.maxWidth / 3).clamp(80.0, 250.0);
    }
    return double.infinity;
  }

  double _calculateMaxHeight(BoxConstraints constraints, bool isRow) {
    if (!isRow && maxHeight == null) {
      // Calculate reasonable max height for expanded widgets in columns
      final screenHeight = MediaQuery.of(Get.context).size.height;
      return (constraints.maxHeight / 2).clamp(50.0, 200.0);
    }
    return double.infinity;
  }
}

/// Safe Flexible Widget with constraints 
class SafeFlexible extends StatelessWidget {
  final Widget child;
  final int flex;
  final FlexFit? fit;
  final bool isRow;
  final double? maxWidth;
  final double? maxHeight;

  const SafeFlexible({
    Key? key,
    required this.child,
    this.flex = 1,
    this.fit,
    this.isRow = false,
    this.maxWidth,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Flexible(
          flex: flex,
          fit: fit ?? FlexFit.tight,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth ?? _calculateMaxWidth(constraints, isRow),
              maxHeight: maxHeight ?? _calculateMaxHeight(constraints, isRow),
            ),
            child: OverflowBox(
              maxWidth: maxWidth ?? _calculateMaxWidth(constraints, isRow),
              maxHeight: maxHeight ?? _calculateMaxHeight(constraints, isRow),
              child: child,
            ),
          ),
        );
      },
    );
  }

  double _calculateMaxWidth(BoxConstraints constraints, bool isRow) {
    if (isRow && maxWidth == null) {
      // Calculate reasonable max width for flexible widgets in rows
      final screenWidth = MediaQuery.of(Get.context).size.width;
      return (constraints.maxWidth / 2.5).clamp(60.0, 300.0);
    }
    return double.infinity;
  }

  double _calculateMaxHeight(BoxConstraints constraints, bool isRow) {
    if (!isRow && maxHeight == null) {
      // Calculate reasonable max height for flexible widgets in columns
      final screenHeight = MediaQuery.of(Get.context).size.height;
      return (constraints.maxHeight * 0.8).clamp(40.0, 300.0);
    }
    return double.infinity;
  }
}
