part of 'models.dart';

class SongModel {
  final String id;
  final String title;
  final String subtitle;
  final String headerDesc;
  final String type;
  final String permaUrl;
  final MediaFormat imagesUrl;
  final String language;
  final String year;
  final String playCount;
  final String albumId;
  final String origin;
  final String duration;
  final bool hasLyrics;
  final String releaseDate;
  final List<SongArtingModel> artistMap;
  final MediaFormat playUrl;
  final String localPath;
  SongModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.headerDesc,
    required this.type,
    required this.permaUrl,
    required this.imagesUrl,
    required this.language,
    required this.year,
    required this.playCount,
    required this.albumId,
    required this.origin,
    required this.duration,
    required this.hasLyrics,
    required this.releaseDate,
    required this.artistMap,
    required this.playUrl,
    required this.localPath,
  });

  factory SongModel.fromJson(Map json) {
    bool hasLyrics = false;
    Type runtimeType = json['more_info']['has_lyrics'].runtimeType;

    if (runtimeType == bool) {
      hasLyrics = json['more_info']['has_lyrics'];
    } else if (runtimeType == String) {
      hasLyrics = json['more_info']['has_lyrics'] == 'true';
    }
    List artistMap = json['more_info']['artistMap']['primary_artists'];
    return SongModel(
      id: json['id'],
      title: filteredText(json['title']),
      subtitle: generateSubTitleForMusic(artistMap),
      headerDesc: json['header_desc'],
      type: json['type'],
      permaUrl: json['perma_url'],
      imagesUrl: createImageLinks(json['image']),
      language: json['language'],
      year: json['year'],
      playCount: json['play_count'],
      albumId: json['more_info']['album_id'],
      origin: json['more_info']['origin'],
      duration: json['more_info']['duration'],
      hasLyrics: hasLyrics,
      releaseDate: json['more_info']['release_date'] ?? '',
      artistMap: artistMap.map((e) => SongArtingModel.fromJson(e)).toList(),
      playUrl: createDownloadLinks(json['more_info']['encrypted_media_url']),
      localPath:
          json['more_info']?['localPath'] ??
          defaultLocalPath(
            createDownloadLinks(json['more_info']['encrypted_media_url']),
          ),
    );
  }

  toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'header_desc': headerDesc,
      'type': type,
      'perma_url': permaUrl,
      'image': imagesUrl.toJson(),
      'language': language,
      'year': year,
      'play_count': playCount,
      'more_info': {
        'album_id': albumId,
        'origin': origin,
        'duration': duration,
        'has_lyrics': hasLyrics,
        'release_date': releaseDate,
        'encrypted_media_url': playUrl.toJson(),
        'localPath': localPath,
        'artistMap': {
          'primary_artists': artistMap.map((e) => e.toJson()).toList(),
        },
      },
    };
  }

  MediaItem toMediaItem(bool isLocal) {
    String path;
    if (isLocal) {
      path = localPath;
    } else {
      path = playUrl.excellent;
      if (Cache.instance.defaultMusicQuality == 'Good') {
        path = playUrl.good;
      } else if (Cache.instance.defaultMusicQuality == 'Regular') {
        path = playUrl.regular;
      }
    }
    return MediaItem(
      id: id,
      title: title,
      artUri: Uri.parse(imagesUrl.excellent),
      artist: subtitle,
      extras: {'url': path, 'model': toJson()},
    );
  }

  bool isThisSong(String id) {
    return this.id == id;
  }
}

class SongArtingModel {
  String id;
  String name;
  String role;
  MediaFormat imagesUrl;
  SongArtingModel({
    required this.id,
    required this.name,
    required this.role,
    required this.imagesUrl,
  });

  factory SongArtingModel.fromJson(Map json) {
    return SongArtingModel(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      imagesUrl: createImageLinks(json['image']),
    );
  }
  toJson() {
    return {'id': id, 'name': name, 'role': role, 'image': imagesUrl.toJson()};
  }
}
