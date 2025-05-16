import 'package:equatable/equatable.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/src/playlist/data/models/playlist_model.dart';

class DiscoverEntiry extends Equatable {
  final String id;
  final String title;
  final List<SongModel> songs;
  final List<PlaylistModel> playlist;
  const DiscoverEntiry({
    required this.id,
    required this.title,
    required this.songs,
    required this.playlist,
  });

  Map toMap() {
    return {
      'id': id,
      'title': title,
      'songs': songs.map((song) => song.toJson()).toList(),
      'playlist': playlist.map((playlist) => playlist.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props {
    return [id, title, songs, playlist];
  }
}
