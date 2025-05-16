import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/utils/function.dart';
import 'package:new_tuneflow/src/album/domain/entites/album_entity.dart';

class AlbumModel extends AlbumEntity {
  const AlbumModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.image,
    required super.songs,
  });

  factory AlbumModel.fromJson(Map json) {
    List songs = json['list'].runtimeType == List ? json['list'] : [];
    if (json['songs'].runtimeType == List) {
      songs = json['songs'];
    }
    return AlbumModel(
      id: json['id'],
      title: filteredText(json['title']),
      subtitle: json['subtitle'],
      image: createImageLinks(json['image']),
      songs: songs.map((song) => SongModel.fromJson(song)).toList(),
    );
  }

  factory AlbumModel.fromEntity(AlbumEntity album) {
    return AlbumModel(
      id: album.id,
      title: album.title,
      subtitle: album.subtitle,
      image: album.image,
      songs: album.songs,
    );
  }

  AlbumEntity toEntity(AlbumModel album) {
    return AlbumEntity(
      id: album.id,
      title: album.title,
      subtitle: album.subtitle,
      image: album.image,
      songs: album.songs,
    );
  }
}
