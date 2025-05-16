import 'package:equatable/equatable.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/src/album/data/models/album_model.dart';
import 'package:new_tuneflow/src/playlist/data/models/playlist_model.dart';

class SearchEntity extends Equatable {
  final List<SongModel> songs;
  final List<PlaylistModel> playlist;
  final List<AlbumModel> album;
  final List<ArtistModel> artists;
  const SearchEntity({
    required this.songs,
    required this.playlist,
    required this.artists,
    required this.album,
  });

  @override
  List<Object?> get props => [songs];
}
