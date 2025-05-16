import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/src/artist_details/domain/usecase/artist_details_usecase.dart';
import 'package:new_tuneflow/src/auth/domain/entites/artist_entity.dart';

part 'artist_details_event.dart';
part 'artist_details_state.dart';

class ArtistDetailsBloc extends Bloc<ArtistDetailsEvent, ArtistDetailsState> {
  final ArtistDetailsUseCase _artistDetailsUseCase;
  ArtistDetailsBloc(this._artistDetailsUseCase)
      : super(ArtistDetailsInitial()) {
    on<ArtistDetailsFetch>(getArtistDetails);
  }

  void getArtistDetails(ArtistDetailsFetch event, Emitter emit) async {
    try {
      emit(ArtistDetailsLoading());
      final dataState = await _artistDetailsUseCase.call(id: event.id);

      if (dataState is DataSuccess) {
        emit(ArtistDetailsLoaded(dataState.data!));
      } else {
        emit(ArtistDetailsError(dataState.error!));
      }
    } catch (e) {
      emit(const ArtistDetailsError('Somthing went wrong'));
    }
  }
}
