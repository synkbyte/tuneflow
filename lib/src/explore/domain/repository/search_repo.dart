import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/src/explore/domain/entites/search_entity.dart';

abstract class SearchRepository {
  Future<DataState<SearchEntity>> searchByQuery(String query, String language);
}
