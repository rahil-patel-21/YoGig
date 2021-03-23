import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:intl/intl.dart';
import 'package:yogigg_users_app/models/user_model.dart';
import 'package:yogigg_users_app/repository/events_repository.dart';
import 'package:yogigg_users_app/utils/service_locator.dart';
import 'package:yogigg_users_app/models/event_model.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _currentDate = DateTime.now();
  EventList<Event> events;
  List<Event> todayEvents;

  @override
  void initState() {
    testEventsMapping();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule'),
        actions: <Widget>[],
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              child: CalendarCarousel<Event>(
                onDayPressed: (DateTime date, List<Event> events) {
                  if(mounted)
                  this.setState(() {
                    _currentDate = date;
                    todayEvents = events;
                  });
                },
                weekendTextStyle: TextStyle(
                  color: Colors.red,
                ),
                thisMonthDayBorderColor: Colors.transparent,
                selectedDayBorderColor: Colors.transparent,
                customDayBuilder: (
                  /// you can provide your own build function to make custom day containers
                  bool isSelectable,
                  int index,
                  bool isSelectedDay,
                  bool isToday,
                  bool isPrevMonthDay,
                  TextStyle textStyle,
                  bool isNextMonthDay,
                  bool isThisMonthDay,
                  DateTime day,
                ) {
                  return null;
                },
                weekFormat: false,
                pageSnapping: true,
                maxSelectedDate:
                    DateTime(DateTime.now().year, DateTime.december, 31),
                minSelectedDate:
                    DateTime(DateTime.now().year, DateTime.january, 1),
                markedDatesMap: events,
                height: 420.0,
                selectedDateTime: _currentDate,
                markedDateMoreShowTotal: true,
                markedDateIconBuilder: (event) {
                  if (event.title == 'Birthday')
                    return Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: event.icon);
                  else
                    return Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.blue),
                      width: 4,
                      height: 4,
                    );
                },
                daysHaveCircularBorder: true,
              ),
            ),
            (todayEvents != null && todayEvents.isNotEmpty)
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Today',
                          style: Theme.of(context)
                              .textTheme
                              .headline5
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: todayEvents.length,
                            itemBuilder: (context, index) {
                              var format = DateFormat('EEE, d/M/y');
                              var dateString =
                                  format.format(todayEvents[index].date);
                              return Card(
                                child: ListTile(
                                  title: Text(todayEvents[index].title),
                                  subtitle: Text(dateString),
                                ),
                              );
                            }),
                      ],
                    ),
                  )
                : Offstage()
          ],
        ),
      ),
    );
  }

  _buildEventsMap() {
    Map<DateTime, List<Event>> eventsMap = Map();
    var userBirthday = locator<UserModel>().userBirthday;
    userBirthday =
        DateTime(DateTime.now().year, userBirthday.month, userBirthday.day);
    eventsMap[userBirthday] = [
      Event(
          date: userBirthday,
          title: 'Birthday',
          icon: Icon(
            Icons.cake,
            color: Colors.white,
          ),
          dot: Container(
            color: Colors.red,
            width: 4,
            height: 4,
          ))
    ];
    events = EventList(events: eventsMap);

    return events;
  }

  testEventsMapping() async {
    List<EventModel> events = await locator<EventsRepository>()
        .getPlatformEvents(locator<UserModel>().userId);
    List<EventModel> personalReminders = await locator<EventsRepository>()
        .getPersonalEvents(locator<UserModel>().userId);
    events.addAll(personalReminders);
    Map<DateTime, List<Event>> eventsMap = Map();

    for (var eventModel in events) {
      eventsMap[eventModel.eventTime] = [];
    }
    print(eventsMap);
    for (var eventKey in eventsMap.keys) {
      List<Event> eventsInDate = [];
      List<EventModel> eventModelsInDate =
          events.where((element) => element.eventTime == eventKey).toList();
      for (var event in eventModelsInDate) {
        eventsInDate.add(Event(
          date: event.eventTime,
          title: event.eventName,
        ));
      }
      eventsMap[eventKey] = eventsInDate;
    }
    var userBirthday = locator<UserModel>().userBirthday;
    userBirthday =
        DateTime(DateTime.now().year, userBirthday.month, userBirthday.day);
    var birthdayEvent = Event(
      date: userBirthday,
      title: 'Birthday',
      icon: Icon(
        Icons.cake,
        color: Colors.white,
      ),
    );
    if (eventsMap.containsKey(userBirthday)) {
      eventsMap[userBirthday].insert(0, birthdayEvent);
    } else {
      eventsMap[userBirthday] = [birthdayEvent];
    }
    print(eventsMap);
    if(mounted)
    setState(() {
      this.events = EventList(events: eventsMap);
    });
  }
}
