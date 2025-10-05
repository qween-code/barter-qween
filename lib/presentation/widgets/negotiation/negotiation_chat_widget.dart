import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../core/theme/neumorphism_standards.dart';
import '../../../core/theme/neuromorphic_effects.dart';
import '../../../core/theme/neumorphism_animations.dart';
import '../../../domain/entities/message_entity.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/chat/chat_event.dart';
import '../../blocs/chat/chat_state.dart';

/// Neuromorphic Negotiation Chat Widget
/// Real-time chat interface for negotiation discussions
class NegotiationChatWidget extends StatefulWidget {
  final String negotiationId;
  final String otherUserId;
  final String otherUserName;

  const NegotiationChatWidget({
    Key? key,
    required this.negotiationId,
    required this.otherUserId,
    required this.otherUserName,
  }) : super(key: key);

  @override
  State<NegotiationChatWidget> createState() => _NegotiationChatWidgetState();
}

class _NegotiationChatWidgetState extends State<NegotiationChatWidget>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  late AnimationController _typingController;
  late AnimationController _messageController_anim;
  late Animation<double> _typingAnimation;
  late Animation<double> _messageAnimation;

  bool _isTyping = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadMessages();
  }

  void _initializeAnimations() {
    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _messageController_anim = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _typingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _typingController,
      curve: Curves.easeInOut,
    ));

    _messageAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _messageController_anim,
      curve: Curves.easeOutCubic,
    ));

    _messageController_anim.forward();
  }

  void _loadMessages() {
    // Load messages for this negotiation
    // This would typically load from repository
    _currentUserId = 'current_user_id'; // Get from auth
  }

  @override
  void dispose() {
    _typingController.dispose();
    _messageController_anim.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChatBloc>(),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Chat Header
            _buildChatHeader(),
            
            const SizedBox(height: 16),
            
            // Messages List
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return _buildLoadingState();
                  }
                  
                  if (state is ChatError) {
                    return _buildErrorState(state.message);
                  }
                  
                  if (state is ChatLoaded) {
                    return _buildMessagesList(state.messages);
                  }
                  
                  return _buildEmptyState();
                },
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Typing Indicator
            if (_isTyping) _buildTypingIndicator(),
            
            // Message Input
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: NeumorphismStandards.baseColor,
        boxShadow: NeumorphismStandards.neumorphismInsetShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: NeumorphismStandards.baseColor,
              boxShadow: NeumorphismStandards.neumorphismOutsetShadow,
            ),
            child: Icon(
              Icons.chat,
              color: NeumorphismStandards.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Negotiation Chat',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: NeumorphismStandards.ultraDark,
                  ),
                ),
                Text(
                  'Discuss terms with ${widget.otherUserName}',
                  style: TextStyle(
                    fontSize: 12,
                    color: NeumorphismStandards.softDark,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: NeumorphismStandards.successColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: NeumorphismStandards.baseColor,
              boxShadow: NeumorphismStandards.neumorphismInsetShadow,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              color: NeumorphismStandards.softDark,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading messages...',
            style: TextStyle(
              color: NeumorphismStandards.softDark,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: NeumorphismStandards.baseColor,
          boxShadow: NeumorphismStandards.neumorphismOutsetShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: NeumorphismStandards.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading messages',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: NeumorphismStandards.ultraDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: NeumorphismStandards.softDark,
              ),
            ),
          ],
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
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: NeumorphismStandards.baseColor,
              boxShadow: NeumorphismStandards.neumorphismInsetShadow,
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              color: NeumorphismStandards.softDark,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Start the conversation',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: NeumorphismStandards.ultraDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send a message to begin negotiating',
            style: TextStyle(
              fontSize: 14,
              color: NeumorphismStandards.softDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(List<MessageEntity> messages) {
    if (messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isCurrentUser = message.senderId == _currentUserId;
        
        return AnimatedBuilder(
          animation: _messageAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                isCurrentUser ? 20 * (1 - _messageAnimation.value) : -20 * (1 - _messageAnimation.value),
                0,
              ),
              child: Opacity(
                opacity: _messageAnimation.value,
                child: _buildMessageBubble(message, isCurrentUser),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(MessageEntity message, bool isCurrentUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isCurrentUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: NeumorphismStandards.baseColor,
                boxShadow: NeumorphismStandards.neumorphismOutsetShadow,
              ),
              child: Icon(
                Icons.person,
                color: NeumorphismStandards.softDark,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isCurrentUser
                    ? NeumorphismStandards.primaryColor.withOpacity(0.1)
                    : NeumorphismStandards.baseColor,
                boxShadow: isCurrentUser
                    ? NeumorphismStandards.neumorphismOutsetShadow
                    : NeumorphismStandards.neumorphismInsetShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: isCurrentUser
                          ? NeumorphismStandards.primaryColor
                          : NeumorphismStandards.ultraDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatMessageTime(message.createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: NeumorphismStandards.lightShadow,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: NeumorphismStandards.baseColor,
                boxShadow: NeumorphismStandards.neumorphismOutsetShadow,
              ),
              child: Icon(
                Icons.person,
                color: NeumorphismStandards.primaryColor,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: NeumorphismStandards.baseColor,
              boxShadow: NeumorphismStandards.neumorphismOutsetShadow,
            ),
            child: Icon(
              Icons.person,
              color: NeumorphismStandards.softDark,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: NeumorphismStandards.baseColor,
              boxShadow: NeumorphismStandards.neumorphismInsetShadow,
            ),
            child: AnimatedBuilder(
              animation: _typingAnimation,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.otherUserName} is typing',
                      style: TextStyle(
                        fontSize: 12,
                        color: NeumorphismStandards.softDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ...List.generate(3, (index) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 200 + (index * 100)),
                        margin: const EdgeInsets.only(left: 2),
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: NeumorphismStandards.softDark,
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: NeumorphismStandards.baseColor,
        boxShadow: NeumorphismStandards.neumorphismInsetShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: TextStyle(
                color: NeumorphismStandards.ultraDark,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(
                  color: NeumorphismStandards.lightShadow,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                // Implement typing indicator logic
                if (value.isNotEmpty && !_isTyping) {
                  setState(() => _isTyping = true);
                  _typingController.forward();
                } else if (value.isEmpty && _isTyping) {
                  setState(() => _isTyping = false);
                  _typingController.reverse();
                }
              },
            ),
          ),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              margin: const EdgeInsets.all(8),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: NeumorphismStandards.baseColor,
                boxShadow: NeumorphismStandards.neumorphismOutsetShadow,
              ),
              child: Icon(
                Icons.send,
                color: NeumorphismStandards.primaryColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    // Send message
    context.read<ChatBloc>().add(
      SendMessageEvent(
        conversationId: widget.negotiationId,
        content: content,
        senderId: _currentUserId!,
        receiverId: widget.otherUserId,
      ),
    );

    _messageController.clear();
    setState(() => _isTyping = false);
    _typingController.reverse();

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }
}
