import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/src/explore/domain/entites/for_you_entiry.dart';
import 'package:new_tuneflow/src/explore/domain/usecase/explore_usecase.dart';

part 'foryou_event.dart';
part 'foryou_state.dart';

class ForyouBloc extends Bloc<ForyouEvent, ForyouState> {
  final ExploreUseCase _exploreUseCase;
  ForyouBloc(this._exploreUseCase) : super(ForyouInitial()) {
    on<ForyouEvent>((event, emit) {});
    on<FetchForYouEvent>(getForYou);
  }

  Future<void> getForYou(
    FetchForYouEvent event,
    Emitter<ForyouState> emit,
  ) async {
    final dataState = await _exploreUseCase.getForYou();

    if (dataState is DataSuccess) {
      emit(ForyouFetched(dataState.data!));
    }
  }
}
