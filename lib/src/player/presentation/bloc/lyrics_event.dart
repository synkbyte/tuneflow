part of 'lyrics_bloc.dart';

sealed class LyricsEvent extends Equatable {
  const LyricsEvent();

  @override
  List<Object> get props => [];
}

final class LyricsGet extends LyricsEvent {
  final String id;
  final bool hasLyrics;
  const LyricsGet({required this.id, required this.hasLyrics});

  @override
  List<Object> get props => [id];
}

class LyricsListen extends LyricsEvent {}
