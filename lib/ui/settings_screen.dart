import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yogigg_users_app/constants/colors.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
        lowerBound: 0.0,
        upperBound: 1.0,
        vsync: this,
        duration: const Duration(milliseconds: 250));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: accentColor1,
      body: Container(
        child: ListView(
          children: [
            Container(
              margin: EdgeInsets.only(
                  left: 28, top: 98 - MediaQuery.of(context).viewPadding.top),
              child: Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 45,
                ),
              ),
            ),
            SizedBox(
              height: 45,
            ),
            ListTile(
              onTap: () {},
              contentPadding: EdgeInsets.only(left: 28, top: 8, bottom: 8),
              title: Text(
                'Account Info',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.only(left: 28, top: 8, bottom: 8),
              title: Text(
                'Alerts',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.only(left: 28, top: 8, bottom: 8),
              title: Text(
                'Support',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.only(left: 28, top: 8, bottom: 8),
              title: Text(
                'Security',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.only(left: 28, top: 8, bottom: 8),
              title: Text(
                'Privacy',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ),
            SizedBox(
              height: 100,
            ),
            Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: RaisedButton(
                  padding: EdgeInsets.all(0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  onPressed: () async {
                    _animationController.forward();
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return AnimatedBuilder(
                            animation: _animationController,
                            builder: (_, __) {
                              return ScaleTransition(
                                scale: _animationController,
                                child: AlertDialog(
                                  contentPadding: EdgeInsets.all(0),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                  content: Container(
                                    padding: EdgeInsets.symmetric(vertical:24,horizontal: 14),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Log Out?',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                          color: accentColor
                                        ),
                                        ),
                                        SizedBox(height: 14,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            RaisedButton(
                                              padding: EdgeInsets.all(20),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12)
                                              ),
                                              color: Colors.red,
                                              onPressed: () async {
                                                
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Logout',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold
                                              ),
                                              ),
                                            ),
                                            RaisedButton(
                                              padding: EdgeInsets.all(20),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12)
                                              ),
                                              color: accentColor1,
                                              onPressed: () async {
                                                
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Cancel',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold
                                              ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            });
                      },
                    );
                    _animationController.reverse();
                  },
                  color: Color(0xFF4074DE),
                  child: SvgPicture.asset(
                    'assets/svg/logout_icon.svg',
                    height: 24,
                    width: 24,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Center(
              child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Back',
                    style: TextStyle(
                      color: Color(0xFF96A7AF),
                      fontWeight: FontWeight.bold,
                      fontSize: 23,
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
