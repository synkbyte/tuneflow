import 'package:equatable/equatable.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/src/album/data/models/album_model.dart';
import 'package:new_tuneflow/src/playlist/data/models/playlist_model.dart';

class ArtistEntity extends Equatable {
  final String id;
  final String name;
  final MediaFormat image;
  final List<SongModel> songs;
  final List<AlbumModel> topAlbums;
  final List<PlaylistModel> dedicatedArtistPlaylist;
  final List<PlaylistModel> featuredArtistPlaylist;
  final List<AlbumModel> singles;
  final List<AlbumModel> latestRelease;
  const ArtistEntity({
    required this.id,
    required this.name,
    required this.image,
    required this.songs,
    required this.topAlbums,
    required this.dedicatedArtistPlaylist,
    required this.featuredArtistPlaylist,
    required this.singles,
    required this.latestRelease,
  });

  toMap() {
    return {
      'id': id,
      'name': name,
      'image': image.toJson(),
    };
  }

  ArtistModel toModel() {
    return ArtistModel(
      id: id,
      name: name,
      image: image,
      songs: songs,
      topAlbums: topAlbums,
      dedicatedArtistPlaylist: dedicatedArtistPlaylist,
      featuredArtistPlaylist: featuredArtistPlaylist,
      singles: singles,
      latestRelease: latestRelease,
    );
  }

  @override
  List<Object?> get props {
    return [
      id,
      name,
      image,
      songs,
      topAlbums,
      dedicatedArtistPlaylist,
      featuredArtistPlaylist,
      singles,
      latestRelease,
    ];
  }
}
