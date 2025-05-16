import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'my_player_event.dart';
part 'my_player_state.dart';

class MyPlayerBloc extends Bloc<MyPlayerEvent, MyPlayerState> {
  MyPlayerBloc() : super(MyPlayerInitial()) {
    on<MyPlayerEvent>((event, emit) {});
  }
}
