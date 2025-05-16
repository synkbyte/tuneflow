part of 'models.dart';

enum PlayingType {
  initial,
  explore,
  discover,
  search,
  artist,
  playlist,
  downloadedPlaylist,
  downloadedAlbum,
  album,
  song,
  download,
}

class PlayingModel {
  final PlayingType type;
  final String id;
  PlayingModel({
    required this.type,
    required this.id,
  });

  bool isPlayingFromThis(PlayingType type, String id) {
    return this.type == type && this.id == id;
  }
}

PlayingType stringToType(String type) {
  switch (type) {
    case 'initial':
      return PlayingType.initial;
    case 'explore':
      return PlayingType.explore;
    case 'discover':
      return PlayingType.discover;
    case 'search':
      return PlayingType.search;
    case 'artist':
      return PlayingType.artist;
    case 'playlist':
      return PlayingType.playlist;
    case 'album':
      return PlayingType.album;
    case 'song':
      return PlayingType.song;
    case 'download':
      return PlayingType.download;
    case 'downloadedPlaylist':
      return PlayingType.downloadedPlaylist;
    case 'downloadedAlbum':
      return PlayingType.downloadedAlbum;
    default:
      return PlayingType.initial;
  }
}
