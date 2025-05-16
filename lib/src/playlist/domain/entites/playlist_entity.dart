import 'package:equatable/equatable.dart';

import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/common/models/user_model.dart';

class PlaylistEntity extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final String image;
  final String songCount;
  final String type;
  final UserModel? userDetails;
  final List<SongModel> songs;
  const PlaylistEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.songCount,
    required this.type,
    required this.userDetails,
    required this.songs,
  });

  @override
  List<Object?> get props {
    return [id, title, subtitle, songs];
  }
}
