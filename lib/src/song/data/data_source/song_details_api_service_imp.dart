part of 'song_details_api_service.dart';

class SongDetailsApiServiceImp implements SongDetailsApiService {
  @override
  Future<DataState<SongDetailsModel>> getSongDetails(String songId) async {
    try {
      final client = http.Client();
      final url = Uri.parse(baseUrl).replace(
        queryParameters: {
          ...defaultParams,
          '__call': 'song.getDetails',
          'pids': songId,
        },
      );
      String language = formateLangaugeForPayload(
        await CacheHelper().getUserSelectedLanguages(),
      );
      final response = await client.get(
        url,
        headers: {'cookie': 'L=$language; gdpr_acceptance=true; DL=english'},
      );

      Map resBody = jsonDecode(response.body);

      SongModel song = SongModel.fromJson(resBody['songs'][0]);
      List<SongModel> songsModel = [song];

      final recoUrl = Uri.parse(baseUrl).replace(
        queryParameters: {
          ...defaultParams,
          '__call': 'reco.getreco',
          'pid': songId,
          'language': resBody['modules']['reco']['source_params']['language'],
        },
      );
      final recoResponse = await client.get(
        recoUrl,
        headers: {'cookie': 'L=$language; gdpr_acceptance=true; DL=english'},
      );
      List recoResBody = jsonDecode(recoResponse.body);
      List<SongModel> recoSongs =
          recoResBody.map((e) => SongModel.fromJson(e)).toList();

      final byArUrl = Uri.parse(baseUrl).replace(
        queryParameters: {
          ...defaultParams,
          '__call': 'search.artistOtherTopSongs',
          'song_id': songId,
          'language': resBody['modules']['songsBysameArtists']['source_params']
              ['language'],
          'artist_ids': resBody['modules']['songsBysameArtists']
              ['source_params']['artist_ids'],
        },
      );
      final byArResponse = await client.get(
        byArUrl,
        headers: {'cookie': 'L=$language; gdpr_acceptance=true; DL=english'},
      );
      List byArResBody = jsonDecode(byArResponse.body);
      List<SongModel> byArSongs =
          byArResBody.map((e) => SongModel.fromJson(e)).toList();

      songsModel.addAll(recoSongs);
      songsModel.addAll(byArSongs);

      return DataSuccess(SongDetailsModel(songs: songsModel));
    } catch (e) {
      return DataError('Something went wrong');
    }
  }
}
