import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/di/injection.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/theme/world_class_components.dart';
import '../../../domain/entities/item_entity.dart';
import '../../../domain/entities/rating_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/items/get_user_items_usecase.dart';
import '../../../domain/usecases/profile/get_user_profile_usecase.dart';
import '../../../domain/usecases/profile/get_user_stats_usecase.dart';
import '../../../domain/usecases/profile/follow_user_usecase.dart';
import '../../../domain/usecases/profile/unfollow_user_usecase.dart';
import '../../../domain/usecases/profile/check_follow_status_usecase.dart';
import '../../../domain/usecases/rating/get_user_ratings_usecase.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/chat/chat_event.dart';
import '../../blocs/chat/chat_state.dart';
import '../../blocs/favorite/favorite_bloc.dart';
import '../../blocs/favorite/favorite_event.dart';
import '../../blocs/favorite/favorite_state.dart';
import '../../blocs/item/item_bloc.dart';
import '../../blocs/item/item_event.dart';
import '../../blocs/item/item_state.dart';
import '../../blocs/trade/trade_bloc.dart';
import '../chat/chat_detail_page.dart';
import '../trades/send_trade_offer_page.dart';
import '../maps/map_view_page.dart';

class EnhancedItemDetailPageV2 extends StatefulWidget {
  final String itemId;

  const EnhancedItemDetailPageV2({Key? key, required this.itemId})
    : super(key: key);

  @override
  State<EnhancedItemDetailPageV2> createState() =>
      _EnhancedItemDetailPageV2State();
}

class _EnhancedItemDetailPageV2State extends State<EnhancedItemDetailPageV2> {
  static const _fallbackImage =
      'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800&auto=format&fit=crop';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final GetUserProfileUseCase _getUserProfile;
  late final GetUserStatsUseCase _getUserStats;
  late final GetUserItemsUseCase _getUserItems;
  late final GetUserRatingsUseCase _getUserRatings;
  late final FollowUserUseCase _followUserUseCase;
  late final UnfollowUserUseCase _unfollowUserUseCase;
  late final CheckFollowStatusUseCase _checkFollowStatusUseCase;

  int _currentImageIndex = 0;
  bool _isFavorited = false;
  bool _showConfetti = false;
  late final FavoriteBloc _favoriteBloc;

  bool _sellerLoading = true;
  String? _sellerError;
  String? _loadedItemId;
  UserEntity? _sellerProfile;
  Map<String, dynamic>? _sellerStats;
  Map<String, dynamic>? _sellerDoc;
  List<ItemEntity> _otherItems = [];
  List<RatingEntity> _ratings = [];
  final Map<String, String> _ratingAuthors = {};
  int? _sellerFollowersCount;
  int? _sellerFollowingCount;
  StreamSubscription<ChatState>? _chatSubscription;
  bool _isConversationDialogVisible = false;
  bool? _isFollowingSeller;
  bool _followActionInProgress = false;

  @override
  void initState() {
    super.initState();
    _favoriteBloc = context.read<FavoriteBloc>();
    _getUserProfile = getIt<GetUserProfileUseCase>();
    _getUserStats = getIt<GetUserStatsUseCase>();
    _getUserItems = getIt<GetUserItemsUseCase>();
    _getUserRatings = getIt<GetUserRatingsUseCase>();
    _followUserUseCase = getIt<FollowUserUseCase>();
    _unfollowUserUseCase = getIt<UnfollowUserUseCase>();
    _checkFollowStatusUseCase = getIt<CheckFollowStatusUseCase>();

    _isFavorited = _favoriteBloc.isFavorited(widget.itemId);
    final favoriteState = _favoriteBloc.state;
    if (favoriteState is! FavoriteLoading &&
        favoriteState is! FavoritesLoaded &&
        favoriteState is! FavoriteToggled) {
      _favoriteBloc.add(const LoadFavorites());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemBloc>().add(LoadItem(widget.itemId));
    });
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FavoriteBloc, FavoriteState>(
      listener: _onFavoriteStateChanged,
      child: BlocBuilder<ItemBloc, ItemState>(
        builder: (context, state) {
          if (state is ItemLoading || state is ItemInitial) {
            return Scaffold(
              appBar: AppBar(title: const Text('Ürün yükleniyor')),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (state is ItemError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Hata')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<ItemBloc>().add(LoadItem(widget.itemId)),
                      child: const Text('Tekrar dene'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ItemLoaded) {
            _ensureSupplementalLoaded(state.item);
            return _buildItemDetail(state.item);
          }

          return Scaffold(
            appBar: AppBar(title: const Text('Ürün bulunamadı')),
            body: const Center(child: Text('Ürün bilgisi bulunamadı')),
          );
        },
      ),
    );
  }

  void _ensureSupplementalLoaded(ItemEntity item) {
    if (_loadedItemId == item.id) return;
    _loadedItemId = item.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _fetchSellerData(item);
    });
  }

