part of 'user_details_bloc.dart';

@immutable
abstract class UserDetailsEvent {}

class UpdateUserDetails extends UserDetailsEvent {
  final UserModel userModel;
  UpdateUserDetails(this.userModel);
}
