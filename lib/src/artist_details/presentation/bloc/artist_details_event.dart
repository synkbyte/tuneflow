part of 'artist_details_bloc.dart';

sealed class ArtistDetailsEvent extends Equatable {
  const ArtistDetailsEvent();

  @override
  List<Object> get props => [];
}

final class ArtistDetailsFetch extends ArtistDetailsEvent {
  final String id;
  const ArtistDetailsFetch({required this.id});
}
