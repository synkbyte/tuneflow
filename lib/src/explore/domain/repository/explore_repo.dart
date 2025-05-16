import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/src/explore/domain/entites/discover_entiry.dart';
import 'package:new_tuneflow/src/explore/domain/entites/explore_entiry.dart';
import 'package:new_tuneflow/src/explore/domain/entites/for_you_entiry.dart';
import 'package:new_tuneflow/src/explore/domain/entites/trending_entity.dart';

abstract class ExploreRepository {
  Future<DataState<List<ExploreEntiry>>> getExplorePlaylists();
  Future<DataState<List<SongModel>>> getExplorePlaylistsSongs(String listId);
  Future<DataState<List<DiscoverEntiry>>> getDiscovers();
  Future<DataState<List<TrendingEntity>>> getTrending();
  Future<DataState<List<ForYouEntity>>> getForYou();
}
