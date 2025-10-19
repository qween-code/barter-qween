// 🔍 WORLD CLASS EXPLORE PAGE
// Visual Search + Voice Search + Smart Filters

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/theme/world_class_components.dart';
import '../../../domain/entities/item_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../blocs/item/item_bloc.dart';
import '../../blocs/item/item_event.dart';
import '../../blocs/item/item_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/favorite/favorite_bloc.dart';
import '../../blocs/favorite/favorite_event.dart';
import '../../blocs/favorite/favorite_state.dart';

const _placeholderImage =
    'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&auto=format&fit=crop';

class WorldClassExplorePage extends StatefulWidget {
  final String? initialCategory;

  const WorldClassExplorePage({Key? key, this.initialCategory})
    : super(key: key);

  @override
  State<WorldClassExplorePage> createState() => _WorldClassExplorePageState();
}

class _WorldClassExplorePageState extends State<WorldClassExplorePage> {
  final TextEditingController _searchController = TextEditingController();
  late final ItemBloc _exploreBloc;
  List<ItemEntity> _items = [];
  String _searchTerm = '';
  UserEntity? _currentUser;
  String? _lastUserId;
  bool _hasUserSynced = false;
  double _maxDistance = 5;

  String _selectedCategory = 'All';
  String _selectedCondition = 'All';
  String _sortBy = 'Recent';

  List<String> _categories = [
    'All',
    'Electronics',
    'Fashion',
    'Books',
    'Gaming',
    'Home',
    'Sports',
  ];

  @override
  void initState() {
    super.initState();
    _exploreBloc = getIt<ItemBloc>()..add(const LoadAllItems());
    _searchController.addListener(_onSearchChanged);

    final incomingCategory = widget.initialCategory;
    if (incomingCategory != null && incomingCategory.trim().isNotEmpty) {
      final normalized = incomingCategory.trim();
      if (!_categories.contains(normalized)) {
        _categories = [
          'All',
          normalized,
          ..._categories.where((category) => category != 'All'),
        ];
      }
      _selectedCategory = normalized;
      Future.microtask(() => _loadItemsForCategory(_selectedCategory));
    }
  }

