import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:yogigg_users_app/models/user_model.dart';
import 'package:yogigg_users_app/repository/user_repository.dart';
import 'package:yogigg_users_app/services/login_service.dart';
import 'package:yogigg_users_app/utils/service_locator.dart';

part 'phone_login_event.dart';
part 'phone_login_state.dart';

class PhoneLoginBloc extends Bloc<PhoneLoginEvent, PhoneLoginState> {
  PhoneLoginBloc() : super(PhoneLoginInitial());

  LoginService _loginService = locator<LoginService>();
  UserRepository _userRepository = locator<UserRepository>();

  @override
  Stream<PhoneLoginState> mapEventToState(
    PhoneLoginEvent event,
  ) async* {
    yield PhoneLoginLoadingState();

    if (event is SendOtpEvent) {
      yield* sendOtp(event);
    } else if (event is VerifyOtpEvent) {
      yield* verifyOtp(event);
    } else if (event is ResendOtpEvent) {
      _loginService.resendOtp(event.phoneNumber,
          event.onVerificationCompletedFunc, event.onVerificationFailed);
    }
  }

  Stream<PhoneLoginState> sendOtp(SendOtpEvent event) async* {
    try {
      await _loginService.sendOtp(event.phoneNumber,
          event.onVerificationCompletedFunc, event.onVerificationFailed);
      yield OtpSentState();
    } catch (e) {
      print(e);
      yield PhoneLoginErrorState(errorMessage: 'Error Sending Otp! Try Again');
    }
  }

  Stream<PhoneLoginState> verifyOtp(VerifyOtpEvent event) async* {
    try {
      final user = await _loginService.signInWithSmsCode(event.otp);
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
      yield PhoneLoginErrorState(
          errorMessage: 'Error Verifying Otp! Try Again');
    }
  }
}
