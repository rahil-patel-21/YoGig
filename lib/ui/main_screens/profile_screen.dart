import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:yogigg_users_app/constants/colors.dart';
import 'package:yogigg_users_app/models/user_model.dart';
import 'package:yogigg_users_app/utils/router_constants.dart';
import 'package:yogigg_users_app/utils/service_locator.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = locator<UserModel>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Container(
              height: context.screenHeight * 0.35,
              child: Stack(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top+8,
                    left: 18,
                    right: 18
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
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
                                SizedBox(width: 8,),
                                Text('${user.firstName} ${user.lastName}',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                )
                              ],
                            ),
                            InkWell(
                              onTap: () => Navigator.of(context).pushNamed(SettingsScreenRoute),
                              child: SvgPicture.asset('assets/svg/settings_icon.svg'),
                            )
                          ],
                        )
                      ],
                    ),
                      height: context.screenHeight * 0.25,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                            accentColor1,
                            accentColor3,
                          ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter))),
                  Positioned(
                    right: 24.0,
                    bottom: 8,
                    child: Container(
                      height: 170,
                      padding: EdgeInsets.all(8),
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: accentColor3,
                            offset: Offset(4, 4),
                            blurRadius: 8,
                          )
                        ]
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text('Giggcode'),
                          QrImage(
                            foregroundColor: Color(0xFF0185D0),
                              embeddedImage:
                                  AssetImage('assets/images/logo.png'),
                              data: user.userId),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
