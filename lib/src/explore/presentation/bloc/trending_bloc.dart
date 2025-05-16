import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/src/explore/domain/entites/trending_entity.dart';
import 'package:new_tuneflow/src/explore/domain/usecase/explore_usecase.dart';

part 'trending_event.dart';
part 'trending_state.dart';

class TrendingBloc extends Bloc<TrendingEvent, TrendingState> {
  final ExploreUseCase _exploreUseCase;
  TrendingBloc(this._exploreUseCase) : super(TrendingInitial()) {
    on<TrendingEvent>((event, emit) {});
    on<FetchTrending>(getTrending);
  }

  Future<void> getTrending(
    FetchTrending event,
    Emitter<TrendingState> emit,
  ) async {
    final dataState = await _exploreUseCase.getTrending();

    if (dataState is DataSuccess) {
      emit(TrendingFetched(dataState.data!));
    }
  }
}
