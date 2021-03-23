part of 'phone_login_bloc.dart';

@immutable
abstract class PhoneLoginEvent {}

class SendOtpEvent extends PhoneLoginEvent {
  final String phoneNumber;
  final Function(AuthCredential) onVerificationCompletedFunc;
  final Function(FirebaseAuthException) onVerificationFailed;
  SendOtpEvent(
      {this.phoneNumber,
      this.onVerificationCompletedFunc,
      this.onVerificationFailed});
}

class VerifyOtpEvent extends PhoneLoginEvent {
  final String otp;
  VerifyOtpEvent({this.otp});
}

class ResendOtpEvent extends PhoneLoginEvent {
  final String phoneNumber;
  final Function(AuthCredential) onVerificationCompletedFunc;
  final Function(FirebaseAuthException) onVerificationFailed;
  ResendOtpEvent(
      {this.phoneNumber,
      this.onVerificationCompletedFunc,
      this.onVerificationFailed});
}
