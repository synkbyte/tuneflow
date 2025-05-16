import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:new_tuneflow/core/common/app/cache_helper.dart';
import 'package:new_tuneflow/core/services/api_service/deep_link/deep_link_api_service.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/main.dart';
import 'package:new_tuneflow/src/settings/delete_account/delete_account.dart';
import 'package:page_transition/page_transition.dart';

class DefferLinkProvider extends ChangeNotifier {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  DeepLinkApiService service = sl();
  bool isInitialized = false;
  bool isInHold = false;
  late String extracted;

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      openAppLink(uri);
    });
  }

  Future<void> openAppLink(Uri uri) async {
    String scheme = uri.toString().split('.info/')[1];
    if (scheme == 'accountDelete') {
      extracted = scheme;
      isInHold = true;
      notifyListeners();
      return;
    }
    extracted = await service.extractLink(scheme);
    if (extracted.isEmpty) return;
    if (isInitialized) {
      navigateToLink();
      return;
    }
    isInHold = true;
    notifyListeners();
  }

  navigateToLink() async {
    if (extracted == 'accountDelete') {
      int userId = await CacheHelper().getUserId();
      if (userId != 0) {
        Navigator.pushAndRemoveUntil(
          navigatorKey.currentContext!,
          PageTransition(
            child: DeleteAccountScreen(),
            type: PageTransitionType.fade,
          ),
          (route) => false,
        );
      }
      return;
    }
    Uri gotUri = Uri.parse(extracted);
    if (extracted.startsWith('https://room.tuneflow.info')) {
      Map query = gotUri.queryParameters;
      String type = query['type'] ?? '';
      String id = query['id'] ?? '';
      if (type == 'join' && id.isNotEmpty) {
        if (!roomProvider.isInRoom) {
          audioHandler.joinRoom(id);
        }
      }
    }
  }

  checkIfHasNavigation() {
    isInitialized = true;
    notifyListeners();
    if (isInHold) {
      navigateToLink();
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }
}
