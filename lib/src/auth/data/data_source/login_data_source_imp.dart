part of 'login_data_source.dart';

class LoginApiServiceImp implements LoginApiService {
  @override
  Future<DataState<LoginModel>> loginRequest(
    String identifier,
    String password,
  ) async {
    ArtistApiService artistApiService = sl();
    LikeApiService likeApiService = sl();
    try {
      final client = http.Client();
      final url = parseUrl('login');
      final body = {
        'identifier': identifier,
        'password': password,
      };
      final response = await client.post(
        url,
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      Map resBody = json.decode(response.body);

      if (resBody['status']) {
        await artistApiService.getSavedArtists(resBody['id']);
        await likeApiService.getUserLikedSongs(resBody['id']);
        return DataSuccess(LoginModel.fromJson(resBody));
      }
      return DataError(resBody['message']);
    } catch (e) {
      return DataError('Somthing went wrong');
    }
  }
}
