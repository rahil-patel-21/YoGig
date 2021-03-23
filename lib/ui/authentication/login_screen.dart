import 'package:flushbar/flushbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:yogigg_users_app/bloc/email_login_bloc/email_login_bloc.dart';
import 'package:yogigg_users_app/constants/colors.dart';
import 'package:yogigg_users_app/constants/common_widget.dart';
import 'package:yogigg_users_app/constants/styles.dart';
import 'package:yogigg_users_app/utils/router_constants.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool showPassword = false;

  final _emailPasswordFormKey = GlobalKey<FormState>();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  EmailLoginBloc _emailLoginBloc = EmailLoginBloc();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark
      ),
          child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: getNoAppBarTheme(context),
        resizeToAvoidBottomInset: false,
        resizeToAvoidBottomPadding: false,
        body: Container(
          padding: EdgeInsets.only(right: 24, left: 24, bottom: 24),
          decoration: BoxDecoration(
              color: Colors.red,
              gradient: LinearGradient(colors: [
                accentColor1,
                accentColor3,
              ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
          child: SafeArea(
            child: BlocConsumer<EmailLoginBloc, EmailLoginState>(
              cubit: _emailLoginBloc,
              listener: (context, state) {
                if (state is LoggedInState) {
                  Navigator.of(context).pushReplacementNamed(MainScreenRoute);
                } else if (state is NewUserState) {
                  Navigator.of(context)
                      .pushReplacementNamed(UserDetailsScreenRoute,arguments: state.user);
                } else if (state is EmailLoginErrorState) {
                  Flushbar(
                    duration: Duration(seconds: 2),
                    margin: EdgeInsets.all(8),
                    borderRadius: 8,
                    message: state.errorMessage,
                  )..show(context);
                  _passwordController.clear();
                }
              },
              builder: (context, state) {
                if (state is EmailLoginInitial || state is EmailLoginErrorState) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  height: context.screenHeight * 0.07,
                                  alignment: Alignment.topRight,
                                  child: Hero(
                                      tag: 'logo_image',
                                      child: Image.asset(
                                          'assets/images/logo_shadow.png')),
                                ),
                                Text(
                                  'Yo!',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline3
                                      .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Log in to continue',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5
                                      .copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                            Center(child: buildEmailPasswordForm()),
                          ],
                        ),
                      ),
                      Column(
                        children: <Widget>[
                          Center(
                            child: SizedBox(
                              width: context.screenWidth * 0.7,
                              child: RaisedButton(
                                  elevation: elevation,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  color: accentColor1,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16.0),
                                    child: Text(
                                      'Sign Up',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pushReplacementNamed(SignUpScreenRoute);
                                  }),
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(children: [
                                TextSpan(
                                    text: 'I have read and agree to YoGigg\'s ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .copyWith(
                                          fontSize: 8,
                                        )),
                                TextSpan(
                                    text: 'Terms of Use ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .copyWith(
                                            fontSize: 10,
                                            color: accentColor,
                                            decoration:
                                                TextDecoration.underline)),
                                TextSpan(
                                    text: 'and ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .copyWith(fontSize: 8)),
                                TextSpan(
                                    text: 'Privacy Policy',
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        .copyWith(
                                            fontSize: 10,
                                            color: accentColor,
                                            decoration: TextDecoration.underline))
                              ]))
                        ],
                      )
                    ],
                  );
                } else
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 8,
                        ),
                        Text('Loading')
                      ],
                    ),
                  );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEmailPasswordForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(4),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  child: Form(
                    key: _emailPasswordFormKey,
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Card(
                                elevation: elevation,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                color: accentColor3,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.email,
                                    color: accentColor1,
                                  ),
                                )),
                            SizedBox(
                              width: 16,
                            ),
                            Expanded(
                              child: TextFormField(
                                validator: (email) {
                                  if (email.contains('@') &&
                                      email.contains('.com')) return null;

                                  return 'Please Enter Valid Email';
                                },
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(hintText: 'Email'),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Row(
                          children: <Widget>[
                            Card(
                                elevation: elevation,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                color: accentColor3,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.lock,
                                    color: accentColor1,
                                  ),
                                )),
                            SizedBox(
                              width: 16,
                            ),
                            Expanded(
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: !showPassword,
                                keyboardType: TextInputType.visiblePassword,
                                validator: (password) {
                                  if (password.length < 8)
                                    return 'Password Too Short';

                                  return null;
                                },
                                decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                        icon: (showPassword)
                                            ? Icon(FontAwesomeIcons.eye)
                                            : ImageIcon(Image.asset(
                                                    'assets/images/password_hidden.png')
                                                .image),
                                        onPressed: () {
                                          setState(() {
                                            showPassword = !showPassword;
                                          });
                                        }),
                                    hintText: 'Password'),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                  alignment: Alignment.center,
                  child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32)),
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed(ForgotPasswordScreenRoute);
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.grey),
                      ))),
              SizedBox(
                height: 8,
              ),
              Container(
                width: context.screenWidth * 0.7,
                height: 136,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      top: 24,
                      bottom: 24,
                      right: 0,
                      left: 0,
                      child: Card(
                        elevation: elevation,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        color: accentColor1,
                        child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              'OR',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            )),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 64,
                      right: 64,
                      child: RaisedButton(
                        elevation: elevation,
                        padding: EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        color: accentColor3,
                        onPressed: () {
                          if (_emailPasswordFormKey.currentState.validate())
                            _emailLoginBloc.add(SignInWithEmailPassword(
                                email: _emailController.text,
                                password: _passwordController.text));
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Text(
                          'Log In',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                    ),
                    Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Card(
                              elevation: elevation,
                              color: Colors.white,
                              child: IconButton(
                                  icon: Icon(
                                    FontAwesomeIcons.phoneAlt,
                                    color: accentColor,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pushReplacementNamed(
                                        PhoneLoginScreenRoute);
                                  }),
                            ),
                            Card(
                              elevation: elevation,
                              color: Colors.white,
                              child: InkWell(
                                onTap: () {
                                  _emailLoginBloc.add(SignInWithGoogle());
                                },
                                child: Container(
                                    padding: EdgeInsets.all(8),
                                    child: Image.asset(
                                      'assets/images/gicon.png',
                                      height: 32,
                                    )),
                              ),
                            ),
                            Card(
                              elevation: elevation,
                              color: Colors.white,
                              child: IconButton(
                                  icon: Icon(
                                    FontAwesomeIcons.facebookF,
                                    color: Color.fromRGBO(59, 89, 152, 1.0),
                                  ),
                                  onPressed: () {
                                    _emailLoginBloc.add(SignInWithFacebook());
                                  }),
                            ),
                            Card(
                              elevation: elevation,
                              color: Colors.white,
                              child: IconButton(
                                  icon: Icon(
                                    FontAwesomeIcons.apple,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {}),
                            )
                          ],
                        ))
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
