import 'dart:math' as math;

import 'package:flutter/material.dart';

class ItemCardContentLayout {
  final double bodyHeight;
  final double bodyWidth;

  const ItemCardContentLayout({
    required this.bodyHeight,
    required this.bodyWidth,
  });

  bool get isCompact => bodyHeight < 120;
  bool get isUltraCompact => bodyHeight < 90;
}

typedef ItemCardContentBuilder =
    Widget Function(BuildContext context, ItemCardContentLayout layout);

class ItemCardFrame extends StatelessWidget {
  final Widget image;
  final List<Widget> imageOverlays;
  final ItemCardContentBuilder contentBuilder;
  final double borderRadius;
  final EdgeInsetsGeometry contentPadding;
  final Color backgroundColor;
  final List<BoxShadow>? boxShadow;
  final BoxBorder? outline;
  final double cardAspectRatio;
  final double imageFraction;
  final Clip clipBehavior;

  const ItemCardFrame({
    super.key,
    required this.image,
    required this.contentBuilder,
    this.imageOverlays = const [],
    this.borderRadius = 16,
    this.contentPadding = const EdgeInsets.fromLTRB(12, 12, 12, 12),
    this.backgroundColor = Colors.white,
    this.boxShadow,
    this.outline,
    this.cardAspectRatio = 0.62,
    this.imageFraction = 0.55,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = _resolveWidth(constraints);
        final aspectRatio = cardAspectRatio.clamp(0.5, 0.9);
        final resolvedImageFraction = imageFraction.clamp(0.4, 0.7);
        final borderRadiusValue = BorderRadius.circular(borderRadius);

        return AspectRatio(
          aspectRatio: aspectRatio,
          child: LayoutBuilder(
            builder: (context, aspectConstraints) {
              final effectiveWidth = aspectConstraints.maxWidth.isFinite
                  ? aspectConstraints.maxWidth
                  : width;
              final effectiveHeight = effectiveWidth / aspectRatio;

              final imageHeight = effectiveHeight * resolvedImageFraction;
              final contentHeight = effectiveHeight - imageHeight;

              final resolvedPadding = contentPadding.resolve(TextDirection.ltr);
              final contentAvailableHeight = math
                  .max(contentHeight - resolvedPadding.vertical, 0)
                  .toDouble();

              return Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: borderRadiusValue,
                  boxShadow: boxShadow,
                  border: outline,
                ),
                clipBehavior: clipBehavior,
                child: Column(
                  children: [
                    SizedBox(
                      height: imageHeight,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: borderRadiusValue.topLeft,
                          topRight: borderRadiusValue.topRight,
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [image, ...imageOverlays],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: contentHeight,
                      child: Padding(
                        padding: contentPadding,
                        child: contentBuilder(
                          context,
                          ItemCardContentLayout(
                            bodyHeight: contentAvailableHeight,
                            bodyWidth: effectiveWidth,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  double _resolveWidth(BoxConstraints constraints) {
    if (constraints.maxWidth.isFinite && constraints.maxWidth > 0) {
      return constraints.maxWidth;
    }
    if (constraints.minWidth.isFinite && constraints.minWidth > 0) {
      return constraints.minWidth;
    }
    return 220;
  }
}
