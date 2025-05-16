import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/utils/function.dart';
import 'package:new_tuneflow/src/explore/domain/entites/discover_entiry.dart';
import 'package:new_tuneflow/src/playlist/data/models/playlist_model.dart';

class DiscoverModel extends DiscoverEntiry {
  const DiscoverModel({
    required super.id,
    required super.title,
    required super.songs,
    required super.playlist,
  });

  factory DiscoverModel.fromJson(Map json) {
    List songs = json['songs'] ?? [];
    List playlist = json['playlist'] ?? [];

    return DiscoverModel(
      id: json['id'],
      title: filteredText(json['title']),
      songs: songs.map((e) => SongModel.fromJson(e)).toList(),
      playlist: playlist.map((e) => PlaylistModel.fromJson(e)).toList(),
    );
  }
}
