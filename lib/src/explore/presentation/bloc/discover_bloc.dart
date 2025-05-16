import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_tuneflow/core/common/app/cache_helper.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/src/explore/data/models/discover_model.dart';
import 'package:new_tuneflow/src/explore/domain/entites/discover_entiry.dart';
import 'package:new_tuneflow/src/explore/domain/usecase/explore_usecase.dart';

part 'discover_event.dart';
part 'discover_state.dart';

class DiscoverBloc extends Bloc<DiscoverEvent, DiscoverState> {
  final ExploreUseCase _exploreUseCase;
  DiscoverBloc(this._exploreUseCase) : super(DiscoverInitial()) {
    on<DiscoverEvent>((event, emit) {});
    on<DiscoverFetch>(getDiscoverItems);
  }

  Future<void> getDiscoverItems(
    DiscoverFetch event,
    Emitter<DiscoverState> emit,
  ) async {
    List contents = await CacheHelper().getDiscoverContents();
    if (contents.isNotEmpty) {
      emit(
        DiscoverFetched(
          contents.map((e) => DiscoverModel.fromJson(e)).toList(),
        ),
      );
    }
    final dataState = await _exploreUseCase.getDiscovers();

    if (dataState is DataSuccess) {
      await CacheHelper().saveDiscoverContents(
        dataState.data!.map((e) => e.toMap()).toList(),
      );
      emit(DiscoverFetched(dataState.data!));
    }
    if (dataState is DataError) {
      emit(DiscoverError(dataState.error!));
    }
  }
}
