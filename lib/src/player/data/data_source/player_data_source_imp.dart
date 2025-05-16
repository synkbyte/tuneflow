part of 'player_data_source.dart';

class PlayerApiServiceImp implements PlayerApiService {
  @override
  Future<DataState<List<SongModel>>> getInitialSongs() async {
    try {
      final client = http.Client();
      final url = Uri.parse(baseUrl).replace(
        queryParameters: {
          ...defaultParams,
          '__call': 'reco.getreco',
          'pid': 'XLPAhjVk',
          'language': 'hindi',
        },
      );
      String language = formateLangaugeForPayload(
        await CacheHelper().getUserSelectedLanguages(),
      );
      final response = await client.get(
        url,
        headers: {'cookie': 'L=$language; gdpr_acceptance=true; DL=english'},
      );

      List songs = jsonDecode(response.body);

      List<SongModel> songsModel =
          songs.map((e) => SongModel.fromJson(e)).toList();

      return DataSuccess(songsModel);
    } catch (e) {
      return DataError('Something went wrong');
    }
  }
}
