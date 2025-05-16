import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:new_tuneflow/core/common/app/cache_helper.dart';
import 'package:new_tuneflow/core/utils/core_utils.dart';
import 'package:new_tuneflow/core/utils/function.dart';
import 'package:new_tuneflow/injection_container.dart';

class AppLifecycleTracker extends StatefulWidget {
  const AppLifecycleTracker({super.key, required this.child});
  final Widget child;

  @override
  State<AppLifecycleTracker> createState() => _AppLifecycleTrackerState();
}

class _AppLifecycleTrackerState extends State<AppLifecycleTracker>
    with WidgetsBindingObserver {
  int userId = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initUser();
  }

  _initUser() async {
    userId = await CacheHelper().getUserId();
    setState(() {});
    _trackLogin();
  }

  void _trackLogin() async {
    if (userId == 0 || !await isConnected()) return;
    // if (!roomProvider.isInRoom) audioHandler.initializeWebSocket();
    get(parseUrl('session/login/$userId'));
  }

  // void _trackLogout() async {
  //   if (userId == 0) return;
  //   // if (!roomProvider.isInRoom) audioHandler.closeSocket();
  //   await get(parseUrl('session/logout/$userId'));
  // }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // if (state == AppLifecycleState.resumed) {
    //   _initUser();
    // }
    // if (state == AppLifecycleState.inactive ||
    //     state == AppLifecycleState.paused) {
    //   _trackLogout();
    // }
    if (state == AppLifecycleState.detached) {
      // _trackLogout();
      audioHandler.stop();
      audioHandler.onTaskRemoved();
      exit(0);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
