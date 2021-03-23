import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';


class MessageModel {
  String messageId;
  String content;
  DateTime timeStamp;
  String fromId;
  String fromName;
  String toId;
  String type;
  String conversationId;
  String roomName;
  String fromPhotoURL;
  String status;
  DateTime startTime;
  DateTime endTime;
  String fileAttachment;
  String fileType;

  File attachment;
  double progress;

  bool sending;

  MessageModel(
      {this.messageId,
      this.content,
      this.fromId,
      this.fromName,
      this.type,
      this.timeStamp,
      this.conversationId,
      this.roomName,
      this.fromPhotoURL,
      this.status,
      this.startTime,
      this.endTime,
      this.fileAttachment,
      this.fileType,
      this.attachment,
      this.sending,
      this.toId});

  MessageModel.fromJson(Map<String, dynamic> data)
      : this.messageId = data['messageId'],
        this.content = data['content'],
        this.fromId = data['fromId'],
        this.fromName = data['fromName'],
        this.toId = data['toId'],
        this.type = data['type'],
        this.fromPhotoURL = data['fromPhotoURL'],
        this.roomName = data['roomName'],
        this.status = data['status'] ?? '',
        this.conversationId = data['conversationId'],
        this.fileAttachment = data['fileAttachment'],
        this.fileType = data['fileType'],
        this.startTime = data['startTime'] == null
            ? null
            : (data['startTime'] as Timestamp).toDate(),
        this.endTime = data['endTime'] == null
            ? null
            : (data['endTime'] as Timestamp).toDate(),
        this.timeStamp = data['timeStamp'] == null
            ? DateTime.now()
            : (data['timeStamp'] as Timestamp).toDate();

  Map<String, dynamic> toJson() {
    return {
      'content': this.content,
      'timeStamp': FieldValue.serverTimestamp(),
      'fromId': this.fromId,
      'type': this.type,
      'fromName': this.fromName,
      'fromPhotoURL': this.fromPhotoURL,
      'toId': this.toId,
      'conversationId': this.conversationId,
      'roomName': this.roomName,
      'messageId': this.messageId,
      'fileType':this.fileType,
      'fileAttachment':this.fileAttachment,
    };
  }
}
