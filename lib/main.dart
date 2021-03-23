import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yogigg_users_app/constants/colors.dart';
import 'package:yogigg_users_app/utils/hive_init.dart';
import 'package:yogigg_users_app/utils/router.dart';
import 'package:yogigg_users_app/utils/router_constants.dart';
import 'package:yogigg_users_app/utils/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupServiceLocator();
  await Firebase.initializeApp();
  await setUpHive();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YoGigg',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: generateRoute,
      initialRoute: SplashScreenRoute,
      theme: ThemeData(
        primaryColor: accentColor1,
        textTheme: GoogleFonts.karlaTextTheme(Theme.of(context).textTheme),
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container());
  }
}
