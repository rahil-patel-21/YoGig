import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yogigg_users_app/models/conversation_model.dart';
import 'package:yogigg_users_app/models/user_model.dart';
import 'package:yogigg_users_app/ui/custom_shapes/custom_app_bar.dart';
import 'package:yogigg_users_app/utils/router_constants.dart';
import 'package:yogigg_users_app/utils/service_locator.dart';
import 'package:yogigg_users_app/utils/time_helper.dart';

class MessagesScreen extends StatefulWidget {
  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<ConversationModel> conversations = List();
  StreamSubscription conversationsListener;

  @override
  void initState() {
    getUserConversations();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: kToolbarHeight,
        ),
      ),
      resizeToAvoidBottomInset: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: SvgPicture.asset('assets/svg/new_chat_icon.svg'),
      ),
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
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    height: 180,
                  ),
                ),
                (conversations.length == 0)
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                        ConversationModel conversationModel =
                            conversations[index];
                        return ListTile(
                          selected: conversationModel.unreadMessagesCounter!=0 && conversationModel.lastMessage.fromId == conversationModel.userId,
                          trailing: Column(
                            children: [
                              Text(
                                conversationTimestamp(conversationModel.lastUpdated)
                              ),
                              (conversationModel.unreadMessagesCounter!=0 && conversationModel.lastMessage.fromId == conversationModel.userId)?CircleAvatar(
                                radius: 15,
                                child: Text(conversationModel.unreadMessagesCounter.toString()),):Offstage()
                            ],
                          ),
                          dense: false,
                          onTap: () {
                            Navigator.of(context).pushNamed(ChatScreenRoute,
                                arguments: conversationModel);
                          },
                          leading: SizedBox(
                            width: 60,
                            child: ClipOval(
                              child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  height: 70,
                                  width: 70,
                                  imageUrl: conversationModel.photoURL),
                            ),
                          ),
                          title: Text(conversationModel.userName),
                          subtitle: Text(conversationModel.lastMessage.content),
                        );
                      }, childCount: conversations.length)),
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.only(bottom: kToolbarHeight + 30),
                  ),
                )
              ],
            ),
            Container(
              child: buildAppBar(context),
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
                  margin: EdgeInsets.only(top: 23, left: 42),
                  child: Text(
                    'Messages',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                buildSearchBar()
              ],
            ),
          )
        ],
      ),
    );
  }

  Container buildSearchBar() {
    return Container(
      height: 56,
      margin: EdgeInsets.only(left: 36, right: 31, top: 14),
      child: Stack(
        children: [
          Center(
            child: Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(right: 5),
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(15)),
              child: Container(
                width: 300,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: TextField(
                  maxLines: 1,
                  //controller: searchEditingController,
                  style: TextStyle(fontSize: 22.0),
                  decoration: InputDecoration(border: InputBorder.none),
                ),
              ),
            ),
          ),
          Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: InkWell(
                onTap: () {
                  // if (searchEditingController.text.isNotEmpty) {
                  //   search(searchEditingController.text);
                  // }
                },
                child: Container(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    child: SvgPicture.asset(
                      'assets/svg/search_icon.svg',
                    ),
                  ),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF0185D0), Color(0xFF512989)])),
                ),
              ))
        ],
      ),
    );
  }

  getUserConversations() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      UserModel userModel = locator<UserModel>();
      QuerySnapshot querySnapshot = await firestore
          .collection('conversations')
          .where('users', arrayContains: userModel.userId)
          .get();

      for (var element in querySnapshot.docs) {
        conversations
            .add(ConversationModel.fromJson(element.data(), userModel.userId));
      }
      if (mounted) setState(() {});

      conversationsListener = firestore
          .collection('conversations')
          .where('users', arrayContains: userModel.userId)
          .limit(1)
          .snapshots()
          .listen((event) {
        ConversationModel model =
            ConversationModel.fromJson(event.docs[0].data(), userModel.userId);
        if (conversations.firstWhere(
              (element) => element.conversationId == model.conversationId,
              orElse: () => null,
            ) !=
            null) {
          var index = conversations.indexWhere(
              (element) => element.conversationId == model.conversationId);
          conversations.removeAt(index);
          conversations.insert(index, model);
        } else {
          conversations.insert(0, model);
        }
        setState(() {
        });
      });
    } catch (e) {
      print(e);
      throw e;
    }
  }

  @override
  void dispose() {
    if (conversationsListener != null) conversationsListener.cancel();
    super.dispose();
  }
}
