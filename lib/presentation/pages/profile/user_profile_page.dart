import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/chat/chat_event.dart';
import '../../blocs/chat/chat_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart' show AuthAuthenticated;
import '../../blocs/favorite/favorite_bloc.dart';
import '../../blocs/favorite/favorite_event.dart';
import '../../blocs/favorite/favorite_state.dart';
import '../../blocs/item/item_bloc.dart';
import '../../blocs/item/item_event.dart';
import '../../blocs/item/item_state.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/profile/profile_event.dart';
import '../../blocs/profile/profile_state.dart';
import '../../widgets/user_avatar_widget.dart';
import '../chat/chat_detail_page.dart';
import '../items/item_detail_page.dart';

class UserProfilePage extends StatelessWidget {
  final String userId;

  const UserProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<ProfileBloc>()
            ..add(LoadProfile(userId))
            ..add(LoadUserStats(userId)),
        ),
        BlocProvider(
          create: (context) => getIt<ItemBloc>()
            ..add(LoadUserItems(userId)),
        ),
        BlocProvider(
          create: (context) => getIt<FavoriteBloc>(),
        ),
      ],
      child: const UserProfileView(),
    );
  }
}

class UserProfileView extends StatelessWidget {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          _buildProfileContent(context),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.background,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoaded) {
                return SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      UserAvatarWidget(
                        photoUrl: state.user.photoUrl,
                        displayName: state.user.displayName,
                        size: 80,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.user.displayName ?? 'User',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                      if (state.user.city != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: AppColors.textOnPrimary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              state.user.city!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textOnPrimary,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildActionButtons(context),
          const SizedBox(height: 16),
          _buildStatsSection(context),
          const SizedBox(height: 24),
          _buildUserItems(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        if (state is! ProfileLoaded) {
          return const SizedBox.shrink();
        }

        final targetUserId = state.user.uid;
        final authState = context.read<AuthBloc>().state;
        final currentUserId = authState is AuthAuthenticated ? authState.user.uid : '';

        // Don't show message button for own profile
        if (targetUserId == currentUserId) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _startConversation(context, targetUserId, currentUserId),
                  icon: const Icon(Icons.message),
                  label: const Text('Send Message'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _startConversation(BuildContext context, String targetUserId, String currentUserId) {
    // Create ChatBloc and get or create conversation
    final chatBloc = getIt<ChatBloc>();
    
    chatBloc.add(GetOrCreateConversation(
      userId: currentUserId,
      otherUserId: targetUserId,
      listingId: null, // No specific listing
    ));

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: chatBloc,
        child: BlocListener<ChatBloc, ChatState>(
          listener: (context, state) {
            if (state is ConversationRetrieved) {
              // Close loading dialog
              Navigator.pop(dialogContext);
              
              // Navigate to chat
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: chatBloc,
                    child: ChatDetailPage(conversation: state.conversation),
                  ),
                ),
              );
            } else if (state is ChatError) {
              // Close loading dialog
              Navigator.pop(dialogContext);
              
              // Show error
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to start conversation: ${state.message}'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Starting conversation...'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        int itemCount = 0;
        int tradeCount = 0;
        double rating = 0.0;

        if (state is UserStatsLoaded) {
          itemCount = state.itemCount;
          tradeCount = state.tradeCount;
          rating = state.averageRating;
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderDefault),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.inventory_2_outlined,
                label: 'Items',
                value: '$itemCount',
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.borderDefault,
              ),
              _buildStatItem(
                icon: Icons.swap_horiz,
                label: 'Trades',
                value: '$tradeCount',
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.borderDefault,
              ),
              _buildStatItem(
                icon: Icons.star_outline,
                label: 'Rating',
                value: rating > 0 ? rating.toStringAsFixed(1) : 'N/A',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildUserItems(BuildContext context) {
    return BlocBuilder<ItemBloc, ItemState>(
      builder: (context, state) {
        if (state is ItemLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is ItemsLoaded) {
          if (state.items.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No items yet',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "User's Items",
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MultiBlocProvider(
                            providers: [
                              BlocProvider(create: (_) => getIt<ItemBloc>()),
                              BlocProvider(create: (_) => getIt<FavoriteBloc>()),
                            ],
                            child: ItemDetailPage(itemId: item.id),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderDefault),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child: item.images.isNotEmpty
                                      ? Image.network(
                                          item.images.first,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        )
                                      : Container(
                                          color: AppColors.surfaceVariant,
                                          child: const Icon(
                                            Icons.image_outlined,
                                            size: 48,
                                            color: AppColors.textTertiary,
                                          ),
                                        ),
                                ),
                                // Favorite button overlay
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: BlocBuilder<FavoriteBloc, FavoriteState>(
                                    builder: (context, favState) {
                                      final favoriteBloc = context.read<FavoriteBloc>();
                                      final isFavorited = favoriteBloc.isFavorited(item.id);
                                      
                                      return Material(
                                        color: Colors.white.withOpacity(0.9),
                                        shape: const CircleBorder(),
                                        child: InkWell(
                                          onTap: () {
                                            final authState = context.read<AuthBloc>().state;
                                            if (authState is AuthAuthenticated) {
                                              favoriteBloc.add(
                                                ToggleFavorite(authState.user.uid, item.id),
                                              );
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    isFavorited
                                                        ? 'Removed from favorites'
                                                        : 'Added to favorites',
                                                  ),
                                                  duration: const Duration(seconds: 1),
                                                ),
                                              );
                                            }
                                          },
                                          customBorder: const CircleBorder(),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Icon(
                                              isFavorited
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: isFavorited
                                                  ? Colors.red
                                                  : AppColors.textSecondary,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.category,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
