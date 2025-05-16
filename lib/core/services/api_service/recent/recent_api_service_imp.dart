part of 'recent_api_service.dart';

class RecentApiServiceImp implements RecentApiService {
  @override
  Future<DataState<List>> getRecentSongs(int userId) async {
    try {
      final client = http.Client();
      final url = parseUrl('recent/$userId');
      final response = await client.get(url);
      Map resBody = json.decode(response.body);
      if (resBody['status']) {
        return DataSuccess(resBody['recentSongs']);
      }
      return DataError('error while getting');
    } catch (e) {
      return DataError('error while getting');
    }
  }

  @override
  Future<void> updateRecentSongs(int userId, List songs) async {
    try {
      final client = http.Client();
      final url = parseUrl('recent');
      final body = json.encode({
        'userId': userId,
        'songs': songs,
        'version': 'new',
      });
      await client.post(
        url,
        body: body,
        headers: {'Content-Type': 'application/json'},
      );
      return;
    } catch (e) {
      return;
    }
  }
}
