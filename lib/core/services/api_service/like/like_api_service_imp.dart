part of 'like_api_service.dart';

class LikeApiServiceImp implements LikeApiService {
  @override
  Future<void> toggleLikeSong(int userId, String songId, Map songMap) async {
    try {
      final client = http.Client();
      final url = parseUrl('favorites');
      final body = {
        'userId': userId,
        'songId': songId,
        'songMap': songMap,
      };
      await client.post(
        url,
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      return;
    } catch (e) {
      return;
    }
  }

  @override
  Future<DataState<List<SongModel>>> getUserLikedSongs(int userId) async {
    try {
      final client = http.Client();
      final url = parseUrl('favorites/$userId');
      final response = await client.get(url);
      Map resBody = json.decode(response.body);
      if (resBody['status']) {
        List favoriteSongs = resBody['favoriteSongs'];
        return DataSuccess(favoriteSongs
            .map((e) => SongModel.fromJson(e['songMap']))
            .toList());
      }
      return DataError('error while getting');
    } catch (e) {
      return DataError(e.toString());
    }
  }
}
