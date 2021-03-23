import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:yogigg_users_app/models/user_model.dart';
import 'package:yogigg_users_app/repository/user_repository.dart';
import 'package:yogigg_users_app/utils/service_locator.dart';

part 'user_details_event.dart';
part 'user_details_state.dart';

class UserDetailsBloc extends Bloc<UserDetailsEvent, UserDetailsState> {
  UserDetailsBloc() : super(UserDetailsInitial());
  UserRepository _userRepository = locator<UserRepository>();

  @override
  Stream<UserDetailsState> mapEventToState(
    UserDetailsEvent event,
  ) async* {
    yield UserDetailsLoadingState();

    if (event is UpdateUserDetails) {
      try {
        await _userRepository.updateUserInfo(event.userModel);
        if (locator.isRegistered<UserModel>()) locator.unregister<UserModel>();
        locator.registerSingleton<UserModel>(event.userModel);
        yield UserDetailsUpdatedState();
      } catch (e) {
        print(e);
        yield UserDetailsErrorState();
      }
    }
  }
}
