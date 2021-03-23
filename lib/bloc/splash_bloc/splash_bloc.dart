import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:yogigg_users_app/models/user_model.dart';
import 'package:yogigg_users_app/repository/user_repository.dart';
import 'package:yogigg_users_app/services/login_service.dart';
import 'package:yogigg_users_app/utils/service_locator.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitial());
  LoginService _loginService = locator<LoginService>();
  UserRepository _userRepository = locator<UserRepository>();

  @override
  Stream<SplashState> mapEventToState(
    SplashEvent event,
  ) async* {
    if (event is GetLoginInfo) {
      if (await _loginService.isSignedIn()) {
        var user = await _loginService.getUser();
        _userRepository.setUserId(user.uid);

        final userData = await _userRepository.getUserFromLocalStorage();
        if (userData == null) {
          _loginService.signOut();
          yield NotLoggedIn();
        } else {
         locator.registerSingleton<UserModel>(userData);
          yield LoggedIn();
        }
      } else
        yield NotLoggedIn();
    }
  }
}
