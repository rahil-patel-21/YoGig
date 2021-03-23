import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yogigg_users_app/constants/colors.dart';
import 'package:yogigg_users_app/models/user_model.dart';
import 'package:yogigg_users_app/utils/service_locator.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final user = locator<UserModel>();
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 4,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              expandedHeight: 187,
              flexibleSpace: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                      gradient: LinearGradient(
                          colors: [
                            accentColor3,
                            accentColor1,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight)),
                  child: SafeArea(
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Container(
                                height: 64,
                                width: 64,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                          offset: Offset(0, 4), blurRadius: 4)
                                    ]),
                                child: ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: user.userPhotoURL,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(left: 15),
                                  height: 45,
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: TextField(
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15)),
                                ),
                              )
                            ],
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.only(top: 15),
                            child: Stack(
                              children: [
                                Divider(
                                  color: Colors.white,
                                  thickness: 1,
                                ),
                                AnimatedPositioned(
                                    top: 8,
                                    left: 26 +
                                        ((MediaQuery.of(context).size.width /
                                                4) *
                                            index),
                                    child: Container(
                                      height: 4,
                                      width: 50,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(100),
                                              bottomRight:
                                                  Radius.circular(100))),
                                    ),
                                    duration: Duration(milliseconds: 250))
                              ],
                            )),
                        Container(
                          child: TabBar(
                              onTap: (value) {
                                setState(() {
                                  index = value;
                                });
                              },
                              indicator: BoxDecoration(),
                              tabs: [
                                Tab(
                                  icon: SvgPicture.asset(
                                      'assets/svg/feed_icon.svg'),
                                ),
                                Tab(
                                  icon: SvgPicture.asset(
                                      'assets/svg/create_post_icon.svg'),
                                ),
                                Tab(
                                  icon: SvgPicture.asset(
                                      'assets/svg/haps_icon.svg'),
                                ),
                                Tab(
                                  icon: SvgPicture.asset(
                                      'assets/svg/feed_search_icon.svg'),
                                ),
                              ]),
                        )
                      ],
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
