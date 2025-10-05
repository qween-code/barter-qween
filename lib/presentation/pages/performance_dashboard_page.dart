import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/neuromorphic_effects.dart';
import '../../core/utils/performance_profiler.dart';
import '../widgets/neumorphism/neumorphism_container.dart';

/// Performance Dashboard Page
/// Real-time monitoring of neuromorphic design performance

class PerformanceDashboardPage extends StatefulWidget {
  const PerformanceDashboardPage({super.key});

  @override
  State<PerformanceDashboardPage> createState() => _PerformanceDashboardPageState();
}

class _PerformanceDashboardPageState extends State<PerformanceDashboardPage> {
  final _profiler = PerformanceProfiler();
  Timer? _updateTimer;
  PerformanceReport? _currentReport;
  bool _isMonitoring = false;

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startMonitoring() {
    if (!_profiler.isEnabled) {
      _profiler.start();
    }
    
    setState(() => _isMonitoring = true);
    
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _currentReport = _profiler.getReport();
        });
      }
    });
  }

  void _stopMonitoring() {
    _updateTimer?.cancel();
    _profiler.stop();
    setState(() => _isMonitoring = false);
  }

  void _clearData() {
    _profiler.clear();
    setState(() {
      _currentReport = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Performance Dashboard'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isMonitoring ? Icons.pause : Icons.play_arrow),
            onPressed: _isMonitoring ? _stopMonitoring : _startMonitoring,
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearData,
          ),
        ],
      ),
      body: _currentReport == null
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildStatusCard(),
                const SizedBox(height: 20),
                _buildFPSCard(),
                const SizedBox(height: 20),
                _buildFrameMetricsCard(),
                const SizedBox(height: 20),
                _buildShadowPerformanceCard(),
                const SizedBox(height: 20),
                _buildRecommendationsCard(),
                const SizedBox(height: 20),
                _buildExportCard(),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.speed,
            size: 100,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 20),
          Text(
            'Monitoring Stopped',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap play to start monitoring',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final report = _currentReport!;
    final isGood = report.isAcceptable;
    
    return NeumorphismContainer(
      type: NeumorphismType.outset,
      depth: CardDepth.deep,
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isGood ? AppColors.success : AppColors.error,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isGood ? AppColors.success : AppColors.error).withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'System Status',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            report.performanceGrade,
            style: AppTextStyles.headlineLarge.copyWith(
              color: isGood ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isGood 
                ? 'Performance is acceptable for production'
                : 'Performance needs optimization',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFPSCard() {
    final report = _currentReport!;
    final fps = report.fps;
    final fpsPercent = (fps / 60.0).clamp(0.0, 1.0);
    
    return NeumorphismContainer(
      type: NeumorphismType.outset,
      depth: CardDepth.medium,
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frames Per Second',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                fps.toStringAsFixed(1),
                style: AppTextStyles.headlineLarge.copyWith(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'fps',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: fpsPercent,
              minHeight: 12,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                fps >= 58 ? AppColors.success :
                fps >= 55 ? AppColors.warning :
                fps >= 50 ? Colors.orange :
                AppColors.error,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Target: 60 fps',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${(fpsPercent * 100).toStringAsFixed(0)}%',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFrameMetricsCard() {
    final report = _currentReport!;
    
    return NeumorphismContainer(
      type: NeumorphismType.outset,
      depth: CardDepth.medium,
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frame Metrics',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          _buildMetricRow(
            'Build Time',
            '${report.averageBuildTime.toStringAsFixed(2)} ms',
            report.averageBuildTime < 8,
          ),
          const Divider(height: 24),
          _buildMetricRow(
            'Raster Time',
            '${report.averageRasterTime.toStringAsFixed(2)} ms',
            report.averageRasterTime < 8,
          ),
          const Divider(height: 24),
          _buildMetricRow(
            'Jank Frames',
            '${report.jankCount} (${report.jankPercentage.toStringAsFixed(1)}%)',
            report.jankPercentage < 5,
          ),
          const Divider(height: 24),
          _buildMetricRow(
            'Total Frames',
            '${report.frameCount}',
            true,
          ),
        ],
      ),
    );
  }

  Widget _buildShadowPerformanceCard() {
    final report = _currentReport!;
    final shadowReport = report.shadowReport;
    
    return NeumorphismContainer(
      type: NeumorphismType.outset,
      depth: CardDepth.medium,
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shadow Performance',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          _buildMetricRow(
            'Average Render',
            '${shadowReport.averageRenderTime.toStringAsFixed(2)} ms',
            shadowReport.averageRenderTime < 2,
          ),
          const Divider(height: 24),
          _buildMetricRow(
            'Max Render',
            '${shadowReport.maxRenderTime.toStringAsFixed(2)} ms',
            shadowReport.maxRenderTime < 5,
          ),
          if (shadowReport.componentBreakdown.isNotEmpty) ...[
            const Divider(height: 24),
            Text(
              'Component Breakdown',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...shadowReport.componentBreakdown.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: AppTextStyles.bodySmall,
                    ),
                    Text(
                      '${entry.value.toStringAsFixed(2)} ms',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard() {
    final report = _currentReport!;
    final recommendations = _getRecommendations(report);
    
    if (recommendations.isEmpty) {
      return NeumorphismContainer(
        type: NeumorphismType.outset,
        depth: CardDepth.medium,
        borderRadius: 24,
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'No optimizations needed',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return NeumorphismContainer(
      type: NeumorphismType.outset,
      depth: CardDepth.medium,
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: AppColors.warning),
              const SizedBox(width: 12),
              Text(
                'Optimization Recommendations',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...recommendations.map((rec) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.arrow_right, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    rec,
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildExportCard() {
    return NeumorphismContainer(
      type: NeumorphismType.outset,
      depth: CardDepth.shallow,
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Export Performance Data',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _exportJSON,
                  icon: const Icon(Icons.download),
                  label: const Text('Export JSON'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _shareReport,
                  icon: const Icon(Icons.share),
                  label: const Text('Share Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, bool isGood) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium,
        ),
        Row(
          children: [
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isGood ? AppColors.success : AppColors.warning,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isGood ? Icons.check_circle : Icons.warning,
              size: 20,
              color: isGood ? AppColors.success : AppColors.warning,
            ),
          ],
        ),
      ],
    );
  }

  List<String> _getRecommendations(PerformanceReport report) {
    final recommendations = <String>[];
    
    if (report.fps < 55) {
      recommendations.add('FPS is below target. Consider reducing shadow layers or enabling caching.');
    }
    
    if (report.averageBuildTime > 8) {
      recommendations.add('Build time is high. Add RepaintBoundary to complex widgets.');
    }
    
    if (report.averageRasterTime > 8) {
      recommendations.add('Raster time is high. Simplify shadow complexity or reduce layer count.');
    }
    
    if (report.jankPercentage > 5) {
      recommendations.add('High jank percentage. Profile slow frames and optimize heavy operations.');
    }
    
    if (report.shadowReport.maxRenderTime > 5) {
      recommendations.add('Shadow rendering is slow. Enable shadow caching for static components.');
    }
    
    return recommendations;
  }

  void _exportJSON() {
    final data = _profiler.exportData();
    // In production, save to file or share
    debugPrint('Exported performance data: ${data.toString()}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Performance data exported!')),
    );
  }

  void _shareReport() {
    final report = _currentReport;
    if (report == null) return;
    
    // In production, use share plugin
    debugPrint(report.toString());
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Performance report copied!')),
    );
  }
}
