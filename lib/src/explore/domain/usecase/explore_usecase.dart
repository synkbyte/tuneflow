import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/core/res/usecase.dart';
import 'package:new_tuneflow/src/explore/domain/entites/discover_entiry.dart';
import 'package:new_tuneflow/src/explore/domain/entites/explore_entiry.dart';
import 'package:new_tuneflow/src/explore/domain/entites/for_you_entiry.dart';
import 'package:new_tuneflow/src/explore/domain/entites/trending_entity.dart';
import 'package:new_tuneflow/src/explore/domain/repository/explore_repo.dart';

class ExploreUseCase implements UseCase<DataState<List<ExploreEntiry>>, void> {
  final ExploreRepository _exploreRepository;
  ExploreUseCase(this._exploreRepository);

  @override
  Future<DataState<List<ExploreEntiry>>> call({void params}) async {
    return await _exploreRepository.getExplorePlaylists();
  }

  Future<DataState<List<SongModel>>> getExploreSongs(String listId) async {
    return await _exploreRepository.getExplorePlaylistsSongs(listId);
  }

  Future<DataState<List<DiscoverEntiry>>> getDiscovers() async {
    return await _exploreRepository.getDiscovers();
  }

  Future<DataState<List<TrendingEntity>>> getTrending() async {
    return await _exploreRepository.getTrending();
  }

  Future<DataState<List<ForYouEntity>>> getForYou() async {
    return await _exploreRepository.getForYou();
  }
}
