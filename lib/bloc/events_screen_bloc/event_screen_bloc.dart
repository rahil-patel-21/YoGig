import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'event_screen_event.dart';
part 'event_screen_state.dart';

class EventScreenBloc extends Bloc<EventScreenEvent, EventScreenState> {
  EventScreenBloc() : super(EventScreenInitial());

  @override
  Stream<EventScreenState> mapEventToState(
    EventScreenEvent event,
  ) async* {
    // TODO: implement mapEventToState
  }
}
