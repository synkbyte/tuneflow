part of 'models.dart';

class ChatModel {
  int id;
  int unreadCount;
  MessageModel lastMessage;
  Map user;
  ChatModel({
    required this.id,
    required this.unreadCount,
    required this.lastMessage,
    required this.user,
  });

  factory ChatModel.fromJson(Map json) {
    return ChatModel(
      id: json['id'],
      unreadCount: json['unreadCount'] ?? 0,
      lastMessage: MessageModel.fromJson(json['lastMessage']),
      user: json['user'],
    );
  }
}

class MessageModel {
  String content;
  String status;
  String role;
  String messageType;
  String at;
  MessageModel({
    required this.content,
    required this.status,
    required this.role,
    required this.messageType,
    required this.at,
  });

  factory MessageModel.fromJson(Map json) {
    return MessageModel(
      content: json['content'],
      status: json['status'],
      role: json['role'],
      messageType: json['messageType'],
      at: json['at'],
    );
  }
}
