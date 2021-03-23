part of 'phone_login_bloc.dart';

@immutable
abstract class PhoneLoginState {}

class PhoneLoginInitial extends PhoneLoginState {}

class LoggedInState extends PhoneLoginState {}

class NewUserState extends PhoneLoginState {
  final UserModel user;
  NewUserState({this.user});
}

class OtpSentState extends PhoneLoginState {}

class PhoneLoginLoadingState extends PhoneLoginState {}

class PhoneLoginErrorState extends PhoneLoginState {
  final String errorMessage;
  PhoneLoginErrorState({this.errorMessage});
}
