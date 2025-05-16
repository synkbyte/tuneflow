part of 'lyrics_bloc.dart';

sealed class LyricsState extends Equatable {
  final LyricsEntity? lyricsEntity;
  final String? error;
  const LyricsState({this.lyricsEntity, this.error});

  @override
  List<Object?> get props => [lyricsEntity, error];
}

final class LyricsInitial extends LyricsState {}

final class LyricsLoading extends LyricsState {}

final class LyricsLoaded extends LyricsState {
  const LyricsLoaded(LyricsEntity lyricsEntity)
      : super(lyricsEntity: lyricsEntity);

  @override
  List<Object?> get props => [lyricsEntity];
}

final class LyricsError extends LyricsState {
  const LyricsError(String error) : super(error: error);

  @override
  List<Object?> get props => [error];
}
