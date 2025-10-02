import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/profile/profile_event.dart';
import '../../blocs/profile/profile_state.dart';
import '../../widgets/user_avatar_widget.dart';
import '../../widgets/profile/rating_summary_widget.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/analytics_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../favorites/favorites_page.dart';
import '../items/user_items_page.dart';
import '../trades/trade_history_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileView();
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    // Reset and load profile immediately
    Future.microtask(() => _resetAndLoadProfile());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if user changed
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      if (_currentUserId != authState.user.uid) {
        print('👤 User changed from $_currentUserId to ${authState.user.uid}');
        _currentUserId = authState.user.uid;
        _resetAndLoadProfile();
      }
    }
  }

  void _resetAndLoadProfile() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      print('🔄 Resetting and loading profile for: ${authState.user.uid}');
      // Reset profile state first
      context.read<ProfileBloc>().add(ResetProfile());
      // Then load new profile
      context.read<ProfileBloc>().add(LoadProfile(authState.user.uid));
      // Also load user stats
      context.read<ProfileBloc>().add(LoadUserStats(authState.user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        // When auth state changes, reload profile
        if (authState is AuthAuthenticated) {
          if (_currentUserId != authState.user.uid) {
            print('🔄 Auth state changed, reloading profile: ${authState.user.uid}');
            _currentUserId = authState.user.uid;
            _resetAndLoadProfile();
          }
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: AppDimensions.spacing16),
                    Text(
                      'Loading...',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text('Profile', style: AppTextStyles.titleLarge),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _navigateToEdit(context),
              ),
            ],
          ),
          body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileLoaded || state is ProfileUpdated || state is AvatarUploaded) {
            // Extract user and stats from state
            final user = state is ProfileLoaded 
                ? state.user 
                : state is ProfileUpdated
                    ? (state as ProfileUpdated).user
                    : (state as AvatarUploaded).user;
            
            final itemCount = state is ProfileLoaded 
                ? state.itemCount
                : state is ProfileUpdated
                    ? (state as ProfileUpdated).itemCount
                    : (state as AvatarUploaded).itemCount;
            
            final tradeCount = state is ProfileLoaded 
                ? state.tradeCount
                : state is ProfileUpdated
                    ? (state as ProfileUpdated).tradeCount
                    : (state as AvatarUploaded).tradeCount;
            
            final averageRating = state is ProfileLoaded 
                ? state.averageRating
                : state is ProfileUpdated
                    ? (state as ProfileUpdated).averageRating
                    : (state as AvatarUploaded).averageRating;
            
            final ratingCount = state is ProfileLoaded 
                ? state.ratingCount
                : state is ProfileUpdated
                    ? (state as ProfileUpdated).ratingCount
                    : (state as AvatarUploaded).ratingCount;
            
            return CustomScrollView(
              slivers: [
                // Header with Avatar and Edit Button
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        children: [
                          const SizedBox(height: AppDimensions.spacing16),
                          
                          // Avatar
                          Stack(
                            children: [
                              UserAvatarWidget(
                                photoUrl: user.photoUrl,
                                displayName: user.displayName,
                                size: 100,
                              ),
                              if (user.isEmailVerified)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.success,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          
                          const SizedBox(height: AppDimensions.spacing16),
                          
                          // Display Name
                          Text(
                            user.displayName ?? 'User',
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: AppColors.textOnPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: AppDimensions.spacing4),
                          
                          // Email
                          Text(
                            user.email,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textOnPrimary.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
const SizedBox(height: AppDimensions.spacing8),
                          // Ratings summary
                          RatingSummaryWidget(userId: user.uid),
                          const SizedBox(height: AppDimensions.spacing24),
                        ],
                      ),
                    ),
                  ),
                ),
                
// Content
                SliverPadding(
                  padding: const EdgeInsets.all(AppDimensions.spacing24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Preferences Section
                      _buildPreferencesCard(),
                      const SizedBox(height: AppDimensions.spacing24),
                      // Account Info Section
                      _buildSectionTitle('Account Information'),
                      const SizedBox(height: AppDimensions.spacing16),
                      
                      _buildInfoCard(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: user.phoneNumber ?? 'Not set',
                        isEmpty: user.phoneNumber == null,
                      ),
                      
                      const SizedBox(height: AppDimensions.spacing12),
                      
                      _buildInfoCard(
                        icon: Icons.location_city_outlined,
                        label: 'City',
                        value: user.city ?? 'Not set',
                        isEmpty: user.city == null,
                      ),
                      
                      const SizedBox(height: AppDimensions.spacing12),
                      
                      _buildInfoCard(
                        icon: Icons.home_outlined,
                        label: 'Address',
                        value: user.address ?? 'Not set',
                        isEmpty: user.address == null,
                      ),
                      
                      const SizedBox(height: AppDimensions.spacing24),
                      
                      // About Section
                      _buildSectionTitle('About'),
                      const SizedBox(height: AppDimensions.spacing16),
                      
                      Container(
                        padding: const EdgeInsets.all(AppDimensions.spacing16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          border: Border.all(
                            color: user.bio != null ? AppColors.borderDefault : AppColors.borderLight,
                          ),
                        ),
                        child: Text(
                          user.bio ?? 'No bio yet. Tell others about yourself!',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: user.bio != null ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: AppDimensions.spacing32),
                      
                      // Stats Section
                      _buildSectionTitle('Trading Stats'),
                      const SizedBox(height: AppDimensions.spacing16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.swap_horiz,
                              label: 'Trades',
                              value: '$tradeCount',
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacing12),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.star_outline,
                              label: 'Rating',
                              value: ratingCount > 0 ? averageRating.toStringAsFixed(1) : 'N/A',
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacing12),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.inventory_2_outlined,
                              label: 'Items',
                              value: '$itemCount',
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppDimensions.spacing32),
                      
                      // Quick Actions
                      _buildSectionTitle('Quick Actions'),
                      const SizedBox(height: AppDimensions.spacing16),
                      
                      _buildActionCard(
                        icon: Icons.inventory_outlined,
                        title: 'My Listings',
                        subtitle: 'View and manage your items',
                        onTap: () => _navigateToUserItems(context),
                      ),
                      
                      const SizedBox(height: AppDimensions.spacing12),
                      
                      _buildActionCard(
                        icon: Icons.favorite_outline,
                        title: 'Favorites',
                        subtitle: 'Items you want to trade',
                        onTap: () => _navigateToFavorites(context),
                      ),
                      
                      const SizedBox(height: AppDimensions.spacing12),
                      
                      _buildActionCard(
                        icon: Icons.history,
                        title: 'Trade History',
                        subtitle: 'Your past transactions',
                        onTap: () => _navigateToTradeHistory(context),
                      ),
                      
                      const SizedBox(height: AppDimensions.spacing32),
                      
                      // Logout Button
                      OutlinedButton.icon(
                        onPressed: () => _handleLogout(context),
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: AppDimensions.spacing24),
                    ]),
                  ),
                ),
              ],
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
                  'Failed to load profile',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing16),
                ElevatedButton(
                  onPressed: _resetAndLoadProfile,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
          );
        },
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return FutureBuilder<SharedPreferences>(
      future: Future.value(getIt<SharedPreferences>()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final prefs = snapshot.data!;
        final enabled = prefs.getBool('analytics_enabled') ?? true;
        return Card(
          child: SwitchListTile(
            title: const Text('Enable analytics'),
            subtitle: const Text('Help improve the app by sharing anonymous usage data'),
            value: enabled,
            onChanged: (val) async {
              await prefs.setBool('analytics_enabled', val);
              try {
                await getIt<AnalyticsService>().enableCollection(val);
              } catch (_) {}
              setState(() {});
            },
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMedium.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    bool isEmpty = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: isEmpty ? AppColors.borderLight : AppColors.borderDefault,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isEmpty 
                  ? AppColors.surfaceVariant 
                  : AppColors.primaryLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isEmpty ? AppColors.textSecondary : AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppDimensions.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isEmpty ? AppColors.textTertiary : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacing16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: AppDimensions.spacing8),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacing4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacing16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: AppDimensions.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEdit(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ProfileBloc>(),
          child: const EditProfilePage(),
        ),
      ),
    );
    
    if (result == true) {
      _resetAndLoadProfile();
    }
  }

  void _navigateToUserItems(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const UserItemsPage(),
      ),
    );
  }

  void _navigateToFavorites(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FavoritesPage(),
      ),
    );
  }

  void _navigateToTradeHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TradeHistoryPage(),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
