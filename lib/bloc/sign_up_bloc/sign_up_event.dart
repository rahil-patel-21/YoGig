part of 'sign_up_bloc.dart';

@immutable
abstract class SignUpEvent {}

class SignUpUser extends SignUpEvent {
  final String email, password;
  SignUpUser({this.email, this.password});
}

class SignUpWithGoogle extends SignUpEvent{}

class SignUpWithFacebook extends SignUpEvent{}
