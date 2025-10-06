// 💬 WORLD CLASS MESSAGES PAGE
// Real-time chat with trade offers

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class WorldClassMessagesPage extends StatefulWidget {
  const WorldClassMessagesPage({Key? key}) : super(key: key);

  @override
  State<WorldClassMessagesPage> createState() => _WorldClassMessagesPageState();
}

class _WorldClassMessagesPageState extends State<WorldClassMessagesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Offers'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatList(),
          _buildOffersList(),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    final mockChats = List.generate(15, (index) {
      return {
        'name': 'User ${index + 1}',
        'message': 'Hey! Is this still available?',
        'time': DateTime.now().subtract(Duration(minutes: index * 15)),
        'unread': index < 3,
        'online': index < 5,
        'avatar': 'https://i.pravatar.cc/150?img=${index + 1}',
      };
    });

    return ListView.separated(
      itemCount: mockChats.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final chat = mockChats[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(chat['avatar'] as String),
              ),
              if (chat['online'] as bool)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.green,
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
                  chat['name'] as String,
                  style: TextStyle(
                    fontWeight: (chat['unread'] as bool) ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              Text(
                timeago.format(chat['time'] as DateTime),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          subtitle: Text(
            chat['message'] as String,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: (chat['unread'] as bool) ? FontWeight.w600 : FontWeight.normal,
              color: (chat['unread'] as bool) ? Colors.black87 : Colors.grey[600],
            ),
          ),
          trailing: (chat['unread'] as bool)
              ? Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '3',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              : null,
          onTap: () {
            // Open chat
          },
        );
      },
    );
  }

  Widget _buildOffersList() {
    final mockOffers = List.generate(8, (index) {
      return {
        'name': 'User ${index + 1}',
        'myItem': 'iPhone 13',
        'theirItem': 'MacBook Air',
        'cashDiff': index % 3 == 0 ? 500 : 0,
        'status': ['pending', 'accepted', 'declined'][index % 3],
        'time': DateTime.now().subtract(Duration(hours: index * 2)),
      };
    });

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: mockOffers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final offer = mockOffers[index];
        final status = offer['status'] as String;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: status == 'pending'
                  ? Colors.orange
                  : (status == 'accepted' ? Colors.green : Colors.grey[300]!),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=${index + 1}'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer['name'] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          timeago.format(offer['time'] as DateTime),
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(status),
                ],
              ),

              const SizedBox(height: 16),

              // Trade Details
              Row(
                children: [
                  Expanded(
                    child: _buildItemPreview(offer['myItem'] as String, 'Your item'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.swap_horiz, color: Colors.grey[400]),
                  ),
                  Expanded(
                    child: _buildItemPreview(offer['theirItem'] as String, 'Their item'),
                  ),
                ],
              ),

              if ((offer['cashDiff'] as int) > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.attach_money, size: 16, color: Colors.green[700]),
                      const SizedBox(width: 4),
                      Text(
                        '+ ₺${offer['cashDiff']} cash',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (status == 'pending') ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                        child: const Text('Decline'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'Pending';
        icon = Icons.schedule;
        break;
      case 'accepted':
        color = Colors.green;
        label = 'Accepted';
        icon = Icons.check_circle;
        break;
      case 'declined':
        color = Colors.red;
        label = 'Declined';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        label = 'Unknown';
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemPreview(String name, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            image: const DecorationImage(
              image: NetworkImage('https://via.placeholder.com/200'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
        Text(
          name,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
