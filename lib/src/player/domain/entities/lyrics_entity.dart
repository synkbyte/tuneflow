import 'package:equatable/equatable.dart';

class LyricsEntity extends Equatable {
  final String lyrics;
  final String scriptTrackingUrl;
  final String lyricsCopyright;
  final String snippet;
  const LyricsEntity({
    required this.lyrics,
    required this.scriptTrackingUrl,
    required this.lyricsCopyright,
    required this.snippet,
  });

  @override
  List<Object?> get props {
    return [
      lyrics,
      scriptTrackingUrl,
      lyricsCopyright,
      snippet,
    ];
  }
}
