import 'package:flutter/material.dart';
import '../../widgets/profile/user_badges_widget.dart';
import '../../widgets/profile/user_stats_widget.dart';
import '../../widgets/profile/user_rating_breakdown_widget.dart';

/// WORLD-CLASS Profile Page V3
/// Based on Depop, Vinted, Poshmark, OfferUp
/// 
/// Features:
/// - Cover photo with gradient
/// - Profile photo with verification badges
/// - Bio and location
/// - Stats dashboard (Poshmark style)
/// - Ratings breakdown (OfferUp style)
/// - Badge collection display
/// - Active listings grid
/// - Follow/Unfollow button
/// - Share profile
class ProfilePageV3WorldClass extends StatefulWidget {
  final String userId;
  final bool isOwnProfile;

  const ProfilePageV3WorldClass({
    Key? key,
    required this.userId,
    this.isOwnProfile = false,
  }) : super(key: key);

  @override
  State<ProfilePageV3WorldClass> createState() => _ProfilePageV3WorldClassState();
}

class _ProfilePageV3WorldClassState extends State<ProfilePageV3WorldClass> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Mock data - replace with BLoC
  final String displayName = 'Ayşe Yılmaz';
  final String bio = 'Fashion lover 👗 Selling gently used items from my closet. Fast shipper! 📦';
  final String city = 'İstanbul, Kadıköy';
  final String photoUrl = 'https://api.dicebear.com/7.x/avataaars/svg?seed=ayse';
  final String? coverPhotoUrl = null;
  
  // Stats
  final int totalSales = 127;
  final int activeListings = 45;
  final double averageRating = 4.9;
  final int totalReviews = 98;
  final int followersCount = 342;
  final int followingCount = 156;
  final String responseTime = 'Within 1 hour';
  final double replyRate = 95.0;
  
  // Ratings breakdown
  final int fiveStarReviews = 92;
  final int fourStarReviews = 5;
  final int threeStarReviews = 1;
  final int twoStarReviews = 0;
  final int oneStarReviews = 0;
  final int timelyCount = 78;
  final int friendlyCount = 85;
  final int reliableCount = 90;
  final int asDescribedCount = 88;
  
  // Badges
  final bool isVerifiedSeller = true;
  final bool isTopSeller = true;
  final bool isTrustedSeller = true;
  final bool hasReplyRateBadge = true;
  final bool hasFastShipperBadge = true;
  final bool hasTopRatedBadge = true;
  final bool isIdVerified = true;
  
  // Social
  bool isFollowing = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // App Bar with cover photo
          _buildAppBar(),
          
          // Profile content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile header
                _buildProfileHeader(),
                
                const SizedBox(height: 20),
                
                // Badges
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: UserBadgesWidget(
                    isVerifiedSeller: isVerifiedSeller,
                    isTopSeller: isTopSeller,
                    isTrustedSeller: isTrustedSeller,
                    hasReplyRateBadge: hasReplyRateBadge,
                    hasFastShipperBadge: hasFastShipperBadge,
                    hasTopRatedBadge: hasTopRatedBadge,
                    isIdVerified: isIdVerified,
                    showLabels: true,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Stats
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: UserStatsWidget(
                    totalSales: totalSales,
                    activeListings: activeListings,
                    averageRating: averageRating,
                    totalReviews: totalReviews,
                    followersCount: followersCount,
                    followingCount: followingCount,
                    responseTime: responseTime,
                    replyRate: replyRate,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Rating breakdown
                if (totalReviews > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: UserRatingBreakdownWidget(
                      averageRating: averageRating,
                      totalReviews: totalReviews,
                      fiveStarReviews: fiveStarReviews,
                      fourStarReviews: fourStarReviews,
                      threeStarReviews: threeStarReviews,
                      twoStarReviews: twoStarReviews,
                      oneStarReviews: oneStarReviews,
                      timelyCount: timelyCount,
                      friendlyCount: friendlyCount,
                      reliableCount: reliableCount,
                      asDescribedCount: asDescribedCount,
                    ),
                  ),
                
                const SizedBox(height: 20),
                
                // Tabs
                _buildTabs(),
              ],
            ),
          ),
          
          // Tab content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildListingsTab(),
                _buildReviewsTab(),
                _buildAboutTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Cover photo or gradient
            if (coverPhotoUrl != null)
              Image.network(
                coverPhotoUrl!,
                fit: BoxFit.cover,
              )
            else
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
                  ),
                ),
              ),
            
            // Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: _shareProfile,
        ),
        if (widget.isOwnProfile)
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          )
        else
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMoreOptions,
          ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Profile photo with badge
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(photoUrl),
                    ),
                  ),
                  if (isVerifiedSeller)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified,
                          color: Colors.blue,
                          size: 24,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(width: 16),
              
              // Name and location
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          city,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Bio
          if (bio.isNotEmpty)
            Text(
              bio,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Action buttons
          if (!widget.isOwnProfile)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _toggleFollow,
                    icon: Icon(isFollowing ? Icons.check : Icons.person_add),
                    label: Text(isFollowing ? 'Following' : 'Follow'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFollowing ? Colors.grey.shade300 : const Color(0xFFFF6B35),
                      foregroundColor: isFollowing ? Colors.grey.shade700 : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Message'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _editProfile,
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B35),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFFFF6B35),
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: const Color(0xFFFF6B35),
        tabs: [
          Tab(text: 'Listings ($activeListings)'),
          Tab(text: 'Reviews ($totalReviews)'),
          const Tab(text: 'About'),
        ],
      ),
    );
  }

  Widget _buildListingsTab() {
    return Container(
      color: const Color(0xFFF8F9FA),
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: 8,
        itemBuilder: (context, index) => _buildListingCard(),
      ),
    );
  }

  Widget _buildListingCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: 150,
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Item Title',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '₺450',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => _buildReviewCard(),
    );
  }

  Widget _buildReviewCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  'https://api.dicebear.com/7.x/avataaars/svg?seed=user$this',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mehmet Yılmaz',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            Icons.star,
                            size: 14,
                            color: i < 5 ? Colors.amber : Colors.grey.shade300,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '2 days ago',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Great seller! Item was exactly as described. Fast shipping and excellent communication. Highly recommended! 👍',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildReviewTag('Timely', Icons.schedule),
              _buildReviewTag('Friendly', Icons.sentiment_satisfied),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewTag(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.green.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab() {
    return Container(
      color: const Color(0xFFF8F9FA),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAboutSection(
            'Joined',
            'March 2023',
            Icons.calendar_today,
          ),
          _buildAboutSection(
            'Response Time',
            responseTime,
            Icons.access_time,
          ),
          _buildAboutSection(
            'Verification',
            'ID Verified • Email Verified • Phone Verified',
            Icons.verified_user,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF6B35)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFollow() {
    setState(() {
      isFollowing = !isFollowing;
    });
  }

  void _sendMessage() {
    // Navigate to chat
  }

  void _editProfile() {
    // Navigate to edit profile
  }

  void _shareProfile() {
    // Share profile
  }

  void _openSettings() {
    // Open settings
  }

  void _showMoreOptions() {
    // Show more options
  }
}
