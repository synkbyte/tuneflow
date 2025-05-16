part of 'user_api_service.dart';

class UserApiServiceImp implements UserApiService {
  @override
  Future<DataState<UserModel>> getUserDetails(int userId) async {
    try {
      final client = http.Client();
      final url = parseUrl('$userId');
      final response = await client.get(url);
      Map resBody = json.decode(response.body);

      if (resBody['status']) {
        return DataSuccess(UserModel.fromJson(resBody['user']));
      }

      return DataError('error while getting user details');
    } catch (e) {
      return DataError(e.toString());
    }
  }

  @override
  Future<DefaultResponse> updateProfile({
    required int id,
    required String name,
    required String phone,
    required String email,
    required String userName,
    required String bio,
    String? avatar,
  }) async {
    try {
      final client = http.Client();
      final url = parseUrl('$id');
      final body = json.encode({
        'name': name,
        'phone': phone,
        'email': email,
        'userName': userName,
        'avatar': avatar,
        'bio': bio,
      });
      final response = await client.put(
        url,
        body: body,
        headers: {'Content-Type': 'application/json'},
      );
      Map resBody = json.decode(response.body);
      return DefaultResponse.fromJson(resBody);
    } catch (e) {
      return DefaultResponse(status: false, message: 'Something went wrong');
    }
  }

  @override
  Future<void> updateNotificationToken(int userId, String token) async {
    try {
      final client = http.Client();
      final url = parseUrl('$userId/notificationToken');
      final body = json.encode({'notificationToken': token});
      await client.put(
        url,
        body: body,
        headers: {'Content-Type': 'application/json'},
      );
      return;
    } catch (e) {
      return;
    }
  }

  @override
  Future<void> updateDevice(int userId, Map details) async {
    try {
      final client = http.Client();
      final url = parseUrl('$userId/device');
      final body = json.encode({'deviceDetails': details});
      await client.put(
        url,
        body: body,
        headers: {'Content-Type': 'application/json'},
      );
      return;
    } catch (e) {
      return;
    }
  }

  @override
  Future<Map> fetchProfile(int userId, int requestedBy) async {
    try {
      final client = http.Client();
      final url = parseUrl('other/$userId/$requestedBy');
      final response = await client.get(url);
      return json.decode(response.body);
    } catch (e) {
      return {'status': false};
    }
  }

  @override
  Future<Map> fetchFollowData(int userId) async {
    try {
      final client = http.Client();
      final url = parseUrl('$userId/followData');
      final response = await client.get(url);
      return json.decode(response.body);
    } catch (e) {
      return {'status': false};
    }
  }

  @override
  Future<Map> fetchLeaderboard() async {
    try {
      final client = http.Client();
      final url = parseUrl('leaderboard/top10');
      final response = await client.get(url);
      return json.decode(response.body);
    } catch (e) {
      return {'status': false};
    }
  }

  @override
  Future<Map> toggleFollow(int userId, int forUser, bool isForFollow) async {
    try {
      final client = http.Client();
      final url =
          isForFollow
              ? parseUrl('$userId/follow/$forUser')
              : parseUrl('$userId/unfollow/$forUser');
      final response = await client.post(url);
      return json.decode(response.body);
    } catch (e) {
      return {'status': false};
    }
  }

  @override
  Future<Map> fetchBatchedUsers() async {
    try {
      final client = http.Client();
      final url = parseUrl('tuneflow/batched/users');
      final response = await client.get(url);
      return json.decode(response.body);
    } catch (e) {
      return {'status': false};
    }
  }

  @override
  Future<Map> searchUsers(String searchTerm) async {
    try {
      final client = http.Client();
      final url = parseUrl('search/users', {'searchTerm': searchTerm});
      final response = await client.get(url);
      return json.decode(response.body);
    } catch (e) {
      return {'status': false};
    }
  }
}
