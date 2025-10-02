import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../domain/entities/item_entity.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/favorite/favorite_bloc.dart';
import '../../blocs/favorite/favorite_event.dart';
import '../../blocs/favorite/favorite_state.dart';
import '../../blocs/item/item_bloc.dart';
import '../../blocs/item/item_event.dart';
import '../../blocs/item/item_state.dart';
import 'create_item_page.dart';
import 'item_detail_page.dart';

class ItemListPage extends StatefulWidget {
  const ItemListPage({super.key});

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  bool _isGridView = true;
  String? _selectedCategory;
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;
  
  // Filter states
  String? _selectedCondition;
  RangeValues _priceRange = const RangeValues(0, 10000);
  double _maxDistance = 50.0;
  bool _showOnlyActive = true;

  @override
  void initState() {
    super.initState();
    context.read<ItemBloc>().add(const LoadAllItems());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(context),
          _buildSearchBar(),
          _buildCategoryFilter(),
          _buildItemsList(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => getIt<ItemBloc>(),
                child: const CreateItemPage(),
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Item'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Discover Items',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.1),
                Theme.of(context).primaryColor.withOpacity(0.05),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isGridView ? Icons.view_list : Icons.grid_view,
            color: Colors.black87,
          ),
          onPressed: () {
            setState(() {
              _isGridView = !_isGridView;
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.black87),
          onPressed: _showFilterBottomSheet,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    final categories = [
      {'name': 'All', 'icon': Icons.apps},
      {'name': 'Electronics', 'icon': Icons.devices},
      {'name': 'Fashion', 'icon': Icons.checkroom},
      {'name': 'Home', 'icon': Icons.home},
      {'name': 'Books', 'icon': Icons.book},
      {'name': 'Sports', 'icon': Icons.sports_soccer},
      {'name': 'Toys', 'icon': Icons.toys},
    ];

    return SliverToBoxAdapter(
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = _selectedCategory == category['name'] ||
                (_selectedCategory == null && category['name'] == 'All');

            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category['name'] == 'All'
                        ? null
                        : category['name'] as String;
                  });
                  context.read<ItemBloc>().add(LoadAllItems(
                        category: _selectedCategory,
                      ));
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        category['icon'] as IconData,
                        color: isSelected ? Colors.white : Colors.black54,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Flexible(
                      child: Text(
                        category['name'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.black54,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            // Cancel previous timer
            if (_debounce?.isActive ?? false) _debounce!.cancel();
            
            setState(() {
              _searchQuery = value.toLowerCase();
            });
            
            // Start new timer for debouncing
            _debounce = Timer(const Duration(milliseconds: 500), () {
              // Only search if query is not empty and has at least 2 characters
              if (value.trim().isNotEmpty && value.trim().length >= 2) {
                print('🔍 Performing search: ${value.trim()}');
                context.read<ItemBloc>().add(SearchItems(value.trim()));
              } else if (value.trim().isEmpty) {
                // Reload all items if search is cleared
                context.read<ItemBloc>().add(LoadAllItems(category: _selectedCategory));
              }
            });
          },
          decoration: InputDecoration(
            hintText: 'Search items (min 2 characters)...',
            helperText: 'Type at least 2 characters to search',
            helperStyle: const TextStyle(fontSize: 11),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                      // Reload all items when search is cleared
                      context.read<ItemBloc>().add(LoadAllItems(category: _selectedCategory));
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  // Remove client-side filtering since we now use server-side search
  List<ItemEntity> _filterItems(List<ItemEntity> items) {
    // Simply return all items - filtering is done server-side via SearchItems event
    return items;
  }

  Widget _buildItemsList() {
    return BlocBuilder<ItemBloc, ItemState>(
      builder: (context, state) {
        if (state is ItemLoading) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ItemError) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ItemBloc>().add(const LoadAllItems());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is ItemsLoaded) {
          final filteredItems = _filterItems(state.items);
          
          if (filteredItems.isEmpty) {
            return SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isNotEmpty ? 'No items match your search' : 'No items found',
                      style: const TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _searchQuery.isNotEmpty ? 'Try different keywords' : 'Be the first to create an item!',
                      style: const TextStyle(fontSize: 14, color: Colors.black38),
                    ),
                  ],
                ),
              ),
            );
          }

          return _isGridView
              ? _buildGridView(filteredItems)
              : _buildListView(filteredItems);
        }

