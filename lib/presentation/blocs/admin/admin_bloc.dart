import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/admin_repository.dart';
import '../../../domain/usecases/admin/approve_item_usecase.dart';
import '../../../domain/usecases/admin/get_dashboard_stats_usecase.dart';
import '../../../domain/usecases/admin/get_pending_items_usecase.dart';
import '../../../domain/usecases/admin/get_user_reports_usecase.dart';
import '../../../domain/usecases/admin/reject_item_usecase.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final GetPendingItemsUseCase getPendingItems;
  final ApproveItemUseCase approveItem;
  final RejectItemUseCase rejectItem;
  final GetDashboardStatsUseCase getDashboardStats;
  final GetUserReportsUseCase getUserReports;

  AdminBloc({
    required this.getPendingItems,
    required this.approveItem,
    required this.rejectItem,
    required this.getDashboardStats,
    required this.getUserReports,
  }) : super(AdminInitial()) {
    on<LoadPendingItems>(_onLoadPendingItems);
    on<ApproveItemRequested>(_onApproveItem);
    on<RejectItemRequested>(_onRejectItem);
    on<LoadDashboardStats>(_onLoadDashboardStats);
    on<LoadUserReports>(_onLoadUserReports);
    on<LoadCurrentAdmin>(_onLoadCurrentAdmin);
  }

  Future<void> _onLoadPendingItems(
    LoadPendingItems event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());

    final result = await getPendingItems(
      priority: event.priority,
      page: event.page,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (requests) => emit(PendingItemsLoaded(
        requests: requests,
        hasMore: requests.length == event.limit,
        currentFilter: event.priority,
      )),
    );
  }

  Future<void> _onApproveItem(
    ApproveItemRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());

    final result = await approveItem(
      itemId: event.itemId,
      tier: event.tier,
      notes: event.notes,
    );

    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (_) => emit(const AdminOperationSuccess(message: 'İlan başarıyla onaylandı')),
    );
  }

  Future<void> _onRejectItem(
    RejectItemRequested event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());

    final result = await rejectItem(
      itemId: event.itemId,
      reason: event.reason,
    );

    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (_) => emit(const AdminOperationSuccess(message: 'İlan başarıyla reddedildi')),
    );
  }

  Future<void> _onLoadDashboardStats(
    LoadDashboardStats event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());

    final result = await getDashboardStats();

    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (stats) => emit(DashboardStatsLoaded(stats: stats)),
    );
  }

  Future<void> _onLoadUserReports(
    LoadUserReports event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());

    final result = await getUserReports();

    result.fold(
      (failure) => emit(AdminError(message: failure.message)),
      (reports) => emit(UserReportsLoaded(reports: reports)),
    );
  }

  Future<void> _onLoadCurrentAdmin(
    LoadCurrentAdmin event,
    Emitter<AdminState> emit,
  ) async {
    // This would typically use a GetCurrentAdminUseCase
    // For now, emit an error as this use case doesn't exist yet
    emit(const AdminError(message: 'Geçerli admin bilgisi alınamadı'));
  }
}