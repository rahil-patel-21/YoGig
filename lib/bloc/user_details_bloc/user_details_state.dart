part of 'user_details_bloc.dart';

@immutable
abstract class UserDetailsState {}

class UserDetailsInitial extends UserDetailsState {}

class UserDetailsLoadingState extends UserDetailsState{}

class UserDetailsUpdatedState extends UserDetailsState{}

class UserDetailsErrorState extends UserDetailsState{}
