import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:yogigg_users_app/models/user_model.dart';
import 'package:yogigg_users_app/repository/user_repository.dart';
import 'package:yogigg_users_app/services/login_service.dart';
import 'package:yogigg_users_app/utils/error_handler.dart';
import 'package:yogigg_users_app/utils/service_locator.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  SignUpBloc() : super(SignUpInitial());

  LoginService _loginService = locator<LoginService>();
  UserRepository _userRepository = locator<UserRepository>();

  @override
  Stream<SignUpState> mapEventToState(
    SignUpEvent event,
  ) async* {
    yield SignUpLoadingState();

    if (event is SignUpUser) {
      yield* signUpUser(event);
    } else if (event is SignUpWithGoogle) {
      yield* loginWithGoogle();
    } else if (event is SignUpWithFacebook) {
      yield* loginWithFacebook();
    }
  }

  Stream<SignUpState> signUpUser(SignUpUser event) async* {
    try {
      var user =
          await _loginService.createUserAccount(event.email, event.password);
      _userRepository.setUserId(user.uid);
      yield NewUserState(user: UserModel.fromFirebaseUser(user));
    } catch (e) {
      print(e);
      yield SignUpErrorState(errorMessage: handleAuthError(e));
    }
  }

  Stream<SignUpState> loginWithGoogle() async* {
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
      yield SignUpErrorState(
          errorMessage: 'Some Error Occurred! Please try again');
    }
  }

  Stream<SignUpState> loginWithFacebook() async* {
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
      yield SignUpErrorState(
          errorMessage: 'Some Error Occurred! Please try again');
    }
  }
}
