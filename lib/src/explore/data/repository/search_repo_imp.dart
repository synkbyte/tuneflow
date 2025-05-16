import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/src/explore/data/data_source/search_api_service.dart';
import 'package:new_tuneflow/src/explore/data/models/search_model.dart';
import 'package:new_tuneflow/src/explore/domain/repository/search_repo.dart';

class SearchRepositoryImp implements SearchRepository {
  final SearchApiService _searchApiService;
  SearchRepositoryImp(this._searchApiService);

  @override
  Future<DataState<SearchModel>> searchByQuery(
    String query,
    String language,
  ) async {
    return await _searchApiService.searchByQuery(query);
  }
}
