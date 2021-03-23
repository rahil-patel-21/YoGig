import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  String eventId;
  String eventName;
  DateTime eventTime;

  EventModel({this.eventId, this.eventName, this.eventTime});

  EventModel.fromJSON(Map<String, dynamic> data)
      : this.eventId = data['eventId'],
        this.eventName = data['eventName'],
        this.eventTime = (data['eventTime'] as Timestamp).toDate();
}
