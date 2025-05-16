part of 'artist_details_bloc.dart';

sealed class ArtistDetailsState extends Equatable {
  final ArtistEntity? artistEntity;
  final String? error;
  const ArtistDetailsState({this.artistEntity, this.error});

  @override
  List<Object?> get props => [artistEntity, error];
}

final class ArtistDetailsInitial extends ArtistDetailsState {}

final class ArtistDetailsLoading extends ArtistDetailsState {}

final class ArtistDetailsError extends ArtistDetailsState {
  const ArtistDetailsError(String error) : super(error: error);

  @override
  List<Object?> get props => [error];
}

final class ArtistDetailsLoaded extends ArtistDetailsState {
  const ArtistDetailsLoaded(ArtistEntity artistEntity)
      : super(artistEntity: artistEntity);

  @override
  List<Object?> get props => [artistEntity];
}
