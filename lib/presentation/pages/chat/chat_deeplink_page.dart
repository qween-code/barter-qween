import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/chat/chat_event.dart';
import '../../blocs/chat/chat_state.dart';
import 'chat_detail_page.dart';
import 'conversations_list_page.dart';

/// Deep-link loader page for chat conversations
/// Used when opening a specific conversation from a notification
class ChatDeepLinkPage extends StatefulWidget {
  final String conversationId;

  const ChatDeepLinkPage({
    super.key,
    required this.conversationId,
  });

  @override
  State<ChatDeepLinkPage> createState() => _ChatDeepLinkPageState();
}

class _ChatDeepLinkPageState extends State<ChatDeepLinkPage> {
  @override
  void initState() {
    super.initState();
    // Load the specific conversation
    context.read<ChatBloc>().add(LoadConversation(widget.conversationId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Loading Conversation...'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ConversationLoaded) {
            // Navigate to the actual chat detail page
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => ChatDetailPage(conversation: state.conversation),
              ),
            );
          } else if (state is ChatError) {
            // Show error and navigate back or to conversations list
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading conversation: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<ChatBloc>(),
                  child: const ConversationsListPage(),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }
          
          if (state is ChatError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load conversation',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<ChatBloc>(),
                            child: const ConversationsListPage(),
                          ),
                        ),
                      );
                    },
                    child: const Text('View All Conversations'),
                  ),
                ],
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        },
      ),
    );
  }
}
