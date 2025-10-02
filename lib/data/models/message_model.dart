import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message_entity.dart';

/// Data model for Message with Firestore serialization
class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.senderName,
    required super.text,
    required super.type,
    required super.createdAt,
    required super.isRead,
    super.imageUrl,
  });

  /// Create from Firestore DocumentSnapshot
  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      conversationId: data['conversationId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      text: data['text'] ?? '',
      type: _parseMessageType(data['type']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      imageUrl: data['imageUrl'],
    );
  }

  /// Create from JSON
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      conversationId: json['conversationId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      text: json['text'] ?? '',
      type: _parseMessageType(json['type']),
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
      imageUrl: json['imageUrl'],
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'type': type.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'imageUrl': imageUrl,
    };
  }

  /// Convert to entity
  MessageEntity toEntity() {
    return MessageEntity(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      text: text,
      type: type,
      createdAt: createdAt,
      isRead: isRead,
      imageUrl: imageUrl,
    );
  }

  /// Parse message type from string
  static MessageType _parseMessageType(dynamic typeValue) {
    if (typeValue == null) return MessageType.text;
    
    final typeString = typeValue.toString().toLowerCase();
    switch (typeString) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'system':
        return MessageType.system;
      default:
        return MessageType.text;
    }
  }

  /// Copy with method for updates
  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? text,
    MessageType? type,
    DateTime? createdAt,
    bool? isRead,
    String? imageUrl,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      text: text ?? this.text,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
