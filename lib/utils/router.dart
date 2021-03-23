

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yogigg_users_app/ui/authentication/forgot_password_screen.dart';
import 'package:yogigg_users_app/ui/authentication/phone_login_screen.dart';
import 'package:yogigg_users_app/ui/authentication/sign_up_screen.dart';
import 'package:yogigg_users_app/ui/chat_screen.dart';
import 'package:yogigg_users_app/ui/main_screens/gigg_search/search_filters_screen.dart';
import 'package:yogigg_users_app/ui/main_screens/main_screen.dart';
import 'package:yogigg_users_app/ui/settings_screen.dart';
import 'package:yogigg_users_app/ui/splash_screen.dart';
import 'package:yogigg_users_app/ui/authentication/login_screen.dart';
import 'package:yogigg_users_app/ui/authentication/user_details_screen.dart';
import 'package:yogigg_users_app/utils/router_constants.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case SplashScreenRoute:
      return MaterialPageRoute(builder: (context) => SplashScreen());
    case LoginScreenRoute:
      return MaterialPageRoute(builder: (context) => LoginScreen());
    case PhoneLoginScreenRoute:
      return MaterialPageRoute(builder: (context) => PhoneLoginScreen());
    case SignUpScreenRoute:
      return MaterialPageRoute(builder: (context) => SignUpScreen());
    case UserDetailsScreenRoute:
      return MaterialPageRoute(
          builder: (context) => UserDetailsScreen(
                userModel: settings.arguments,
              ));
    case MainScreenRoute:
      return MaterialPageRoute(builder: (context) => MainScreen());
    case ForgotPasswordScreenRoute:
      return MaterialPageRoute(builder: (context) => ForgotPasswordScreen());
    case SearchFiltersScreenRoute:
      return MaterialPageRoute(
          fullscreenDialog: true, builder: (context) => SearchFiltersScreen());
    case SettingsScreenRoute:
      return MaterialPageRoute(
          fullscreenDialog: true, builder: (context) => SettingsScreen());
    case ChatScreenRoute:
      return MaterialPageRoute(builder: (context) => ChatScreen(settings.arguments));

    default:
  }
}
