import 'package:get_it/get_it.dart';
import 'package:yogigg_users_app/repository/events_repository.dart';
import 'package:yogigg_users_app/repository/user_repository.dart';
import 'package:yogigg_users_app/services/login_service.dart';

GetIt locator = GetIt.instance;

setupServiceLocator() {
  locator.registerLazySingleton<LoginService>(() => LoginService());
  locator.registerLazySingleton<UserRepository>(() => UserRepository());
  locator.registerLazySingleton<EventsRepository>(() => EventsRepository());
}
