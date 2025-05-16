part of 'search_api_service.dart';

class SearchApiServiceImp implements SearchApiService {
  @override
  Future<DataState<SearchModel>> searchByQuery(String query) async {
    try {
      final client = http.Client();
      final url = Uri.parse(baseUrl).replace(
        queryParameters: {
          ...defaultParams,
          '__call': 'search.getResults',
          'q': query,
        },
      );
      String language = formateLangaugeForPayload(
        await CacheHelper().getUserSelectedLanguages(),
      );
      final response = await client.get(
        url,
        headers: {'cookie': 'L=$language; gdpr_acceptance=true; DL=english'},
      );
      List songsResult = jsonDecode(response.body)['results'];
      List<SongModel> songsModel =
          songsResult.map((e) => SongModel.fromJson(e)).toList();

      final playlistUrl = Uri.parse(baseUrl).replace(
        queryParameters: {
          ...defaultParams,
          '__call': 'search.getPlaylistResults',
          'q': query,
        },
      );
      final playlistResponse = await client.get(
        playlistUrl,
        headers: {'cookie': 'L=$language; gdpr_acceptance=true; DL=english'},
      );
      List playlistResult = [];
      if (playlistResponse.statusCode == 200) {
        playlistResult = jsonDecode(playlistResponse.body)['results'];
      }
      List<PlaylistModel> playlistModel =
          playlistResult.map((e) => PlaylistModel.fromJson(e)).toList();

      final artistUrl = Uri.parse(baseUrl).replace(
        queryParameters: {
          ...defaultParams,
          '__call': 'search.getArtistResults',
          'q': query,
        },
      );
      final artistResponse = await client.get(
        artistUrl,
        headers: {'cookie': 'L=$language; gdpr_acceptance=true; DL=english'},
      );
      List artistResult = jsonDecode(artistResponse.body)['results'];
      List<ArtistModel> artistModel =
          artistResult.map((e) => ArtistModel.fromJson(e)).toList();

      final albumUrl = Uri.parse(baseUrl).replace(
        queryParameters: {
          ...defaultParams,
          '__call': 'search.getAlbumResults',
          'q': query,
        },
      );
      final albumResponse = await client.get(
        albumUrl,
        headers: {'cookie': 'L=$language; gdpr_acceptance=true; DL=english'},
      );
      List albumResult = jsonDecode(albumResponse.body)['results'];
      List<AlbumModel> albumModel =
          albumResult.map((e) => AlbumModel.fromJson(e)).toList();

      return DataSuccess(SearchModel(
        songs: songsModel,
        playlist: playlistModel,
        artists: artistModel,
        album: albumModel,
      ));
    } catch (e) {
      return DataError('Something went wrong');
    }
  }
}
