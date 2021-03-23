import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yogigg_users_app/constants/colors.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:yogigg_users_app/constants/common_widget.dart';
import 'package:yogigg_users_app/constants/styles.dart';
import 'package:yogigg_users_app/utils/error_handler.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailPasswordFormKey = GlobalKey<FormState>();

  TextEditingController _emailController = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(brightness: Brightness.dark),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: getNoAppBarTheme(context),
        resizeToAvoidBottomInset: false,
        body: Container(
          padding: EdgeInsets.only(right: 24, left: 24, bottom: 16, top: 16),
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            accentColor1,
            accentColor3,
          ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
          child: SafeArea(
            child: (loading)
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            height: context.screenHeight * 0.07,
                            alignment: Alignment.topRight,
                            child: Hero(
                                tag: 'logo_image',
                                child: Image.asset('assets/images/logo.png')),
                          ),
                          Text(
                            'Enter Email address',
                            style: Theme.of(context)
                                .textTheme
                                .headline3
                                .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'to reset password',
                            style: Theme.of(context)
                                .textTheme
                                .headline6
                                .copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Form(
                        key: _emailPasswordFormKey,
                        child: TextFormField(
                          validator: (email) {
                            if (email.contains('@') && email.contains('.com'))
                              return null;

                            return 'Please Enter Valid Email';
                          },
                          onFieldSubmitted: sendResetPasswordLink,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(hintText: 'Email'),
                        ),
                      ),
                      SizedBox(
                        height: 32,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: RaisedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              color: accentColor1,
                              elevation: elevation,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: Icon(
                                FontAwesomeIcons.longArrowAltLeft,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            flex: 4,
                            child: RaisedButton(
                              elevation: elevation,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              color: accentColor3,
                              onPressed: sendResetPasswordLink,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    'Next ',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Icon(FontAwesomeIcons.longArrowAltRight)
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  void sendResetPasswordLink([String email]) async {
    if (_emailPasswordFormKey.currentState.validate())
      try {
        showSnackbar(
            'Password Reset Link sent to ${_emailController.text}.', context);
        var firebaseAuth = FirebaseAuth.instance;
        firebaseAuth.sendPasswordResetEmail(
            email: _emailController.text.toString());

        Navigator.of(context).pop();
      } catch (e) {
        showSnackbar(handleAuthError(e), context);
        print('error sending email ${e.toString()}');
      }
  }
}
