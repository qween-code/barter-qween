import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/analytics_service.dart';
import '../../../domain/entities/item_entity.dart';
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
import '../profile/user_profile_page.dart';
import '../trades/send_trade_offer_page.dart';
import 'edit_item_page.dart';

class ItemDetailPage extends StatefulWidget {
  final String itemId;

  const ItemDetailPage({super.key, required this.itemId});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    context.read<ItemBloc>().add(LoadItem(widget.itemId));
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUserId = authState.user.uid;
    }
    
    // Log item view
    try {
      getIt<AnalyticsService>().logItemViewed(itemId: widget.itemId);
    } catch (_) {}
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<ItemBloc, ItemState>(
        builder: (context, state) {
          if (state is ItemLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ItemError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          if (state is ItemLoaded) {
            return _buildItemDetail(context, state.item);
          }

          return const Center(child: Text('Loading...'));
        },
      ),
    );
  }

  Widget _buildItemDetail(BuildContext context, ItemEntity item) {
    return CustomScrollView(
      slivers: [
        _buildImageCarousel(item),
        _buildItemInfo(item),
      ],
    );
  }

  Widget _buildImageCarousel(ItemEntity item) {
    final images = item.images.isNotEmpty ? item.images : [];

    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share, color: Colors.white, size: 20),
          ),
          onPressed: () => _shareItem(item),
        ),
        BlocBuilder<FavoriteBloc, FavoriteState>(
          builder: (context, favoriteState) {
            final favoriteBloc = context.read<FavoriteBloc>();
            final isFavorited = favoriteBloc.isFavorited(item.id);
            
            return IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: isFavorited ? Colors.red : Colors.white,
                  size: 20,
                ),
              ),
              onPressed: () => _toggleFavorite(context, item.id),
            );
          },
        ),
        if (_currentUserId != null && _currentUserId == item.ownerId)
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 20),
            ),
            onPressed: () => _editItem(context, item),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: images.isEmpty
            ? Container(
                color: Colors.grey.shade200,
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 100,
                  color: Colors.grey.shade400,
                ),
              )
            : Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: images[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.image_not_supported,
                            size: 60,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      );
                    },
                  ),
                  if (images.length > 1)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildItemInfo(ItemEntity item) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Category
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildChip(
                        label: item.category,
                        icon: Icons.category,
                        color: Theme.of(context).primaryColor,
                      ),
                      _buildChip(
                        label: item.condition ?? 'Good',
                        icon: Icons.new_releases,
                        color: Colors.green,
                      ),
                      _buildChip(
                        label: item.status.toString().split('.').last,
                        icon: Icons.check_circle,
                        color: Colors.blue,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          color: Colors.red.shade400, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${item.city ?? "Unknown City"}',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Stats
                  Row(
                    children: [
                      _buildStatItem(
                        icon: Icons.visibility,
                        label: 'Views',
                        value: '${item.viewCount}',
                      ),
                      const SizedBox(width: 24),
                      _buildStatItem(
                        icon: Icons.access_time,
                        label: 'Posted',
                        value: _formatDate(item.createdAt),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Contact Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MultiBlocProvider(
                                  providers: [
                                    BlocProvider(create: (_) => getIt<TradeBloc>()),
                                    BlocProvider(create: (_) => getIt<ItemBloc>()),
                                  ],
                                  child: SendTradeOfferPage(requestedItem: item),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.swap_horiz),
                          label: const Text('Trade Offer'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () => _startConversation(context, item),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Icon(Icons.chat_bubble_outline),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Owner Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.ownerName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'Member since ${_formatDate(item.createdAt)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () => _viewOwnerProfile(context, item.ownerId),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Profile'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _shareItem(ItemEntity item) {
    final String shareText = '''
🎁 Check out this item on Barter Qween!

${item.title}

📦 Category: ${item.category}
📍 Location: ${item.city ?? 'Unknown'}
💫 Condition: ${item.condition ?? 'Good'}

${item.description}

🔗 View more details in the app!
''';
    Share.share(shareText);
  }

  Future<void> _editItem(BuildContext context, ItemEntity item) async {
    final itemBloc = context.read<ItemBloc>();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: itemBloc,
          child: EditItemPage(item: item),
        ),
      ),
    );

    if (result != null) {
      // Reload item after edit
      itemBloc.add(LoadItem(item.id));
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _toggleFavorite(BuildContext context, String itemId) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final favoriteBloc = context.read<FavoriteBloc>();
      final wasFavorited = favoriteBloc.isFavorited(itemId);
      
      favoriteBloc.add(ToggleFavorite(authState.user.uid, itemId));
      
      // Log analytics
      try {
        getIt<AnalyticsService>().logFavoriteToggled(itemId: itemId, added: !wasFavorited);
      } catch (_) {}
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasFavorited
                ? 'Removed from favorites'
                : 'Added to favorites',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _viewOwnerProfile(BuildContext context, String ownerId) {
    // Log analytics
    try {
      getIt<AnalyticsService>().logProfileViewed(profileUserId: ownerId);
    } catch (_) {}
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfilePage(userId: ownerId),
      ),
    );
  }

  void _startConversation(BuildContext context, ItemEntity item) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to send messages'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final currentUserId = authState.user.uid;
    final targetUserId = item.ownerId;

    // Don't allow messaging yourself
    if (currentUserId == targetUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot message yourself'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    print('💬 Starting conversation about item: ${item.title}');
    
    // Create ChatBloc and get or create conversation
    final chatBloc = getIt<ChatBloc>();
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => WillPopScope(
        onWillPop: () async => false,
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
    );

    // Listen to ChatBloc stream
    chatBloc.stream.listen((state) {
      print('💬 Chat state: ${state.runtimeType}');
      
      if (state is ConversationRetrieved) {
        // Close loading dialog
        Navigator.of(context, rootNavigator: true).pop();
        
        // Create initial message with item info
        final initialMessage = """👋 Hi! I'm interested in your item:

📍 "${item.title}"
🏷️ Category: ${item.category}
📍 Location: ${item.city ?? 'Unknown'}

Can you tell me more about it?""";
        
        // Navigate to chat with initial message
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: chatBloc,
              child: ChatDetailPage(
                conversation: state.conversation,
                initialMessage: initialMessage,
              ),
            ),
          ),
        );
      } else if (state is ChatError) {
        // Close loading dialog
        Navigator.of(context, rootNavigator: true).pop();
        
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start conversation: ${state.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    // Trigger event after setting up listener
    chatBloc.add(GetOrCreateConversation(
      userId: currentUserId,
      otherUserId: targetUserId,
      listingId: item.id,
    ));
  }
}
