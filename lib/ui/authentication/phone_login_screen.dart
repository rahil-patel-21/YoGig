import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:yogigg_users_app/bloc/phone_login_bloc/phone_login_bloc.dart';
import 'package:yogigg_users_app/constants/colors.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:yogigg_users_app/constants/common_widget.dart';
import 'package:yogigg_users_app/constants/styles.dart';
import 'package:yogigg_users_app/utils/router_constants.dart';

import 'package:quiver/async.dart';

class PhoneLoginScreen extends StatefulWidget {
  @override
  _PhoneLoginScreenState createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen>
    with TickerProviderStateMixin {
  PhoneLoginBloc _phoneLoginBloc = PhoneLoginBloc();

  final _phoneNumberFormKey = GlobalKey<FormState>();

  TextEditingController _phoneNumberFieldController = TextEditingController();

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
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
            accentColor1,
            accentColor3,
          ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
          child: SafeArea(
              child: Container(
            height: context.screenHeight,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: context.screenHeight * 0.07,
                      alignment: Alignment.topRight,
                      child: Hero(
                          tag: 'logo_image',
                          child: Image.asset('assets/images/logo_shadow.png')),
                    ),
                    Text(
                      'Enter Mobile Number',
                      style: Theme.of(context).textTheme.headline3.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    buildPhoneLoginForm(),
                  ],
                ),
                RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(children: [
                      TextSpan(
                          text: 'I have read and agree to YoGigg\'s ',
                          style: Theme.of(context).textTheme.caption),
                      TextSpan(
                          text: 'Terms of Use',
                          style: Theme.of(context).textTheme.caption.copyWith(
                              color: blueAccentColor,
                              decoration: TextDecoration.underline)),
                      TextSpan(
                          text: ' & ',
                          style: Theme.of(context).textTheme.caption),
                      TextSpan(
                          text: 'Privacy Policy',
                          style: Theme.of(context).textTheme.caption.copyWith(
                              color: blueAccentColor,
                              decoration: TextDecoration.underline)),
                    ]))
              ],
            ),
          )),
        ),
      ),
    );
  }

  Widget buildPhoneLoginForm() {
    return BlocConsumer<PhoneLoginBloc, PhoneLoginState>(
      listener: (context, state) {
        if (state is LoggedInState || state is NewUserState) {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacementNamed(MainScreenRoute);
        } else if(state is NewUserState){
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacementNamed(UserDetailsScreenRoute,arguments: state.user);
        } 
        else if (state is PhoneLoginErrorState) {
          Flushbar(
            duration: Duration(seconds: 2),
            margin: EdgeInsets.all(8),
            borderRadius: 8,
            message: state.errorMessage,
          )..show(context);
        } else if (state is OtpSentState) {
          showOtpSheet();
        }
      },
      cubit: _phoneLoginBloc,
      builder: (context, state) {
        if (state is PhoneLoginInitial ||
            state is PhoneLoginErrorState ||
            state is OtpSentState) {
          return Column(
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
                          Icons.phone,
                          color: accentColor1,
                        ),
                      )),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Form(
                        key: _phoneNumberFormKey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              maxLength: 10,
                              buildCounter: (context,
                                  {currentLength, isFocused, maxLength}) {
                                return null;
                              },
                              controller: _phoneNumberFieldController,
                              validator: (value) {
                                if (value.length < 10)
                                  return 'Invalid Phone Number';

                                return null;
                              },
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                  prefix: Text('+1 '),
                                  prefixStyle: TextStyle(color: Colors.white),
                                  hintText: 'Phone Number'),
                            ),
                          ],
                        )),
                  ),
                ],
              ),
              SizedBox(
                height: 32,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushReplacementNamed(SignUpScreenRoute);
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
                      onPressed: () {
                        if (_phoneNumberFormKey.currentState.validate())
                          _phoneLoginBloc.add(SendOtpEvent(
                            phoneNumber: _phoneNumberFieldController.text,
                            onVerificationCompletedFunc: (authCredential) {},
                            onVerificationFailed: (authException) {
                              print(authException.message);
                            },
                          ));
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'Next ',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                          ),
                          Icon(FontAwesomeIcons.longArrowAltRight)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        } else
          return Center(
            child: CircularProgressIndicator(),
          );
      },
    );
  }

  showOtpSheet() {
    return showModalBottomSheet(
        isDismissible: false,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12), topRight: Radius.circular(12))),
        context: context,
        builder: (context) {
          return BlocProvider.value(
              value: _phoneLoginBloc,
              child: OtpSheet(_phoneNumberFieldController.text));
        });
  }
}

class OtpSheet extends StatefulWidget {
  final String phoneNumber;
  OtpSheet(this.phoneNumber);
  @override
  _OtpSheetState createState() => _OtpSheetState();
}

class _OtpSheetState extends State<OtpSheet> {
  CountdownTimer _countdownTimer;

  int _start = 30;
  int _current = 30;

  bool timerRunning = true;
  Function onResendPressed = null;

  String otp = '';

  var sub;

  @override
  void initState() {
    startTimer();
    super.initState();
  }

  @override
  void dispose() {
    sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewPadding.bottom + 16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12), topRight: Radius.circular(12)),
          gradient: LinearGradient(colors: [
            accentColor3,
            accentColor1,
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          OTPTextField(
            length: 6,
            width: context.screenWidth - 64,
            onChanged: (value) {
              otp = value;
              print(otp);
            },
            onCompleted: (value) {
              otp = value;
              print(otp);
            },
          ),
          SizedBox(
            height: 16,
          ),
          Text('Please enter 6 digit code we sent on your number as SMS'),
          SizedBox(
            height: 16,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: RaisedButton(
                    elevation: elevation,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    color: accentColor3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: (timerRunning)
                        ? Text('WAIT ${_current}s')
                        : Text('RESEND OTP'),
                    onPressed: onResendPressed),
              ),
              SizedBox(
                width: 16,
              ),
              Expanded(
                child: RaisedButton(
                    elevation: elevation,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    color: accentColor3,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Text('NEXT '),
                    onPressed: () {
                      if (otp.length == 6)
                        BlocProvider.of<PhoneLoginBloc>(context)
                            .add(VerifyOtpEvent(otp: otp));
                      else
                        showSnackbar('Enter full OTP!!', context);
                    }),
              ),
            ],
          )
        ],
      ),
    );
  }

  startTimer() {
    _countdownTimer =
        CountdownTimer(Duration(seconds: _start), Duration(seconds: 1));
    sub = _countdownTimer.listen(null);
    sub.onData((duration) {
      setState(() {
        _current = _start - duration.elapsed.inSeconds;
      });
    });

    sub.onDone(() {
      setState(() {
        timerRunning = false;
        onResendPressed = () {
          BlocProvider.of<PhoneLoginBloc>(context).add(ResendOtpEvent(
            phoneNumber: widget.phoneNumber,
            onVerificationCompletedFunc: (authCredential) {},
            onVerificationFailed: (authException) {
              print(authException.message);
            },
          ));
          setState(() {
            timerRunning = true;
            _current = 30;
            onResendPressed = null;
          });
          startTimer();
        };
      });
      sub.cancel();
    });
  }
}
