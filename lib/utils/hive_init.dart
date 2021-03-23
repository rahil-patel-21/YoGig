import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:yogigg_users_app/models/user_model.dart';

setUpHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());
}

const String UserBoxName = 'userBox';
