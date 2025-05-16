part of 'artist_bloc.dart';

sealed class ArtistEvent extends Equatable {
  const ArtistEvent();

  @override
  List<Object> get props => [];
}

final class ArtistGetTop extends ArtistEvent {}

final class ArtistSearch extends ArtistEvent {
  final String query;

  const ArtistSearch(this.query);

  @override
  List<Object> get props => [query];
}
