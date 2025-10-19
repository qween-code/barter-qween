import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/error/failures.dart';
import '../../../core/routes/app_router.dart';
import '../../../domain/entities/item_entity.dart';
import '../../../domain/entities/rating_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/get_user_favorites_usecase.dart';
import '../../../domain/usecases/items/get_user_items_usecase.dart';
import '../../../domain/usecases/profile/get_user_stats_usecase.dart';
import '../../../domain/usecases/rating/get_user_ratings_usecase.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import 'package:share_plus/share_plus.dart';

import '../../widgets/profile/user_badges_widget.dart';
import '../../widgets/profile/user_rating_breakdown_widget.dart';
import '../../widgets/profile/user_stats_widget.dart';

class WorldClassProfilePage extends StatefulWidget {
  const WorldClassProfilePage({Key? key}) : super(key: key);

  @override
  State<WorldClassProfilePage> createState() => _WorldClassProfilePageState();
}

class _WorldClassProfilePageState extends State<WorldClassProfilePage>
    with SingleTickerProviderStateMixin {
  static const _fallbackImage =
      'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&auto=format&fit=crop';

  late final GetUserItemsUseCase _getUserItems;
  late final GetUserFavoritesUseCase _getUserFavorites;
  late final GetUserStatsUseCase _getUserStats;
  late final GetUserRatingsUseCase _getUserRatings;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TabController _tabController;
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _error;
  String? _loadedUserId;
  AuthAuthenticated? _lastAuthState;

  List<ItemEntity> _myItems = [];
  List<ItemEntity> _favoriteItems = [];
  List<RatingEntity> _ratings = [];
  final Map<String, String> _ratingAuthors = {};
  Map<String, dynamic>? _userStats;
  Map<String, dynamic>? _userDoc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _getUserItems = getIt<GetUserItemsUseCase>();
    _getUserFavorites = getIt<GetUserFavoritesUseCase>();
    _getUserStats = getIt<GetUserStatsUseCase>();
    _getUserRatings = getIt<GetUserRatingsUseCase>();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _ensureDataLoaded(AuthAuthenticated state) {
    final user = state.user;
    final applied = _applyAuthStateData(state);
    if (applied && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
    }

    if (_loadedUserId == user.uid && _hasLoaded) {
      return;
    }

    _loadedUserId = user.uid;
    _fetchProfileData(
      user,
      cachedProfile: state.profileData,
      cachedStats: state.stats,
      cachedSocial: state.social,
    );
  }

  Future<void> _fetchProfileData(
    UserEntity user, {
    Map<String, dynamic>? cachedProfile,
    Map<String, dynamic>? cachedStats,
    Map<String, dynamic>? cachedSocial,
  }) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _hasLoaded = false;
    });

    try {
      final itemsFuture = _getUserItems(user.uid);
      final favoritesFuture = _getUserFavorites();
      final statsFuture = cachedStats != null
          ? Future.value(Right<Failure, Map<String, dynamic>>(cachedStats))
          : _getUserStats(user.uid);
      final ratingsFuture = _getUserRatings(user.uid);
      final profileFuture = cachedProfile != null
          ? Future.value(cachedProfile)
          : _firestore
                .collection('users')
                .doc(user.uid)
                .get()
                .then((doc) => doc.data());

      final Either<Failure, List<ItemEntity>> itemsResult = await itemsFuture;
      final Either<Failure, List<ItemEntity>> favoritesResult =
          await favoritesFuture;
      final Either<Failure, Map<String, dynamic>> statsResult =
          await statsFuture;
      final Either<Failure, List<RatingEntity>> ratingsResult =
          await ratingsFuture;
      final profileData = await profileFuture;

      final items = itemsResult.fold<List<ItemEntity>>((failure) {
        _error ??= failure.message;
        return [];
      }, (items) => items);

      final filteredItems =
          items.where((item) => item.ownerId == user.uid).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final favorites = favoritesResult.fold<List<ItemEntity>>((failure) {
        _error ??= failure.message;
        return [];
      }, (value) => value);

      final stats = statsResult.fold<Map<String, dynamic>?>((failure) {
        _error ??= failure.message;
        return null;
      }, (value) => value);

      final ratings = ratingsResult.fold<List<RatingEntity>>((failure) {
        _error ??= failure.message;
        return [];
      }, (value) => value);

      if (!mounted) return;
      setState(() {
        _myItems = filteredItems;
        _favoriteItems = favorites;
        _userStats = stats;
        _ratings = ratings;
        if (profileData != null) {
          _userDoc = profileData;
        }
        if (cachedSocial != null && _userDoc != null) {
          _userDoc = {
            ..._userDoc!,
            'social': {
              ...((profileData?['social'] as Map<String, dynamic>?) ?? {}),
              ...cachedSocial,
            },
          };
        }
        _isLoading = false;
        _hasLoaded = true;
      });

      unawaited(_loadReviewAuthors(_ratings));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _hasLoaded = true;
      });
    }
  }

  Future<void> _loadReviewAuthors(List<RatingEntity> ratings) async {
    final pending = ratings
        .map((rating) => rating.fromUserId)
        .where((id) => id.isNotEmpty && !_ratingAuthors.containsKey(id))
        .toSet();

    if (pending.isEmpty) return;

    final Map<String, String> resolved = {};
    final ids = pending.toList();

    for (var i = 0; i < ids.length; i += 10) {
      final chunk = ids.skip(i).take(10).toList();
      try {
        final snapshot = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        for (final doc in snapshot.docs) {
          final data = doc.data();
          final displayName = (data['displayName'] as String?)?.trim();
          final username = (data['username'] as String?)?.trim();
          final social = data['social'] as Map<String, dynamic>?;
          final socialUsername = (social?['username'] as String?)?.trim();

          final label = displayName != null && displayName.isNotEmpty
              ? displayName
              : socialUsername != null && socialUsername.isNotEmpty
                  ? '@$socialUsername'
                  : username != null && username.isNotEmpty
                      ? '@$username'
                      : '@${_truncateId(doc.id)}';

          resolved[doc.id] = label;
        }

        for (final id in chunk) {
          resolved.putIfAbsent(id, () => '@${_truncateId(id)}');
        }
      } catch (_) {
        for (final id in chunk) {
          resolved.putIfAbsent(id, () => '@${_truncateId(id)}');
        }
      }
    }

    if (!mounted || resolved.isEmpty) return;
    setState(() {
      _ratingAuthors.addAll(resolved);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            _lastAuthState = state;
            _ensureDataLoaded(state);
          } else {
            _lastAuthState = null;
            _resetProfileState();
          }
        },
        builder: (context, state) {
          final authState = state is AuthAuthenticated ? state : _lastAuthState;

          if (authState == null) {
            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return _buildLoginPrompt();
          }

          if (_isLoading && !_hasLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_error != null && !_isLoading) {
            return _buildErrorState(authState.user);
          }

          return _buildProfileContent(authState.user);
        },
      ),
    );
  }

  void _resetProfileState() {
    _isLoading = false;
    _hasLoaded = false;
    _error = null;
    _loadedUserId = null;
    _userDoc = null;
    _userStats = null;
    _myItems = [];
    _favoriteItems = [];
    _ratings = [];
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.lock_outline, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text('Profilinizi görmek için giriş yapmalısınız.'),
        ],
      ),
    );
  }

  /// Apply cached profile data from the authenticated session so that the
  /// profile screen can render immediately while Firestore requests are in
  /// flight.
  bool _applyAuthStateData(AuthAuthenticated state) {
    bool updated = false;

    if (state.profileData != null) {
      if (_userDoc == null) {
        _userDoc = Map<String, dynamic>.from(state.profileData!);
        updated = true;
      } else {
        final merged = {..._userDoc!, ...state.profileData!};
        if (!_mapEquals(_userDoc!, merged)) {
          _userDoc = merged;
          updated = true;
        }
      }
    }

    if (state.stats != null) {
      if (_userStats == null) {
        _userStats = Map<String, dynamic>.from(state.stats!);
        updated = true;
      } else {
        final mergedStats = {..._userStats!, ...state.stats!};
        if (!_mapEquals(_userStats!, mergedStats)) {
          _userStats = mergedStats;
          updated = true;
        }
      }
    }

    return updated;
  }

  bool _mapEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (!b.containsKey(entry.key) || b[entry.key] != entry.value) {
        return false;
      }
    }
    for (final entry in b.entries) {
      if (!a.containsKey(entry.key) || a[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }

  Widget _buildErrorState(UserEntity user) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Bilinmeyen bir hata oluştu.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasLoaded = false;
                });
                _fetchProfileData(user);
              },
              child: const Text('Yeniden Dene'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshProfile() async {
    final authState = _lastAuthState ?? context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      await _fetchProfileData(
        authState.user,
        cachedProfile: authState.profileData,
        cachedStats: authState.stats,
        cachedSocial: authState.social,
      );
    }
  }

  void _shareProfile(UserEntity user) {
    final primaryName = user.displayName?.trim();
    final display = (primaryName != null && primaryName.isNotEmpty)
        ? primaryName
        : user.email;
    final location = user.city?.trim();

    final buffer = StringBuffer()
      ..writeln("$display'in BarterQween profilini keşfedin.")
      ..writeln('Profil ID: ${user.uid}');

    if (location != null && location.isNotEmpty) {
      buffer.writeln('Konum: $location');
    }

    buffer
      ..writeln()
      ..writeln('BarterQween uygulamasında profilini görüntüleyin.');

    Share.share(buffer.toString().trim());
  }

  Widget _buildProfileContent(UserEntity user) {
    final stats = _userStats ?? {};
    final docStats = (_userDoc?['stats'] as Map<String, dynamic>?) ?? {};
    final social = (_userDoc?['social'] as Map<String, dynamic>?) ?? {};

    final averageRating = _toDouble(stats['averageRating']);
    final totalReviews = _toInt(stats['ratingCount']);
    final totalSales = _toInt(
      stats['tradeCount'] ?? docStats['completedTrades'],
    );
    final activeListings = _toInt(stats['itemCount'], _myItems.length);
    final followersCount = _toInt(social['followersCount']);
    final followingCount = _toInt(social['followingCount']);
    final responseTime = docStats['responseTime']?.toString();
    final replyRate = docStats['replyRate'] is num
        ? (docStats['replyRate'] as num).toDouble()
        : null;
    final trustScoreValue = _toDouble(
      docStats['trustScore'] ?? _userDoc?['trustScore'],
    );
    final pendingTrades = _toInt(docStats['pendingTrades']);

    final ratingDistribution = _buildRatingDistribution();
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          backgroundColor: Colors.white,
          elevation: innerBoxIsScrolled ? 2 : 0,
          pinned: true,
          expandedHeight: 220,
          flexibleSpace: FlexibleSpaceBar(
            background: _buildCoverSection(user),
            titlePadding: const EdgeInsetsDirectional.only(
              start: 16,
              bottom: 16,
            ),
            title: Text(
              user.displayName ?? 'Profil',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.black),
              onPressed: () {},
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
                              ),
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFFF6B35,
                                  ).withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: user.photoUrl != null
                                ? ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: user.photoUrl!,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => const Icon(
                                        Icons.person,
                                        size: 45,
                                        color: Colors.white,
                                      ),
                                      placeholder: (_, __) => const Icon(
                                        Icons.person,
                                        size: 45,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : const Center(
                                    child: Icon(
                                      Icons.person,
                                      size: 45,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  activeListings.toString(),
                                  'İlanlar',
                                ),
                                _buildStatItem(
                                  followersCount.toString(),
                                  'Takipçi',
                                ),
                                _buildStatItem(
                                  followingCount.toString(),
                                  'Takip',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.displayName ?? user.email,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            if ((user.bio ?? '').isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                user.bio!,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                            if ((user.city ?? '').isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Color(0xFFFF6B35),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    user.city!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6B35),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Profili Düzenle'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _shareProfile(user),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFFF6B35),
                                ),
                                foregroundColor: const Color(0xFFFF6B35),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Icon(Icons.share, size: 20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _showLogoutDialog,
                        icon: const Icon(Icons.logout, size: 20),
                        label: const Text('Çıkış Yap'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      UserBadgesWidget(
                        isVerifiedSeller: trustScoreValue >= 80,
                        isTopSeller: totalSales >= 5,
                        isTrustedSeller: trustScoreValue >= 90,
                        hasReplyRateBadge: (replyRate ?? 0) >= 90,
                        hasFastShipperBadge: pendingTrades <= 1,
                        hasTopRatedBadge:
                            averageRating >= 4.5 && totalReviews >= 5,
                        isIdVerified: trustScoreValue >= 85,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UserStatsWidget(
                        totalSales: totalSales,
                        activeListings: activeListings,
                        averageRating: averageRating,
                        totalReviews: totalReviews,
                        followersCount: followersCount,
                        followingCount: followingCount,
                        responseTime: responseTime,
                        replyRate: replyRate,
                      ),
                      const SizedBox(height: 16),
                      UserRatingBreakdownWidget(
                        averageRating: averageRating,
                        totalReviews: totalReviews,
                        fiveStarReviews: ratingDistribution[5] ?? 0,
                        fourStarReviews: ratingDistribution[4] ?? 0,
                        threeStarReviews: ratingDistribution[3] ?? 0,
                        twoStarReviews: ratingDistribution[2] ?? 0,
                        oneStarReviews: ratingDistribution[1] ?? 0,
                        timelyCount: _toInt(docStats['positiveReviews']),
                        friendlyCount: _toInt(docStats['friendlyCount']),
                        reliableCount: _toInt(docStats['reliableCount']),
                        asDescribedCount: _toInt(docStats['asDescribedCount']),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverAppBarDelegate(
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFFFF6B35),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFFFF6B35),
              tabs: const [
                Tab(icon: Icon(Icons.grid_on), text: 'İlanlar'),
                Tab(icon: Icon(Icons.favorite_border), text: 'Favoriler'),
                Tab(icon: Icon(Icons.star_border), text: 'Değerlendirmeler'),
              ],
            ),
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyItemsTab(),
          _buildFavoritesTab(),
          _buildReviewsTab(),
        ],
      ),
    );
  }

  Widget _buildCoverSection(UserEntity user) {
    final coverPhotoUrl = user.photoUrl;

    Widget gradientBackground() {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF6B35), Color(0xFFF7931E)],
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        if (coverPhotoUrl != null)
          CachedNetworkImage(
            imageUrl: coverPhotoUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => gradientBackground(),
            errorWidget: (_, __, ___) => gradientBackground(),
          )
        else
          gradientBackground(),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.1), Colors.white],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildMyItemsTab() {
    if (_myItems.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshProfile,
        child: ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(vertical: 48),
          children: [_buildEmptyTab('Henüz aktif ilan yok.')],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshProfile,
      child: GridView.builder(
        padding: const EdgeInsets.all(2),
        primary: false,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: _myItems.length,
        itemBuilder: (context, index) {
          final item = _myItems[index];
          final imageUrl = item.images.isNotEmpty
              ? item.images.first
              : _fallbackImage;
          return GestureDetector(
            onTap: () => AppRouter.toItemDetail(context, item.id),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported, size: 28),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoritesTab() {
    if (_favoriteItems.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshProfile,
        child: ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(vertical: 48),
          children: [_buildEmptyTab('Henüz favori ürününüz yok.')],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshProfile,
      child: GridView.builder(
        padding: const EdgeInsets.all(2),
        primary: false,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: _favoriteItems.length,
        itemBuilder: (context, index) {
          final item = _favoriteItems[index];
          final imageUrl = item.images.isNotEmpty
              ? item.images.first
              : _fallbackImage;
          return GestureDetector(
            onTap: () => AppRouter.toItemDetail(context, item.id),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                color: Colors.grey.shade200,
                child: const Icon(Icons.image_not_supported, size: 28),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewsTab() {
    if (_ratings.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshProfile,
        child: ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
          children: [_buildEmptyTab('Henüz değerlendirme yok.')],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshProfile,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: _ratings.length,
        itemBuilder: (context, index) {
          final rating = _ratings[index];
          final reviewer = rating.fromUserId;
          final authorLabel = _ratingAuthors[reviewer] ?? '@${_truncateId(reviewer, 8)}';
          final dateLabel = _relativeTime(rating.createdAt);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey.shade200,
                      child: Text(
                        rating.rating.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authorLabel,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                i < rating.rating
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 14,
                                color: Colors.amber.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      dateLabel,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if ((rating.comment ?? '').isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(rating.comment!, style: const TextStyle(fontSize: 14)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyTab(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(AuthLogoutRequested());
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }

  Map<int, int> _buildRatingDistribution() {
    final distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final rating in _ratings) {
      distribution[rating.rating] = (distribution[rating.rating] ?? 0) + 1;
    }
    return distribution;
  }

  int _toInt(dynamic value, [int fallback = 0]) {
    if (value is num) {
      return value.toInt();
    }
    return fallback;
  }

  double _toDouble(dynamic value, [double fallback = 0]) {
    if (value is num) {
      return value.toDouble();
    }
    return fallback;
  }

  String _truncateId(String value, [int max = 6]) {
    if (value.length <= max) return value;
    return value.substring(0, max);
  }

  String _relativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'az önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} sa önce';
    if (diff.inDays < 30) return '${diff.inDays} gün önce';
    final months = (diff.inDays / 30).floor();
    if (months < 12) return '$months ay önce';
    final years = (diff.inDays / 365).floor();
    return '$years yıl önce';
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
