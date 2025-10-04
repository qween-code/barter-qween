import 'package:equatable/equatable.dart';
import 'item_entity.dart';

class ModerationRequestEntity extends Equatable {
  final String id;
  final String itemId;
  final ItemEntity item;
  final String userId;
  final ModerationStatus status;
  final ModerationPriority priority;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final String? reviewNotes;
  final ItemTier? suggestedTier;
  final List<String>? flagReasons;

  const ModerationRequestEntity({
    required this.id,
    required this.itemId,
    required this.item,
    required this.userId,
    required this.status,
    required this.priority,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewedBy,
    this.reviewNotes,
    this.suggestedTier,
    this.flagReasons,
  });

  @override
  List<Object?> get props => [
        id, itemId, item, userId, status, priority, submittedAt,
        reviewedAt, reviewedBy, reviewNotes, suggestedTier, flagReasons
      ];

  ModerationRequestEntity copyWith({
    String? id,
    String? itemId,
    ItemEntity? item,
    String? userId,
    ModerationStatus? status,
    ModerationPriority? priority,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? reviewedBy,
    String? reviewNotes,
    ItemTier? suggestedTier,
    List<String>? flagReasons,
  }) {
    return ModerationRequestEntity(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      item: item ?? this.item,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewNotes: reviewNotes ?? this.reviewNotes,
      suggestedTier: suggestedTier ?? this.suggestedTier,
      flagReasons: flagReasons ?? this.flagReasons,
    );
  }
}

enum ModerationPriority {
  low,
  medium,
  high,
  urgent,
}