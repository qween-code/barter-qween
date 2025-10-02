import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/conversation_entity.dart';

/// Data model for Conversation with Firestore serialization
class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.participants,
    super.listingId,
    required super.lastMessage,
    required super.lastMessageSenderId,
    required super.lastMessageTime,
    required super.unreadCount,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create from Firestore DocumentSnapshot
  factory ConversationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConversationModel(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      listingId: data['listingId'],
      lastMessage: data['lastMessage'] ?? '',
      lastMessageSenderId: data['lastMessageSenderId'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      unreadCount: Map<String, int>.from(
        (data['unreadCount'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(key, value as int),
            ) ??
            {},
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create from JSON
  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'],
      participants: List<String>.from(json['participants'] ?? []),
      listingId: json['listingId'],
      lastMessage: json['lastMessage'] ?? '',
      lastMessageSenderId: json['lastMessageSenderId'] ?? '',
      lastMessageTime: DateTime.parse(json['lastMessageTime']),
      unreadCount: Map<String, int>.from(json['unreadCount'] ?? {}),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'participants': participants,
      'listingId': listingId,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'unreadCount': unreadCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Convert to entity
  ConversationEntity toEntity() {
    return ConversationEntity(
      id: id,
      participants: participants,
      listingId: listingId,
      lastMessage: lastMessage,
      lastMessageSenderId: lastMessageSenderId,
      lastMessageTime: lastMessageTime,
      unreadCount: unreadCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Copy with method for updates
  ConversationModel copyWith({
    String? id,
    List<String>? participants,
    String? listingId,
    String? lastMessage,
    String? lastMessageSenderId,
    DateTime? lastMessageTime,
    Map<String, int>? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      listingId: listingId ?? this.listingId,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
