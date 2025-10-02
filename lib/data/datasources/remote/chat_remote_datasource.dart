import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/exceptions.dart';
import '../../models/conversation_model.dart';
import '../../models/message_model.dart';

/// Remote data source for chat operations using Firestore
@lazySingleton
class ChatRemoteDataSource {
  final FirebaseFirestore _firestore;

  ChatRemoteDataSource(this._firestore);

  // Collection references
  CollectionReference get _conversationsRef =>
      _firestore.collection('conversations');
  CollectionReference get _messagesRef => _firestore.collection('messages');

  /// Get all conversations for a user as a stream (real-time updates)
  Stream<List<ConversationModel>> getConversationsStream(String userId) {
    try {
      return _conversationsRef
          .where('participants', arrayContains: userId)
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => ConversationModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw ServerException('Failed to get conversations: $e');
    }
  }

  /// Get a specific conversation by ID
  Future<ConversationModel> getConversation(String conversationId) async {
    try {
      final doc = await _conversationsRef.doc(conversationId).get();
      
      if (!doc.exists) {
        throw NotFoundException('Conversation not found');
      }

      return ConversationModel.fromFirestore(doc);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException('Failed to get conversation: $e');
    }
  }

  /// Get or create a conversation between two users
  Future<ConversationModel> getOrCreateConversation({
    required String userId,
    required String otherUserId,
    String? listingId,
  }) async {
    try {
      // Sort user IDs to ensure consistent conversation lookup
      final participantIds = [userId, otherUserId]..sort();

      // Try to find existing conversation
      final querySnapshot = await _conversationsRef
          .where('participants', isEqualTo: participantIds)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return ConversationModel.fromFirestore(querySnapshot.docs.first);
      }

      // Create new conversation if not exists
      final now = DateTime.now();
      final conversationData = {
        'participants': participantIds,
        'listingId': listingId,
        'lastMessage': '',
        'lastMessageSenderId': '',
        'lastMessageTime': Timestamp.fromDate(now),
        'unreadCount': {
          userId: 0,
          otherUserId: 0,
        },
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      final docRef = await _conversationsRef.add(conversationData);
      final createdDoc = await docRef.get();

      return ConversationModel.fromFirestore(createdDoc);
    } catch (e) {
      throw ServerException('Failed to get or create conversation: $e');
    }
  }
  }

  /// Get messages for a conversation as a stream (real-time updates)
  Stream<List<MessageModel>> getMessagesStream(
    String conversationId, {
    int limit = 50,
  }) {
    print('📥 Firestore: Creating messages stream for conversation: $conversationId');
    try {
      // Temporarily remove orderBy to test if that's causing the issue
      return _messagesRef
          .where('conversationId', isEqualTo: conversationId)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
        print('📥 Firestore: Received ${snapshot.docs.length} messages from stream');
        return snapshot.docs
            .map((doc) {
              try {
                return MessageModel.fromFirestore(doc);
              } catch (e) {
                print('❌ Firestore: Error parsing message ${doc.id}: $e');
                rethrow;
              }
            })
            .toList();
      }).handleError((error) {
        print('❌ Firestore: Stream error - $error');
        throw ServerException('Failed to get messages: $error');
      });
    } catch (e) {
      print('❌ Firestore: Exception creating stream - $e');
      throw ServerException('Failed to get messages: $e');
    }
  }

  /// Send a text message
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    try {
      final now = DateTime.now();
      final messageData = {
        'conversationId': conversationId,
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        'type': 'text',
        'createdAt': Timestamp.fromDate(now),
        'isRead': false,
        'imageUrl': null,
      };

      // Add message to messages collection
      final messageRef = await _messagesRef.add(messageData);
      final messageDoc = await messageRef.get();

      // Update conversation with last message info
      final conversationRef = _conversationsRef.doc(conversationId);
      final conversationDoc = await conversationRef.get();
      
      if (conversationDoc.exists) {
        final conversationData = conversationDoc.data() as Map<String, dynamic>;
        final participants = List<String>.from(conversationData['participants'] ?? []);
        final currentUnreadCount = Map<String, dynamic>.from(conversationData['unreadCount'] ?? {});
        
        // Increment unread count for other participants
        final updatedUnreadCount = <String, int>{};
        for (final participantId in participants) {
          if (participantId == senderId) {
            updatedUnreadCount[participantId] = 0; // Sender has 0 unread
          } else {
            updatedUnreadCount[participantId] = (currentUnreadCount[participantId] ?? 0) + 1;
          }
        }

        await conversationRef.update({
          'lastMessage': text,
          'lastMessageSenderId': senderId,
          'lastMessageTime': Timestamp.fromDate(now),
          'unreadCount': updatedUnreadCount,
          'updatedAt': Timestamp.fromDate(now),
        });
      }

      return MessageModel.fromFirestore(messageDoc);
    } catch (e) {
      throw ServerException('Failed to send message: $e');
    }
  }

  /// Mark messages as read for a user
  Future<void> markMessagesAsRead({
    required String conversationId,
    required String userId,
  }) async {
    try {
      // Update unread count in conversation
      final conversationRef = _conversationsRef.doc(conversationId);
      await conversationRef.update({
        'unreadCount.$userId': 0,
      });

      // Optionally, mark individual messages as read
      // (This can be done in batches for better performance)
      final unreadMessages = await _messagesRef
          .where('conversationId', isEqualTo: conversationId)
          .where('senderId', isNotEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      throw ServerException('Failed to mark messages as read: $e');
    }
  }

  /// Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    try {
      // Delete all messages in the conversation
      final messages = await _messagesRef
          .where('conversationId', isEqualTo: conversationId)
          .get();

      final batch = _firestore.batch();
      for (final doc in messages.docs) {
        batch.delete(doc.reference);
      }

      // Delete the conversation
      batch.delete(_conversationsRef.doc(conversationId));

      await batch.commit();
    } catch (e) {
      throw ServerException('Failed to delete conversation: $e');
    }
  }

  /// Get total unread message count for a user
  Future<int> getUnreadMessageCount(String userId) async {
    try {
      final conversations = await _conversationsRef
          .where('participants', arrayContains: userId)
          .get();

      int totalUnread = 0;
      for (final doc in conversations.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final unreadCount = Map<String, dynamic>.from(data['unreadCount'] ?? {});
        totalUnread += (unreadCount[userId] as int?) ?? 0;
      }

      return totalUnread;
    } catch (e) {
      throw ServerException('Failed to get unread count: $e');
    }
  }
}
