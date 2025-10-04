import 'package:equatable/equatable.dart';
import '../../../domain/entities/moderation_request_entity.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class LoadPendingItems extends AdminEvent {
  final ModerationPriority? priority;
  final int page;
  final int limit;

  const LoadPendingItems({
    this.priority,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [priority, page, limit];
}

class ApproveItemRequested extends AdminEvent {
  final String itemId;
  final ItemTier tier;
  final String? notes;

  const ApproveItemRequested({
    required this.itemId,
    required this.tier,
    this.notes,
  });

  @override
  List<Object?> get props => [itemId, tier, notes];
}

class RejectItemRequested extends AdminEvent {
  final String itemId;
  final String reason;

  const RejectItemRequested({
    required this.itemId,
    required this.reason,
  });

  @override
  List<Object?> get props => [itemId, reason];
}

class LoadDashboardStats extends AdminEvent {
  const LoadDashboardStats();
}

class LoadUserReports extends AdminEvent {
  const LoadUserReports();
}

class LoadCurrentAdmin extends AdminEvent {
  const LoadCurrentAdmin();
}