part of 'splash_bloc.dart';

@immutable
abstract class SplashState {}

class SplashInitial extends SplashState {}

class NotLoggedIn extends SplashState {
}

class LoggedIn extends SplashState {
  LoggedIn();
}
