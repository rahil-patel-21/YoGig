part of 'email_login_bloc.dart';

@immutable
abstract class EmailLoginState {}

class EmailLoginInitial extends EmailLoginState {}

class LoggedInState extends EmailLoginState {}

class NewUserState extends EmailLoginState {
  final UserModel user;
  NewUserState({this.user});
}

class EmailLoginLoadingState extends EmailLoginState {}

class EmailLoginErrorState extends EmailLoginState {
  final String errorMessage;
  EmailLoginErrorState({this.errorMessage});
}
