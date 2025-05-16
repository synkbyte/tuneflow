part of 'state_bloc.dart';

sealed class StateEvent extends Equatable {
  const StateEvent();

  @override
  List<Object> get props => [];
}

class StateChangeIndex extends StateEvent {
  final int index;
  const StateChangeIndex(this.index);

  @override
  List<Object> get props => [index];
}

class ProfileChangeIndex extends StateEvent {
  final int index;
  const ProfileChangeIndex(this.index);

  @override
  List<Object> get props => [index];
}
