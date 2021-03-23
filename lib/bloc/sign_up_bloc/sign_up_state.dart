part of 'sign_up_bloc.dart';

@immutable
abstract class SignUpState {}

class SignUpInitial extends SignUpState {}

class SignUpLoadingState extends SignUpState {}

class SignUpErrorState extends SignUpState {
  final String errorMessage;
  SignUpErrorState({this.errorMessage});
}

class NewUserState extends SignUpState {
  final UserModel user;
  NewUserState({this.user});
}

class LoggedInState extends SignUpState {}
