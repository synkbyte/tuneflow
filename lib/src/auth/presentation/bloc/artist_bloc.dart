import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/src/auth/domain/entites/artist_entity.dart';
import 'package:new_tuneflow/src/auth/domain/usecase/artist_usecase.dart';
import 'package:stream_transform/stream_transform.dart';

part 'artist_event.dart';
part 'artist_state.dart';

const _debounceDuration = Duration(milliseconds: 300);

class ArtistBloc extends Bloc<ArtistEvent, ArtistState> {
  final ArtistUseCase _artistUseCase;
  ArtistBloc(this._artistUseCase) : super(ArtistInitial()) {
    on<ArtistGetTop>(getTopArtists);
    on<ArtistSearch>(
      getArtistByQuery,
      transformer: (events, mapper) =>
          events.debounce(_debounceDuration).switchMap(mapper),
    );
  }

  void getTopArtists(ArtistGetTop event, Emitter emit) async {
    emit(ArtistLoading());
    try {
      final dataState = await _artistUseCase();

      if (dataState is DataSuccess) {
        emit(ArtistLoaded(dataState.data!));
      } else {
        emit(ArtistError(dataState.error!));
      }
    } catch (e) {
      emit(const ArtistError('Something went wrong'));
    }
  }

  void getArtistByQuery(ArtistSearch event, Emitter emit) async {
    emit(ArtistLoading());
    try {
      final dataState = await _artistUseCase.getArtistByQuery(event.query);

      if (dataState is DataSuccess) {
        emit(ArtistLoaded(dataState.data!));
      } else {
        emit(ArtistError(dataState.error!));
      }
    } catch (e) {
      emit(const ArtistError('Something went wrong'));
    }
  }
}
