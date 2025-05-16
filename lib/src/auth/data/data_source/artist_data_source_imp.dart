part of 'artist_data_source.dart';

class ArtistApiServiceImp extends ArtistApiService {
  @override
  Future<DataState<List<ArtistModel>>> getArtistByQuery({String? query}) async {
    try {
      final client = http.Client();
      final artistUrl = Uri.parse(baseUrl).replace(
        queryParameters: {
          ...defaultParams,
          '__call': 'search.getArtistResults',
          'q': query,
        },
      );
      String language = formateLangaugeForPayload(
        await CacheHelper().getUserSelectedLanguages(),
      );
      final artistResponse = await client.get(
        artistUrl,
        headers: {'cookie': 'L=$language; gdpr_acceptance=true; DL=english'},
      );

      List artistResult = jsonDecode(artistResponse.body)['results'];
      List<ArtistModel> artistModel =
          artistResult.map((e) => ArtistModel.fromJson(e)).toList();

      return DataSuccess(artistModel);
    } catch (e) {
      return DataError('Something went wrong');
    }
  }

  @override
  Future<DataState<List<ArtistModel>>> getTopArtists() async {
    try {
      String language = formateLangaugeForPayload(
        await CacheHelper().getUserSelectedLanguages(),
      );
      final client = http.Client();
      final artistUrl = Uri.parse(baseUrl).replace(
        queryParameters: {
          ...defaultParams,
          '__call': 'social.getTopArtists',
          'entity_language': language,
          'entity_type': 'song'
        },
      );
      final artistResponse = await client.get(
        artistUrl,
        headers: {'cookie': 'L=$language; gdpr_acceptance=true; DL=english'},
      );

      List artistResult = jsonDecode(artistResponse.body)['top_artists'];
      List<ArtistModel> artistModel =
          artistResult.map((e) => ArtistModel.fromJson(e)).toList();

      return DataSuccess(artistModel);
    } catch (e) {
      return DataError('Something went wrong');
    }
  }

  @override
  Future<DataState<SignupModel>> updateSelectedArtists(
    int userId,
    List artists,
  ) async {
    try {
      final client = http.Client();
      final url = parseUrl('artist');
      final body = {
        'userId': userId,
        'artistsMap': artists,
      };
      final response = await client.post(
        url,
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      return DataSuccess(SignupModel.fromString(response.body));
    } catch (e) {
      return DataError('Somthing went wrong');
    }
  }

  @override
  Future<DataState<List<ArtistModel>>> getSavedArtists(int userId) async {
    try {
      final client = http.Client();
      final url = parseUrl('artist/$userId');
      final response = await client.get(url);
      Map resBody = json.decode(response.body);

      if (resBody['status']) {
        List artists = resBody['artistsMap'];
        return DataSuccess(
            artists.map((e) => ArtistModel.fromJson(e)).toList());
      }

      return DataError('error while getting');
    } catch (e) {
      return DataError(e.toString());
    }
  }
}
