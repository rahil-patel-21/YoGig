import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:yogigg_users_app/constants/colors.dart';
import 'package:yogigg_users_app/models/conversation_model.dart';
import 'package:yogigg_users_app/models/message_model.dart';
import 'package:yogigg_users_app/models/user_model.dart';
import 'package:yogigg_users_app/models/video_call_data.dart';
import 'package:yogigg_users_app/ui/custom_shapes/chat_bubble.dart';
import 'package:yogigg_users_app/ui/custom_shapes/custom_app_bar.dart';
import 'package:yogigg_users_app/ui/image_preview_screen.dart';
import 'package:yogigg_users_app/ui/video_call_screen.dart';
import 'package:yogigg_users_app/utils/service_locator.dart';
import 'package:yogigg_users_app/utils/time_helper.dart';
import 'package:path/path.dart' as path;

class ChatScreen extends StatefulWidget {
  final ConversationModel conversationModel;
  ChatScreen(this.conversationModel);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  TextEditingController messageEditingController = TextEditingController();
  ScrollController chatListController = ScrollController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  StreamSubscription messagesListener;
  StreamSubscription userOnlineListener;
  String userStatus = '';

  List<MessageModel> messagesList = List();

  File imageFile;

  QueryDocumentSnapshot lastDocument;
  bool allMessagesLoaded = false;

  @override
  void initState() {
    getMessages();
    getUserStatus();
    clearUnreadCounter();
    setChatListListener();
    super.initState();
  }

