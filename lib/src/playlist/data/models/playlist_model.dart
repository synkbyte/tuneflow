import 'dart:math';

import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/utils/function.dart';
import 'package:new_tuneflow/src/playlist/domain/entites/playlist_entity.dart';

class PlaylistModel extends PlaylistEntity {
  const PlaylistModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.image,
    required super.songCount,
    required super.type,
    super.userDetails,
    required super.songs,
  });

  factory PlaylistModel.fromJson(Map json) {
    List songs = json['list'] ?? [];
    return PlaylistModel(
      id: '${json['id']}',
      title: filteredText(json['title']),
      subtitle: json['subtitle'].toString().contains('Follow')
          ? getRandomJustUpdatedVariant()
          : json['subtitle'],
      image: createHighQualityImage(json['image']),
      songCount: getSongCount(json),
      type: json['type'],
      userDetails: json['userDetails'],
      songs: songs.map((song) => SongModel.fromJson(song)).toList(),
    );
  }

  toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'subtitle': subtitle,
      'type': type,
      'userDetails': userDetails,
      'list': songs.map((song) => song.toJson()).toList(),
    };
  }
}

String getSongCount(Map json) {
  if (json['more_info'] != null) {
    if (json['more_info'].runtimeType == List) {
      return '0';
    }
    if (json['more_info']['song_count'] != null) {
      return json['more_info']['song_count'];
    } else {
      return '0';
    }
  }
  return json['list_count'] ?? '0';
}

String getRandomJustUpdatedVariant() {
  List<String> justUpdatedVariants = [
    "Recently Refreshed",
    "Latest Changes",
    "Freshly Updated",
    "Newly Refined",
    "Latest Edition",
    "Hot Off the Press",
    "Recently Tweaked",
    "Fresh Update",
    "New Additions",
    "Current Version",
  ];
  int randomIndex = Random().nextInt(justUpdatedVariants.length);
  return justUpdatedVariants[randomIndex];
}
