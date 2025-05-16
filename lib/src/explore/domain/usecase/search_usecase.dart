import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/core/res/usecase.dart';
import 'package:new_tuneflow/src/explore/domain/entites/search_entity.dart';
import 'package:new_tuneflow/src/explore/domain/repository/search_repo.dart';

class SearchUseCase implements UseCase<DataState<SearchEntity>, void> {
  final SearchRepository _searchRepository;
  SearchUseCase(this._searchRepository);

  @override
  Future<DataState<SearchEntity>> call({
    void params,
    String? query,
    String? language,
  }) async {
    return await _searchRepository.searchByQuery(query!, language!);
  }
}
