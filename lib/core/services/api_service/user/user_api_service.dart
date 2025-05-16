import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/common/models/user_model.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/core/utils/core_utils.dart';

part 'user_api_service_imp.dart';

abstract class UserApiService {
  Future<DataState<UserModel>> getUserDetails(int userId);
  Future<DefaultResponse> updateProfile({
    required int id,
    required String name,
    required String phone,
    required String email,
    required String userName,
    required String bio,
    String? avatar,
  });
  Future<void> updateNotificationToken(int userId, String token);
  Future<void> updateDevice(int userId, Map details);
  Future<Map> fetchProfile(int userId, int requestedBy);
  Future<Map> fetchFollowData(int userId);
  Future<Map> fetchLeaderboard();
  Future<Map> fetchBatchedUsers();
  Future<Map> searchUsers(String searchTerm);
  Future<Map> toggleFollow(int userId, int forUser, bool isForFollow);
}
