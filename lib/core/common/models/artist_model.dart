part of 'models.dart';

class ArtistModel extends ArtistEntity {
  const ArtistModel({
    required super.id,
    required super.name,
    required super.image,
    required super.songs,
    required super.topAlbums,
    required super.dedicatedArtistPlaylist,
    required super.featuredArtistPlaylist,
    required super.singles,
    required super.latestRelease,
  });

  factory ArtistModel.fromJson(Map json) {
    List songs = json['topSongs'] ?? [];
    List topAlbums = json['topAlbums'] ?? [];
    List dedicatedArtistPlaylist = json['dedicated_artist_playlist'] ?? [];
    List featuredArtistPlaylist = json['featured_artist_playlist'] ?? [];
    List singles = json['singles'] ?? [];
    List latestRelease = json['latest_release'] ?? [];
    return ArtistModel(
      id: json['artistId'] ?? json['id'] ?? json['artistid'],
      name: filteredText(json['name'] ?? json['title']),
      image: createImageLinks(json['image']),
      songs: songs.map((e) => SongModel.fromJson(e)).toList(),
      topAlbums: topAlbums.map((e) => AlbumModel.fromJson(e)).toList(),
      dedicatedArtistPlaylist: dedicatedArtistPlaylist
          .map((e) => PlaylistModel.fromJson(e))
          .toList(),
      featuredArtistPlaylist:
          featuredArtistPlaylist.map((e) => PlaylistModel.fromJson(e)).toList(),
      singles: singles.map((e) => AlbumModel.fromJson(e)).toList(),
      latestRelease: latestRelease.map((e) => AlbumModel.fromJson(e)).toList(),
    );
  }

  forBookmark() {
    return {
      'id': id,
      'name': name,
      'image': image.toJson(),
    };
  }

  ArtistEntity toEntity() {
    return ArtistEntity(
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
}
