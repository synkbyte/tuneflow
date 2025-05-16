part of 'playlist_bloc.dart';

sealed class PlaylistState extends Equatable {
  final PlaylistEntity? playlist;
  final String? error;
  const PlaylistState({this.playlist, this.error});

  @override
  List<Object?> get props => [playlist, error];
}

final class PlaylistInitial extends PlaylistState {}

final class PlaylistLoading extends PlaylistState {}

final class PlaylistError extends PlaylistState {
  const PlaylistError(String error) : super(error: error);

  @override
  List<Object?> get props => [error];
}

final class PlaylistLoaded extends PlaylistState {
  const PlaylistLoaded(PlaylistEntity playlist) : super(playlist: playlist);

  @override
  List<Object?> get props => [playlist];
}
