part of 'song_details_bloc.dart';

sealed class SongDetailsState extends Equatable {
  final SongDetailsEntity? songDetails;
  final String? error;
  const SongDetailsState({this.songDetails, this.error});

  @override
  List<Object?> get props => [songDetails, error];
}

final class SongDetailsInitial extends SongDetailsState {}

final class SongDetailsLoading extends SongDetailsState {}

final class SongDetailsError extends SongDetailsState {
  const SongDetailsError(String error) : super(error: error);

  @override
  List<Object?> get props => [error];
}

final class SongDetailsLoaded extends SongDetailsState {
  const SongDetailsLoaded(SongDetailsEntity songDetails)
      : super(songDetails: songDetails);

  @override
  List<Object?> get props => [songDetails];
}
