import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:yogigg_users_app/constants/colors.dart';
import 'package:yogigg_users_app/constants/styles.dart';
import 'package:yogigg_users_app/models/user_model.dart';
import 'package:yogigg_users_app/models/video_call_data.dart';
import 'package:yogigg_users_app/ui/main_screens/messages_screen.dart';
import 'package:yogigg_users_app/ui/main_screens/feed_screen.dart';
import 'package:yogigg_users_app/ui/main_screens/gigg_search/gigg_search_screen.dart';
import 'package:yogigg_users_app/ui/main_screens/profile_screen.dart';
import 'package:yogigg_users_app/ui/main_screens/schedule_screen.dart';
import 'package:yogigg_users_app/ui/video_call_screen.dart';
import 'package:yogigg_users_app/utils/hive_init.dart';
import 'package:yogigg_users_app/utils/service_locator.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;

  PageController _pageController = PageController();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    setUserStatus();
    updateFCMToken();
    setNotificationsListener();
    WidgetsBinding.instance.addObserver(this);

    Hive.openBox('notificationBox').then((value) {
      var title = value.get('title') ?? '';
      var body = value.get('body') ?? '';
      print('title $title body $body');
    });

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      setOffline();
    } else if (state == AppLifecycleState.resumed) {
      setOnline();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          Container(
            child: PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: <Widget>[
                FeedScreen(),
                GiggSearchScreen(),
                ScheduleScreen(),
                MessagesScreen(),
                ProfileScreen(),
              ],
            ),
          ),
          Positioned(
            right: 0,
            left: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              child: BottomNavigationBar(
                  onTap: (value) {
                    setState(() {
                      _currentIndex = value;
                    });
                    _pageController.jumpToPage(
                      value,
                    );
                  },
                  currentIndex: _currentIndex,
                  elevation: elevation,
                  backgroundColor: accentColor1,
                  selectedItemColor: accentColor3,
                  unselectedItemColor: Colors.white,
                  type: BottomNavigationBarType.fixed,
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  items: getNavBarItems()),
            ),
          )
        ],
      ),
      // resizeToAvoidBottomInset: false,
      // resizeToAvoidBottomPadding: false,
    );
  }

  getNavBarItems() {
    return [
      BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/svg/yo_icon.svg',
            color: (_currentIndex == 0) ? accentColor3 : Colors.white,
          ),
          title: Text('')),
      BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/svg/search_icon.svg',
            color: (_currentIndex == 1) ? accentColor3 : Colors.white,
          ),
          title: Text('')),
      BottomNavigationBarItem(
          icon: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              SvgPicture.asset(
                'assets/svg/calendar_icon.svg',
                color: (_currentIndex == 2) ? accentColor3 : Colors.white,
              ),
              Text(
                '${DateTime.now().day}',
                style: TextStyle(
                    color: (_currentIndex == 2) ? Colors.white : accentColor1),
              )
            ],
          ),
          title: Text('')),
      BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/svg/chat_icon.svg',
            color: (_currentIndex == 3) ? accentColor3 : Colors.white,
          ),
          title: Text('')),
      BottomNavigationBarItem(
          icon: Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              border: Border.all(width: 4, color: accentColor3),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: locator<UserModel>().userPhotoURL,
                fit: BoxFit.cover,
              ),
            ),
          ),
          title: Text('')),
    ];
  }

  setNotificationsListener() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('notification_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: (a, b, c, d) {});
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationChannel videoNotificationChannel =
        AndroidNotificationChannel(
      'videoCall',
      'Video Call Notifications',
      'Incoming Video Call Alerts',
      importance: Importance.Max,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(videoNotificationChannel);

    const AndroidNotificationChannel messageNotificationChannel =
        AndroidNotificationChannel(
      'message',
      'Message Notifications',
      'Incoming Messages Alerts',
      importance: Importance.Max,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(messageNotificationChannel);

    RemoteMessage initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      if (initialMessage.data['type'] == 'videoCall') {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => VideoCallScreen(VideoCallData(
                calling: false,
                userId: initialMessage.data['userId'],
                userName: initialMessage.data['userName'],
                userPhotoURL: initialMessage.data['photoURL'],
                conversationId: initialMessage.data['conversationId'],
                messageId: initialMessage.data['messageId'],
                roomName: initialMessage.data['roomName']))));
      }
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage: $message");

      if (Platform.isIOS) {
        if (message.data['type'] == 'videoCall') {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => VideoCallScreen(VideoCallData(
                  calling: false,
                  userId: message.data['userId'],
                  userName: message.data['userName'],
                  userPhotoURL: message.data['photoURL'],
                  conversationId: message.data['conversationId'],
                  messageId: message.data['messageId'],
                  roomName: message.data['roomName']))));
        }
      } else if (message.data['type'] == 'videoCall') {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => VideoCallScreen(VideoCallData(
                calling: false,
                userId: message.data['userId'],
                userName: message.data['userName'],
                userPhotoURL: message.data['photoURL'],
                conversationId: message.data['conversationId'],
                messageId: message.data['messageId'],
                roomName: message.data['roomName']))));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('on Launch $message');
      if (Platform.isIOS) {
        if (message.data['type'] == 'videoCall') {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => VideoCallScreen(VideoCallData(
                  calling: false,
                  userId: message.data['userId'],
                  userName: message.data['userName'],
                  userPhotoURL: message.data['photoURL'],
                  conversationId: message.data['conversationId'],
                  messageId: message.data['messageId'],
                  roomName: message.data['roomName']))));
        }
      } else if (message.data['type'] == 'videoCall') {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => VideoCallScreen(VideoCallData(
                calling: false,
                userId: message.data['userId'],
                userName: message.data['userName'],
                userPhotoURL: message.data['photoURL'],
                conversationId: message.data['conversationId'],
                messageId: message.data['messageId'],
                roomName: message.data['roomName']))));
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessagingHandler);
  }

  updateFCMToken() async {
    String uid = locator<UserModel>().userId;

    var token = await _firebaseMessaging.getToken();
    Map<String, dynamic> data = Map();
    data['fcmToken'] = token;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  setUserStatus() {
    String uid = locator<UserModel>().userId;
    var database = FirebaseDatabase.instance;
    var databaseRef = database.reference().child('status').child(uid);
    var isOfflineForDatabase = {
      'state': "offline",
      'last_changed': ServerValue.timestamp,
    };

    database.reference().child('.info/connected').onValue.listen((event) {
      if (event.snapshot.value == false) {
        return;
      }

      databaseRef.onDisconnect().set(isOfflineForDatabase).then((value) {
        setOnline();
      });
    });
  }

  setOnline() {
    String uid = locator<UserModel>().userId;
    var database = FirebaseDatabase.instance;
    var databaseRef = database.reference().child('status').child(uid);
    var isOnlineForDatabase = {
      'state': "online",
      'last_changed': ServerValue.timestamp,
    };
    databaseRef.set(isOnlineForDatabase);
  }

  setOffline() {
    String uid = locator<UserModel>().userId;
    var database = FirebaseDatabase.instance;
    var databaseRef = database.reference().child('status').child(uid);
    var isOfflineForDatabase = {
      'state': "offline",
      'last_changed': ServerValue.timestamp,
    };
    databaseRef.set(isOfflineForDatabase);
  }
}

Future<void> _firebaseBackgroundMessagingHandler(RemoteMessage message) async {
  print('Got Message ${message.data}');

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid =
      AndroidInitializationSettings('notification_icon');
  var initializationSettingsIOS =
      IOSInitializationSettings(onDidReceiveLocalNotification: (a, b, c, d) {});
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'message', 'Message Notifications', 'Incoming Messages Alerts',
      importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
  var iOSPlatformChannelSpecifics = IOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    message.data['title'],
    message.data['body'],
    platformChannelSpecifics,
  );


}
