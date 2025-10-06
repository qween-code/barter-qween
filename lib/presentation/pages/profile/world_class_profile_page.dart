import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/world_class_design_system.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../blocs/profile/profile_event.dart';
import '../../blocs/profile/profile_state.dart';

class WorldClassProfilePage extends StatefulWidget {
  const WorldClassProfilePage({Key? key}) : super(key: key);

  @override
  State<WorldClassProfilePage> createState() => _WorldClassProfilePageState();
}

class _WorldClassProfilePageState extends State<WorldClassProfilePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: WorldClassDesignSystem.animationSlow,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WorldClassDesignSystem.primaryBackground,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return _buildLoadingState();
              } else if (state is ProfileLoaded) {
                return _buildProfileContent(state);
              } else if (state is ProfileError) {
                return _buildErrorState(state.message);
              } else {
                return _buildDefaultContent();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        color: WorldClassDesignSystem.primaryColor,
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: WorldClassDesignSystem.errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading profile',
            style: WorldClassDesignSystem.headingMedium.copyWith(
              color: WorldClassDesignSystem.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: WorldClassDesignSystem.bodyMedium.copyWith(
              color: WorldClassDesignSystem.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<ProfileBloc>().add(LoadProfile('current_user'));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: WorldClassDesignSystem.primaryColor,
              foregroundColor: WorldClassDesignSystem.primaryWhite,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
              ),
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultContent() {
    // Mock user data for demonstration
    final user = {
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&h=200&fit=crop&crop=face',
      'location': 'Istanbul, Turkey',
      'memberSince': '2023',
      'rating': 4.8,
      'totalTrades': 24,
      'successfulTrades': 22,
      'itemsSold': 15,
      'itemsBought': 9,
    };

    return _buildProfileContent(user);
  }

  Widget _buildProfileContent(dynamic user) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileHeader(user),
          _buildStatsSection(user),
          _buildMenuSection(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(user['avatar'] ?? ''),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    // TODO: Implement edit profile picture
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: WorldClassDesignSystem.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: WorldClassDesignSystem.primaryWhite,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user['name'] ?? 'Unknown User',
            style: WorldClassDesignSystem.headingLarge.copyWith(
              color: WorldClassDesignSystem.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user['email'] ?? '',
            style: WorldClassDesignSystem.bodyMedium.copyWith(
              color: WorldClassDesignSystem.secondaryText,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: WorldClassDesignSystem.secondaryText,
              ),
              const SizedBox(width: 4),
              Text(
                user['location'] ?? '',
                style: WorldClassDesignSystem.bodyMedium.copyWith(
                  color: WorldClassDesignSystem.secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star,
                size: 16,
                color: WorldClassDesignSystem.warningColor,
              ),
              const SizedBox(width: 4),
              Text(
                '${user['rating'] ?? 0.0}',
                style: WorldClassDesignSystem.bodyMedium.copyWith(
                  color: WorldClassDesignSystem.primaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Member since ${user['memberSince'] ?? ''}',
                style: WorldClassDesignSystem.bodyMedium.copyWith(
                  color: WorldClassDesignSystem.secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement edit profile
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: WorldClassDesignSystem.cardBackground,
              foregroundColor: WorldClassDesignSystem.primaryText,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
              ),
            ),
            child: Text('Edit Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(dynamic user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: WorldClassDesignSystem.cardBackground,
        borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusLarge),
        boxShadow: [WorldClassDesignSystem.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trading Statistics',
            style: WorldClassDesignSystem.headingMedium.copyWith(
              color: WorldClassDesignSystem.primaryText,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Trades',
                  '${user['totalTrades'] ?? 0}',
                  Icons.swap_horiz,
                  WorldClassDesignSystem.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Success Rate',
                  '${((user['successfulTrades'] ?? 0) / (user['totalTrades'] ?? 1) * 100).toStringAsFixed(0)}%',
                  Icons.check_circle,
                  WorldClassDesignSystem.successColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Items Sold',
                  '${user['itemsSold'] ?? 0}',
                  Icons.sell,
                  WorldClassDesignSystem.warningColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Items Bought',
                  '${user['itemsBought'] ?? 0}',
                  Icons.shopping_cart,
                  WorldClassDesignSystem.infoColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: WorldClassDesignSystem.headingMedium.copyWith(
              color: WorldClassDesignSystem.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: WorldClassDesignSystem.bodySmall.copyWith(
              color: WorldClassDesignSystem.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    final menuItems = [
      {
        'title': 'My Items',
        'subtitle': 'Manage your listed items',
        'icon': Icons.inventory,
        'onTap': () {
          // TODO: Navigate to my items
        },
      },
      {
        'title': 'Favorites',
        'subtitle': 'Your saved items',
        'icon': Icons.favorite,
        'onTap': () {
          // TODO: Navigate to favorites
        },
      },
      {
        'title': 'Trade History',
        'subtitle': 'View your trading history',
        'icon': Icons.history,
        'onTap': () {
          // TODO: Navigate to trade history
        },
      },
      {
        'title': 'Notifications',
        'subtitle': 'Manage your notifications',
        'icon': Icons.notifications,
        'onTap': () {
          // TODO: Navigate to notifications
        },
      },
      {
        'title': 'Settings',
        'subtitle': 'App preferences and privacy',
        'icon': Icons.settings,
        'onTap': () {
          // TODO: Navigate to settings
        },
      },
      {
        'title': 'Help & Support',
        'subtitle': 'Get help and contact support',
        'icon': Icons.help,
        'onTap': () {
          // TODO: Navigate to help
        },
      },
      {
        'title': 'Sign Out',
        'subtitle': 'Sign out of your account',
        'icon': Icons.logout,
        'onTap': () {
          _showSignOutDialog();
        },
      },
    ];

    return Container(
      margin: const EdgeInsets.all(24),
      child: Column(
        children: menuItems.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: item['onTap'] as VoidCallback,
                borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: WorldClassDesignSystem.cardBackground,
                    borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
                    boxShadow: [WorldClassDesignSystem.cardShadow],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: WorldClassDesignSystem.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: WorldClassDesignSystem.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'] as String,
                              style: WorldClassDesignSystem.bodyMedium.copyWith(
                                color: WorldClassDesignSystem.primaryText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['subtitle'] as String,
                              style: WorldClassDesignSystem.bodySmall.copyWith(
                                color: WorldClassDesignSystem.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: WorldClassDesignSystem.secondaryText,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: WorldClassDesignSystem.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusLarge),
          ),
          title: Text(
            'Sign Out',
            style: WorldClassDesignSystem.headingMedium.copyWith(
              color: WorldClassDesignSystem.primaryText,
            ),
          ),
          content: Text(
            'Are you sure you want to sign out?',
            style: WorldClassDesignSystem.bodyMedium.copyWith(
              color: WorldClassDesignSystem.secondaryText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: WorldClassDesignSystem.bodyMedium.copyWith(
                  color: WorldClassDesignSystem.secondaryText,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement sign out
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: WorldClassDesignSystem.errorColor,
                foregroundColor: WorldClassDesignSystem.primaryWhite,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
                ),
              ),
              child: Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }
}