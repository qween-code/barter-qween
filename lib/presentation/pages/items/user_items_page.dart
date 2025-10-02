import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/item_entity.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/item/item_bloc.dart';
import '../../blocs/item/item_event.dart';
import '../../blocs/item/item_state.dart';
import '../../blocs/favorite/favorite_bloc.dart';
import '../../blocs/trade/trade_bloc.dart';
import 'item_detail_page.dart';

class UserItemsPage extends StatelessWidget {
  const UserItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ItemBloc>(),
      child: const UserItemsView(),
    );
  }
}

class UserItemsView extends StatefulWidget {
  const UserItemsView({super.key});

  @override
  State<UserItemsView> createState() => _UserItemsViewState();
}

class _UserItemsViewState extends State<UserItemsView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadUserItems());
  }

  void _loadUserItems() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ItemBloc>().add(LoadUserItems(authState.user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Listings', style: AppTextStyles.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<ItemBloc, ItemState>(
        listener: (context, state) {
          if (state is ItemError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }

          if (state is ItemDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Item deleted successfully'),
                backgroundColor: AppColors.success,
              ),
            );
            _loadUserItems();
          }
        },
        builder: (context, state) {
          if (state is ItemLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ItemsLoaded) {
            if (state.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 80,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: AppDimensions.spacing16),
                    Text(
                      'No items yet',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacing8),
                    Text(
                      'Create your first listing to start trading!',
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
              onRefresh: () async => _loadUserItems(),
              child: CustomScrollView(
                slivers: [
                  // Stats Header
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(AppDimensions.spacing16),
                      padding: const EdgeInsets.all(AppDimensions.spacing16),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            icon: Icons.inventory_2_outlined,
                            label: 'Total Items',
                            value: '${state.items.length}',
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppColors.textOnPrimary.withOpacity(0.3),
                          ),
                          _buildStatItem(
                            icon: Icons.visibility_outlined,
                            label: 'Active',
                            value: '${state.items.where((item) => item.status == ItemStatus.active).length}',
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppColors.textOnPrimary.withOpacity(0.3),
                          ),
                          _buildStatItem(
                            icon: Icons.pause_circle_outline,
                            label: 'Inactive',
                            value: '${state.items.where((item) => item.status != ItemStatus.active).length}',
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Items Grid
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacing16,
                      vertical: AppDimensions.spacing8,
                    ),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: AppDimensions.spacing12,
                        mainAxisSpacing: AppDimensions.spacing12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = state.items[index];
                          return _buildItemCard(item);
                        },
                        childCount: state.items.length,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppDimensions.spacing24),
                  ),
                ],
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
                  'Failed to load items',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing16),
                ElevatedButton(
                  onPressed: _loadUserItems,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateItem(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildItemCard(item) {
    return GestureDetector(
      onTap: () => _showItemOptions(context, item.id),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppDimensions.radiusMedium),
                    topRight: Radius.circular(AppDimensions.radiusMedium),
                  ),
                ),
                child: item.images.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppDimensions.radiusMedium),
                          topRight: Radius.circular(AppDimensions.radiusMedium),
                        ),
                        child: Image.network(
                          item.images.first,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: AppColors.textTertiary,
                        ),
                      ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacing12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.spacing4),
                  Text(
                    item.category,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacing8,
                          vertical: AppDimensions.spacing4,
                        ),
                        decoration: BoxDecoration(
                          color: item.status == ItemStatus.active
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                        ),
                        child: Text(
                          item.status == ItemStatus.active ? 'Active' : 'Inactive',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: item.status == ItemStatus.active
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        item.condition,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textOnPrimary, size: 24),
        const SizedBox(height: AppDimensions.spacing4),
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textOnPrimary.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  void _showItemOptions(BuildContext context, String itemId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppDimensions.spacing8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppDimensions.spacing16),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
              title: const Text('Edit Item'),
              onTap: () {
                Navigator.pop(ctx);
                _navigateToEditItem(context, itemId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility_outlined, color: AppColors.primary),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider.value(value: context.read<ItemBloc>()),
                        BlocProvider.value(value: context.read<AuthBloc>()),
                        BlocProvider(create: (_) => getIt<FavoriteBloc>()),
                        BlocProvider(create: (_) => getIt<TradeBloc>()),
                      ],
                      child: ItemDetailPage(itemId: itemId),
                    ),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('Delete Item', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(ctx);
                _showDeleteConfirmation(context, itemId);
              },
            ),
            const SizedBox(height: AppDimensions.spacing16),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String itemId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text(
          'Are you sure you want to delete this item? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ItemBloc>().add(DeleteItem(itemId));
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _navigateToCreateItem(BuildContext context) {
    Navigator.pushNamed(context, '/create-item');
  }

  void _navigateToEditItem(BuildContext context, String itemId) {
    Navigator.pushNamed(context, '/edit-item', arguments: itemId);
  }
}
