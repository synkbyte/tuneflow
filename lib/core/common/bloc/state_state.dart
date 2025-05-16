part of 'state_bloc.dart';

sealed class StateState extends Equatable {
  final int? homeIndex;
  final int? profileIndex;
  const StateState({this.homeIndex = 1, this.profileIndex = 0});

  @override
  List<Object> get props => [homeIndex ?? 1];
}

final class StateInitial extends StateState {}

final class StateIndexChanged extends StateState {
  final int index;
  const StateIndexChanged(this.index);

  @override
  List<Object> get props => [index];
}

final class ProfileIndexChanged extends StateState {
  final int index;
  const ProfileIndexChanged(this.index);

  @override
  List<Object> get props => [index];
}
