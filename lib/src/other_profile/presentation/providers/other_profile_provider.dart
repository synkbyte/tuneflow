import 'package:flutter/material.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/common/models/user_model.dart';
import 'package:new_tuneflow/core/common/singletones/cache.dart';
import 'package:new_tuneflow/core/services/api_service/user/user_api_service.dart';
import 'package:new_tuneflow/injection_container.dart';

class OtherProfileProvider extends ChangeNotifier {
  bool gotError = true;
  String errorMessage = 'Somthing went wrong';
  bool isGetting = true;
  late UserModel profile;
  List<UserPlaylistModel> playlists = [];
  UserApiService service = sl();
  bool followedByMe = false;
  bool followedByThis = false;
  bool blockedByMe = false;
  bool isBlockedByThis = false;

  late UserModel followDataUser;
  bool followDataLoading = true;
  bool followDataError = false;
  String followDataErrorMessage = 'Somthing went wrong';
  List followers = [];
  List following = [];

  fetchProfile(int id) async {
    try {
      isGetting = true;
      gotError = false;
      notifyListeners();
      Map response = await service.fetchProfile(id, Cache.instance.userId);
      if (response['status']) {
        profile = UserModel.fromJson(response['user']);
        playlists =
            List.from(
              response['playlists'],
            ).map((playlist) => UserPlaylistModel.fromJson(playlist)).toList();
        followedByMe = response['followedByMe'];
        followedByThis = response['followedByThis'];
        blockedByMe = response['blockedByMe'];
        isBlockedByThis = response['isBlockedByThis'];
      } else {
        gotError = true;
      }
      isGetting = false;
      notifyListeners();
    } catch (error) {
      gotError = true;
      isGetting = false;
      notifyListeners();
    }
  }

  toggleFollow() async {
    followedByMe = !followedByMe;
    followedByMe ? profile.followers++ : profile.followers--;
    notifyListeners();
    await service.toggleFollow(Cache.instance.userId, profile.id, followedByMe);
    userProvider.initializeUser(isSecondTime: true);
  }

  fetchFollowers(UserModel model) async {
    try {
      followDataUser = model;
      followDataLoading = true;
      followDataError = false;
      notifyListeners();
      Map response = await service.fetchFollowData(model.id);
      if (response['status']) {
        followDataLoading = false;
        followDataError = false;
        followers = response['followers'];
        following = response['following'];
      } else {
        followDataLoading = false;
        followDataError = true;
      }
      notifyListeners();
    } catch (error) {
      followDataError = true;
      followDataLoading = false;
      notifyListeners();
    }
  }
}
