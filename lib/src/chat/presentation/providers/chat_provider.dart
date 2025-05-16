import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:new_tuneflow/core/common/app/cache_helper.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/injection_container.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatModel> chats = [];
  int selectedChatId = 0;
  Map selectedChat = {};

  int unreadCount = 0;

  listenServerMessages(Map event) {
    if (event['type'] == 'gotChats') {
      chats.clear();
      chats =
          List.from(event['chats']).map((e) => ChatModel.fromJson(e)).toList();
      notifyListeners();
      finalizeUnreadCount();
    }
    if (event['type'] == 'chatDetails') {
      selectedChatId = event['chat']['id'];
      selectedChat = event;
      markChatAsRead(selectedChatId, selectedChat['chat']['user']['id']);
      notifyListeners();
    }
    if (event['type'] == 'messageSent') {
      int chatId = event['chatId'];
      MessageModel message = MessageModel.fromJson(event['message']);
      selectedChatId = chatId;

      if (event['isNewChat']) {
        selectedChatId = chatId;
        selectedChat = event['chat'];
      } else {
        List messages = selectedChat['messages'].first['messages'];
        int index = messages.indexWhere(
          (msg) =>
              msg['content'] == message.content && msg['status'] == 'sending',
        );
        if (index != -1) {
          messages[index] = event['message'];
        } else {
          messages.add(event['message']);
        }
      }

      int chatIndex = chats.indexWhere((chat) => chat.id == chatId);
      if (chatIndex != -1) {
        chats[chatIndex].lastMessage = message;
        ChatModel updatedChat = chats.removeAt(chatIndex);
        chats.insert(0, updatedChat);
      }
      notifyListeners();
    }
    if (event['type'] == 'newMessage') {
      int chatId = event['chatId'];
      MessageModel message = MessageModel.fromJson(event['message']);
      int chatIndex = chats.indexWhere((chat) => chat.id == chatId);

      if (chatIndex != -1) {
        chats[chatIndex].lastMessage = message;
        chats[chatIndex].unreadCount++;
        ChatModel updatedChat = chats.removeAt(chatIndex);
        chats.insert(0, updatedChat);
        notifyListeners();
        if (selectedChatId == chatId) chats[chatIndex].unreadCount = 0;
      }
      if (selectedChatId == chatId) {
        selectedChat['messages'].first['messages'].add(event['message']);
        markChatAsRead(chatId, selectedChat['chat']['user']['id']);
      }
      finalizeUnreadCount();
    }
    if (event['type'] == 'chatRead') {
      int chatId = event['chatId'];
      int chatIndex = chats.indexWhere((chat) => chat.id == chatId);
      if (chatIndex != -1) {
        if (chats[chatIndex].lastMessage.status != 'deleted' &&
            chats[chatIndex].lastMessage.role != 'You') {
          chats[chatIndex].lastMessage.status = 'read';
        }
      }
      if (selectedChatId == chatId) {
        selectedChat['messages'].forEach((chat) {
          chat['messages'].forEach((message) {
            if (message['isDeletedForEveryone'] == false &&
                message['role'] != 'You') {
              message['status'] = 'read';
            }
          });
        });
      }
      notifyListeners();
      finalizeUnreadCount();
    }
    if (event['type'] == 'messageDelivered') {
      int chatId = event['chatId'];
      int chatIndex = chats.indexWhere((chat) => chat.id == chatId);
      if (chatIndex != -1) {
        chats[chatIndex].lastMessage.status = 'delivered';
      }
      if (selectedChatId == chatId) {
        selectedChat['messages'].forEach((chat) {
          chat['messages'].forEach((message) {
            if (message['status'] == 'sent') {
              message['status'] = 'delivered';
            }
          });
        });
      }
      notifyListeners();
    }
    if (event['type'] == 'messagesDeleted') {
      int chatId = event['chatId'];

      List<int> messagesIds =
          event['messageIds']
              .map<int>((id) => int.tryParse(id.toString()) ?? -1)
              .toList();

      if (chatId == selectedChatId && selectedChat['messages'] != null) {
        selectedChat['messages'].removeWhere((messageGroup) {
          if (messageGroup['messages'] is! List) return false;

          messageGroup['messages'].removeWhere((msg) {
            int msgId = int.tryParse(msg['id'].toString()) ?? -1;
            return messagesIds.contains(msgId);
          });

          return (messageGroup['messages'] as List).isEmpty;
        });
      }
      int chatIndex = chats.indexWhere((chat) => chat.id == chatId);
      if (chatIndex != -1) {
        chats[chatIndex].lastMessage.content = '';
        chats[chatIndex].lastMessage.status = 'deleted';
      }
      notifyListeners();
      Fluttertoast.cancel();
      Fluttertoast.showToast(msg: 'Deleted');
    }
    if (event['type'] == 'messageDeletedForEveryone') {
      int chatId = event['chatId'];

      List<int> messagesIds =
          event['messageIds']
              .map<int>((id) => int.tryParse(id.toString()) ?? -1)
              .toList();

      if (chatId == selectedChatId && selectedChat['messages'] != null) {
        for (var messageGroup in selectedChat['messages']) {
          if (messageGroup['messages'] is List) {
            for (var msg in messageGroup['messages']) {
              int msgId = int.tryParse(msg['id'].toString()) ?? -1;

              if (messagesIds.contains(msgId)) {
                msg['isDeletedForEveryone'] = true;
                msg['content'] = "This message was deleted";
              }
            }
          }
        }
      }
      int chatIndex = chats.indexWhere((chat) => chat.id == chatId);
      if (chatIndex != -1) {
        chats[chatIndex].lastMessage.content = 'This message was deleted';
        chats[chatIndex].lastMessage.status = 'deleted';
      }
      notifyListeners();

      Fluttertoast.cancel();
      Fluttertoast.showToast(msg: 'Deleted for everyone');
    }
  }

  sentMessage(String content, int friendId) async {
    if (selectedChat['messages'].isNotEmpty) {
      selectedChat['messages'].first['messages'].add({
        'role': 'You',
        'content': content,
        'at': DateFormat('hh:mm a').format(DateTime.now()),
        'status': 'sending',
      });
      notifyListeners();
    }
    audioHandler.webSocket.send(
      jsonEncode({
        'type': 'sendMessage',
        'userId': await CacheHelper().getUserId(),
        'friendId': friendId,
        'messageType': 'text',
        'content': content,
      }),
    );
  }

  getChatById(int id, Map user, {int? friendId}) async {
    int chatIndex = chats.indexWhere((chat) => chat.id == id);
    if (chatIndex != -1) {
      chats[chatIndex].unreadCount = 0;
      finalizeUnreadCount();
    }
    selectedChat = {
      'chat': {
        'user': {...user, 'lastSeen': ''},
      },
      'messages': [],
    };
    selectedChatId = id;
    notifyListeners();
    audioHandler.webSocket.send(
      jsonEncode({
        'type': 'getChatById',
        'chatId': id,
        'friendId': friendId,
        'userId': await CacheHelper().getUserId(),
      }),
    );
  }

  markChatAsRead(int chatId, int friendId) async {
    audioHandler.webSocket.send(
      jsonEncode({
        'type': 'markChatAsRead',
        'chatId': selectedChatId,
        'friendId': friendId,
        'userId': await CacheHelper().getUserId(),
      }),
    );
  }

  deselectChat() {
    selectedChatId = 0;
    selectedChat = {};
  }

  finalizeUnreadCount() {
    unreadCount = 0;
    for (var e in chats) {
      unreadCount += e.unreadCount;
    }
    notifyListeners();
  }

  deleteMessageForMe(List<Map> messages) async {
    Fluttertoast.showToast(msg: 'Deleting...');
    audioHandler.webSocket.send(
      jsonEncode({
        'type': 'deleteMessageForMe',
        'messageIds': messages.map((e) => '${e['id']}').toList(),
        'userId': await CacheHelper().getUserId(),
        'chatId': selectedChatId,
      }),
    );
  }

  deleteMessageForEveryone(List<Map> messages) async {
    Fluttertoast.showToast(msg: 'Deleting...');
    audioHandler.webSocket.send(
      jsonEncode({
        'type': 'deleteMessageForEveryone',
        'messageIds': messages.map((e) => '${e['id']}').toList(),
        'userId': await CacheHelper().getUserId(),
        'chatId': selectedChatId,
        'friendId': selectedChat['chat']['user']['id'],
      }),
    );
  }

  deleteChat(List<ChatModel> chats) async {
    Fluttertoast.showToast(msg: 'Chats deleted');
    audioHandler.webSocket.send(
      jsonEncode({
        'type': 'deleteChatForMe',
        'chatIds': chats.map((e) => e.id).toList(),
        'userId': await CacheHelper().getUserId(),
      }),
    );
    this.chats.removeWhere((chat) => chats.contains(chat));
    notifyListeners();
  }
}
