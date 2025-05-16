part of 'lyrics_data_source.dart';

class LyricsApiServiceImp implements LyricsApiService {
  @override
  Future<DataState<LyricsModel>> getLyrics(String id) async {
    try {
      final client = http.Client();
      final url = Uri.parse(baseUrl).replace(
        queryParameters: {
          ...defaultParams,
          '__call': 'lyrics.getLyrics',
          'lyrics_id': id,
        },
      );
      final response = await client.get(
        url,
        headers: {'cookie': 'L=english; gdpr_acceptance=true; DL=english'},
      );

      Map resBody = jsonDecode(response.body);

      return DataSuccess(LyricsModel(
        lyrics: resBody['lyrics'],
        scriptTrackingUrl: resBody['script_tracking_url'],
        lyricsCopyright: resBody['lyrics_copyright'],
        snippet: resBody['snippet'],
      ));
    } catch (e) {
      return DataError('Something went wrong');
    }
  }
}