  void setChatListListener() {
    chatListController.addListener(() {
      if (chatListController.offset >=
              chatListController.position.maxScrollExtent &&
          !chatListController.position.outOfRange) {
        getPreviousMessages();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        brightness: Brightness.light,
      ),
      body: Container(
        child: Stack(
          children: [
            CustomScrollView(
              controller: chatListController,
              reverse: true,
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    height: 80,
                  ),
                ),
                SliverList(
                    delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return buildMessage(index);
                  },
                  childCount: messagesList.length,
                )),
                SliverToBoxAdapter(
                  child: (!allMessagesLoaded && messagesList.isNotEmpty)
                      ? Container(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : Offstage(),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    height: 160,
                  ),
                ),
              ],
            ),
            Container(
              child: buildAppBar(context),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 16),
                child: AnimatedSize(
                  alignment: Alignment.bottomCenter,
                  duration: Duration(milliseconds: 300),
                  vsync: this,
                  child: Column(
                    children: [
                      imageFile != null
                          ? Stack(
                              children: [
                                Container(
                                  margin: EdgeInsets.all(16),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(9),
                                      child: Image.file(
                                        imageFile,
                                        fit: BoxFit.cover,
                                        height: 300,
                                      )),
                                ),
                                Positioned(
                                    top: 8,
                                    right: 8,
                                    child: IconButton(
                                        icon: Icon(Icons.cancel),
                                        onPressed: () {
                                          setState(() {
                                            imageFile = null;
                                          });
                                        }))
                              ],
                            )
                          : Container(),
                      Row(
                        children: [
                          IconButton(
                              icon: SvgPicture.asset(
                                  'assets/svg/attach_image_icon.svg'),
                              onPressed: () async {
                                final picker = ImagePicker();
                                var image = await picker.getImage(
                                    source: ImageSource.gallery);
                                if (image != null) {
                                  setState(() {
                                    imageFile = File(image.path);
                                  });
                                }
                              }),
                          IconButton(
                              icon: SvgPicture.asset(
                                  'assets/svg/open_camera_icon.svg'),
                              onPressed: () {}),
                          Expanded(
                              child: TextField(
                            controller: messageEditingController,
                            minLines: 1,
                            maxLines: 4,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Type Message...'),
                          )),
                          IconButton(
                              icon: SvgPicture.asset(
                                'assets/svg/send_message_icon.svg',
                                color: accentColor1,
                              ),
                              onPressed: () {
                                sendMessage();
                              })
                        ],
                      ),
                    ],
                  ),
                ),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                      offset: Offset(0, -4),
                      blurRadius: 8,
                      color: Colors.black.withOpacity(0.05))
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAppBar(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Container(
            color: Colors.white,
            height: 83,
            width: 83,
          ),
          IgnorePointer(
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 225),
              painter: CustomToolBar(
                  LinearGradient(
                      colors: [Color(0xFFFF464F), Color(0xFF512989)]),
                  83.0),
              child: Container(
                height: 225,
                color: Colors.transparent,
              ),
            ),
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    margin: EdgeInsets.only(top: 23, left: 42, right: 24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: RaisedButton(
                            shape: CircleBorder(),
                            padding: EdgeInsets.all(0),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Icon(Icons.keyboard_arrow_left),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(
                              left: 10,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userStatus,
                                  style: TextStyle(
                                      fontSize: 18, color: Color(0xFFD2BBC7)),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Text(
                                  widget.conversationModel.userName
                                      .split(' ')
                                      .first,
                                  style: TextStyle(
                                    fontSize: 40,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => VideoCallScreen(VideoCallData(
                                    calling: true,
                                    userName: widget.conversationModel.userName,
                                    conversationId:
                                        widget.conversationModel.conversationId,
                                    userPhotoURL:
                                        widget.conversationModel.photoURL,
                                    userId: widget.conversationModel.userId))));
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 16),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Color(0xFF007AFF).withOpacity(0.25),
                                shape: BoxShape.circle),
                            child: SvgPicture.asset(
                              'assets/svg/video_call_icon.svg',
                            ),
                          ),
                        ),
                        Container(
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 39,
                                child: ClipOval(
                                    child: CachedNetworkImage(
                                  imageUrl: widget.conversationModel.photoURL,
                                  width: 78,
                                  fit: BoxFit.cover,
                                  height: 78,
                                )),
                              ),
                              (userStatus == 'Online')
                                  ? Positioned(
                                      bottom: 5,
                                      left: 5,
                                      child: CircleAvatar(
                                        radius: 7,
                                        backgroundColor: Colors.green,
                                      ),
                                    )
                                  : Container()
                            ],
                          ),
                        )
                      ],
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildMessage(int index) {
    MessageModel messageModel = messagesList[index];
    bool isMe = !(messageModel.fromId == widget.conversationModel.userId);
    DateFormat dateFormat = DateFormat('HH:mm');
    String timeString = dateFormat.format(messageModel.timeStamp);
    var nipRadius = 10.0;
    bool lastMessageInGroupLayout = false;
    if (index == 0) {
      lastMessageInGroupLayout = true;
    } else {
      DateTime messageDate = DateTime(messageModel.timeStamp.year,
          messageModel.timeStamp.month, messageModel.timeStamp.day);
      MessageModel previousMessage = messagesList[index - 1];
      DateTime previousMessageDateTime = previousMessage.timeStamp;
      DateTime previousMessageDate = DateTime(previousMessageDateTime.year,
          previousMessageDateTime.month, previousMessageDateTime.day);
      lastMessageInGroupLayout =
          previousMessage.fromId != messageModel.fromId ||
              messageDate != previousMessageDate;
    }

    Widget messageWidget;
    double messageBubblePadding = 16.0;

    if (messageModel.type != null && messageModel.type == 'videoCall') {
      if (messageModel.status != null) {
        if (isMe) {
          if (messageModel.endTime != null && messageModel.startTime != null) {
            String duration = timeFormatter(messageModel.endTime
                .difference(messageModel.startTime)
                .inSeconds);
            messageWidget = Container(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.call_made,
                    size: 18,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    'Video Call Ended (Duration : $duration)',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            );
          } else
            messageWidget = Container(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.call_made,
                    size: 18,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    'You Started a Video Call',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            );
        } else {
          if (messageModel.status == 'missed') {
            messageWidget = Container(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.missed_video_call,
                    size: 18,
                    color: Colors.black,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    'Missed Video Call',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          } else {
            if (messageModel.endTime != null &&
                messageModel.startTime != null) {
              String duration = timeFormatter(messageModel.endTime
                  .difference(messageModel.startTime)
                  .inSeconds);
              messageWidget = Container(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.call_received,
                      size: 18,
                      color: Colors.black,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Video Call Ended (Duration : $duration)',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            } else
              messageWidget = Container(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.call_received,
                      size: 18,
                      color: Colors.black,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      '${widget.conversationModel.userName} Started a Video Call',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
          }
        }
      }
    } else if (messageModel.attachment != null ||
        messageModel.fileAttachment != null) {
      if (messageModel.sending != null && messageModel.sending) {
        if (messageModel.content != null && messageModel.content.isNotEmpty)
          messageBubblePadding = 8.0;
        else
          messageBubblePadding = 4.0;
        messageWidget = Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Image.file(
                      messageModel.attachment,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Container(
                      child: BackdropFilter(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(9),
                          ),
                        ),
                        filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: messageModel.progress,
                    ),
                  ),
                )
              ],
            ),
            messageModel.content != null && messageModel.content.isNotEmpty
                ? Column(
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        messageModel.content,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                            fontSize: 12),
                      )
                    ],
                  )
                : Offstage(),
          ],
        );
      } else {
        if (messageModel.content != null && messageModel.content.isNotEmpty)
          messageBubblePadding = 8.0;
        else
          messageBubblePadding = 4.0;
        messageWidget = Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return ImagePreviewScreen(messageModel.fileAttachment);
                    }));
                  },
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.width * 0.6,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Hero(
                        tag: messageModel.fileAttachment,
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            height: MediaQuery.of(context).size.width * 0.6,
                          ),
                          imageUrl: messageModel.fileAttachment,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            messageModel.content != null && messageModel.content.isNotEmpty
                ? Column(
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        messageModel.content,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                            fontSize: 12),
                      )
                    ],
                  )
                : Offstage(),
          ],
        );
      }
    }

    if (isMe) {
      if (!lastMessageInGroupLayout)
        return Container(
          margin: EdgeInsets.only(right: 20),
          child: Row(
            children: [
              Spacer(),
              Container(
                margin: EdgeInsets.only(bottom: 4, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9),
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF0185D0), Color(0xFFA826C7)])),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.all(messageBubblePadding),
                      child: Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.6),
                        child: messageWidget ??
                            Text(
                              messageModel.content,
                              overflow: TextOverflow.clip,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                      ),
                    ),
                    Text(
                      timeString,
                      style: TextStyle(fontSize: 10),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      else
        return Container(
          margin: EdgeInsets.only(right: 20),
          child: Row(
            children: [
              Spacer(),
              Container(
                margin: EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomPaint(
                      painter: ChatBubble(
                        9.0,
                        nipRadius,
                        isMe,
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF0185D0), Color(0xFFA826C7)]),
                      ),
                      child: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(
                            left: messageBubblePadding,
                            right: messageBubblePadding + nipRadius,
                            top: messageBubblePadding,
                            bottom: messageBubblePadding),
                        child: Container(
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.6),
                          child: messageWidget ??
                              Text(
                                messageModel.content,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                        ),
                      ),
                    ),
                    Text(
                      timeString,
                      style: TextStyle(fontSize: 10),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
    } else {
      if (lastMessageInGroupLayout)
        return Container(
          margin: EdgeInsets.only(left: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                margin: EdgeInsets.only(
                  bottom: 24,
                ),
                child: CircleAvatar(
                  radius: 15,
                  child: ClipOval(
                      child: CachedNetworkImage(
                    imageUrl: widget.conversationModel.photoURL,
                    width: 30,
                    fit: BoxFit.cover,
                    height: 30,
                  )),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 8, left: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomPaint(
                      painter: ChatBubble(9.0, nipRadius, isMe,
                          bubbleColor: Color(0xFFEAECF2)),
                      child: Container(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        padding: EdgeInsets.only(
                            left: messageBubblePadding + nipRadius,
                            right: messageBubblePadding,
                            top: messageBubblePadding,
                            bottom: messageBubblePadding),
                        child: Container(
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.6),
                          child: messageWidget ??
                              Text(
                                messageModel.content,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                    color: Color(0xFF63697B), fontSize: 12),
                              ),
                        ),
                      ),
                    ),
                    Text(
                      timeString,
                      style: TextStyle(fontSize: 10),
                    )
                  ],
                ),
              ),
              Spacer()
            ],
          ),
        );
      else
        return Container(
          margin: EdgeInsets.only(left: 20),
          child: Row(
            children: [
              Container(
                width: 30,
              ),
              Container(
                margin: EdgeInsets.only(bottom: 8, left: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Color(0xFFEAECF2),
                          borderRadius: BorderRadius.circular(9)),
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      padding: EdgeInsets.all(messageBubblePadding),
                      child: Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.6),
                        child: messageWidget ??
                            Text(
                              messageModel.content,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                  color: Color(0xFF63697B), fontSize: 12),
                            ),
                      ),
                    ),
                    Text(
                      timeString,
                      style: TextStyle(fontSize: 10),
                    )
                  ],
                ),
              ),
              Spacer()
            ],
          ),
        );
    }
  }

  getUserStatus() {
    userOnlineListener = firestore
        .collection('users')
        .doc(widget.conversationModel.userId)
        .snapshots()
        .listen((event) {
      if (event.data().containsKey('state') &&
          event.data()['state'] == 'online') {
        if (mounted)
          setState(() {
            userStatus = 'Online';
          });
      } else {
        if (mounted)
          setState(() {
            userStatus = '';
          });
      }
    });
  }

  getMessages() async {
    QuerySnapshot initialMessages = await firestore
        .collection('conversations')
        .doc(widget.conversationModel.conversationId)
        .collection('messages')
        .orderBy('timeStamp', descending: true)
        .limit(20)
        .get();

    if (initialMessages.docs.isNotEmpty)
      lastDocument = initialMessages.docs.last;

    for (var element in initialMessages.docs) {
      messagesList.add(MessageModel.fromJson(element.data()));
    }
    if (mounted) setState(() {});

    messagesListener = firestore
        .collection('conversations')
        .doc(widget.conversationModel.conversationId)
        .collection('messages')
        .orderBy('timeStamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((event) {
      MessageModel newMessage = MessageModel.fromJson(event.docs[0].data());
      if (messagesList.firstWhere(
            (element) => element.messageId == newMessage.messageId,
            orElse: () => null,
          ) ==
          null) {
        messagesList.insert(0, newMessage);
        if (mounted) setState(() {});
      }

      if (newMessage.fromId == widget.conversationModel.userId) {
        Map<String, dynamic> conversationData = Map();
        conversationData['unreadMessages'] = 0;
        firestore
            .collection('conversations')
            .doc(widget.conversationModel.conversationId)
            .set(conversationData, SetOptions(merge: true));
      }
    });
  }

  getPreviousMessages() async {
    if (!allMessagesLoaded) {
      print('getting older messages');
      QuerySnapshot messages = await firestore
          .collection('conversations')
          .doc(widget.conversationModel.conversationId)
          .collection('messages')
          .orderBy('timeStamp', descending: true)
          .limit(20)
          .startAfterDocument(lastDocument)
          .get();

      if (messages.docs.isEmpty) {
        setState(() {
          allMessagesLoaded = true;
        });
      } else {
        lastDocument = messages.docs.last;
        for (var element in messages.docs) {
          messagesList.add(MessageModel.fromJson(element.data()));
        }
        if (mounted) setState(() {});
      }
    }
  }

  clearUnreadCounter() async {
    if (widget.conversationModel.unreadMessagesCounter != 0 &&
        widget.conversationModel.lastMessage.fromId ==
            widget.conversationModel.userId) {
      Map<String, dynamic> conversationData = Map();
      conversationData['unreadMessages'] = 0;
      await firestore
          .collection('conversations')
          .doc(widget.conversationModel.conversationId)
          .set(conversationData, SetOptions(merge: true));
    }
  }

  sendMessage() async {
    UserModel userModel = locator<UserModel>();
    if (imageFile != null) {
      var dir = await getTemporaryDirectory();

      FirebaseStorage storage = FirebaseStorage.instance;
      String fileType = path.extension(imageFile.path);
      String fileName = '${DateTime.now().millisecondsSinceEpoch}$fileType';
      var attachment = await File(path.join(dir.path, fileName))
          .writeAsBytes(await imageFile.readAsBytes());
      print('FileName $fileName');
      String messageId = DateTime.now().millisecondsSinceEpoch.toString();
      MessageModel messageModel = MessageModel(
          messageId: messageId,
          type: "message",
          conversationId: widget.conversationModel.conversationId,
          content: messageEditingController.text,
          toId: widget.conversationModel.userId,
          fromName: userModel.firstName + " " + userModel.lastName,
          attachment: attachment,
          sending: true,
          timeStamp: DateTime.now(),
          fileType: 'image',
          fromId: userModel.userId);
      messageEditingController.clear();

      setState(() {
        messagesList.insert(0, messageModel);
        imageFile = null;
      });

      var attachmentsRef = storage.ref().child('attachments').child(fileName);

      var uploadTask = attachmentsRef.putFile(messageModel.attachment);
      uploadTask.snapshotEvents.listen((event) async {
        int index = messagesList
            .indexWhere((element) => element.messageId == messageId);
        if (event.state == TaskState.running) {
          double progress = event.bytesTransferred / event.totalBytes;
          print('uploading image ${progress * 100}');
          setState(() {
            messagesList[index].progress = progress;
          });
        } else if (event.state == TaskState.success) {
          print('image uploaded');
          attachment.delete();
          var message = messagesList.removeAt(index);
          message.sending = false;
          message.attachment = null;
          message.fileAttachment = await event.ref.getDownloadURL();
          message.progress = null;

          var messagesRef = firestore
              .collection('conversations')
              .doc(widget.conversationModel.conversationId)
              .collection('messages')
              .doc(messageId);

          var conversationsRef = firestore
              .collection('conversations')
              .doc(widget.conversationModel.conversationId);
          Map<String, dynamic> conversationData = Map();
          conversationData['lastMessage'] = message.toJson();
          conversationData['unreadMessages'] = FieldValue.increment(1);

          await firestore.runTransaction((transaction) {
            messagesRef.set(message.toJson());
            conversationsRef.set(conversationData, SetOptions(merge: true));
            return;
          });
          setState(() {});
        } else {
          print('failed to send image');
          attachment.delete();

          setState(() {
            messagesList.removeAt(index);
          });
        }
      });
    } else if (messageEditingController.text.isNotEmpty) {
      String messageId = DateTime.now().millisecondsSinceEpoch.toString();
      MessageModel messageModel = MessageModel(
          messageId: messageId,
          type: "message",
          conversationId: widget.conversationModel.conversationId,
          content: messageEditingController.text,
          toId: widget.conversationModel.userId,
          fromName: userModel.firstName + " " + userModel.lastName,
          fromId: userModel.userId);

      messageEditingController.clear();

      var messagesRef = firestore
          .collection('conversations')
          .doc(widget.conversationModel.conversationId)
          .collection('messages')
          .doc(messageId);

      var conversationsRef = firestore
          .collection('conversations')
          .doc(widget.conversationModel.conversationId);
      Map<String, dynamic> conversationData = Map();
      conversationData['lastMessage'] = messageModel.toJson();
      conversationData['unreadMessages'] = FieldValue.increment(1);
      await firestore.runTransaction((transaction) {
        messagesRef.set(messageModel.toJson());
        conversationsRef.set(conversationData, SetOptions(merge: true));
        return;
      });
    }
  }

  @override
  void dispose() {
    if (messagesListener != null) messagesListener.cancel();
    if (userOnlineListener != null) userOnlineListener.cancel();
    super.dispose();
  }
}
