part of 'artist_bloc.dart';

sealed class ArtistState extends Equatable {
  final List<ArtistEntity>? artists;
  final String? error;
  const ArtistState({this.artists, this.error});

  @override
  List<Object?> get props => [artists, error];
}

final class ArtistInitial extends ArtistState {}

final class ArtistLoading extends ArtistState {}

final class ArtistError extends ArtistState {
  const ArtistError(String error) : super(error: error);

  @override
  List<Object?> get props => [error];
}

final class ArtistLoaded extends ArtistState {
  const ArtistLoaded(List<ArtistEntity> artists) : super(artists: artists);

  @override
  List<Object?> get props => [artists];
}
