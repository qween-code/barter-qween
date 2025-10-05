/// Pinterest Seviyesi Ultra Nöromorfik Grid Sistemi
/// Çok katmanlı derinlik ve dinamik spacing kuralları

import 'package:flutter/material.dart';
import 'app_dimensions.dart';
import 'neumorphism_standards.dart';

/// Ultra gelişmiş nöromorfik grid sistemi
class NeumorphismGridSystem {
  NeumorphismGridSystem._();

  // ============================================
  // PINTEREST SEVIYESI GRID SABITLERI
  // ============================================

  /// Nöromorfik grid sistem sabitleri
  static const double neumorphismGridBaseUnit = 4.0;
  static const double neumorphismGridMaxWidth = 1440.0;
  static const double neumorphismGridMargin = 24.0;

  /// Pinterest tarzı nöromorfik grid kolonları
  static const int neumorphismGridColumns1 = 1;
  static const int neumorphismGridColumns2 = 2;
  static const int neumorphismGridColumns3 = 3;
  static const int neumorphismGridColumns4 = 4;
  static const int neumorphismGridColumns5 = 5;
  static const int neumorphismGridColumns6 = 6;
  static const int neumorphismGridColumns7 = 7;
  static const int neumorphismGridColumns8 = 8;
  static const int neumorphismGridColumns9 = 9;
  static const int neumorphismGridColumns10 = 10;
  static const int neumorphismGridColumns11 = 11;
  static const int neumorphismGridColumns12 = 12;

  /// Nöromorfik grid gap sistemi (derinlik bazlı)
  static const double neumorphismGridGapUltraMicro = 2.0;
  static const double neumorphismGridGapMicro = 4.0;
  static const double neumorphismGridGapSmall = 8.0;
  static const double neumorphismGridGapMedium = 12.0;
  static const double neumorphismGridGapLarge = 16.0;
  static const double neumorphismGridGapXLarge = 20.0;
  static const double neumorphismGridGapXXLarge = 24.0;
  static const double neumorphismGridGapUltra = 32.0;
  static const double neumorphismGridGapMega = 40.0;

  /// Nöromorfik grid derinlik sistemi
  static const double neumorphismGridDepth1 = 0.0;    // Düz grid
  static const double neumorphismGridDepth2 = 4.0;    // Hafif derinlik
  static const double neumorphismGridDepth3 = 8.0;    // Orta derinlik
  static const double neumorphismGridDepth4 = 12.0;   // Derin grid
  static const double neumorphismGridDepth5 = 16.0;   // Ultra derin
  static const double neumorphismGridDepth6 = 20.0;   // Mega derin
  static const double neumorphismGridDepth8 = 28.0;   // Sinematik derinlik
  static const double neumorphismGridDepth10 = 36.0;  // Pinterest derinlik

  /// Nöromorfik grid border radius sistemi
  static const double neumorphismGridRadiusMicro = 4.0;
  static const double neumorphismGridRadiusSmall = 8.0;
  static const double neumorphismGridRadiusMedium = 12.0;
  static const double neumorphismGridRadiusLarge = 16.0;
  static const double neumorphismGridRadiusXLarge = 20.0;
  static const double neumorphismGridRadiusXXLarge = 24.0;
  static const double neumorphismGridRadiusUltra = 32.0;
  static const double neumorphismGridRadiusMega = 40.0;
  static const double neumorphismGridRadiusCinematic = 48.0;

  /// Nöromorfik grid animasyon süreleri
  static const Duration neumorphismGridAnimationUltraFast = Duration(milliseconds: 100);
  static const Duration neumorphismGridAnimationFast = Duration(milliseconds: 150);
  static const Duration neumorphismGridAnimationNormal = Duration(milliseconds: 250);
  static const Duration neumorphismGridAnimationSlow = Duration(milliseconds: 400);
  static const Duration neumorphismGridAnimationUltraSlow = Duration(milliseconds: 600);
  static const Duration neumorphismGridAnimationCinematic = Duration(milliseconds: 1000);

  // ============================================
  // PINTEREST SEVIYESI GRID WIDGET'LARI
  // ============================================

