part of 'explore_remote_data_source.dart';

class ExploreAPIServiceImp implements ExploreAPIService {
  @override
  Future<DataState<List<ExploreModel>>> getExplorePlaylist() async {
    try {
      final client = http.Client();
      final url = Uri.parse(baseUrl).replace(
        queryParameters: {
          ...defaultParams,
          '__call': 'content.getBrowseModules',
        },
      );
      String language = formateLangaugeForPayload(
        await CacheHelper().getUserSelectedLanguages(),
      );
      final response = await client.get(
        url,
        headers: {'cookie': 'L=$language; gdpr_acceptance=true; DL=english'},
      );
      List topPlaylists = jsonDecode(response.body)['top_playlists'];
      return DataSuccess(
        topPlaylists.map((json) => ExploreModel.fromJson(json)).toList(),
      );
    } catch (e) {
      return DataError('Something went wrong');
    }
  }

  @override
  Future<DataState<List<SongModel>>> getExplorePlaylistSong({
    required String listId,
  }) async {
    try {
      final client = http.Client();
      final url = Uri.parse(baseUrl).replace(
        queryParameters: {
          ...defaultParams,
          '__call': 'playlist.getDetails',
          'listid': listId,
        },
      );
      String language = formateLangaugeForPayload(
        await CacheHelper().getUserSelectedLanguages(),
      );
      final response = await client.get(
        url,
        headers: {'cookie': 'L=$language; gdpr_acceptance=true; DL=english'},
      );
      List topPlaylists = jsonDecode(response.body)['list'];
      return DataSuccess(
        topPlaylists.map((json) => SongModel.fromJson(json)).toList(),
      );
    } catch (e) {
      return DataError('Somthing went wrong');
    }
  }

  @override
  Future<DataState<List<DiscoverModel>>> getDiscovers() async {
    try {
      final client = http.Client();
      final url = Uri.parse(baseUrl).replace(
        queryParameters: {...defaultParams, '__call': 'webapi.getLaunchData'},
      );
      String language = formateLangaugeForPayload(
        await CacheHelper().getUserSelectedLanguages(),
      );
      final response = await client.get(
        url,
        headers: {'cookie': 'L=$language; gdpr_acceptance=true; DL=english'},
      );
      List browseDiscover = jsonDecode(response.body)['browse_discover'];
      List<DiscoverModel> gotData = [];

      for (int i = 0; i < browseDiscover.length; i++) {
        final url = Uri.parse(baseUrl).replace(
          queryParameters: {
            ...defaultParams,
            '__call': 'channel.getDetails',
            'channel_id': browseDiscover[i]['id'],
          },
        );
        final response = await client.get(
          url,
          headers: {'cookie': 'L=$language; gdpr_acceptance=true; DL=english'},
        );
        Map resBody = jsonDecode(response.body);
        List songs = [];
        if (resBody['top_songs'] != null) {
          songs = resBody['top_songs'];
        }
        List playlists = [];
        if (resBody['top_playlists'] != null) {
          playlists = resBody['top_playlists'];
        }
        List<SongModel> songsModel =
            songs.map((e) => SongModel.fromJson(e)).toList();
        List<PlaylistModel> playlistsModel =
            playlists.map((e) => PlaylistModel.fromJson(e)).toList();
        if (songsModel.isNotEmpty) {
          gotData.add(
            DiscoverModel(
              id: browseDiscover[i]['id'],
              title: filteredText(browseDiscover[i]['title']),
              songs: songsModel,
              playlist: playlistsModel,
            ),
          );
        }
      }
      return DataSuccess(gotData);
    } catch (e) {
      return DataError('Somthing went wrong');
    }
  }

  @override
  Future<DataState<List<ForYouModel>>> getForYou() async {
    try {
      final client = http.Client();
      final url = Uri.parse(baseUrl).replace(
        queryParameters: {
          ...defaultParams,
          '__call': 'content.getBrowseModules',
        },
      );
      String language = formateLangaugeForPayload(
        await CacheHelper().getUserSelectedLanguages(),
      );
      final response = await client.get(
        url,
        headers: {'cookie': 'L=$language; gdpr_acceptance=true; DL=english'},
      );
      List topPlaylists = jsonDecode(response.body)['new_albums'];
      return DataSuccess(
        topPlaylists
            .where((json) => json['type'] != 'playlist')
            .map((json) => ForYouModel.fromJson(json))
            .toList(),
      );
    } catch (e) {
      return DataError('Somthing went wrong');
    }
  }

  @override
  Future<DataState<List<TrendingModel>>> getTrending() async {
    try {
      final client = http.Client();
      final url = Uri.parse(baseUrl).replace(
        queryParameters: {
          ...defaultParams,
          '__call': 'content.getBrowseModules',
        },
      );
      String language = formateLangaugeForPayload(
        await CacheHelper().getUserSelectedLanguages(),
      );
      final response = await client.get(
        url,
        headers: {'cookie': 'L=$language; gdpr_acceptance=true; DL=english'},
      );
      List topPlaylists = jsonDecode(response.body)['new_trending'];
      List removedSongs =
          topPlaylists.where((e) => e['type'] != 'song').toList();
      return DataSuccess(
        removedSongs.map((json) => TrendingModel.fromJson(json)).toList(),
      );
    } catch (e) {
      return DataError('Somthing went wrong');
    }
  }
}
