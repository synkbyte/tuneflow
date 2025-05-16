import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/src/explore/domain/entites/search_entity.dart';
import 'package:new_tuneflow/src/explore/domain/usecase/search_usecase.dart';
import 'package:stream_transform/stream_transform.dart';

part 'search_event.dart';
part 'search_state.dart';

const _debounceDuration = Duration(milliseconds: 300);

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchUseCase _searchUseCase;
  SearchBloc(this._searchUseCase) : super(SearchInitial()) {
    on<SearchQueryChanged>(
      searchByQuery,
      transformer: (events, mapper) =>
          events.debounce(_debounceDuration).switchMap(mapper),
    );
  }

  void searchByQuery(
      SearchQueryChanged event, Emitter<SearchState> emit) async {
    try {
      emit(SearchLoading());
      final dataState = await _searchUseCase.call(
        query: event.query,
        language: 'hindi',
      );

      if (dataState is DataSuccess) {
        emit(SearchResults(dataState.data!));
      } else {
        emit(SearchError(dataState.error!));
      }
    } catch (e) {
      emit(const SearchError('Something went wrong'));
    }
  }
}
