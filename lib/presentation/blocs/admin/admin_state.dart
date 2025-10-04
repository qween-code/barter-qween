import 'package:equatable/equatable.dart';
import '../../../domain/entities/admin_user_entity.dart';
import '../../../domain/entities/moderation_request_entity.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {
  const AdminInitial();
}

class AdminLoading extends AdminState {
  const AdminLoading();
}

class PendingItemsLoaded extends AdminState {
  final List<ModerationRequestEntity> requests;
  final bool hasMore;
  final ModerationPriority? currentFilter;

  const PendingItemsLoaded({
    required this.requests,
    this.hasMore = true,
    this.currentFilter,
  });

  @override
  List<Object?> get props => [requests, hasMore, currentFilter];
}

class DashboardStatsLoaded extends AdminState {
  final AdminDashboardStats stats;

  const DashboardStatsLoaded({required this.stats});

  @override
  List<Object?> get props => [stats];
}

class UserReportsLoaded extends AdminState {
  final List<UserReportEntity> reports;

  const UserReportsLoaded({required this.reports});

  @override
  List<Object?> get props => [reports];
}

class CurrentAdminLoaded extends AdminState {
  final AdminUserEntity admin;

  const CurrentAdminLoaded({required this.admin});

  @override
  List<Object?> get props => [admin];
}

class AdminOperationSuccess extends AdminState {
  final String message;

  const AdminOperationSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AdminError extends AdminState {
  final String message;

  const AdminError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AdminPermissionDenied extends AdminState {
  const AdminPermissionDenied();
}