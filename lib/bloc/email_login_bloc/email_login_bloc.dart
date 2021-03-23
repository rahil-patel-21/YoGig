import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:yogigg_users_app/models/user_model.dart';
import 'package:yogigg_users_app/repository/user_repository.dart';
import 'package:yogigg_users_app/services/login_service.dart';
import 'package:yogigg_users_app/utils/error_handler.dart';
import 'package:yogigg_users_app/utils/service_locator.dart';

part 'email_login_event.dart';
part 'email_login_state.dart';

class EmailLoginBloc extends Bloc<EmailLoginEvent, EmailLoginState> {
  EmailLoginBloc() : super(EmailLoginInitial());

  LoginService _loginService = locator<LoginService>();
  UserRepository _userRepository = locator<UserRepository>();

  @override
  Stream<EmailLoginState> mapEventToState(
    EmailLoginEvent event,
  ) async* {
    yield EmailLoginLoadingState();
    if (event is SignInWithEmailPassword) {
      yield* loginWithEmail(event.email, event.password);
    } else if (event is SignInWithGoogle) {
      yield* loginWithGoogle();
    } else if (event is SignInWithFacebook) {
      yield* loginWithFacebook();
    }
  }

  Stream<EmailLoginState> loginWithEmail(String email, String password) async* {
    try {
      var user = await _loginService.signInWithEmailPassword(email, password);
      _userRepository.setUserId(user.uid);
      if (await _userRepository.isNewUser()) {
        yield NewUserState(user: UserModel.fromFirebaseUser(user));
      } else {
        final userData = await _userRepository.getUserFromFirebase();
        if (locator.isRegistered<UserModel>()) locator.unregister<UserModel>();
        locator.registerSingleton<UserModel>(userData);
        yield LoggedInState();
      }
    } catch (e) {
      print(e);
      yield EmailLoginErrorState(errorMessage: handleAuthError(e));
    }
  }

  Stream<EmailLoginState> loginWithGoogle() async* {
    try {
      var user = await _loginService.signInWithGoogle();
      _userRepository.setUserId(user.uid);
      if (await _userRepository.isNewUser()) {
        yield NewUserState(user: UserModel.fromFirebaseUser(user));
      } else {
        final userData = await _userRepository.getUserFromFirebase();
        if (locator.isRegistered<UserModel>()) locator.unregister<UserModel>();
        locator.registerSingleton<UserModel>(userData);
        yield LoggedInState();
      }
    } catch (e) {
      print(e);
      yield EmailLoginErrorState(
          errorMessage: 'Some Error Occurred! Please try again');
    }
  }

  Stream<EmailLoginState> loginWithFacebook() async* {
    try {
      var user = await _loginService.signInWithFacebook();
      _userRepository.setUserId(user.userId);
      if (await _userRepository.isNewUser()) {
        yield NewUserState(user: user);
      } else {
        final userData = await _userRepository.getUserFromFirebase();
        if (locator.isRegistered<UserModel>()) locator.unregister<UserModel>();
        locator.registerSingleton<UserModel>(userData);
        yield LoggedInState();
      }
    } catch (e) {
      print(e);
      yield EmailLoginErrorState(
          errorMessage: 'Some Error Occurred! Please try again');
    }
  }
}
