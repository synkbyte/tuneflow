import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'state_event.dart';
part 'state_state.dart';

class StateBloc extends Bloc<StateEvent, StateState> {
  StateBloc() : super(StateInitial()) {
    on<StateChangeIndex>((event, emit) {
      emit(StateIndexChanged(event.index));
    });
    on<ProfileChangeIndex>((event, emit) {
      emit(ProfileIndexChanged(event.index));
    });
  }
}