  void _onFavoriteStateChanged(BuildContext context, FavoriteState state) {
    if (!mounted) return;

    if (state is FavoriteError) {
      _showSnackMessage(state.message, isError: true);
      return;
    }

    if (state is FavoriteToggled) {
      if (state.itemId == widget.itemId) {
        _syncFavoriteState(showFeedback: true, forceValue: state.isFavorited);
      } else {
        _syncFavoriteState();
      }
      return;
    }

    if (state is FavoritesLoaded) {
      _syncFavoriteState();
    }
  }

  Future<void> _loadReviewAuthors(List<RatingEntity> ratings) async {
    final pending = ratings
        .map((r) => r.fromUserId)
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

  void _syncFavoriteState({bool showFeedback = false, bool? forceValue}) {
    final isFav = forceValue ?? _favoriteBloc.isFavorited(widget.itemId);
    if (_isFavorited != isFav) {
      setState(() => _isFavorited = isFav);
    }
    if (showFeedback) {
      _showFavoriteFeedback(isFav);
    }
  }

  void _showFavoriteFeedback(bool isFavorited) {
    _showSnackMessage(
      isFavorited ? 'Favorilere eklendi' : 'Favorilerden çıkarıldı',
    );
    if (isFavorited) {
      _triggerConfetti();
    }
  }

  Future<Map<String, dynamic>> _loadSellerDocument(String ownerId) async {
    try {
      final snapshot = await _firestore.collection('users').doc(ownerId).get();
      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data()!;
      }
    } catch (e) {
      debugPrint('Seller doc read failed: $e');
    }
    return <String, dynamic>{};
  }

  UserEntity _buildFallbackProfile(
    ItemEntity item,
    Map<String, dynamic>? sellerData,
  ) {
    final data = sellerData ?? <String, dynamic>{};
    final createdAtRaw = data['createdAt'];
    final updatedAtRaw = data['updatedAt'];

    DateTime createdAt;
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else {
      createdAt = item.createdAt;
    }

    DateTime? updatedAt;
    if (updatedAtRaw is Timestamp) {
      updatedAt = updatedAtRaw.toDate();
    }

    return UserEntity(
      uid: item.ownerId,
      email: (data['email'] as String?) ?? '${item.ownerId}@barter.local',
      displayName: (data['displayName'] as String?) ?? item.ownerName,
      phoneNumber: data['phoneNumber'] as String?,
      photoUrl: (data['photoUrl'] as String?) ?? item.ownerPhotoUrl,
      createdAt: createdAt,
      isEmailVerified: data['isEmailVerified'] as bool? ?? false,
      bio: data['bio'] as String?,
      address: data['address'] as String?,
      city: (data['city'] as String?) ?? item.city,
      location: (data['location'] as String?) ?? item.location,
      latitude: (data['latitude'] as num?)?.toDouble() ?? item.latitude,
      longitude: (data['longitude'] as num?)?.toDouble() ?? item.longitude,
      updatedAt: updatedAt,
      trustScore: (data['trustScore'] as num?)?.toDouble(),
      stats: data['stats'] as Map<String, dynamic>?,
      social: data['social'] as Map<String, dynamic>?,
    );
  }

