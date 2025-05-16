import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/route_manager.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:new_tuneflow/core/common/providers/banner_provider.dart';
import 'package:new_tuneflow/core/common/providers/dash_provider.dart';
import 'package:new_tuneflow/core/common/providers/state_provider.dart';
import 'package:new_tuneflow/core/common/widget/session_tracker.dart';
import 'package:new_tuneflow/core/services/notification_service.dart';
import 'package:new_tuneflow/src/album/presentation/provider/album_provider.dart';
import 'package:new_tuneflow/src/artist_details/presentation/providers/artist_provider.dart';
import 'package:new_tuneflow/src/chat/presentation/providers/chat_provider.dart';
import 'package:new_tuneflow/src/equalizer/presentation/providers/equalizer_provider.dart';
import 'package:new_tuneflow/src/explore/presentation/providers/explore_provider.dart';
import 'package:new_tuneflow/src/forum/presentation/providers/forum_provider.dart';
import 'package:new_tuneflow/src/other_profile/presentation/providers/other_profile_provider.dart';
import 'package:new_tuneflow/src/settings/providers/delete_account_provider.dart';
import 'package:new_tuneflow/src/social/presentation/providers/social_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:new_tuneflow/core/common/bloc/state_bloc.dart';
import 'package:new_tuneflow/core/common/providers/artist_provider.dart';
import 'package:new_tuneflow/core/common/providers/deffer_link_provider.dart';
import 'package:new_tuneflow/core/common/providers/downloads_provider.dart';
import 'package:new_tuneflow/core/common/providers/player_provider.dart';
import 'package:new_tuneflow/core/common/providers/favorite_provider.dart';
import 'package:new_tuneflow/core/common/providers/playlist_provider.dart';
import 'package:new_tuneflow/core/common/providers/profile_provider.dart';
import 'package:new_tuneflow/core/common/providers/room_provider.dart';
import 'package:new_tuneflow/core/common/providers/search_suggestions_provider.dart';
import 'package:new_tuneflow/core/common/providers/user_provider.dart';
import 'package:new_tuneflow/core/res/styles/theme.dart';
import 'package:new_tuneflow/firebase_options.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/src/artist_details/presentation/bloc/artist_details_bloc.dart';
import 'package:new_tuneflow/src/auth/presentation/bloc/artist_bloc.dart';
import 'package:new_tuneflow/src/explore/presentation/bloc/discover_bloc.dart';
import 'package:new_tuneflow/src/explore/presentation/bloc/explore_bloc.dart';
import 'package:new_tuneflow/src/explore/presentation/bloc/foryou_bloc.dart';
import 'package:new_tuneflow/src/explore/presentation/bloc/search_bloc.dart';
import 'package:new_tuneflow/src/explore/presentation/bloc/trending_bloc.dart';
import 'package:new_tuneflow/src/player/presentation/bloc/lyrics_bloc.dart';
import 'package:new_tuneflow/src/playlist/presentation/bloc/playlist_bloc.dart';
import 'package:new_tuneflow/src/song/presentation/bloc/song_details_bloc.dart';
import 'package:new_tuneflow/src/splash/presentation/screens/splash.dart';

@pragma('vm:entry-point')
Future<void> backgroundHandler(RemoteMessage message) async {
  NotificationService.showLocalNotification(message);
}

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class IAPConnection {
  static InAppPurchase? _instance;
  static set instance(InAppPurchase value) {
    _instance = value;
  }

  static InAppPurchase get instance {
    _instance ??= InAppPurchase.instance;
    return _instance!;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('app');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  MobileAds.instance.initialize();
  NotificationService.initialize();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  await initializeDependencies();
  runApp(AppLifecycleTracker(child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ExploreBloc>(
          create: (context) => sl()..add(const ExploreFetch()),
        ),
        BlocProvider<TrendingBloc>(
          create: (context) => sl()..add(const FetchTrending()),
        ),
        BlocProvider<ForyouBloc>(
          create: (context) => sl()..add(const FetchForYouEvent()),
        ),
        BlocProvider<DiscoverBloc>(
          create: (context) => sl()..add(const DiscoverFetch()),
        ),
        BlocProvider<StateBloc>(create: (context) => sl()),
        BlocProvider<PlaylistBloc>(create: (context) => sl()),
        BlocProvider<SongDetailsBloc>(create: (context) => sl()),
        BlocProvider<SearchBloc>(create: (context) => sl()),
        BlocProvider<ArtistDetailsBloc>(create: (context) => sl()),
        BlocProvider<LyricsBloc>(create: (context) => sl()),
        BlocProvider<ArtistBloc>(create: (context) => sl()),
      ],
      child: MultiProvider(
        providers: [
          ListenableProvider<PlayerProvider>(create: (context) => sl()),
          ListenableProvider<FavoriteProvider>(create: (context) => sl()),
          ListenableProvider<ArtistProvider>(create: (context) => sl()),
          ListenableProvider<UserProvider>(create: (context) => sl()),
          ListenableProvider<PlaylistProvider>(create: (context) => sl()),
          ListenableProvider<DownloadsProvider>(create: (context) => sl()),
          ListenableProvider<RoomProvider>(create: (context) => sl()),
          ListenableProvider<SearchSuggestionsProvider>(
            create: (context) => sl(),
          ),
          ListenableProvider<ProfileProvider>(create: (context) => sl()),
          ListenableProvider<DefferLinkProvider>(create: (context) => sl()),
          ListenableProvider<DashProvider>(create: (context) => sl()),
          ListenableProvider<ExploreProvider>(create: (context) => sl()),
          ListenableProvider<OtherProfileProvider>(create: (context) => sl()),
          ListenableProvider<ForumProvider>(create: (context) => sl()),
          ListenableProvider<SocialProvider>(create: (context) => sl()),
          ListenableProvider<ChatProvider>(create: (context) => sl()),
          ListenableProvider<EqualizerProvider>(create: (context) => sl()),
          ListenableProvider<BannerProvider>(create: (context) => sl()),
          ListenableProvider<ArtistSongsProvider>(create: (context) => sl()),
          ListenableProvider<AlbumProvider>(create: (context) => sl()),
          ListenableProvider<StateProvider>(create: (context) => sl()),
          ListenableProvider<DeleteAccountProvider>(create: (context) => sl()),
        ],
        child: ValueListenableBuilder(
          valueListenable: Hive.box('app').listenable(),
          builder: (context, value, child) {
            String themeValue = value.get('themeMode') ?? 'System Default';
            ThemeMode themeMode = ThemeMode.system;
            if (themeValue == 'Light') {
              themeMode = ThemeMode.light;
            } else if (themeValue == 'Dark') {
              themeMode = ThemeMode.dark;
            }

            return DynamicColorBuilder(
              builder: (lightDynamic, darkDynamic) {
                return GetMaterialApp(
                  debugShowCheckedModeBanner: false,
                  navigatorKey: navigatorKey,
                  theme: AppTheme.lightTheme(lightDynamic),
                  darkTheme: AppTheme.dartTheme(darkDynamic),
                  themeMode: themeMode,
                  home: const SplashScreen(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
