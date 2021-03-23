part of 'email_login_bloc.dart';

@immutable
abstract class EmailLoginEvent {}

class SignInWithGoogle extends EmailLoginEvent {}

class SignInWithEmailPassword extends EmailLoginEvent {
  final String email, password;
  SignInWithEmailPassword({this.email, this.password});
}

class SignInWithFacebook extends EmailLoginEvent {}