  void _triggerConfetti() {
    if (!mounted) return;
    setState(() => _showConfetti = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _showConfetti = false);
    });
  }

  void _showSnackMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          backgroundColor: isError ? Colors.redAccent : null,
        ),
      );
  }

  void _onFavoritePressed(ItemEntity item) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      _showSnackMessage(
        'Favorilere eklemek için giriş yapmalısınız',
        isError: true,
      );
      return;
    }

    if (_favoriteBloc.state is FavoriteLoading) {
      return;
    }

    _favoriteBloc.add(ToggleFavorite(item.id));
  }

  void _shareItem(ItemEntity item) {
    final buffer = StringBuffer();
    final title = item.title.trim();
    final priceText = item.price != null ? _formatPrice(item.price!) : null;
    final location = _locationLabel(item);

    buffer.writeln(title.isEmpty ? 'BarterQween ürünü' : title);
    if (priceText != null) {
      buffer.writeln('Fiyat: $priceText');
    }
    if (item.condition != null && item.condition!.isNotEmpty) {
      buffer.writeln('Durum: ${item.condition}');
    }
    if (location != null && location.isNotEmpty) {
      buffer.writeln('Konum: $location');
    }
    if (item.description.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln(item.description.trim());
    }

    buffer
      ..writeln()
      ..writeln('BarterQween uygulamasında incele. İlan kodu: ${item.id}');

    Share.share(buffer.toString().trim());
  }

  Future<void> _fetchSellerData(ItemEntity item) async {
    if (!mounted) return;
    setState(() {
      _sellerLoading = true;
      _sellerError = null;
      _isFollowingSeller = null;
    });

    try {
      final sellerData = await _loadSellerDocument(item.ownerId);
      final profileResult = await _getUserProfile(item.ownerId);
      final statsResult = await _getUserStats(item.ownerId);
      final itemsResult = await _getUserItems(item.ownerId);
      final ratingsResult = await _getUserRatings(item.ownerId);
      final socialData =
          (sellerData['social'] as Map<String, dynamic>?) ??
          <String, dynamic>{};
      final followersCount = _extractSocialCount(
        socialData,
        'followersCount',
        'followers',
      );
      final followingCount = _extractSocialCount(
        socialData,
        'followingCount',
        'following',
      );

      final profile = profileResult.fold<UserEntity?>((failure) {
        final message = failure.message;
        final lowered = message.toLowerCase();
        if (lowered.contains('not found')) {
          return _buildFallbackProfile(item, sellerData);
        }
        _sellerError ??= message;
        return _buildFallbackProfile(item, sellerData);
      }, (user) => user);

      final stats = statsResult.fold<Map<String, dynamic>?>((failure) {
        _sellerError ??= failure.message;
        return null;
      }, (value) => value);

      final items = itemsResult.fold<List<ItemEntity>>((failure) {
        _sellerError ??= failure.message;
        return [];
      }, (value) => value);

      final ratings = ratingsResult.fold<List<RatingEntity>>((failure) {
        _sellerError ??= failure.message;
        return [];
      }, (value) => value);

      if (!mounted) return;
      setState(() {
        _sellerProfile = profile;
        _sellerStats = stats;
        _sellerDoc = sellerData;
        _sellerFollowersCount = followersCount;
        _sellerFollowingCount = followingCount;
        _otherItems = items.where((e) => e.id != item.id).take(6).toList();
        _ratings = ratings.take(5).toList();
        _sellerLoading = false;
      });

      unawaited(_loadReviewAuthors(_ratings));

      await _refreshSellerFollowStatus(item.ownerId);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sellerError = e.toString();
        _sellerLoading = false;
      });
    }
  }

  Future<void> _refreshSellerFollowStatus(String ownerId) async {
    if (!mounted) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated || authState.user.uid == ownerId) {
      setState(() {
        _isFollowingSeller = false;
      });
      return;
    }

    final viewerId = authState.user.uid;
    final result = await _checkFollowStatusUseCase(viewerId, ownerId);

    if (!mounted) return;
    setState(() {
      _isFollowingSeller = result.fold((_) => false, (value) => value);
    });
  }

  Future<void> _toggleFollowSeller(String ownerId) async {
    if (!mounted || _followActionInProgress) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      _showSnackMessage('Takip etmek için giriş yapmalısınız.', isError: true);
      return;
    }

    if (authState.user.uid == ownerId) {
      return;
    }

    setState(() => _followActionInProgress = true);

    try {
      if (_isFollowingSeller == true) {
        final result = await _unfollowUserUseCase(authState.user.uid, ownerId);

        result.fold(
          (failure) => _showSnackMessage(failure.message, isError: true),
          (_) {
            if (!mounted) return;
            setState(() {
              _isFollowingSeller = false;
              if (_sellerFollowersCount != null && _sellerFollowersCount! > 0) {
                _sellerFollowersCount = _sellerFollowersCount! - 1;
              }
            });
            _showSnackMessage('Satıcı takipten çıkarıldı');
          },
        );
      } else {
        final result = await _followUserUseCase(authState.user.uid, ownerId);

        result.fold(
          (failure) => _showSnackMessage(failure.message, isError: true),
          (_) {
            if (!mounted) return;
            setState(() {
              _isFollowingSeller = true;
              _sellerFollowersCount = (_sellerFollowersCount ?? 0) + 1;
            });
            _showSnackMessage('Satıcı takip edildi');
          },
        );
      }
    } finally {
      if (mounted) {
        setState(() => _followActionInProgress = false);
      }
    }
  }

  int _extractSocialCount(
    Map<String, dynamic>? social,
    String counterKey,
    String listKey,
  ) {
    if (social == null) return 0;
    final counter = social[counterKey];
    if (counter is num) return counter.toInt();
    final list = social[listKey];
    if (list is Iterable) {
      return list.length;
    }
    return 0;
  }

  Widget _buildItemDetail(ItemEntity item) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        final prevUid = previous is AuthAuthenticated
            ? previous.user.uid
            : null;
        final currUid = current is AuthAuthenticated ? current.user.uid : null;
        return prevUid != currUid;
      },
      listener: (context, state) {
        if (!mounted) return;
        unawaited(_refreshSellerFollowStatus(item.ownerId));
      },
      child: ConfettiOverlay(
        show: _showConfetti,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              _buildImageGallery(item),
              SliverToBoxAdapter(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleSection(item),
                      _buildSellerSection(item),
                      _buildMetricsSection(item),
                      _buildDescriptionSection(item),
                      _buildDetailsSection(item),
                      _buildLocationSection(item),
                      _buildReviewsSection(),
                      _buildOtherItemsSection(),
                      const SizedBox(height: 88),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildActionBar(item),
        ),
      ),
    );
  }

  Widget _buildImageGallery(ItemEntity item) {
    final images = item.images.isNotEmpty ? item.images : [_fallbackImage];

    return SliverAppBar(
      expandedHeight: 360,
      pinned: true,
      backgroundColor: Colors.black,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              _isFavorited ? Icons.favorite : Icons.favorite_border,
              color: _isFavorited ? Colors.red : Colors.black,
            ),
            onPressed: () => _onFavoritePressed(item),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.ios_share, color: Colors.black),
            onPressed: () => _shareItem(item),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            PhotoViewGallery.builder(
              itemCount: images.length,
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(images[index]),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                );
              },
              onPageChanged: (index) =>
                  setState(() => _currentImageIndex = index),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (index) {
                  final isActive = _currentImageIndex == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isActive ? 18 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(isActive ? 0.95 : 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(ItemEntity item) {
    final price = item.price ?? item.monetaryValue;
    final original = item.originalPrice;
    final discount = (original != null && price != null && original > 0)
        ? ((1 - (price / original)) * 100).round()
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price != null ? _formatPrice(price) : 'Fiyat paylaşılmadı',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              if (original != null && price != null && original > price) ...[
                const SizedBox(width: 12),
                Text(
                  _formatPrice(original),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
              if (discount != null && discount >= 5) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '-$discount%',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            children: [
              _chip(Icons.category, item.category),
              if (item.condition != null && item.condition!.isNotEmpty)
                _chip(Icons.check_circle, item.condition!),
              if (item.tradePreference != null &&
                  item.tradePreference!.isNotEmpty)
                _chip(Icons.swap_horiz, item.tradePreference!),
              if (item.city != null && item.city!.isNotEmpty)
                _chip(Icons.location_on, item.city!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.grey.shade700),
      label: Text(label, style: TextStyle(color: Colors.grey.shade800)),
      backgroundColor: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildSellerSection(ItemEntity item) {
    if (_sellerLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: _infoCard(
          child: Row(
            children: const [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Expanded(child: Text('Satıcı bilgileri yükleniyor...')),
            ],
          ),
        ),
      );
    }

    if (_sellerError != null && _sellerProfile == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: _infoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Satıcı bilgileri alınamadı',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(_sellerError!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _fetchSellerData(item),
                child: const Text('Tekrar dene'),
              ),
            ],
          ),
        ),
      );
    }

    final profile = _sellerProfile;
    final social = (_sellerDoc?['social'] as Map<String, dynamic>?) ?? {};
    final stats = (_sellerDoc?['stats'] as Map<String, dynamic>?) ?? {};
    final followers =
        _sellerFollowersCount ??
        _extractSocialCount(social, 'followersCount', 'followers');
    final following =
        _sellerFollowingCount ??
        _extractSocialCount(social, 'followingCount', 'following');
    final completedTradesSource =
        stats['completedTrades'] ?? _sellerStats?['tradeCount'] ?? 0;
    final completedTrades = completedTradesSource is num
        ? completedTradesSource.toInt()
        : 0;
    final listingSource = stats['listingCount'];
    final listingCount = listingSource is num
        ? listingSource.toInt()
        : (_otherItems.length + 1);
    final trustScore = (stats['trustScore'] ?? _sellerDoc?['trustScore'] ?? 0)
        .toString();

    final authState = context.watch<AuthBloc>().state;
    final currentUserId = authState is AuthAuthenticated
        ? authState.user.uid
        : null;
    final isOwnListing = currentUserId == item.ownerId;
    final canNavigate = item.ownerId.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GestureDetector(
        onTap: canNavigate ? () => _openSellerProfile(item) : null,
        child: _infoCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: profile?.photoUrl != null
                    ? NetworkImage(profile!.photoUrl!)
                    : null,
                child: profile?.photoUrl == null
                    ? const Icon(Icons.person, size: 28, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          profile?.displayName ?? item.ownerName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (_isTrustedSeller())
                          const Icon(
                            Icons.verified,
                            size: 18,
                            color: Colors.blue,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (profile?.city != null && profile!.city!.isNotEmpty)
                      Text(
                        profile.city!,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _sellerStat(
                          Icons.shopping_bag,
                          'Tamamlanan takas',
                          completedTrades.toString(),
                        ),
                        _sellerStat(
                          Icons.inventory_2,
                          'Aktif ilan',
                          listingCount.toString(),
                        ),
                        _sellerStat(
                          Icons.people,
                          'Takipçi',
                          followers.toString(),
                        ),
                        _sellerStat(
                          Icons.person_add_alt_1,
                          'Takip',
                          following.toString(),
                        ),
                        _sellerStat(Icons.shield, 'Güven skoru', trustScore),
                      ],
                    ),
                    if (!isOwnListing) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed:
                                  (_isFollowingSeller == null ||
                                      _followActionInProgress)
                                  ? null
                                  : () => _toggleFollowSeller(item.ownerId),
                              icon: _followActionInProgress
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      _isFollowingSeller == true
                                          ? Icons.person_remove_alt_1
                                          : Icons.person_add_alt,
                                    ),
                              label: Text(
                                _isFollowingSeller == null
                                    ? 'Yükleniyor...'
                                    : _isFollowingSeller == true
                                    ? 'Takibi bırak'
                                    : 'Takip et',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _startConversationWithSeller(item),
                              icon: const Icon(Icons.message_outlined),
                              label: const Text('Mesaj gönder'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isTrustedSeller() {
    final trust =
        (_sellerDoc?['trustScore'] ?? (_sellerDoc?['stats']?['trustScore']))
            ?.toString();
    if (trust == null) return false;
    final value = double.tryParse(trust) ?? 0;
    return value >= 90;
  }

  Widget _sellerStat(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(
          '$value · $label',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildMetricsSection(ItemEntity item) {
    final postedAgo = _relativeTime(item.createdAt);
    final viewCount = _formatNumber(item.viewCount);
    final favorites = _formatNumber(item.favoriteCount);
    final inquiries = _formatNumber(item.inquiryCount);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: _infoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'İlan performansı',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _metricTile(Icons.visibility, 'Görüntülenme', viewCount),
                _metricTile(
                  Icons.favorite_border,
                  'Favorilere ekleme',
                  favorites,
                ),
                _metricTile(Icons.chat_bubble_outline, 'Mesaj', inquiries),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Yayın tarihi: $postedAgo',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricTile(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade700),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(ItemEntity item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Açıklama',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            (item.description.isNotEmpty
                ? item.description
                : 'Satıcı henüz detay paylaşmadı.'),
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(ItemEntity item) {
    final details = <Map<String, String>>[
      {'label': 'Kategori', 'value': item.category},
      if (item.condition != null && item.condition!.isNotEmpty)
        {'label': 'Durum', 'value': item.condition!},
      if (item.brand != null && item.brand!.isNotEmpty)
        {'label': 'Marka', 'value': item.brand!},
      if (item.size != null && item.size!.isNotEmpty)
        {'label': 'Beden', 'value': item.fullSize ?? item.size!},
      if (item.color != null && item.color!.isNotEmpty)
        {'label': 'Renk', 'value': item.color!},
      if (item.tradePreference != null && item.tradePreference!.isNotEmpty)
        {'label': 'Takas Tercihi', 'value': item.tradePreference!},
      if (item.features != null && item.features!.isNotEmpty)
        {'label': 'Öne çıkan özellikler', 'value': item.features!.join(', ')},
      if (item.meetupLocation != null && item.meetupLocation!.isNotEmpty)
        {'label': 'Buluşma noktası', 'value': item.meetupLocation!},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: _infoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detaylar',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...details.map(
              (detail) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        detail['label']!,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        detail['value']!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(ItemEntity item) {
    final meetupPoints = item.preferredMeetupPoints ?? [];
    final locationLabel = _locationLabel(item) ?? 'Konum belirtilmedi';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: _infoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Konum & Teslimat',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue.shade600, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    locationLabel,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                if (item.latitude != null && item.longitude != null)
                  TextButton(
                    onPressed: () => _openMap(item),
                    child: const Text('Haritada aç'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Teslimat seçenekleri',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: [
                if (item.shippingAvailable) _tag('Kargo uygun'),
                if (item.localPickupOnly) _tag('Sadece elden teslim'),
                if (meetupPoints.isNotEmpty) _tag('Güvenli buluşma noktası'),
              ],
            ),
            if (meetupPoints.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Satıcının önerdiği buluşma noktaları',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(height: 6),
              ...meetupPoints.map(
                (point) => Padding(
                  padding: const EdgeInsets.only(left: 4, top: 2),
                  child: Text('• $point', style: const TextStyle(fontSize: 13)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: Colors.grey.shade800),
      ),
    );
  }

  Widget _buildReviewsSection() {
    final averageRating = (_sellerStats?['averageRating'] ?? 0).toDouble();
    final totalReviews = (_sellerStats?['ratingCount'] ?? 0) as int;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: _infoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Son değerlendirmeler',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Icon(Icons.star, size: 18, color: Colors.amber.shade600),
                const SizedBox(width: 4),
                Text(
                  '${averageRating.toStringAsFixed(1)} • $totalReviews yorum',
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_ratings.isEmpty)
              Text(
                'Henüz değerlendirme yapılmamış.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              )
            else
              Column(children: _ratings.map(_reviewTile).toList()),
          ],
        ),
      ),
    );
  }

  Widget _reviewTile(RatingEntity rating) {
    final reviewer = rating.fromUserId;
    final resolved = _ratingAuthors[reviewer];
    final shortName = resolved ?? '@${_truncateId(reviewer)}';
    final date = _relativeTime(rating.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: Text(rating.rating.toString()),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shortName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rating.rating
                              ? Icons.star
                              : Icons.star_border,
                          size: 14,
                          color: Colors.amber.shade600,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Text(
                date,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              ),
            ],
          ),
          if (rating.comment != null && rating.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(rating.comment!, style: const TextStyle(fontSize: 13)),
          ],
        ],
      ),
    );
  }

  Widget _buildOtherItemsSection() {
    if (_otherItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              'Satıcının diğer ürünleri',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 360,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final item = _otherItems[index];
                final imageUrl = item.images.isNotEmpty
                    ? item.images.first
                    : _fallbackImage;
                return SizedBox(
                  width: 220,
                  child: PremiumItemCard(
                    imageUrl: imageUrl,
                    title: item.title,
                    username: _sellerHandle(item),
                    price: item.price,
                    condition: item.condition ?? 'Belirtilmedi',
                    distance: _locationLabel(item),
                    viewCount: item.viewCount,
                    showFavoriteButton: false,
                    onTap: () => AppRouter.toItemDetail(context, item.id),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: _otherItems.length,
            ),
          ),
        ],
      ),
    );
  }

  void _openSellerProfile(ItemEntity item) {
    final sellerId = item.ownerId.trim();
    if (sellerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Satıcı profiline ulaşılamadı.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    AppRouter.toUserProfile(context, sellerId);
  }

  void _openMap(ItemEntity item) {
    if (item.latitude == null || item.longitude == null) {
      _showSnackMessage('Konum bilgisi bulunamadı.', isError: true);
      return;
    }

    final itemBloc = context.read<ItemBloc>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            BlocProvider.value(value: itemBloc, child: const MapViewPage()),
      ),
    );
  }

  String? _sellerHandle(ItemEntity item) {
    final name = item.ownerName.trim();
    if (name.isNotEmpty && name.toLowerCase() != 'unknown') {
      return name;
    }

    final fallback = item.ownerId.trim();
    if (fallback.isEmpty) return null;
    return fallback;
  }

  void _startConversationWithSeller(ItemEntity item) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      _showSnackMessage(
        'Mesaj göndermek için giriş yapmalısınız.',
        isError: true,
      );
      return;
    }

    if (authState.user.uid == item.ownerId) {
      _showSnackMessage('Kendi ilanınıza mesaj gönderemezsiniz.');
      return;
    }

    final chatBloc = getIt<ChatBloc>();
    _chatSubscription?.cancel();

    _chatSubscription = chatBloc.stream.listen((state) {
      if (!mounted) {
        _chatSubscription?.cancel();
        return;
      }

      if (state is ConversationRetrieved) {
        _dismissConversationDialog();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: chatBloc,
              child: ChatDetailPage(
                conversation: state.conversation,
                initialMessage: _composeInitialMessage(item),
              ),
            ),
          ),
        );

        _chatSubscription?.cancel();
        _chatSubscription = null;
      } else if (state is ChatError) {
        _dismissConversationDialog();
        _showSnackMessage(
          state.message.isNotEmpty
              ? state.message
              : 'Mesaj başlatılamadı. Lütfen tekrar deneyin.',
          isError: true,
        );
        _chatSubscription?.cancel();
        _chatSubscription = null;
      }
    });

    _showConversationDialog();

    chatBloc.add(
      GetOrCreateConversation(
        userId: authState.user.uid,
        otherUserId: item.ownerId,
        listingId: item.id,
      ),
    );
  }

  void _openTradeOffer(ItemEntity item) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      _showSnackMessage(
        'Takas teklifi göndermek için giriş yapmalısınız.',
        isError: true,
      );
      return;
    }

    if (authState.user.uid == item.ownerId) {
      _showSnackMessage('Kendi ilanınıza takas teklifi yapamazsınız.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<AuthBloc>()),
            BlocProvider(create: (_) => getIt<ItemBloc>()),
            BlocProvider(create: (_) => getIt<TradeBloc>()),
          ],
          child: SendTradeOfferPage(requestedItem: item),
        ),
      ),
    );
  }

  void _showConversationDialog() {
    if (_isConversationDialogVisible || !mounted) {
      return;
    }

    _isConversationDialogVisible = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const Dialog(
        backgroundColor: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Mesaj başlatılıyor...'),
            ],
          ),
        ),
      ),
    ).whenComplete(() {
      if (mounted) {
        _isConversationDialogVisible = false;
      }
    });
  }

  void _dismissConversationDialog() {
    if (!_isConversationDialogVisible || !mounted) {
      return;
    }

    _isConversationDialogVisible = false;
    Navigator.of(context, rootNavigator: true).pop();
  }

  String _composeInitialMessage(ItemEntity item) {
    final name = item.ownerName.trim();
    final hasName = name.isNotEmpty && name.toLowerCase() != 'unknown';
    final greeting = hasName ? 'Merhaba $name!' : 'Merhaba!';
    final title = item.title.trim();
    final listingLabel = title.isEmpty ? 'ilanınız' : '"$title" ilanınız';
    return '$greeting $listingLabel ile ilgileniyorum. Detayları konuşabilir miyiz?';
  }

  Widget _buildActionBar(ItemEntity item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: IconButton(
                icon: Icon(
                  _isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorited ? Colors.red : Colors.grey.shade700,
                ),
                onPressed: () => _onFavoritePressed(item),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _startConversationWithSeller(item),
                icon: const Icon(Icons.message_outlined),
                label: const Text('Mesaj gönder'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: GradientButton(
                text: 'Takas teklifi yap',
                icon: Icons.swap_horiz,
                onPressed: () => _openTradeOffer(item),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  String? _locationLabel(ItemEntity item) {
    if (item.city != null && item.city!.isNotEmpty) {
      return item.city;
    }
    if (item.fullAddress != null && item.fullAddress!.isNotEmpty) {
      return item.fullAddress;
    }
    if (item.district != null && item.district!.isNotEmpty) {
      return item.district;
    }
    if (item.location != null && item.location!.isNotEmpty) {
      return item.location;
    }
    return null;
  }

  String _formatPrice(double value) {
    final formatted = value.toStringAsFixed(0);
    return '₺$formatted';
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

  String _formatNumber(int value) {
    if (value >= 1000000) {
      final formatted = (value / 1000000).toStringAsFixed(1);
      final compact = formatted.endsWith('.0')
          ? formatted.substring(0, formatted.length - 2)
          : formatted;
      return '${compact}M';
    }
    if (value >= 1000) {
      final formatted = (value / 1000).toStringAsFixed(1);
      final compact = formatted.endsWith('.0')
          ? formatted.substring(0, formatted.length - 2)
          : formatted;
      return '${compact}K';
    }
    return value.toString();
  }
}
