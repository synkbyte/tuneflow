import 'package:equatable/equatable.dart';

import 'package:new_tuneflow/core/common/models/models.dart';

class AlbumEntity extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final MediaFormat image;
  final List<SongModel> songs;
  const AlbumEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.songs,
  });

  Map toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'image': image.toJson(),
      'songs': songs.map((song) => song.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props {
    return [id, title, subtitle, songs];
  }
}
