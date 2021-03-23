import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';

Widget getNoAppBarTheme(BuildContext context) {
  return PreferredSize(
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      preferredSize: Size(MediaQuery.of(context).size.width, 0));
}

Widget showSnackbar(String message, BuildContext context) {
  Flushbar(
    duration: Duration(seconds: 2),
    margin: EdgeInsets.all(8),
    borderRadius: 8,
    message: message,
  )..show(context);
}
