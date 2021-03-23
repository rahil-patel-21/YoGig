import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yogigg_users_app/models/message_model.dart';

class ConversationModel {
  String conversationId;
  String userName;
  String photoURL;
  String userId;
  MessageModel lastMessage;
  DateTime lastUpdated;
  int unreadMessagesCounter;

  ConversationModel(
      {this.conversationId,
      this.userId,
      this.userName,
      this.photoURL,
      this.lastMessage,
      this.unreadMessagesCounter,
      this.lastUpdated});

  ConversationModel.fromJson(Map<String, dynamic> data, String userId) {
    this.userId =
        (data['users'] as List).where((element) => element != userId).first;
    this.conversationId = data['conversationId'];
    this.unreadMessagesCounter = data['unreadMessages'] ?? 0;
    this.userName =
        data[this.userId]['firstName'] + ' ' + data[this.userId]['lastName'];
    this.photoURL = data[this.userId]['photoURL'];
    this.lastMessage = MessageModel.fromJson(data['lastMessage']);
    this.lastUpdated = (data['lastMessage']['timeStamp']!=null)?  (data['lastMessage']['timeStamp'] as Timestamp).toDate() : DateTime.now();
  }
}
