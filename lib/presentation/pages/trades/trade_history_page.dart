import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/trade_offer_entity.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/trade/trade_bloc.dart';
import '../../blocs/trade/trade_event.dart';
import '../../blocs/trade/trade_state.dart';
import 'package:intl/intl.dart';

class TradeHistoryPage extends StatelessWidget {
  const TradeHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<TradeBloc>(),
      child: const TradeHistoryView(),
    );
  }
}

class TradeHistoryView extends StatefulWidget {
  const TradeHistoryView({super.key});

  @override
  State<TradeHistoryView> createState() => _TradeHistoryViewState();
}

class _TradeHistoryViewState extends State<TradeHistoryView> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadTrades());
  }

  void _loadTrades() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<TradeBloc>().add(LoadUserTradeOffers(authState.user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Trade History', style: AppTextStyles.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacing16,
              vertical: AppDimensions.spacing8,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: AppDimensions.spacing8),
                  _buildFilterChip('Completed', 'completed'),
                  const SizedBox(width: AppDimensions.spacing8),
                  _buildFilterChip('Pending', 'pending'),
                  const SizedBox(width: AppDimensions.spacing8),
                  _buildFilterChip('Cancelled', 'cancelled'),
                ],
              ),
            ),
          ),
          
          // Trade list
          Expanded(
            child: BlocConsumer<TradeBloc, TradeState>(
              listener: (context, state) {
                if (state is TradeError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is TradeLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is TradeOffersLoaded) {
                  final filteredTrades = _filterTrades(state.offers);
                  
                  if (filteredTrades.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 80,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: AppDimensions.spacing16),
                          Text(
                            'No trades found',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spacing8),
                          Text(
                            'Your trade history will appear here',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textTertiary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _loadTrades(),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(AppDimensions.spacing16),
                      itemCount: filteredTrades.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppDimensions.spacing12),
                      itemBuilder: (context, index) {
                        final trade = filteredTrades[index];
                        return _buildTradeCard(trade);
                      },
                    ),
                  );
                }

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: AppDimensions.spacing16),
                      Text(
                        'Failed to load trades',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacing16),
                      ElevatedButton(
                        onPressed: _loadTrades,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: AppColors.primaryLight,
      checkmarkColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      labelStyle: AppTextStyles.labelMedium.copyWith(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  List<TradeOfferEntity> _filterTrades(List<TradeOfferEntity> trades) {
    if (_selectedFilter == 'all') return trades;
    return trades.where((trade) {
      final status = trade.status.toString().split('.').last;
      return status == _selectedFilter;
    }).toList();
  }

  Widget _buildTradeCard(TradeOfferEntity trade) {
    final authState = context.read<AuthBloc>().state;
    final currentUserId = authState is AuthAuthenticated ? authState.user.uid : '';
    final isOfferedByMe = trade.fromUserId == currentUserId;
    
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isOfferedByMe ? 'You offered' : 'You received',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              _buildStatusBadge(trade.status),
            ],
          ),
          const SizedBox(height: AppDimensions.spacing12),
          
          // Trade details
          Text(
            'Trade Offer',
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing8),
          
          if (trade.message != null && trade.message!.isNotEmpty) ...[
            Text(
              trade.message!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppDimensions.spacing8),
          ],
          
          // Date
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 16,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: AppDimensions.spacing4),
              Text(
                DateFormat('MMM d, yyyy').format(trade.createdAt),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(TradeStatus status) {
    Color color;
    String label;
    
    switch (status) {
      case TradeStatus.completed:
        color = AppColors.success;
        label = 'Completed';
        break;
      case TradeStatus.pending:
        color = AppColors.warning;
        label = 'Pending';
        break;
      case TradeStatus.cancelled:
        color = AppColors.error;
        label = 'Cancelled';
        break;
      case TradeStatus.rejected:
        color = AppColors.error;
        label = 'Rejected';
        break;
      default:
        color = AppColors.textSecondary;
        label = 'Unknown';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacing12,
        vertical: AppDimensions.spacing4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
