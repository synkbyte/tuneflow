import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:new_tuneflow/core/common/app/cache_helper.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/common/models/user_model.dart';
import 'package:new_tuneflow/core/common/singletones/cache.dart';
import 'package:new_tuneflow/core/common/singletones/user.dart';
import 'package:new_tuneflow/core/res/data_state.dart';
import 'package:new_tuneflow/core/services/api_service/user/user_api_service.dart';
import 'package:new_tuneflow/core/utils/function.dart';
import 'package:new_tuneflow/injection_container.dart';

class UserProvider extends ChangeNotifier {
  UserApiService service = sl();
  UserModel? userModel;
  List<LanguageModel> languages = [];
  String languagesString = '';

  updateUserRoom() async {
    DataState state = await service.getUserDetails(Cache.instance.userId);
    if (state is DataSuccess) {
      userModel = state.data;
      User.instance.setUserModel(userModel!);
      await CacheHelper().saveUserModel(userModel!);
    }
    return;
  }

  initializeUser({bool isSecondTime = false}) async {
    userModel = await CacheHelper().getUserModel();
    if (userModel != null) User.instance.setUserModel(userModel!);
    notifyListeners();

    DataState state = await service.getUserDetails(Cache.instance.userId);
    if (state is DataSuccess) {
      userModel = state.data;
      User.instance.setUserModel(userModel!);
      await CacheHelper().saveUserModel(userModel!);
      notifyListeners();
    }
    if (isSecondTime) return;
    await audioHandler.initializeWebSocket();
    await CacheHelper().saveDefaultMusicQuality(
      await CacheHelper().getDefaultMusicQuality(),
    );
    CacheHelper().saveDefaultDownloadQuality(
      await CacheHelper().getDefaultDownloadQuality(),
    );
    languages = userModel!.languages;
    await CacheHelper().saveSelectedUserLanguages(
      languages.map((e) => e.toMap()).toList(),
    );
    FirebaseCrashlytics.instance.setUserIdentifier(
      '${userModel!.name}-${userModel!.id}',
    );
    notifyListeners();
    finalizeLanguage();
    updateUserDetails();
  }

  updateUserDetails() async {
    if (Hive.box('app').get('token') != null) {
      await service.updateNotificationToken(
        userModel!.id,
        Hive.box('app').get('token'),
      );
    }
    Map info = await getDeviceInfo();
    await service.updateDevice(userModel!.id, info);
    notifyListeners();
  }

  finalizeLanguage() {
    languagesString = '';
    for (var i = 0; i < languages.length; i++) {
      languagesString += languages[i].name;
      if (i != languages.length - 1) {
        languagesString += ', ';
      }
    }
    notifyListeners();
  }
}