        return const SliverFillRemaining(
          child: Center(child: Text('Start browsing items')),
        );
      },
    );
  }

  Widget _buildGridView(List<ItemEntity> items) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildGridItem(items[index]),
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _buildGridItem(ItemEntity item) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with buttons overlay
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: item.images.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: item.images.first,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (context, url) => Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey.shade200,
                              child: Icon(Icons.image_not_supported,
                                  size: 40, color: Colors.grey.shade400),
                            ),
                          )
                        : Container(
                            color: Colors.grey.shade200,
                            child: Icon(Icons.inventory_2_outlined,
                                size: 40, color: Colors.grey.shade400),
                          ),
                  ),
                  // Favorite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: BlocBuilder<FavoriteBloc, FavoriteState>(
                      builder: (context, state) {
                        final isFavorited = context.read<FavoriteBloc>().isFavorited(item.id);
                        return GestureDetector(
                          onTap: () => _toggleFavorite(item.id),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              isFavorited ? Icons.favorite : Icons.favorite_border,
                              color: isFavorited ? Colors.red : Colors.grey.shade700,
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Quick look button
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _showQuickLook(item),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.visibility_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.category,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.location_on,
                            size: 12, color: Colors.grey.shade600),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            item.city ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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

  Widget _buildListView(List<ItemEntity> items) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildListItem(items[index]),
          childCount: items.length,
        ),
      ),
    );
  }

  Widget _buildListItem(ItemEntity item) {
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
        margin: const EdgeInsets.only(bottom: 16),
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
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(16)),
              child: item.images.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.images.first,
                      fit: BoxFit.cover,
                      width: 120,
                      height: 120,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade200,
                        child: Icon(Icons.image_not_supported,
                            size: 40, color: Colors.grey.shade400),
                      ),
                    )
                  : Container(
                      width: 120,
                      height: 120,
                      color: Colors.grey.shade200,
                      child: Icon(Icons.inventory_2_outlined,
                          size: 40, color: Colors.grey.shade400),
                    ),
            ),
            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.category,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.location_on,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            item.city ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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

  void _toggleFavorite(String itemId) {
    final authBloc = context.read<AuthBloc>();
    if (authBloc.state is AuthAuthenticated) {
      final authState = authBloc.state as AuthAuthenticated;
      context.read<FavoriteBloc>().add(
        ToggleFavorite(authState.user.uid, itemId),
      );
    }
  }

  void _showQuickLook(ItemEntity item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Image
                if (item.images.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: item.images.first,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.category,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            item.city ?? 'Unknown',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
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
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('View Full Details'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter Options',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          _selectedCondition = null;
                          _priceRange = const RangeValues(0, 10000);
                          _maxDistance = 50.0;
                          _showOnlyActive = true;
                        });
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Condition Filter
                const Text(
                  'Condition',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: ['New', 'Like New', 'Good', 'Fair', 'Poor'].map((condition) {
                    final isSelected = _selectedCondition == condition;
                    return FilterChip(
                      label: Text(condition),
                      selected: isSelected,
                      onSelected: (selected) {
                        setModalState(() {
                          _selectedCondition = selected ? condition : null;
                        });
                      },
                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      checkmarkColor: Theme.of(context).primaryColor,
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 24),
                
                // Price Range Filter
                const Text(
                  'Price Range (Estimated Value)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 10000,
                  divisions: 100,
                  labels: RangeLabels(
                    '₺${_priceRange.start.round()}',
                    '₺${_priceRange.end.round()}',
                  ),
                  onChanged: (values) {
                    setModalState(() {
                      _priceRange = values;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('₺${_priceRange.start.round()}'),
                    Text('₺${_priceRange.end.round()}'),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Distance Filter
                const Text(
                  'Maximum Distance',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Slider(
                  value: _maxDistance,
                  min: 5,
                  max: 100,
                  divisions: 19,
                  label: '${_maxDistance.round()} km',
                  onChanged: (value) {
                    setModalState(() {
                      _maxDistance = value;
                    });
                  },
                ),
                Text(
                  '${_maxDistance.round()} km',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                
                const SizedBox(height: 24),
                
                // Show only active items
                SwitchListTile(
                  title: const Text('Show only active items'),
                  subtitle: Text(
                    'Hide traded or inactive items',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  value: _showOnlyActive,
                  onChanged: (value) {
                    setModalState(() {
                      _showOnlyActive = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                
                const SizedBox(height: 20),
                
                // Apply button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // Apply filters
                      });
                      Navigator.pop(context);
                      _applyFilters();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
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
        ),
      ),
    );
  }
  
  void _applyFilters() {
    // Reload items with filters applied
    context.read<ItemBloc>().add(LoadAllItems(
      category: _selectedCategory,
    ));
    // Additional filtering logic can be added in the bloc
  }
}
