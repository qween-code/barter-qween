import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/world_class_design_system.dart';
import '../../blocs/item/item_bloc.dart';
import '../../blocs/item/item_event.dart';
import '../../blocs/item/item_state.dart';

class WorldClassMessagesPage extends StatefulWidget {
  const WorldClassMessagesPage({Key? key}) : super(key: key);

  @override
  State<WorldClassMessagesPage> createState() => _WorldClassMessagesPageState();
}

class _WorldClassMessagesPageState extends State<WorldClassMessagesPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  String _searchQuery = '';
  String _selectedFilter = 'all';

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
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WorldClassDesignSystem.primaryBackground,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildAppBar(),
              _buildSearchBar(),
              _buildFilterChips(),
              Expanded(
                child: _buildMessagesList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Text(
            'Messages',
            style: WorldClassDesignSystem.headingLarge.copyWith(
              color: WorldClassDesignSystem.primaryText,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              // TODO: Implement new message
            },
            icon: Icon(
              Icons.add_comment,
              color: WorldClassDesignSystem.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: WorldClassDesignSystem.bodyMedium.copyWith(
          color: WorldClassDesignSystem.primaryText,
        ),
        decoration: InputDecoration(
          hintText: 'Search messages...',
          hintStyle: WorldClassDesignSystem.bodyMedium.copyWith(
            color: WorldClassDesignSystem.secondaryText,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: WorldClassDesignSystem.secondaryText,
          ),
          filled: true,
          fillColor: WorldClassDesignSystem.cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(WorldClassDesignSystem.radiusMedium),
            borderSide: BorderSide(
              color: WorldClassDesignSystem.primaryColor,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'value': 'all', 'label': 'All'},
      {'value': 'unread', 'label': 'Unread'},
      {'value': 'negotiations', 'label': 'Negotiations'},
      {'value': 'trades', 'label': 'Trades'},
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter['value'];
          
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(filter['label']!),
              selected: isSelected,
              onSelected: (selected) {
                _onFilterChanged(filter['value']!);
              },
              selectedColor: WorldClassDesignSystem.primaryColor.withOpacity(0.2),
              checkmarkColor: WorldClassDesignSystem.primaryColor,
              labelStyle: WorldClassDesignSystem.bodyMedium.copyWith(
                color: isSelected
                    ? WorldClassDesignSystem.primaryColor
                    : WorldClassDesignSystem.secondaryText,
              ),
              backgroundColor: WorldClassDesignSystem.cardBackground,
              side: BorderSide(
                color: isSelected
                    ? WorldClassDesignSystem.primaryColor
                    : WorldClassDesignSystem.borderColor,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessagesList() {
    // Mock data for demonstration
    final messages = [
      {
        'id': '1',
        'userName': 'Ahmet Yılmaz',
        'userAvatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face',
        'lastMessage': 'Thanks for the offer!',
        'timestamp': '2 min ago',
        'isUnread': true,
        'itemTitle': 'iPhone 13 Pro',
        'itemImage': 'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=100&h=100&fit=crop',
        'type': 'negotiation',
      },
      {
        'id': '2',
        'userName': 'Elif Kaya',
        'userAvatar': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100&h=100&fit=crop&crop=face',
        'lastMessage': 'When can we meet?',
        'timestamp': '1 hour ago',
        'isUnread': false,
        'itemTitle': 'MacBook Air',
        'itemImage': 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=100&h=100&fit=crop',
        'type': 'trade',
      },
      {
        'id': '3',
        'userName': 'Mehmet Demir',
        'userAvatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
        'lastMessage': 'Perfect condition!',
        'timestamp': '3 hours ago',
        'isUnread': false,
        'itemTitle': 'Samsung Galaxy S21',
        'itemImage': 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=100&h=100&fit=crop',
        'type': 'negotiation',
      },
    ];

    if (messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageItem(message);
      },
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to chat detail
          },
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
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(message['userAvatar']),
                    ),
                    if (message['isUnread'])
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: WorldClassDesignSystem.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              message['userName'],
                              style: WorldClassDesignSystem.bodyMedium.copyWith(
                                color: WorldClassDesignSystem.primaryText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            message['timestamp'],
                            style: WorldClassDesignSystem.bodySmall.copyWith(
                              color: WorldClassDesignSystem.secondaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message['lastMessage'],
                        style: WorldClassDesignSystem.bodyMedium.copyWith(
                          color: WorldClassDesignSystem.secondaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(message['itemImage']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              message['itemTitle'],
                              style: WorldClassDesignSystem.bodySmall.copyWith(
                                color: WorldClassDesignSystem.secondaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: message['type'] == 'negotiation'
                                  ? WorldClassDesignSystem.warningColor.withOpacity(0.2)
                                  : WorldClassDesignSystem.successColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              message['type'] == 'negotiation' ? 'Negotiation' : 'Trade',
                              style: WorldClassDesignSystem.bodySmall.copyWith(
                                color: message['type'] == 'negotiation'
                                    ? WorldClassDesignSystem.warningColor
                                    : WorldClassDesignSystem.successColor,
                                fontWeight: FontWeight.w600,
                              ),
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
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: WorldClassDesignSystem.secondaryText,
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: WorldClassDesignSystem.headingMedium.copyWith(
              color: WorldClassDesignSystem.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation by making an offer on an item',
            style: WorldClassDesignSystem.bodyMedium.copyWith(
              color: WorldClassDesignSystem.secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to explore page
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
            child: Text('Browse Items'),
          ),
        ],
      ),
    );
  }
}