import 'dart:async';
import 'dart:ui';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:twilio_programmable_video/twilio_programmable_video.dart';

import 'package:yogigg_users_app/models/message_model.dart';
import 'package:yogigg_users_app/models/user_model.dart';
import 'package:yogigg_users_app/models/video_call_data.dart';
import 'package:yogigg_users_app/utils/call_status.dart';
import 'package:yogigg_users_app/utils/service_locator.dart';
import 'package:yogigg_users_app/utils/time_helper.dart';

class VideoCallScreen extends StatefulWidget {
  final VideoCallData videoCallData;
  VideoCallScreen(this.videoCallData);
  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen>
    with TickerProviderStateMixin {
  Room _room;
  final Completer<Room> _completer = Completer<Room>();
  Widget myVideoWidget;
  Widget userVideoWidget;
  var firestore = FirebaseFirestore.instance;
  var database = FirebaseDatabase.instance;
  String messageId;

  StreamSubscription onDisconnectListener;
  CallStatus status;

  Timer callTimer;
  int callDurationInSeconds = 0;

  double callPickButtonDragStart = 0.0;
  double callPickButtonOffset = 0.0;

  double callRejectButtonDragStart = 0.0;
  double callRejectButtonOffset = 0.0;

  AnimationController pickCallButtonAnimationController;
  Animation pickCallAnimation;

  AnimationController rejectCallButtonAnimationController;
  Animation rejectCallAnimation;

  bool callPicked = false;
  bool callRejected = false;
  AssetsAudioPlayer audioPlayer = AssetsAudioPlayer.newPlayer();

  @override
  void initState() {
    pickCallButtonAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));

    pickCallAnimation = Tween<double>(begin: 1.0, end: 7.0).animate(
        CurvedAnimation(
            parent: pickCallButtonAnimationController, curve: Curves.ease));
    pickCallButtonAnimationController.addListener(() {
      if (mounted) setState(() {});
    });

    rejectCallButtonAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    rejectCallAnimation = Tween<double>(begin: 1.0, end: 7.0).animate(
        CurvedAnimation(
            parent: rejectCallButtonAnimationController, curve: Curves.ease));
    rejectCallButtonAnimationController.addListener(() {
      if (mounted) setState(() {});
    });
    if (!widget.videoCallData.calling) {
      status = CallStatus.Incoming;

      receiveCall();
    } else
      startCall();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: status == CallStatus.Incoming
          ? buildIncomingCallScreen()
          : buildCallScreen(context),
    );
  }

  Container buildCallScreen(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          Positioned(
              right: 0,
              left: 0,
              bottom: 0,
              height: MediaQuery.of(context).size.height * 0.25,
              child: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.videoCallData.userName,
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Text(
                          getCallStatus(),
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                          child: IconButton(
                              icon: Icon(Icons.call_end),
                              color: Colors.white,
                              onPressed: () async {
                                if (status != null &&
                                    status == CallStatus.Calling) {
                                  cancelCallBeforePicked();
                                } else if (status == CallStatus.Connected)
                                  cutCall();
                              }),
                        )
                      ],
                    )
                  ],
                ),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFF464F), Color(0xFF512989)])),
              )),
          Container(
            height: MediaQuery.of(context).size.height * 0.85,
            child: ClipRRect(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24)),
                child: userVideoWidget ??
                    CachedNetworkImage(
                      imageUrl: widget.videoCallData.userPhotoURL,
                      fit: BoxFit.cover,
                    )),
          ),
          Positioned(
            left: 30,
            bottom: MediaQuery.of(context).size.height * 0.15 + 85,
            child: Container(
              height: 172,
              width: 109,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(17),
                  child: myVideoWidget ??
                      CachedNetworkImage(
                        imageUrl: locator<UserModel>().userPhotoURL,
                        fit: BoxFit.cover,
                      )),
            ),
          ),
        ],
      ),
    );
  }

  Container buildIncomingCallScreen() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          CachedNetworkImage(
            imageUrl: widget.videoCallData.userPhotoURL,
            fit: BoxFit.cover,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10.0,
              sigmaY: 10.0,
            ),
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          SafeArea(
            child: Container(
              margin: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Image.asset(
                    'assets/images/icon.png',
                    width: 172,
                  ),
                  Text(
                    getCallStatus(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.videoCallData.userName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: CachedNetworkImage(
                      imageUrl: widget.videoCallData.userPhotoURL,
                      height: 172,
                      width: 109,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Transform.translate(
                        offset: Offset(-50, 0),
                        child: GestureDetector(
                          onHorizontalDragStart: (details) {
                            print('drag start ${details.localPosition}');
                            callRejectButtonDragStart =
                                details.localPosition.dx;
                          },
                          onHorizontalDragUpdate: (details) {
                            print('drag update ${details.localPosition}');
                            setState(() {
                              if (details.localPosition.dx -
                                          callRejectButtonDragStart >
                                      0 &&
                                  details.localPosition.dx -
                                          callRejectButtonDragStart <=
                                      76)
                                callRejectButtonOffset =
                                    details.localPosition.dx -
                                        callRejectButtonDragStart;
                            });
                            print('offset$callRejectButtonOffset');
                          },
                          onHorizontalDragEnd: (details) {
                            print('drag end');
                            setState(() {
                              if (callRejectButtonOffset > 40.0 &&
                                  details.primaryVelocity > 500) {
                                rejectCallButtonAnimationController.forward();
                                callRejected = true;
                              } else
                                callRejectButtonOffset = 0.0;
                            });
                            Future.delayed(Duration(milliseconds: 400), () {
                              if (callRejected) declineCall();
                            });
                          },
                          child: Transform.scale(
                            scale: rejectCallAnimation.value,
                            child: AnimatedOpacity(
                              opacity: callRejected ? 0.0 : 1.0,
                              duration: Duration(milliseconds: 500),
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 250),
                                width: 150 + callRejectButtonOffset,
                                height: 150 + callRejectButtonOffset,
                                child: Container(
                                    margin: EdgeInsets.only(left: 50),
                                    child: callRejected
                                        ? Container()
                                        : Icon(
                                            Icons.call_end,
                                            color: Colors.white,
                                            size: 40,
                                          )),
                                decoration: BoxDecoration(
                                    color: Colors.red, shape: BoxShape.circle),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(50, 0),
                        child: GestureDetector(
                          onHorizontalDragStart: (details) {
                            print('drag start ${details.localPosition}');
                            callPickButtonDragStart = details.localPosition.dx;
                          },
                          onHorizontalDragUpdate: (details) {
                            print('drag update ${details.localPosition}');
                            setState(() {
                              if (callPickButtonDragStart -
                                          details.localPosition.dx >
                                      0 &&
                                  callPickButtonDragStart -
                                          details.localPosition.dx <=
                                      76)
                                callPickButtonOffset = callPickButtonDragStart -
                                    details.localPosition.dx;
                            });
                            print('offset$callPickButtonOffset');
                          },
                          onHorizontalDragEnd: (details) {
                            print('drag end, ${details.primaryVelocity}');
                            setState(() {
                              if (callPickButtonOffset > 40.0 &&
                                  details.primaryVelocity < -500.0) {
                                pickCallButtonAnimationController.forward();
                                callPicked = true;
                              } else
                                callPickButtonOffset = 0.0;
                            });
                            Future.delayed(Duration(milliseconds: 400), () {
                              if (callPicked) acceptCall();
                            });
                          },
                          child: Transform.scale(
                            scale: pickCallAnimation.value,
                            child: AnimatedOpacity(
                              opacity: callPicked ? 0.0 : 1.0,
                              duration: Duration(milliseconds: 500),
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 250),
                                width: 150 + callPickButtonOffset,
                                height: 150 + callPickButtonOffset,
                                child: Container(
                                    margin: EdgeInsets.only(right: 50),
                                    child: callPicked
                                        ? Container()
                                        : Icon(
                                            Icons.call,
                                            color: Colors.white,
                                            size: 40,
                                          )),
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  String getCallStatus() {
    if (status != null) {
      switch (status) {
        case CallStatus.Busy:
          return 'Busy on Call';
        case CallStatus.Incoming:
          return 'Incoming Call';
        case CallStatus.Calling:
          return 'Calling';
        case CallStatus.Connecting:
          return 'Connecting';
        case CallStatus.Connected:
          return timeFormatter(callDurationInSeconds);
        case CallStatus.Disconnected:
          return 'Disconnected';
        case CallStatus.Declined:
          return 'Declined';
        default:
          return '';
      }
    } else
      return '';
  }

  Timer missCallTimer;
  StreamSubscription callStatusListener;
  OnDisconnect callingOnDisconnect;
  UserModel user = locator<UserModel>();
  MessageModel messageModel;

  startCall() async {
    status = CallStatus.Connecting;

    //check if user is on another call
    var userSnapshot = await firestore
        .collection('users')
        .doc(widget.videoCallData.userId)
        .get();
    if (userSnapshot.data().containsKey('onCall') &&
        userSnapshot.data()['onCall']) {
      setState(() {
        status = CallStatus.Busy;
      });
      await Future.delayed(Duration(seconds: 1));
      Navigator.of(context).pop();
    } else {
      //user is free for call

      //setting call message in conversation
      //setting user status as on call
      setState(() {
      status = CallStatus.Calling;
      });
      audioPlayer.open(
        Audio('assets/audio/skype_ringtone.mp3'),
        loopMode: LoopMode.single,
        showNotification: false,
      );

      var roomName = user.userId +
          '-' +
          widget.videoCallData.userId +
          '-' +
          DateTime.now().millisecondsSinceEpoch.toString();

      messageId = DateTime.now().millisecondsSinceEpoch.toString();
      messageModel = MessageModel(
          messageId: messageId,
          type: "videoCall",
          conversationId: widget.videoCallData.conversationId,
          roomName: roomName,
          content: 'Video Call',
          fromPhotoURL: user.userPhotoURL,
          toId: widget.videoCallData.userId,
          fromName: user.firstName + " " + user.lastName,
          fromId: user.userId);

      var messagesRef = firestore
          .collection('conversations')
          .doc(widget.videoCallData.conversationId)
          .collection('messages')
          .doc(messageId);

      var conversationsRef = firestore
          .collection('conversations')
          .doc(widget.videoCallData.conversationId);

      var userRef = firestore.collection('users').doc(user.userId);

      Map<String, dynamic> conversationData = Map();
      conversationData['lastMessage'] = messageModel.toJson();
      conversationData['unreadMessages'] = FieldValue.increment(1);

      Map<String, dynamic> userData = Map();
      userData['onCall'] = true;

      await firestore.runTransaction((transaction) {
        messagesRef.set(messageModel.toJson());
        conversationsRef.set(conversationData, SetOptions(merge: true));
        userRef.set(userData, SetOptions(merge: true));
        return;
      });

      var databaseRef =
          database.reference().child('videoCall').child(messageId);
      var onDisconnectData = {
        'messageId': messageId,
        'conversationId': widget.videoCallData.conversationId,
        'fromId': user.userId,
        'toId': widget.videoCallData.userId,
        'status': "missed",
      };
      callingOnDisconnect = databaseRef.onDisconnect();

      //setting 45 sec timer to check if call missed
      int start = 45;
      const oneSec = const Duration(seconds: 1);
      missCallTimer = new Timer.periodic(
        oneSec,
        (Timer timer) => setState(
          () {
            print('waiting to pick up ${start}s');
            if (start < 1) {
              timer.cancel();
              //call missed
              if (callStatusListener != null) callStatusListener.cancel();
              callingOnDisconnect.cancel();
              cancelCallBeforePicked();
            } else {
              start = start - 1;
            }
          },
        ),
      );

      //setting on disconnect listener
      database.reference().child('.info/connected').onValue.listen((event) {
        if (event.snapshot.value == false) {
          return;
        }
        callingOnDisconnect.set(onDisconnectData);
      });

      //setting firestore listener to check if call was picked or declined
      callStatusListener = messagesRef.snapshots().listen((event) {
        if (event.data().containsKey('status') &&
            (event.data()['status'] == 'picked' ||
                event.data()['status'] == 'declined')) {
          if (event.data()['status'] == 'picked') {
            //call was picked

            missCallTimer.cancel();
            if (callStatusListener != null) callStatusListener.cancel();
            callingOnDisconnect.cancel();
            audioPlayer.stop();
            connectToCall(roomName);
            setState(() {
              status = CallStatus.Connecting;
            });
          } else {
            //call was declined
            audioPlayer.stop();
            missCallTimer.cancel();
            if (callStatusListener != null) callStatusListener.cancel();
            callingOnDisconnect.cancel();
            userData['onCall'] = false;
            userRef.set(userData, SetOptions(merge: true));
            setState(() {
              status = CallStatus.Declined;
            });
            Future.delayed(Duration(seconds: 2), () {
              Navigator.of(context).pop();
            });
          }
        }
      });
    }
  }

  cancelCallBeforePicked() async {
    //call cancelled
    setState(() {
      status = CallStatus.Disconnected;
    });

    audioPlayer.stop();
    var messagesRef = firestore
        .collection('conversations')
        .doc(widget.videoCallData.conversationId)
        .collection('messages')
        .doc(messageModel.messageId);

    var userRef = firestore.collection('users').doc(user.userId);

    var messageJson = messageModel.toJson();

    Map<String, dynamic> userData = Map();
    userData['onCall'] = false;
    messageJson['status'] = 'missed';

    firestore.runTransaction((transaction) {
      messagesRef.set(messageJson, SetOptions(merge: true));
      userRef.set(userData, SetOptions(merge: true));
      return;
    });

    if (missCallTimer != null) missCallTimer.cancel();
    if (callStatusListener != null) await callStatusListener.cancel();
    await callingOnDisconnect.cancel();

    await sendMissedCallVideoNotification(messageModel);

    Navigator.of(context).pop();
  }

  StreamSubscription incomingCallStatusListener;
  receiveCall() async {
    FlutterRingtonePlayer.playRingtone(volume: 1.0);
    this.messageId = widget.videoCallData.messageId;
    var userRef = firestore.collection('users').doc(user.userId);
    var messagesRef = firestore
        .collection('conversations')
        .doc(widget.videoCallData.conversationId)
        .collection('messages')
        .doc(messageId);
    Map<String, dynamic> userData = Map();
    userData['onCall'] = true;

    await userRef.set(userData, SetOptions(merge: true));
    incomingCallStatusListener = messagesRef.snapshots().listen((event) {
      if (event.data().containsKey('status') &&
          event.data()['status'] == 'missed') {
        if (incomingCallStatusListener != null)
          incomingCallStatusListener.cancel();
        userData['onCall'] = false;
        userRef.set(userData, SetOptions(merge: true));
        Navigator.of(context).pop();
      }
    });
  }

  acceptCall() async {
    setState(() {
      status = CallStatus.Connecting;
    });
    FlutterRingtonePlayer.stop();

    if (incomingCallStatusListener != null) incomingCallStatusListener.cancel();

    var userRef = firestore.collection('users').doc(user.userId);
    var messagesRef = firestore
        .collection('conversations')
        .doc(widget.videoCallData.conversationId)
        .collection('messages')
        .doc(widget.videoCallData.messageId);
    Map<String, dynamic> userData = Map();
    userData['onCall'] = true;

    Map<String, dynamic> data = Map();
    data['status'] = 'picked';
    data['startTime'] = FieldValue.serverTimestamp();
    firestore.runTransaction((transaction) {
      messagesRef.set(data, SetOptions(merge: true));

      userRef.set(userData, SetOptions(merge: true));
      return;
    });
    connectToCall(widget.videoCallData.roomName);
    setState(() {
      status = CallStatus.Connecting;
    });
  }

  declineCall() async {
    setState(() {
      status = CallStatus.Declined;
    });
    FlutterRingtonePlayer.stop();
    if (incomingCallStatusListener != null) incomingCallStatusListener.cancel();

    var userRef = firestore.collection('users').doc(user.userId);
    var messagesRef = firestore
        .collection('conversations')
        .doc(widget.videoCallData.conversationId)
        .collection('messages')
        .doc(messageId);

    Map<String, dynamic> userData = Map();
    userData['onCall'] = false;

    Map<String, dynamic> data = Map();
    data['status'] = 'declined';
    setState(() {
      status = CallStatus.Declined;
    });

    firestore.runTransaction((transaction) {
      messagesRef.set(data, SetOptions(merge: true));

      userRef.set(userData, SetOptions(merge: true));
      return;
    });
    Navigator.of(context).pop();
  }

  OnDisconnect callConnectedOnDisconnect;
  StreamSubscription connectedCallStatusListener;
  connectToCall(String roomName) async {
    var user = locator<UserModel>();

    var databaseRef = database.reference().child('videoCall').child(messageId);
    var onDisconnectData = {
      'messageId': messageId,
      'conversationId': widget.videoCallData.conversationId,
      'fromId': user.userId,
      'toId': widget.videoCallData.userId,
      'status': "disconnected",
      'endTime': ServerValue.timestamp,
    };
    callConnectedOnDisconnect = databaseRef.onDisconnect();
    database.reference().child('.info/connected').onValue.listen((event) {
      if (event.snapshot.value == false) {
        return;
      }
      callConnectedOnDisconnect.set(onDisconnectData);
    });
    var messagesRef = firestore
        .collection('conversations')
        .doc(widget.videoCallData.conversationId)
        .collection('messages')
        .doc(messageId);
    connectedCallStatusListener = messagesRef.snapshots().listen((event) async {
      if ((event.data().containsKey('status') &&
              event.data()['status'] == 'disconnected') &&
          (event.data().containsKey('endTime') &&
              event.data()['endTime'] != null)) {
        //call has ended
        setState(() {
          status = CallStatus.Disconnected;
        });

        var userRef = firestore.collection('users').doc(user.userId);

        Map<String, dynamic> userData = Map();
        userData['onCall'] = false;
        userRef.set(userData, SetOptions(merge: true));

        connectedCallStatusListener.cancel();
        callConnectedOnDisconnect.cancel();
        await _room.disconnect();
        Navigator.of(context).pop();
      }
    });

    //generateAccessToken
    var accessToken = await generateAccessToken(roomName, user.userId);

    connectToRoom(roomName, accessToken);
  }

  cutCall() async {
    print('cutting call');
    setState(() {
      status = CallStatus.Disconnected;
    });
    if (connectedCallStatusListener != null)
      connectedCallStatusListener.cancel();
    callConnectedOnDisconnect.cancel();
    callTimer.cancel();
    var messagesRef = firestore
        .collection('conversations')
        .doc(widget.videoCallData.conversationId)
        .collection('messages')
        .doc(messageId);

    var userRef = firestore.collection('users').doc(user.userId);

    Map<String, dynamic> messageJson = Map();

    Map<String, dynamic> userData = Map();
    userData['onCall'] = false;
    messageJson['status'] = 'disconnected';
    messageJson['endTime'] = FieldValue.serverTimestamp();

    print('cutting call setting firestore data');

    await firestore.runTransaction((transaction) {
      messagesRef.set(messageJson, SetOptions(merge: true));

      userRef.set(userData, SetOptions(merge: true));
      return;
    });
    print('cutting call disconnecting from room');
    await _room.disconnect();
    Navigator.of(context).pop();
  }

  Future sendMissedCallVideoNotification(MessageModel messageModel) async {
    Map<String, dynamic> map = {
      "fromId": messageModel.fromId,
      "toId": messageModel.toId,
      "conversationId": messageModel.conversationId,
      "fromName": messageModel.fromName,
    };
    final HttpsCallable callable = FirebaseFunctions.instance
        .httpsCallable('sendMissedVideoCallNotification');
    HttpsCallableResult response = await callable.call(map);
  }

  Future<String> generateAccessToken(String roomName, String uid) async {
    final HttpsCallable callable = FirebaseFunctions.instance
        .httpsCallable( 'authenticateTwilioVideoCallRequest');
    HttpsCallableResult response = await callable
        .call(<String, dynamic>{"userId": uid, "roomName": roomName});
    return response.data['accessToken'];
  }

  Future<Room> connectToRoom(String roomName, String accessToken) async {
    print('connecting to $roomName');
    var connectOptions = ConnectOptions(
      accessToken,
      roomName: roomName, // Optional name for the room

      preferredAudioCodecs: [
        OpusCodec()
      ], // Optional list of preferred AudioCodecs
      preferredVideoCodecs: [
        H264Codec()
      ], // Optional list of preferred VideoCodecs.
      audioTracks: [LocalAudioTrack(true)], // Optional list of audio tracks.
      dataTracks: [
        LocalDataTrack(
          DataTrackOptions(), // Optional
        ),
      ], // Optional list of data tracks
      videoTracks: ([
        LocalVideoTrack(true, CameraCapturer(CameraSource.FRONT_CAMERA))
      ]), // Optional list of video tracks.
    );
    _room = await TwilioProgrammableVideo.connect(connectOptions);
    _room.onConnected.listen(_onConnected);
    _room.onConnectFailure.listen(_onConnectFailure);

    return _completer.future;
  }

  void _onConnected(Room room) {
    print('Connected to ${room.name}');
    setState(() {
      status = CallStatus.Connected;
    });
    callTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        callDurationInSeconds = callDurationInSeconds + 1;
      });
    });
    _completer.complete(_room);
    // Create an audio track.
    var localAudioTrack = LocalAudioTrack(true);

// A video track request an implementation of VideoCapturer.
    var cameraCapturer = CameraCapturer(CameraSource.FRONT_CAMERA);

// Create a video track.
    var localVideoTrack = LocalVideoTrack(true, cameraCapturer);

// Getting the local video track widget.
// This can only be called after the TwilioProgrammableVideo.connect() is called.
    myVideoWidget = localVideoTrack.widget();
    if (_room.remoteParticipants.isNotEmpty) {
      _room.remoteParticipants[0].onVideoTrackSubscribed
          .listen(onParticipantVideoSubscribed);
    } else {
      room.onParticipantConnected.listen(onParticipantConnected);
      if (mounted) setState(() {});
    }

    room.onParticipantDisconnected.listen(onParticipantDisconnected);

    room.onDisconnected.listen(onDisconnected);
  }

  void onDisconnected(RoomDisconnectedEvent event) {
    print('disconnected:${event.exception.message}');
    callTimer.cancel();
    Navigator.of(context).pop();
  }

  void onParticipantConnected(RoomParticipantConnectedEvent roomEvent) {
    print('participant connected ${roomEvent.remoteParticipant.identity}');
    roomEvent.remoteParticipant.onVideoTrackSubscribed
        .listen(onParticipantVideoSubscribed);
  }

  void onParticipantDisconnected(RoomParticipantDisconnectedEvent event) async {
    print('participant left ${event.remoteParticipant.identity}');
    await _room.disconnect();
    Navigator.of(context).pop();
  }

  void onParticipantVideoSubscribed(RemoteVideoTrackSubscriptionEvent event) {
    userVideoWidget = event.remoteVideoTrack.widget();
    setState(() {});
  }

  @override
  void dispose() {
    if (onDisconnectListener != null) onDisconnectListener.cancel();
    super.dispose();
  }

  void _onConnectFailure(RoomConnectFailureEvent event) {
    print(
        'Failed to connect to room ${event.room.name} with exception: ${event.exception}');
    _completer.completeError(event.exception);
  }
}
