part of 'song_details_bloc.dart';

sealed class SongDetailsEvent extends Equatable {
  const SongDetailsEvent();

  @override
  List<Object> get props => [];
}

class SongDetailsFetch extends SongDetailsEvent {
  final String songId;
  const SongDetailsFetch({required this.songId});
}
