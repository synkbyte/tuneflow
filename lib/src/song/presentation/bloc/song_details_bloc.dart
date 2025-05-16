import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/src/song/data/data_source/song_details_api_service.dart';
import 'package:new_tuneflow/src/song/domain/entites/song_details_entity.dart';

part 'song_details_event.dart';
part 'song_details_state.dart';

class SongDetailsBloc extends Bloc<SongDetailsEvent, SongDetailsState> {
  final SongDetailsApiService _songDetailsApiService;
  SongDetailsBloc(this._songDetailsApiService) : super(SongDetailsInitial()) {
    on<SongDetailsFetch>(getSongDetails);
  }

  void getSongDetails(SongDetailsFetch even, Emitter emit) async {
    try {
      emit(SongDetailsLoading());

      final dataState = await _songDetailsApiService.getSongDetails(
        even.songId,
      );

      if (dataState is DataSuccess) {
        emit(SongDetailsLoaded(dataState.data!));
      } else {
        emit(SongDetailsError(dataState.error!));
      }
    } catch (e) {
      emit(const SongDetailsError('Somthing went wrong'));
    }
  }
}
