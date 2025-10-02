import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/failures.dart';
import '../../../domain/entities/conversation_entity.dart';
import '../../../domain/entities/message_entity.dart';
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
    on<LoadConversation>(_onLoadConversation);
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<MarkMessagesAsRead>(_onMarkMessagesAsRead);
    on<GetOrCreateConversation>(_onGetOrCreateConversation);
    on<DeleteConversation>(_onDeleteConversation);
    on<GetUnreadCount>(_onGetUnreadCount);
  }

  /// Load a specific conversation by ID
  Future<void> _onLoadConversation(
    LoadConversation event,
    Emitter<ChatState> emit,
  ) async {
    print('💬 ChatBloc: LoadConversation event received for ID: ${event.conversationId}');
    emit(const ChatLoading());

    final result = await chatRepository.getConversation(event.conversationId);
    result.fold(
      (failure) {
        print('❌ ChatBloc: Failed to load conversation - ${failure.message}');
        emit(ChatError(failure.message));
      },
      (conversation) {
        print('✅ ChatBloc: Conversation loaded successfully');
        emit(ConversationLoaded(conversation));
      },
    );
  }

  /// Load all conversations with real-time updates
  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<ChatState> emit,
  ) async {
    print('💬 ChatBloc: LoadConversations event received for user: ${event.userId}');
    // Cancel previous subscription if exists
    await _conversationsSubscription?.cancel();

    // Use emit.forEach to properly handle the stream
    await emit.forEach<Either<Failure, List<ConversationEntity>>>(
      getConversationsUseCase(event.userId),
      onData: (result) {
        print('💬 ChatBloc: Conversations stream update received');
        return result.fold(
          (failure) {
            print('❌ ChatBloc: Failed to load conversations - ${failure.message}');
            return ChatError(failure.message);
          },
          (conversations) {
            print('✅ ChatBloc: Loaded ${conversations.length} conversations');
            // Calculate total unread count
            int totalUnread = 0;
            for (final conv in conversations) {
              totalUnread += conv.getUnreadCountForUser(event.userId);
            }

            return ConversationsLoaded(
              conversations: conversations,
              totalUnreadCount: totalUnread,
            );
          },
        );
      },
      onError: (error, stackTrace) {
        print('❌ ChatBloc: Conversations stream error - $error');
        return ChatError('Failed to load conversations: $error');
      },
    );
  }

  /// Load messages for a conversation with real-time updates
  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    print('📥 ChatBloc: Loading messages for conversation: ${event.conversationId}');
    
    // Cancel previous subscription if exists
    await _messagesSubscription?.cancel();

    // Use emit.forEach to properly handle the stream
    await emit.forEach<Either<Failure, List<MessageEntity>>>(
      getMessagesUseCase(
        GetMessagesParams(conversationId: event.conversationId),
      ),
      onData: (result) {
        return result.fold(
          (failure) {
            print('❌ ChatBloc: Failed to load messages - ${failure.message}');
            return ChatError(failure.message);
          },
          (messages) {
            print('✅ ChatBloc: Loaded ${messages.length} messages from stream');
            // Sort messages by date (newest first)
            final sortedMessages = List.of(messages)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return MessagesLoaded(
              conversationId: event.conversationId,
              messages: sortedMessages,
            );
          },
        );
      },
      onError: (error, stackTrace) {
        print('❌ ChatBloc: Stream error - $error');
        return ChatError('Failed to load messages: $error');
      },
    );
  }

  /// Send a message
  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    print('💬 ChatBloc: Sending message - Conv: ${event.conversationId}, Sender: ${event.senderId}');
    
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
      (failure) {
        print('❌ ChatBloc: Failed to send message - ${failure.message}');
        emit(ChatError(failure.message));
      },
      (message) {
        print('✅ ChatBloc: Message sent successfully - ${message.id}');
        emit(MessageSent(message));
        // Don't reload - the stream will automatically emit new messages
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
