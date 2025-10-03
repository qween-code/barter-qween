import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/di/injection.dart';
import '../../../domain/entities/item_entity.dart';
import '../../../domain/usecases/barter/calculate_compatibility_score_usecase.dart';
import '../../blocs/barter/barter_bloc.dart';
import '../../blocs/barter/barter_event.dart';
import '../../blocs/barter/barter_state.dart';
import '../../widgets/items/item_card_widget.dart';
import '../../widgets/barter/barter_compatibility_badge.dart';

/// Barter Match Results Page
/// Shows filtered items that match the user's barter conditions
class BarterMatchResultsPage extends StatefulWidget {
  final ItemEntity sourceItem;

  const BarterMatchResultsPage({
    super.key,
    required this.sourceItem,
  });

  @override
  State<BarterMatchResultsPage> createState() => _BarterMatchResultsPageState();
}

class _BarterMatchResultsPageState extends State<BarterMatchResultsPage> {
  String _sortBy = 'best_match'; // best_match, newest, value
  String? _filterCategory;
  late final CalculateCompatibilityScoreUseCase _calculateScoreUseCase;

  @override
  void initState() {
    super.initState();
    _calculateScoreUseCase = getIt<CalculateCompatibilityScoreUseCase>();
    
    // Trigger GetMatchingItems use case
    if (widget.sourceItem.barterCondition != null) {
      context.read<BarterBloc>().add(
            GetMatchingItems(
              condition: widget.sourceItem.barterCondition!,
              currentItemId: widget.sourceItem.id,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Eşleşen Ürünler'),
        elevation: 0,
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortSheet,
          ),
        ],
      ),
      body: BlocBuilder<BarterBloc, BarterState>(
        builder: (context, state) {
          if (state is BarterLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BarterError) {
            return _buildErrorState(state.message);
          }

          if (state is MatchingItemsLoaded) {
            if (state.items.isEmpty) {
              return _buildEmptyState();
            }

            var matches = List<ItemEntity>.from(state.items);

            // Apply filter
            if (_filterCategory != null) {
              matches = matches
                  .where((item) => item.category == _filterCategory)
                  .toList();
            }

            // Apply sort
            _sortMatches(matches);

            return Column(
              children: [
                _buildResultsHeader(matches.length, state.items.length),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.spacing16),
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      final match = matches[index];
                      return _buildMatchCard(match);
                    },
                  ),
                ),
              ],
            );
          }

          return const Center(child: Text('Yükleniyor...'));
        },
      ),
    );
  }

  Widget _buildResultsHeader(int filtered, int total) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      color: AppColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            filtered == total
                ? '$total eşleşme bulundu'
                : '$total eşleşmeden $filtered gösteriliyor',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_filterCategory != null || _sortBy != 'best_match')
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _filterCategory = null;
                  _sortBy = 'best_match';
                });
              },
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('Temizle'),
            ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(ItemEntity item) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacing12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Column(
        children: [
          // Compatibility score header (simplified for now)
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacing12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimensions.radiusMedium),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Uyumluluk',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                BarterCompatibilityBadge(
                  score: _calculateScoreUseCase(
                    sourceItem: widget.sourceItem,
                    matchItem: item,
                  ),
                  size: 'small',
                  showLabel: true,
                ),
              ],
            ),
          ),
          // Item card
          SizedBox(
            height: 200,
            child: ItemCardWidget(item: item),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppDimensions.spacing16),
            Text(
              'Eşleşme Bulunamadı',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              'Şu anda takas şartlarınıza uygun ürün yok.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacing24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Geri Dön'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppDimensions.spacing16),
            Text(
              'Bir Hata Oluştu',
              style: AppTextStyles.titleLarge,
            ),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacing24),
            ElevatedButton(
              onPressed: () {
                if (widget.sourceItem.barterCondition != null) {
                  context.read<BarterBloc>().add(
                        GetMatchingItems(
                          condition: widget.sourceItem.barterCondition!,
                          currentItemId: widget.sourceItem.id,
                        ),
                      );
                }
              },
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  void _sortMatches(List<ItemEntity> items) {
    switch (_sortBy) {
      case 'best_match':
        // Sort by real compatibility score (highest first)
        items.sort((a, b) {
          final scoreA = _calculateScoreUseCase(
            sourceItem: widget.sourceItem,
            matchItem: a,
          );
          final scoreB = _calculateScoreUseCase(
            sourceItem: widget.sourceItem,
            matchItem: b,
          );
          return scoreB.compareTo(scoreA);
        });
        break;
      case 'newest':
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'value':
        items.sort((a, b) => (b.monetaryValue ?? 0)
            .compareTo(a.monetaryValue ?? 0));
        break;
    }
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sıralama', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppDimensions.spacing16),
            _buildSortOption('En İyi Eşleşme', 'best_match', Icons.stars),
            _buildSortOption('En Yeni', 'newest', Icons.new_releases),
            _buildSortOption('En Değerli', 'value', Icons.attach_money),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String value, IconData icon) {
    final isSelected = _sortBy == value;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primary : null),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? AppColors.primary : null,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () {
        setState(() => _sortBy = value);
        Navigator.pop(context);
      },
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kategori Filtresi', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppDimensions.spacing16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ItemCategory.all.map((category) {
                final isSelected = _filterCategory == category;
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _filterCategory = selected ? category : null;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
