import 'package:new_tuneflow/src/player/domain/entities/lyrics_entity.dart';

class LyricsModel extends LyricsEntity {
  const LyricsModel({
    required super.lyrics,
    required super.scriptTrackingUrl,
    required super.lyricsCopyright,
    required super.snippet,
  });
}
