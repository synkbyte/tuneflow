part of 'my_player_bloc.dart';

sealed class MyPlayerState extends Equatable {
  const MyPlayerState();
  
  @override
  List<Object> get props => [];
}

final class MyPlayerInitial extends MyPlayerState {}