  /// Ultra nöromorfik grid container
  static Widget neumorphismGridContainer({
    required List<Widget> children,
    required int columns,
    double gap = neumorphismGridGapLarge,
    double depth = neumorphismGridDepth4,
    EdgeInsetsGeometry? padding,
    ScrollPhysics? physics,
  }) {
    return Container(
      padding: padding ?? AppDimensions.getNeumorphismGridPadding(depth: depth.toInt()),
      child: GridView.builder(
        physics: physics ?? const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: gap,
          crossAxisSpacing: gap,
          childAspectRatio: 0.8,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) {
          return neumorphismGridItem(
            child: children[index],
            depth: depth,
            index: index,
          );
        },
      ),
    );
  }

  /// Ultra nöromorfik grid item
  static Widget neumorphismGridItem({
    required Widget child,
    required double depth,
    required int index,
    VoidCallback? onTap,
    bool enableHover = true,
  }) {
    return AnimatedContainer(
      duration: neumorphismGridAnimationNormal,
      decoration: BoxDecoration(
        borderRadius: AppDimensions.getNeumorphismGridBorderRadius(
          depth: depth.toInt(),
        ),
        boxShadow: NeumorphismStandards.create3DShadow(
          depth: depth,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppDimensions.getNeumorphismGridBorderRadius(
            depth: depth.toInt(),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppDimensions.getNeumorphismGridBorderRadius(
                depth: depth.toInt(),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  /// Pinterest tarzı masonry grid
  static Widget neumorphismMasonryGrid({
    required List<Widget> children,
    required double screenWidth,
    double gap = neumorphismGridGapLarge,
    double depth = neumorphismGridDepth5,
    EdgeInsetsGeometry? padding,
  }) {
    final columns = AppDimensions.getNeumorphismResponsiveColumns(screenWidth);

    return Container(
      padding: padding ?? AppDimensions.getNeumorphismGridPadding(depth: depth.toInt()),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          mainAxisSpacing: gap,
          crossAxisSpacing: gap,
          childAspectRatio: AppDimensions.getNeumorphismMasonryAspectRatio(0),
        ),
        itemCount: children.length,
        itemBuilder: (context, index) {
          final aspectRatio = AppDimensions.getNeumorphismMasonryAspectRatio(index);

          return neumorphismMasonryItem(
            child: children[index],
            aspectRatio: aspectRatio,
            depth: depth,
            index: index,
          );
        },
      ),
    );
  }

  /// Masonry grid item
  static Widget neumorphismMasonryItem({
    required Widget child,
    required double aspectRatio,
    required double depth,
    required int index,
    VoidCallback? onTap,
  }) {
    return AnimatedContainer(
      duration: neumorphismGridAnimationNormal,
      child: Container(
        height: 200 * aspectRatio,
        decoration: BoxDecoration(
          borderRadius: AppDimensions.getNeumorphismGridBorderRadius(
            depth: depth.toInt(),
          ),
          boxShadow: NeumorphismStandards.create3DShadow(
            depth: depth,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppDimensions.getNeumorphismGridBorderRadius(
              depth: depth.toInt(),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppDimensions.getNeumorphismGridBorderRadius(
                  depth: depth.toInt(),
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================
  // PINTEREST SEVIYESI GRID UTILITY METODLARI
  // ============================================

  /// Nöromorfik grid için optimal kolon sayısı hesapla
  static int calculateOptimalNeumorphismGridColumns({
    required double screenWidth,
    double minItemWidth = 200.0,
    double gap = neumorphismGridGapLarge,
  }) {
    final availableWidth = screenWidth - (2 * neumorphismGridMargin);
    final columns = ((availableWidth + gap) / (minItemWidth + gap)).floor();
    return columns.clamp(1, neumorphismGridColumns6);
  }

  /// Nöromorfik grid için dinamik gap hesapla
  static double calculateNeumorphismDynamicGap({
    required double screenWidth,
    required int columns,
    double baseGap = neumorphismGridGapLarge,
  }) {
    final densityFactor = screenWidth / AppDimensions.neumorphismBreakpointLarge;
    final columnFactor = columns / neumorphismGridColumns4;
    return baseGap * densityFactor * columnFactor;
  }

  /// Nöromorfik grid için derinlik bazlı spacing hesapla
  static double calculateNeumorphismDepthSpacing({
    required int depth,
    required double baseSpacing,
  }) {
    final depthMultiplier = 1.0 + (depth * 0.15);
    return baseSpacing * depthMultiplier;
  }

  /// Nöromorfik grid için responsive padding hesapla
  static EdgeInsets calculateNeumorphismResponsivePadding({
    required double screenWidth,
    double basePadding = neumorphismGridMargin,
  }) {
    final scaleFactor = screenWidth / AppDimensions.neumorphismBreakpointLarge;
    return EdgeInsets.all(basePadding * scaleFactor);
  }

  /// Nöromorfik grid için aspect ratio hesapla
  static double calculateNeumorphismAspectRatio({
    required int index,
    List<double>? customRatios,
  }) {
    final ratios = customRatios ?? AppDimensions.neumorphismMasonryRatios;
    return ratios[index % ratios.length];
  }
}

/// Pinterest seviyesi nöromorfik grid widget koleksiyonu
class NeumorphismGridCollection {
  NeumorphismGridCollection._();

  /// Ultra derin grid widget'ı
  static Widget ultraDeepGrid({
    required List<Widget> children,
    required int columns,
    double gap = NeumorphismGridSystem.neumorphismGridGapLarge,
    double depth = NeumorphismGridSystem.neumorphismGridDepth5,
  }) {
    return NeumorphismGridSystem.neumorphismGridContainer(
      children: children,
      columns: columns,
      gap: gap,
      depth: depth,
    );
  }

  /// Pinterest tarzı masonry grid
  static Widget pinterestMasonryGrid({
    required List<Widget> children,
    required double screenWidth,
    double gap = NeumorphismGridSystem.neumorphismGridGapLarge,
    double depth = NeumorphismGridSystem.neumorphismGridDepth6,
  }) {
    return NeumorphismGridSystem.neumorphismMasonryGrid(
      children: children,
      screenWidth: screenWidth,
      gap: gap,
      depth: depth,
    );
  }

  /// Sinematik grid widget'ı
  static Widget cinematicGrid({
    required List<Widget> children,
    required int columns,
    double gap = NeumorphismGridSystem.neumorphismGridGapXLarge,
    double depth = NeumorphismGridSystem.neumorphismGridDepth8,
  }) {
    return NeumorphismGridSystem.neumorphismGridContainer(
      children: children,
      columns: columns,
      gap: gap,
      depth: depth,
      padding: AppDimensions.getNeumorphismGridPadding(depth: depth.toInt()),
    );
  }
}