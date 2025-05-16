import 'package:audio_service/audio_service.dart';
import 'package:new_tuneflow/core/common/models/models.dart';

extension MediaItemExt on MediaItem {
  SongModel get songModel => SongModel.fromJson(extras!['model']);
}
