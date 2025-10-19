import 'package:flutter/material.dart';
import '../../../core/theme/minimal_design_system.dart';
import '../../../domain/entities/negotiation_entity.dart';

/// Neuromorphic Negotiation Timeline Widget
/// Shows the progression of negotiation with visual timeline
class NegotiationTimelineWidget extends StatefulWidget {
  final NegotiationEntity negotiation;
  final Function(NegotiationEntity)? onCounterOffer;

  const NegotiationTimelineWidget({
    Key? key,
    required this.negotiation,
    this.onCounterOffer,
  }) : super(key: key);

  @override
  State<NegotiationTimelineWidget> createState() =>
      _NegotiationTimelineWidgetState();
}

class _NegotiationTimelineWidgetState extends State<NegotiationTimelineWidget>
    with TickerProviderStateMixin {
  late AnimationController _timelineController;
  late AnimationController _pulseController;
  late List<Animation<double>> _stepAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _timelineController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Create animations for each timeline step
    _stepAnimations = List.generate(
      _getTimelineSteps().length,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _timelineController,
          curve: Interval(
            index * 0.2,
            (index * 0.2) + 0.3,
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
    );

    _timelineController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _timelineController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  List<TimelineStep> _getTimelineSteps() {
    return [
      TimelineStep(
        title: 'Negotiation Started',
        subtitle: 'Initial offer sent',
        icon: Icons.play_arrow,
        status: TimelineStepStatus.completed,
        timestamp: widget.negotiation.createdAt,
      ),
      if (widget.negotiation.counterOffers.isNotEmpty)
        TimelineStep(
          title: 'Counter Offer',
          subtitle: 'New terms proposed',
          icon: Icons.swap_horiz,
          status: TimelineStepStatus.active,
          timestamp: widget.negotiation.counterOffers.last.createdAt,
        ),
      TimelineStep(
        title: 'Final Agreement',
        subtitle: 'Terms accepted',
        icon: Icons.handshake,
        status: TimelineStepStatus.pending,
        timestamp: null,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final steps = _getTimelineSteps();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: MinimalDesignSystem.baseColor,
                  boxShadow: MinimalDesignSystem.neumorphismInsetShadow,
                ),
                child: Icon(
                  Icons.timeline,
                  color: MinimalDesignSystem.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Negotiation Timeline',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: MinimalDesignSystem.ultraDark,
                      ),
                    ),
                    Text(
                      'Track the progress of your negotiation',
                      style: TextStyle(
                        fontSize: 12,
                        color: MinimalDesignSystem.softDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Timeline Steps
          Expanded(
            child: ListView.builder(
              itemCount: steps.length,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _stepAnimations[index],
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        20 * (1 - _stepAnimations[index].value),
                      ),
                      child: Opacity(
                        opacity: _stepAnimations[index].value,
                        child: _buildTimelineStep(steps[index], index),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(TimelineStep step, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline connector
          Column(
            children: [
              _buildStepIcon(step),
              if (index < _getTimelineSteps().length - 1)
                Container(
                  width: 2,
                  height: 40,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: MinimalDesignSystem.lightShadow,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 16),

          // Step content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: MinimalDesignSystem.baseColor,
                boxShadow: step.status == TimelineStepStatus.active
                    ? MinimalDesignSystem.neumorphismOutsetShadow
                    : MinimalDesignSystem.neumorphismInsetShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          step.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _getStepTextColor(step.status),
                          ),
                        ),
                      ),
                      if (step.status == TimelineStepStatus.active)
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 0.9 + (0.1 * _pulseController.value),
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: MinimalDesignSystem.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: MinimalDesignSystem.softDark,
                    ),
                  ),
                  if (step.timestamp != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _formatTimestamp(step.timestamp!),
                      style: TextStyle(
                        fontSize: 10,
                        color: MinimalDesignSystem.lightShadow,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIcon(TimelineStep step) {
    Color iconColor;
    Color backgroundColor;
    List<BoxShadow> shadows;

    switch (step.status) {
      case TimelineStepStatus.completed:
        iconColor = MinimalDesignSystem.successColor;
        backgroundColor = MinimalDesignSystem.baseColor;
        shadows = MinimalDesignSystem.neumorphismOutsetShadow;
        break;
      case TimelineStepStatus.active:
        iconColor = MinimalDesignSystem.primaryColor;
        backgroundColor = MinimalDesignSystem.baseColor;
        shadows = MinimalDesignSystem.neumorphismOutsetShadow;
        break;
      case TimelineStepStatus.pending:
        iconColor = MinimalDesignSystem.lightShadow;
        backgroundColor = MinimalDesignSystem.baseColor;
        shadows = MinimalDesignSystem.neumorphismInsetShadow;
        break;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: backgroundColor,
        boxShadow: shadows,
      ),
      child: Icon(step.icon, color: iconColor, size: 16),
    );
  }

  Color _getStepTextColor(TimelineStepStatus status) {
    switch (status) {
      case TimelineStepStatus.completed:
        return MinimalDesignSystem.successColor;
      case TimelineStepStatus.active:
        return MinimalDesignSystem.primaryColor;
      case TimelineStepStatus.pending:
        return MinimalDesignSystem.softDark;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

class TimelineStep {
  final String title;
  final String subtitle;
  final IconData icon;
  final TimelineStepStatus status;
  final DateTime? timestamp;

  TimelineStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.status,
    this.timestamp,
  });
}

enum TimelineStepStatus { completed, active, pending }
