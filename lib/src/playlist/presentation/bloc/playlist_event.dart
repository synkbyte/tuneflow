part of 'playlist_bloc.dart';

sealed class PlaylistEvent extends Equatable {
  const PlaylistEvent();

  @override
  List<Object> get props => [];
}

final class PlaylistFetch extends PlaylistEvent {
  final String id;
  final String type;
  final UserPlaylistModel? playlist;
  final UserModel? user;
  const PlaylistFetch({
    required this.id,
    required this.type,
    this.playlist,
    this.user,
  });
}
