import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/error/lyrics_error.dart';
import 'package:new_tuneflow/core/extensions/media_item_extenstions.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/src/player/domain/entities/lyrics_entity.dart';
import 'package:new_tuneflow/src/player/domain/usecase/lyrics_usecase.dart';

part 'lyrics_event.dart';
part 'lyrics_state.dart';

class LyricsBloc extends Bloc<LyricsEvent, LyricsState> {
  final LyricsUseCase _lyricsUseCase;
  LyricsBloc(this._lyricsUseCase) : super(LyricsInitial()) {
    on<LyricsGet>(getLyrics);
    on<LyricsListen>((event, emit) => listenToChangesInSong());
  }

  void listenToChangesInSong() {
    audioHandler.mediaItem.listen((mediaItem) {
      if (mediaItem == null) return;
      SongModel nowPlaying = mediaItem.songModel;
      add(LyricsGet(id: nowPlaying.id, hasLyrics: nowPlaying.hasLyrics));
    });
  }

  void getLyrics(LyricsGet event, Emitter emit) async {
    bool hasLyrics = event.hasLyrics;
    if (!hasLyrics) {
      emit(LyricsError(LyricsErrors.lyricsNotAvailable));
      return;
    }

    try {
      emit(LyricsLoading());

      final dataState = await _lyricsUseCase.call(id: event.id);

      if (dataState is DataSuccess) {
        emit(LyricsLoaded(dataState.data!));
      } else {
        emit(LyricsError(dataState.error!));
      }
    } catch (e) {
      emit(LyricsError(LyricsErrors.apiError));
    }
  }
}
