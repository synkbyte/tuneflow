// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_tuneflow/core/common/app/cache_helper.dart';
import 'package:new_tuneflow/core/common/bloc/state_bloc.dart';
import 'package:new_tuneflow/core/common/providers/deffer_link_provider.dart';
import 'package:new_tuneflow/core/common/providers/player_provider.dart';
import 'package:new_tuneflow/core/common/providers/room_provider.dart';
import 'package:new_tuneflow/core/common/providers/state_provider.dart';
import 'package:new_tuneflow/core/common/providers/user_provider.dart';
import 'package:new_tuneflow/core/common/widget/edge_to_edge.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/res/media.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/src/auth/presentation/screens/signin_or_signup.dart';
import 'package:new_tuneflow/src/chat/presentation/providers/chat_provider.dart';
import 'package:new_tuneflow/src/home/presentation/screens/home.dart';
import 'package:new_tuneflow/src/other_profile/presentation/providers/other_profile_provider.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const platform = MethodChannel('device_info_channel');
  int maxTry = 3;
  int currentTry = 0;

  @override
  void initState() {
    super.initState();
    checkAndRun();
  }

  checkAndRun() async {
    int sdkVersion = await fetchSdkVersion();
    await updateSdkVersion(sdkVersion);
    initializeApplication();
  }

  Future<int> fetchSdkVersion() async {
    return (await platform.invokeMethod<int>('getSdkVersion') ?? 0);
  }

  Future<bool> updateSdkVersion(int version) async {
    return await context.read<StateProvider>().updateSdkVersion(version);
  }

  initializeApplication() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<DefferLinkProvider>(context, listen: false).initDeepLinks();
      stateProvider = Provider.of<StateProvider>(context, listen: false);
      stateProvider.checkPermissionStatus();
      stateProvider.initialize();
      redirect();
    });
  }

  @override
  Widget build(BuildContext context) {
    roomProvider = Provider.of<RoomProvider>(context);
    playerProvider = Provider.of<PlayerProvider>(context);
    stateBloc = BlocProvider.of<StateBloc>(context);
    defferLinkProvider = Provider.of<DefferLinkProvider>(context);
    userProvider = Provider.of<UserProvider>(context);
    otherProfileProvider = Provider.of<OtherProfileProvider>(context);
    chatProvider = Provider.of<ChatProvider>(context);

    return EdgeToEdge(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Center(child: _buildLogo())],
        ),
      ),
    );
  }

  _buildLogo() {
    return Container(
      height: 150,
      width: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            blurRadius: 100,
            color: context.primary.withValues(alpha: .1),
          ),
        ],
        image: const DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage(Media.logo),
        ),
      ),
    );
  }

  Future<void> redirect() async {
    await Future.delayed(const Duration(seconds: 2));
    int userId = await CacheHelper().getUserId();
    if (stateProvider.faultRes.isNotEmpty) {
      currentTry++;
      if (currentTry < maxTry) {
        redirect();
      }
      return;
    }
    if (userId != 0) {
      Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
          child: const HomeScreen(),
          type: PageTransitionType.fade,
        ),
        (route) => false,
      );
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      PageTransition(
        child: const SignInOrSignUpScreen(),
        type: PageTransitionType.fade,
      ),
      (route) => false,
    );
  }
}
