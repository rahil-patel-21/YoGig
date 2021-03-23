import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:yogigg_users_app/bloc/splash_bloc/splash_bloc.dart';
import 'package:yogigg_users_app/constants/colors.dart';
import 'package:yogigg_users_app/constants/common_widget.dart';
import 'package:yogigg_users_app/constants/styles.dart';
import 'package:yogigg_users_app/utils/router_constants.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  AnimationController _iconController;
  Animation _iconAnimation;

  AnimationController _captionTextController;
  Animation _captionTextAnimation;

  AnimationController _moneyBagController;
  Animation _moneyBagAnimation;

  AnimationController _moneyBagfadeAnimController;
  Animation _moneyBagFadeAnimation;

  int animDurationMs = 1000;

  LinearGradient gradient = LinearGradient(colors: [
    Color.fromRGBO(72, 33, 96, 1.0),
    Color.fromRGBO(193, 29, 93, 1.0)
  ], begin: Alignment.bottomCenter, end: Alignment.topCenter);

  double topPadding = 4;

  Color centerColor = accentColor3;

  SplashBloc _splashBloc = SplashBloc();

  @override
  void initState() {
    startAnimation();
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent));
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: getNoAppBarTheme(context),
      body: Center(
        child: BlocListener<SplashBloc, SplashState>(
          cubit: _splashBloc,
          listener: (context, state) {
            if (state is LoggedIn) {
              Navigator.of(context).pushReplacementNamed(MainScreenRoute);
            } else Navigator.of(context).pushReplacementNamed(SignUpScreenRoute);
          },
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              accentColor1,
              accentColor3,
            ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: Stack(
              children: <Widget>[
                Positioned(
                    left: -(context.screenHeight * 0.25),
                    top: context.screenHeight * 0.2,
                    child: Container(
                      width: context.screenHeight * 0.5,
                      height: context.screenHeight * 0.5,
                      decoration: BoxDecoration(
                          color: accentColor3, shape: BoxShape.circle),
                    )),
                Positioned(
                  right: -10,
                  top: context.screenHeight * 0.6,
                  child: Card(
                    elevation: elevation,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    color: accentColor3,
                    child: Container(
                      width: 100,
                      height: 130,
                    ),
                  ),
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    height: context.screenHeight,
                    width: context.screenWidth,
                    color: Colors.transparent,
                  ),
                ),
                Positioned(
                  right: -70,
                  top: -20,
                  child: Card(
                    elevation: elevation,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    color: accentColor3,
                    child: Container(
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -50,
                  left: -10,
                  child: Card(
                    elevation: elevation,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    color: accentColor3,
                    child: Container(
                      width: context.screenWidth * 0.25 + 10,
                      height: 100,
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: context.screenWidth * 0.8,
                        child: Stack(
                          fit: StackFit.loose,
                          children: <Widget>[
                            Container(
                              alignment: Alignment.center,
                              child:
                                  Image.asset('assets/images/yGigg_icon.png'),
                            ),
                            AnimatedPositioned(
                                duration: Duration(milliseconds: 500),
                                left: context.screenWidth * 0.15,
                                top: topPadding,
                                bottom: 4,
                                child: Transform(
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.001)
                                    ..rotateX(_iconAnimation.value),
                                  alignment: FractionalOffset.bottomCenter,
                                  child: AnimatedContainer(
                                      alignment: Alignment.center,
                                      width: context.screenWidth * 0.15,
                                      height: context.screenWidth * 0.15,
                                      child: Container(
                                        width: context.screenWidth * 0.15 - 28,
                                        height: context.screenWidth * 0.15 - 28,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: centerColor,
                                        ),
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: gradient,
                                        shape: BoxShape.circle,
                                      ),
                                      duration: Duration(milliseconds: 500)),
                                )),
                            Positioned(
                              left: context.screenWidth * 0.11,
                              top: 4,
                              child: Transform.translate(
                                offset: Offset(0, _moneyBagAnimation.value),
                                child: FadeTransition(
                                  opacity: _moneyBagFadeAnimation,
                                  child: Hero(
                                    tag: 'logo_image',
                                    child: Image.asset(
                                      'assets/images/logo.png',
                                      width: context.screenWidth * 0.25,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      ScaleTransition(
                          scale: _captionTextAnimation,
                          child: Text(
                            'Freedom to secure flexible funds',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void startAnimation() async {
    _iconController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    _iconAnimation = Tween<double>(begin: 0.0, end: 1.5)
        .chain(CurveTween(curve: Curves.bounceOut))
        .animate(_iconController);

    _captionTextController = AnimationController(
        vsync: this, duration: Duration(milliseconds: animDurationMs));
    _captionTextAnimation = CurvedAnimation(
        parent: _captionTextController, curve: Curves.elasticOut);

    _moneyBagController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    _moneyBagAnimation = Tween<double>(begin: -100.0, end: 0.0)
        .chain(CurveTween(curve: Curves.bounceOut))
        .animate(_moneyBagController);

    _moneyBagfadeAnimController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    _moneyBagFadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(_moneyBagfadeAnimController);

    _iconAnimation.addListener(() {
      setState(() {});
    });

    _moneyBagAnimation.addListener(() {
      setState(() {});
    });

    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      topPadding = 48;

      gradient = LinearGradient(colors: [
        Color.fromRGBO(0, 0, 0, 0.26),
        Color.fromRGBO(0, 0, 0, 0.26)
      ], begin: Alignment.bottomCenter, end: Alignment.topCenter);
    });
    _moneyBagfadeAnimController.forward();
    _iconController.forward();

    _moneyBagController.forward();

    await Future.delayed(Duration(milliseconds: 250));
    _captionTextController.forward();
    setState(() {
      centerColor = Colors.transparent;
    });
    await Future.delayed(Duration(milliseconds: 1750));
    _splashBloc.add(GetLoginInfo());
  }

  @override
  void dispose() {
    _iconController.dispose();
    _moneyBagController.dispose();
    _captionTextController.dispose();
    _moneyBagfadeAnimController.dispose();
    super.dispose();
  }
}
