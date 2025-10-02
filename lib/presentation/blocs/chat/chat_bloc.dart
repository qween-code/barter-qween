import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/usecases/chat/get_conversations_usecase.dart';
import '../../../domain/usecases/chat/get_messages_usecase.dart';
import '../../../domain/usecases/chat/send_message_usecase.dart';
import '../../../domain/usecases/chat/mark_as_read_usecase.dart';
import '../../../domain/usecases/chat/get_or_create_conversation_usecase.dart';
import '../../../domain/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

/// BLoC for managing chat functionality with real-time updates
@injectable
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetConversationsUseCase getConversationsUseCase;
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final MarkAsReadUseCase markAsReadUseCase;
  final GetOrCreateConversationUseCase getOrCreateConversationUseCase;
  final ChatRepository chatRepository;

  // Stream subscriptions for real-time updates
  StreamSubscription? _conversationsSubscription;
  StreamSubscription? _messagesSubscription;

  ChatBloc({
    required this.getConversationsUseCase,
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
    required this.markAsReadUseCase,
    required this.getOrCreateConversationUseCase,
    required this.chatRepository,
  }) : super(const ChatInitial()) {
    // Register event handlers
    on<LoadConversations>(_onLoadConversations);
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<MarkMessagesAsRead>(_onMarkMessagesAsRead);
    on<GetOrCreateConversation>(_onGetOrCreateConversation);
    on<DeleteConversation>(_onDeleteConversation);
    on<GetUnreadCount>(_onGetUnreadCount);
  }

  /// Load all conversations with real-time updates
  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());

    // Cancel previous subscription if exists
    await _conversationsSubscription?.cancel();

    // Subscribe to conversations stream
    _conversationsSubscription = getConversationsUseCase(event.userId).listen(
      (result) async {
        if (emit.isDone) return;
        result.fold(
          (failure) {
            if (!emit.isDone) emit(ChatError(failure.message));
          },
          (conversations) {
            if (emit.isDone) return;
            // Calculate total unread count
            int totalUnread = 0;
            for (final conv in conversations) {
              totalUnread += conv.getUnreadCountForUser(event.userId);
            }

            emit(ConversationsLoaded(
              conversations: conversations,
              totalUnreadCount: totalUnread,
            ));
          },
        );
      },
      onError: (error) {
        if (!emit.isDone) emit(ChatError('Failed to load conversations: $error'));
      },
    );
  }

  /// Load messages for a conversation with real-time updates
  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());

    // Cancel previous subscription if exists
    await _messagesSubscription?.cancel();

    // Subscribe to messages stream
    _messagesSubscription = getMessagesUseCase(
      GetMessagesParams(conversationId: event.conversationId),
    ).listen(
      (result) async {
        if (emit.isDone) return;
        result.fold(
          (failure) {
            if (!emit.isDone) emit(ChatError(failure.message));
          },
          (messages) {
            if (emit.isDone) return;
            // Sort messages by date (newest first)
            final sortedMessages = List.of(messages)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            emit(MessagesLoaded(
              conversationId: event.conversationId,
              messages: sortedMessages,
            ));
          },
        );
      },
      onError: (error) {
        if (!emit.isDone) emit(ChatError('Failed to load messages: $error'));
      },
    );
  }

  /// Send a message
  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    // Show optimistic update
    emit(SendingMessage(
      conversationId: event.conversationId,
      text: event.text,
    ));

    final result = await sendMessageUseCase(
      SendMessageParams(
        conversationId: event.conversationId,
        senderId: event.senderId,
        senderName: event.senderName,
        text: event.text,
      ),
    );

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (message) {
        emit(MessageSent(message));
        // Reload messages to show the new message
        add(LoadMessages(event.conversationId));
      },
    );
  }

  /// Mark messages as read
  Future<void> _onMarkMessagesAsRead(
    MarkMessagesAsRead event,
    Emitter<ChatState> emit,
  ) async {
    final result = await markAsReadUseCase(
      MarkAsReadParams(
        conversationId: event.conversationId,
        userId: event.userId,
      ),
    );

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (_) => emit(MessagesMarkedAsRead(event.conversationId)),
    );
  }

  /// Get or create a conversation
  Future<void> _onGetOrCreateConversation(
    GetOrCreateConversation event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());

    final result = await getOrCreateConversationUseCase(
      GetOrCreateConversationParams(
        userId: event.userId,
        otherUserId: event.otherUserId,
        listingId: event.listingId,
      ),
    );

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (conversation) => emit(ConversationRetrieved(conversation)),
    );
  }

  /// Delete a conversation
  Future<void> _onDeleteConversation(
    DeleteConversation event,
    Emitter<ChatState> emit,
  ) async {
    final result = await chatRepository.deleteConversation(event.conversationId);

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (_) => emit(ConversationDeleted(event.conversationId)),
    );
  }

  /// Get unread message count
  Future<void> _onGetUnreadCount(
    GetUnreadCount event,
    Emitter<ChatState> emit,
  ) async {
    final result = await chatRepository.getUnreadMessageCount(event.userId);

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (count) => emit(UnreadCountRetrieved(count)),
    );
  }

  @override
  Future<void> close() {
    // Cancel all subscriptions when bloc is closed
    _conversationsSubscription?.cancel();
    _messagesSubscription?.cancel();
    return super.close();
  }
}
