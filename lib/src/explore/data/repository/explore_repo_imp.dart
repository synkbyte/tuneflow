import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/src/explore/data/data_source/explore_remote_data_source.dart';
import 'package:new_tuneflow/src/explore/data/models/discover_model.dart';
import 'package:new_tuneflow/src/explore/data/models/explore_model.dart';
import 'package:new_tuneflow/src/explore/data/models/for_you_model.dart';
import 'package:new_tuneflow/src/explore/data/models/trending_model.dart';
import 'package:new_tuneflow/src/explore/domain/repository/explore_repo.dart';

class ExploreRepositoryImpl implements ExploreRepository {
  final ExploreAPIService _exploreAPIService;
  const ExploreRepositoryImpl(this._exploreAPIService);

  @override
  Future<DataState<List<ExploreModel>>> getExplorePlaylists() async {
    try {
      final response = await _exploreAPIService.getExplorePlaylist();

      if (response is DataSuccess) {
        List<ExploreModel> updatePlaylist = [];

        List<ExploreModel> playlists = response.data!;
        for (var playlist in playlists) {
          final dataState = await _exploreAPIService.getExplorePlaylistSong(
            listId: playlist.id!,
          );
          if (dataState is DataSuccess) {
            updatePlaylist.add(ExploreModel(
              id: playlist.id!,
              title: playlist.title!,
              subtitle: playlist.subtitle!,
              type: playlist.type!,
              permaUrl: playlist.permaUrl!,
              moreInfo: playlist.moreInfo!,
              explicitContent: playlist.explicitContent!,
              miniObj: playlist.miniObj!,
              isGotSongs: true,
              songs: dataState.data!,
            ));
          }
        }

        return DataSuccess(updatePlaylist);
      }

      return DataError(response.error!);
    } catch (error) {
      return DataError('Somthing went wrong');
    }
  }

  @override
  Future<DataState<List<SongModel>>> getExplorePlaylistsSongs(
    String listId,
  ) async {
    try {
      final response = await _exploreAPIService.getExplorePlaylistSong(
        listId: listId,
      );

      if (response is DataSuccess) {
        return response;
      }

      return DataError(response.error!);
    } catch (error) {
      return DataError('Somthing went wrong');
    }
  }

  @override
  Future<DataState<List<DiscoverModel>>> getDiscovers() async {
    try {
      final response = await _exploreAPIService.getDiscovers();

      if (response is DataSuccess) {
        return response;
      }

      return DataError(response.error!);
    } catch (error) {
      return DataError('Somthing went wrong');
    }
  }

  @override
  Future<DataState<List<TrendingModel>>> getTrending() async {
    try {
      final response = await _exploreAPIService.getTrending();

      if (response is DataSuccess) {
        return response;
      }

      return DataError(response.error!);
    } catch (error) {
      return DataError('Somthing went wrong');
    }
  }

  @override
  Future<DataState<List<ForYouModel>>> getForYou() async {
    try {
      final response = await _exploreAPIService.getForYou();

      if (response is DataSuccess) {
        return response;
      }

      return DataError(response.error!);
    } catch (error) {
      return DataError('Somthing went wrong');
    }
  }
}
