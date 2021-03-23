import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yogigg_users_app/models/event_model.dart';

class EventsRepository {
  final FirebaseFirestore _firestore;

  EventsRepository() : _firestore = FirebaseFirestore.instance;

  Future<List<EventModel>> getPlatformEvents(String userId) async {
    try {
      List<EventModel> events = List();
      QuerySnapshot eventsSnapshot = await _firestore
          .collection('yogigg_events')
          .where('subscribers', arrayContains: userId)
          .get();
      eventsSnapshot.docs.forEach((eventDocument) {
        events.add(EventModel.fromJSON(eventDocument.data()));
      });
      return events;
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<List<EventModel>> getPersonalEvents(String userId) async {
    try {
      List<EventModel> events = List();
      QuerySnapshot personalEventsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .get();
      personalEventsSnapshot.docs.forEach((eventDocument) {
        events.add(EventModel.fromJSON(eventDocument.data()));
      });
      return events;
    } catch (e) {
      print(e);
      throw e;
    }
  }
}
