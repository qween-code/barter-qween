import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Modern Chat List Page V2
/// 
/// Features:
/// - WhatsApp-inspired design
/// - Unread message badges
/// - Last message preview
/// - Online status indicators
/// - Search functionality
/// - Swipe to delete/archive
/// 
/// Inspired by:
/// - WhatsApp
/// - Telegram
/// - Instagram DMs
class ChatListPageV2 extends StatefulWidget {
  const ChatListPageV2({Key? key}) : super(key: key);

  @override
  State<ChatListPageV2> createState() => _ChatListPageV2State();
}

class _ChatListPageV2State extends State<ChatListPageV2> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // Mock data - replace with actual chat data
  final List<ChatPreview> _chats = [
    ChatPreview(
      id: '1',
      userName: 'Alice Johnson',
      userAvatar: 'https://via.placeholder.com/150',
      lastMessage: 'iPhone 13 için teklif kabul etti!',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: 2,
      isOnline: true,
    ),
    ChatPreview(
      id: '2',
      userName: 'Bob Smith',
      userAvatar: null,
      lastMessage: 'Yarın buluşalım mı?',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      unreadCount: 0,
      isOnline: false,
    ),
    ChatPreview(
      id: '3',
      userName: 'Carol White',
      userAvatar: 'https://via.placeholder.com/150',
      lastMessage: 'Trade için fotoğrafları gönderebilir misin?',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      unreadCount: 5,
      isOnline: true,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: _isSearching
            ? _buildSearchField()
            : const Text(
                'Mesajlar',
                style: TextStyle(
                  color: Color(0xFF2D3142),
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: const Color(0xFF2D3142),
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: _chats.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _chats.length,
              itemBuilder: (context, index) {
                return _buildChatItem(_chats[index]);
              },
            ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Mesajlarda ara...',
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 16,
        ),
      ),
      style: const TextStyle(
        color: Color(0xFF2D3142),
        fontSize: 16,
      ),
    );
  }

  Widget _buildChatItem(ChatPreview chat) {
    return Dismissible(
      key: Key(chat.id),
      background: Container(
        color: Colors.red[400],
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 28,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          _chats.remove(chat);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${chat.userName} silindi'),
            action: SnackBarAction(
              label: 'Geri Al',
              onPressed: () {
                setState(() {
                  _chats.add(chat);
                });
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey[200],
                backgroundImage: chat.userAvatar != null
                    ? NetworkImage(chat.userAvatar!)
                    : null,
                child: chat.userAvatar == null
                    ? Text(
                        chat.userName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B35),
                        ),
                      )
                    : null,
              ),
              if (chat.isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFF34A853),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  chat.userName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: chat.unreadCount > 0
                        ? FontWeight.bold
                        : FontWeight.w600,
                    color: const Color(0xFF2D3142),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _formatTimestamp(chat.timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: chat.unreadCount > 0
                      ? const Color(0xFFFF6B35)
                      : Colors.grey[600],
                  fontWeight: chat.unreadCount > 0
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
          subtitle: Row(
            children: [
              Expanded(
                child: Text(
                  chat.lastMessage,
                  style: TextStyle(
                    fontSize: 14,
                    color: chat.unreadCount > 0
                        ? Colors.grey[800]
                        : Colors.grey[600],
                    fontWeight: chat.unreadCount > 0
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (chat.unreadCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    chat.unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          onTap: () => _openChat(chat),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Color(0xFFFF6B35),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Henüz mesajınız yok',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bir trade başlattığınızda burada görünecek',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}dk';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}sa';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}g';
    } else {
      return DateFormat('dd/MM/yy').format(timestamp);
    }
  }

  void _openChat(ChatPreview chat) {
    Navigator.pushNamed(
      context,
      '/chat-detail',
      arguments: chat,
    );
  }
}

/// Chat Preview Model
class ChatPreview {
  final String id;
  final String userName;
  final String? userAvatar;
  final String lastMessage;
  final DateTime timestamp;
  final int unreadCount;
  final bool isOnline;

  ChatPreview({
    required this.id,
    required this.userName,
    this.userAvatar,
    required this.lastMessage,
    required this.timestamp,
    this.unreadCount = 0,
    this.isOnline = false,
  });
}