  void _handleAuthState(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      final userChanged = state.user.uid != _lastUserId;
      setState(() {
        _currentUser = state.user;
        _lastUserId = state.user.uid;
      });
      if (userChanged || !_hasUserSynced) {
        _hasUserSynced = true;
        _loadItemsForCategory(_selectedCategory);
      }
    } else if (state is AuthUnauthenticated) {
      if (_currentUser != null) {
        setState(() {
          _currentUser = null;
          _lastUserId = null;
          _hasUserSynced = false;
          _maxDistance = 5;
        });
        _exploreBloc.add(const LoadAllItems());
      }
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _exploreBloc.close();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchTerm = _searchController.text.trim().toLowerCase();
    });
  }

  void _loadItemsForCategory(String category) {
    final categoryFilter = category == 'All' ? null : category;

    if (_currentUser != null) {
      final filters = <String, dynamic>{};
      if (categoryFilter != null) filters['category'] = categoryFilter;
      if (_selectedCondition != 'All') {
        filters['condition'] = _selectedCondition;
      }
      if (_currentUser!.city != null && _currentUser!.city!.isNotEmpty) {
        filters['city'] = _currentUser!.city;
      }
      if (_currentUser!.latitude != null && _currentUser!.longitude != null) {
        filters['latitude'] = _currentUser!.latitude;
        filters['longitude'] = _currentUser!.longitude;
        filters['maxDistance'] = _maxDistance;
      }

      _exploreBloc.add(FilterItems(filters));
    } else {
      _exploreBloc.add(LoadAllItems(category: categoryFilter));
    }
  }

  Future<void> _refreshItems() async {
    _loadItemsForCategory(_selectedCategory);
  }

  List<ItemEntity> _applyFilters() {
    var filtered = [..._items];

    final currentUserId = _currentUser?.uid;
    if (currentUserId != null && currentUserId.isNotEmpty) {
      filtered = filtered
          .where((item) => item.ownerId.trim() != currentUserId)
          .toList();
    }

    if (_selectedCategory != 'All') {
      filtered = filtered
          .where(
            (item) =>
                (item.category).toLowerCase() ==
                _selectedCategory.toLowerCase(),
          )
          .toList();
    }

    if (_selectedCondition != 'All') {
      filtered = filtered
          .where(
            (item) =>
                (item.condition ?? '').toLowerCase() ==
                _selectedCondition.toLowerCase(),
          )
          .toList();
    }

    if (_searchTerm.isNotEmpty) {
      filtered = filtered.where((item) {
        final title = item.title.toLowerCase();
        final description = item.description.toLowerCase();
        return title.contains(_searchTerm) || description.contains(_searchTerm);
      }).toList();
    }

    return _applySort(filtered);
  }

  List<ItemEntity> _applySort(List<ItemEntity> items) {
    final sorted = [...items];

    switch (_sortBy) {
      case 'Popular':
        sorted.sort((a, b) => b.viewCount.compareTo(a.viewCount));
        break;
      case 'Distance':
        sorted.sort((a, b) {
          final distA = _distanceToUser(a);
          final distB = _distanceToUser(b);
          return distA.compareTo(distB);
        });
        break;
      case 'Match Score':
        sorted.sort((a, b) => b.favoriteCount.compareTo(a.favoriteCount));
        break;
      case 'Recent':
      default:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return sorted;
  }

  Widget _buildItemsSection(
    List<ItemEntity> items,
    ItemState state,
    bool isInitialLoading,
  ) {
    if (isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ItemError && items.isEmpty) {
      return _buildErrorPlaceholder(state.message);
    }

    if (items.isEmpty) {
      return _buildEmptyPlaceholder('Aramanızla eşleşen sonuç bulunamadı.');
    }

    return RefreshIndicator(
      onRefresh: _refreshItems,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.58,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) => _buildItemTile(items[index]),
      ),
    );
  }

  Widget _buildItemTile(ItemEntity item) {
    final imageUrl = item.images.isNotEmpty
        ? item.images.first
        : _placeholderImage;
    final locationLabel = _locationLabel(item);
    final distanceLabel = _distanceLabel(item);
    final infoLabel = (locationLabel != null && locationLabel.trim().isNotEmpty)
        ? locationLabel
        : distanceLabel;

    return BlocBuilder<FavoriteBloc, FavoriteState>(
      builder: (context, state) {
        final favoriteBloc = context.read<FavoriteBloc>();
        final isFavorited = favoriteBloc.isFavorited(item.id);
        return PremiumItemCard(
          imageUrl: imageUrl,
          title: item.title,
          username: _sellerLabel(item),
          price: item.price,
          condition: item.condition ?? 'Belirtilmedi',
          distance: infoLabel,
          viewCount: item.viewCount,
          isVerified: false,
          isFavorited: isFavorited,
          onTap: () => AppRouter.toItemDetail(context, item.id),
          onFavorite: () => _toggleFavorite(item),
        );
      },
    );
  }

  String? _sellerLabel(ItemEntity item) {
    final name = item.ownerName.trim();
    if (name.isNotEmpty && name.toLowerCase() != 'unknown') {
      return name;
    }
    final fallback = item.ownerId.trim();
    if (fallback.isEmpty) return null;
    return fallback;
  }

  String? _locationLabel(ItemEntity item) {
    if (item.city != null && item.city!.isNotEmpty) {
      return item.city;
    }
    if (item.fullAddress != null && item.fullAddress!.isNotEmpty) {
      return item.fullAddress;
    }
    if (item.location != null && item.location!.isNotEmpty) {
      return item.location;
    }
    if (item.district != null && item.district!.isNotEmpty) {
      return item.district;
    }
    return null;
  }

  String? _distanceLabel(ItemEntity item) {
    final distanceKm = _distanceToUser(item);
    if (!distanceKm.isFinite) return null;
    if (distanceKm >= 10) {
      return '${distanceKm.round()} km';
    }
    if (distanceKm <= 0) {
      return null;
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  void _toggleFavorite(ItemEntity item) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Favorilere eklemek için giriş yapmalısınız'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final favoriteBloc = context.read<FavoriteBloc>();
    final wasFavorited = favoriteBloc.isFavorited(item.id);
    favoriteBloc.add(ToggleFavorite(item.id));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasFavorited ? 'Favorilerden çıkarıldı' : 'Favorilere eklendi',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  double _distanceToUser(ItemEntity item) {
    final userLat = _currentUser?.latitude;
    final userLng = _currentUser?.longitude;
    if (userLat == null || userLng == null) {
      return double.infinity;
    }
    if (item.latitude == null || item.longitude == null) {
      return double.infinity;
    }
    return _calculateDistance(
      userLat,
      userLng,
      item.latitude!,
      item.longitude!,
    );
  }

  double _calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = _degreesToRadians(endLat - startLat);
    final dLon = _degreesToRadians(endLng - startLng);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(startLat)) *
            cos(_degreesToRadians(endLat)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) => degrees * pi / 180;

  Widget _buildErrorPlaceholder(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _refreshItems(),
            child: const Text('Tekrar dene'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPlaceholder(String message) {
    return Center(
      child: Text(message, style: TextStyle(color: Colors.grey.shade600)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: _handleAuthState,
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<ItemBloc, ItemState>(
            bloc: _exploreBloc,
            builder: (context, state) {
              if (state is ItemsLoaded) {
                _items = state.items;
              }

              final isInitialLoading = state is ItemLoading && _items.isEmpty;
              final visibleItems = _applyFilters();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SmartSearchBar(
                      controller: _searchController,
                      onVoiceSearch: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🎤 Voice search coming soon!'),
                          ),
                        );
                      },
                      onCameraSearch: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('📸 Visual search coming soon!'),
                          ),
                        );
                      },
                      onFilterTap: _showFilters,
                      onChanged: (_) => _onSearchChanged(),
                    ),
                  ),

                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = category == _selectedCategory;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() => _selectedCategory = category);
                              _loadItemsForCategory(category);
                            },
                            selectedColor: Theme.of(context).primaryColor,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${visibleItems.length} items',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        DropdownButton<String>(
                          value: _sortBy,
                          underline: const SizedBox(),
                          items:
                              const [
                                    'Recent',
                                    'Popular',
                                    'Distance',
                                    'Match Score',
                                  ]
                                  .map(
                                    (sort) => DropdownMenuItem(
                                      value: sort,
                                      child: Text(sort),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _sortBy = value);
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: _buildItemsSection(
                      visibleItems,
                      state,
                      isInitialLoading,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        floatingActionButton: PulsingFAB(
          onPressed: () => AppRouter.toAddItem(context),
          icon: Icons.add,
          heroTag: 'explore-fab',
        ),
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = 'All';
                            _selectedCondition = 'All';
                            _sortBy = 'Recent';
                            _maxDistance = 5;
                          });
                          _loadItemsForCategory('All');
                          Navigator.pop(context);
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Condition
                  const Text(
                    'Condition',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['All', 'Brand New', 'Like New', 'Good', 'Fair']
                        .map((condition) {
                          return FilterChip(
                            label: Text(condition),
                            selected: _selectedCondition == condition,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCondition = condition;
                              });
                            },
                          );
                        })
                        .toList(),
                  ),

                  const SizedBox(height: 24),

                  // Distance
                  const Text(
                    'Distance',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: _maxDistance,
                    min: 1,
                    max: 30,
                    divisions: 29,
                    label: '${_maxDistance.round()} km',
                    onChanged: (value) {
                      setState(() {
                        _maxDistance = value;
                      });
                    },
                  ),
                  Text(
                    'Within ${_maxDistance.round()} km',
                    style: TextStyle(color: Colors.grey[600]),
                  ),

                  const SizedBox(height: 24),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _loadItemsForCategory(_selectedCategory);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
