import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_tuneflow/src/explore/domain/entites/explore_entiry.dart';
import 'package:new_tuneflow/src/explore/domain/usecase/explore_usecase.dart';

part 'explore_event.dart';
part 'explore_state.dart';

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final ExploreUseCase exploreUseCase;
  ExploreBloc(this.exploreUseCase) : super(ExploreInitial()) {
    on<ExploreEvent>((event, emit) {});
    on<ExploreFetch>(getExploreItems);
  }

  Future<void> getExploreItems(
    ExploreFetch event,
    Emitter<ExploreState> emit,
  ) async {
    // List contents = await CacheHelper().getExploreContents();
    // if (contents.isNotEmpty) {
    //   emit(ExploreFetched(
    //       contents.map((e) => ExploreEntiry.fromJson(e)).toList()));
    // }
    // final dataState = await _exploreUseCase();

    // if (dataState is DataSuccess) {
    //   await CacheHelper()
    //       .saveExploreContents(dataState.data!.map((e) => e.toMap()).toList());
    //   emit(ExploreFetched(dataState.data!));
    // }
    // if (dataState is DataError) {
    //   emit(ExploreError(dataState.error!));
    // }
  }
}
