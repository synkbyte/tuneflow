import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:new_tuneflow/core/common/app/cache_helper.dart';
import 'package:new_tuneflow/core/constants/constants.dart';
import 'package:new_tuneflow/core/services/notification_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:new_tuneflow/core/utils/core_utils.dart';
import 'package:http/http.dart' as http;
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/main.dart';
import 'package:new_tuneflow/screens/maintenance_screen.dart';
import 'package:page_transition/page_transition.dart';

class StateProvider extends ChangeNotifier {
  bool isDrawerOpened = false;
  bool hasPermission = false;

  bool hasCheckedForFault = false;
  Map faultRes = {};

  bool versionChecked = false;
  int sdkInt = 0;

  bool clickedOnRetry = false;
  bool hasInternetConnection = true;

  void toggleDrawer() {
    isDrawerOpened = !isDrawerOpened;
    notifyListeners();
  }

  void checkPermissionStatus() async {
    hasPermission = await NotificationService.isServiceEnabled();
    notifyListeners();
  }

  initialize() async {
    bool hasCheckedForFault = await checkAnyIssue();
    if (!hasCheckedForFault) {
      Connectivity().onConnectivityChanged.listen((event) {
        if (!event.contains(ConnectivityResult.none) &&
            !this.hasCheckedForFault) {
          checkAnyIssue();
        }
      });
    }
  }

  Future<bool> checkAnyIssue() async {
    int userId = await CacheHelper().getUserId();
    try {
      final client = http.Client();
      final url = parseUrl('checkIssue/ifHave', {
        'version': '$buildNumber',
        if (userId != 0) 'userId': '$userId',
      });
      final response = await client.get(url);
      faultRes = jsonDecode(response.body);
      hasCheckedForFault = true;
      notifyListeners();
      if (response.statusCode == 403) {
        audioHandler.stop();
        Navigator.pushAndRemoveUntil(
          navigatorKey.currentContext!,
          PageTransition(
            child: MaintenanceScreen(),
            type: PageTransitionType.fade,
          ),
          (route) => false,
        );
      } else {
        faultRes = {};
        notifyListeners();
      }
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<bool> updateSdkVersion(int version) async {
    versionChecked = true;
    sdkInt = version;
    notifyListeners();
    return true;
  }

  updateRetry(bool value) {
    clickedOnRetry = value;
    notifyListeners();
  }

  updateHasInternetConnection(bool value) {
    hasInternetConnection = value;
    notifyListeners();
  }
}
