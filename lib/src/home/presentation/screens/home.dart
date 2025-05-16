// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_seek_bar/circular_seek_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:ionicons/ionicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:new_tuneflow/core/common/bloc/state_bloc.dart';
import 'package:new_tuneflow/core/common/providers/artist_provider.dart';
import 'package:new_tuneflow/core/common/providers/banner_provider.dart';
import 'package:new_tuneflow/core/common/providers/dash_provider.dart';
import 'package:new_tuneflow/core/common/providers/downloads_provider.dart';
import 'package:new_tuneflow/core/common/providers/favorite_provider.dart';
import 'package:new_tuneflow/core/common/providers/player_provider.dart';
import 'package:new_tuneflow/core/common/providers/playlist_provider.dart';
import 'package:new_tuneflow/core/common/providers/profile_provider.dart';
import 'package:new_tuneflow/core/common/providers/room_provider.dart';
import 'package:new_tuneflow/core/common/providers/search_suggestions_provider.dart';
import 'package:new_tuneflow/core/common/providers/state_provider.dart';
import 'package:new_tuneflow/core/common/providers/user_provider.dart';
import 'package:new_tuneflow/core/common/singletones/user.dart';
import 'package:new_tuneflow/core/common/widget/edge_to_edge.dart';
import 'package:new_tuneflow/core/common/widget/like_button.dart';
import 'package:new_tuneflow/core/common/widget/loading.dart';
import 'package:new_tuneflow/core/common/widget/threed_drawer.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/res/media.dart';
import 'package:new_tuneflow/core/snackbar/snackbar.dart';
import 'package:new_tuneflow/core/utils/function.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/screens/no_internet_screen.dart';
import 'package:new_tuneflow/src/explore/presentation/providers/explore_provider.dart';
import 'package:new_tuneflow/src/explore/presentation/screen/explore_main.dart';
import 'package:new_tuneflow/src/explore/presentation/screen/search.dart';
import 'package:new_tuneflow/src/forum/presentation/providers/forum_provider.dart';
import 'package:new_tuneflow/src/player/presentation/bloc/lyrics_bloc.dart';
import 'package:new_tuneflow/src/player/presentation/screens/player_screen.dart';
import 'package:new_tuneflow/src/profile/presentation/screens/profile.dart';
import 'package:new_tuneflow/src/social/presentation/providers/social_provider.dart';
import 'package:new_tuneflow/src/social/presentation/screens/social.dart';
import 'package:provider/provider.dart';
import 'package:ticker_text/ticker_text.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.haveToInitilized = true});
  final bool haveToInitilized;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initializeApp();
    });
  }

  late PlayerProvider playerProvider;

  initializeApp() {
    if (!widget.haveToInitilized) return;
    tryLoadingApp();
  }

  bool hasInternetConnection = true;

  checkForInternetConnection() async {
    hasInternetConnection = await isConnected();
    context.read<StateProvider>().updateHasInternetConnection(
      hasInternetConnection,
    );
    setState(() {});
    if (!hasInternetConnection) {
      context.read<StateBloc>().add(const StateChangeIndex(4));
      Provider.of<ProfileProvider>(context, listen: false).changeIndex(2);
      errorMessage(context, 'No Internet connection');
    }
  }

  int homeIndex = 1;

  tryLoadingApp() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<StateProvider>().updateRetry(false);
    });
    await checkForInternetConnection();
    Provider.of<UserProvider>(context, listen: false).initializeUser();
    playerProvider.getInitialSongs();
    Provider.of<RoomProvider>(context, listen: false).checkUpdate();
    Provider.of<SocialProvider>(context, listen: false).fetchLeaderboards();
    Provider.of<ExploreProvider>(context, listen: false).fetchExploreApi();
    Provider.of<PlayerProvider>(context, listen: false).initializeRecentList();
    Provider.of<FavoriteProvider>(context, listen: false).initFavoriteSongs();
    Provider.of<PlaylistProvider>(context, listen: false).initPlaylists();
    Provider.of<ArtistProvider>(context, listen: false).intializeArtist();
    Provider.of<DownloadsProvider>(context, listen: false).initUserDownloads();
    BlocProvider.of<LyricsBloc>(context, listen: false).add(LyricsListen());
    Provider.of<SearchSuggestionsProvider>(
      context,
      listen: false,
    ).getTrendings();
    Provider.of<DashProvider>(context, listen: false).initialize();
    Provider.of<ForumProvider>(context, listen: false).fetchExploreFeed();
    Provider.of<ForumProvider>(context, listen: false).fetchMineFeed();
    Provider.of<ForumProvider>(context, listen: false).fetchNotifications();
    Provider.of<BannerProvider>(context, listen: false).fetchBanners();
  }

  Future<void> sendAppToBackground() async {
    const platform = MethodChannel('app.channel.shared.data');
    try {
      await platform.invokeMethod('sendToBackground');
    } on PlatformException catch (e) {
      debugPrint("Failed to send app to background: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    playerProvider = Provider.of<PlayerProvider>(context);
    final stateProvider = Provider.of<StateProvider>(context);

    if (stateProvider.clickedOnRetry) {
      tryLoadingApp();
    }

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top],
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (stateProvider.isDrawerOpened) {
          stateProvider.toggleDrawer();
          return;
        }
        if (playerProvider.isLoaded && homeIndex == 0) {
          sendAppToBackground();
          return;
        }
        if (!playerProvider.isLoaded && homeIndex == 1) {
          sendAppToBackground();
          return;
        }
        context.read<StateBloc>().add(
          StateChangeIndex(playerProvider.isLoaded ? 0 : 1),
        );
      },
      child: EdgeToEdge(
        value: SystemUiOverlayStyle(
          systemStatusBarContrastEnforced: true,
          statusBarColor: context.bgColor.withValues(alpha: .002),
          systemNavigationBarColor: context.bgColor.withValues(alpha: .002),
          systemNavigationBarDividerColor: context.bgColor.withValues(
            alpha: .002,
          ),
          statusBarIconBrightness: context.brightness,
          systemNavigationBarIconBrightness: context.brightness,
        ),
        child: BlocBuilder<StateBloc, StateState>(
          builder: (context, state) {
            homeIndex = 1;
            if (state is StateInitial) {
              homeIndex = state.homeIndex ?? 1;
            }

            if (state is StateIndexChanged) {
              homeIndex = state.index;
            }

            return Stack(
              children: [
                if (User.instance.user != null) ThreedDrawer(),
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  transform:
                      Matrix4.identity()
                        ..translate(
                          stateProvider.isDrawerOpened ? -200.0 : 0.0,
                          stateProvider.isDrawerOpened ? 50.0 : 0.0,
                        )
                        ..scale(stateProvider.isDrawerOpened ? 0.85 : 1.0)
                        ..rotateZ(stateProvider.isDrawerOpened ? pi / 50 : 0),
                  decoration: BoxDecoration(
                    borderRadius:
                        stateProvider.isDrawerOpened
                            ? BorderRadius.circular(20)
                            : BorderRadius.zero,
                    boxShadow:
                        stateProvider.isDrawerOpened
                            ? [
                              BoxShadow(
                                color: context.primary.withValues(alpha: .3),
                                blurRadius: 30,
                              ),
                            ]
                            : [],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      stateProvider.isDrawerOpened ? 20 : 0,
                    ),
                    child: Scaffold(
                      body:
                          User.instance.user != null
                              ? IndexedStack(
                                index: homeIndex,
                                children:
                                    !hasInternetConnection
                                        ? [
                                          if (playerProvider.isLoaded)
                                            const PlayerScreen()
                                          else
                                            const SizedBox(),
                                          const NoInternetScreen(),
                                          const NoInternetScreen(),
                                          const NoInternetScreen(),
                                          const ProfileScreen(),
                                        ]
                                        : [
                                          if (playerProvider.isLoaded)
                                            const PlayerScreen()
                                          else
                                            const SizedBox(),
                                          const ExploreNew(),
                                          const SocialScreen(),
                                          const SearchScreen(),
                                          const ProfileScreen(),
                                        ],
                              )
                              : const LoadingWidget(),
                      bottomNavigationBar: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: context.scheme.secondaryContainer,
                            ),
                            child: Column(
                              children: [
                                if (homeIndex != 0 && playerProvider.isLoaded)
                                  const Gap(5),
                                if (homeIndex != 0 && playerProvider.isLoaded)
                                  GestureDetector(
                                    onTap: () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      context.read<StateBloc>().add(
                                        const StateChangeIndex(0),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color:
                                            context.scheme.secondaryContainer,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 20,
                                          right: 10,
                                        ),
                                        child: Row(
                                          children: [
                                            CircularSeekBar(
                                              width: 50,
                                              height: 50,
                                              minProgress: 0,
                                              maxProgress:
                                                  (playerProvider.isLoading ||
                                                          !playerProvider
                                                              .isLoaded ||
                                                          playerProvider
                                                                  .totalDuration ==
                                                              Duration.zero ||
                                                          playerProvider
                                                                  .totalDuration
                                                                  .inMilliseconds ==
                                                              0)
                                                      ? 100
                                                      : playerProvider
                                                          .totalDuration
                                                          .inMilliseconds
                                                          .toDouble(),

                                              progress:
                                                  (playerProvider.isLoading ||
                                                          !playerProvider
                                                              .isLoaded ||
                                                          playerProvider
                                                                  .currentDuration ==
                                                              Duration.zero)
                                                      ? 0
                                                      : playerProvider
                                                          .currentDuration
                                                          .inMilliseconds
                                                          .toDouble(),
                                              animation: false,
                                              startAngle: 360,
                                              barWidth: 3,
                                              progressColor:
                                                  context.scheme.primary,
                                              trackColor:
                                                  context.scheme.onPrimary,
                                              child: Center(
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      playerProvider
                                                          .nowPlaying
                                                          ?.imagesUrl
                                                          .excellent ??
                                                      '',
                                                  placeholder: (context, url) {
                                                    return Container(
                                                      height: 45,
                                                      width: 45,
                                                      decoration:
                                                          const BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            image: DecorationImage(
                                                              fit: BoxFit.cover,
                                                              image: AssetImage(
                                                                Media.logo,
                                                              ),
                                                            ),
                                                          ),
                                                    );
                                                  },
                                                  imageBuilder: (
                                                    context,
                                                    imageProvider,
                                                  ) {
                                                    return Container(
                                                      height: 45,
                                                      width: 45,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        image: DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: imageProvider,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  TickerText(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    speed: 20,
                                                    startPauseDuration:
                                                        const Duration(
                                                          seconds: 3,
                                                        ),
                                                    endPauseDuration:
                                                        const Duration(
                                                          seconds: 3,
                                                        ),
                                                    returnDuration:
                                                        const Duration(
                                                          milliseconds: 10,
                                                        ),
                                                    primaryCurve: Curves.linear,
                                                    returnCurve: Curves.easeOut,
                                                    child: Text(
                                                      playerProvider
                                                              .nowPlaying
                                                              ?.title ??
                                                          '',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Text(
                                                    playerProvider
                                                            .nowPlaying
                                                            ?.subtitle ??
                                                        '',
                                                    style: const TextStyle(
                                                      fontSize: 8,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            LikeButton(
                                              song: playerProvider.nowPlaying!,
                                              size: 21,
                                              color: context.onBgColor,
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                playerProvider.togglePlayer();
                                              },
                                              icon:
                                                  playerProvider.isLoading
                                                      ? LoadingAnimationWidget.staggeredDotsWave(
                                                        color:
                                                            context
                                                                .scheme
                                                                .onSurface,
                                                        size: 22,
                                                      )
                                                      : Icon(
                                                        playerProvider.isPlaying
                                                            ? Icons.pause
                                                            : Icons.play_arrow,
                                                        size: 22,
                                                        color:
                                                            context.onBgColor,
                                                      ),
                                            ),
                                            if (audioHandler
                                                .audioPlayer
                                                .hasNext)
                                              IconButton(
                                                onPressed: () {
                                                  audioHandler.skipToNext();
                                                },
                                                icon: Icon(
                                                  Icons.skip_next,
                                                  size: 22,
                                                  color: context.onBgColor,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                if (homeIndex != 0 && playerProvider.isLoaded)
                                  Divider(
                                    color: context.scheme.onSurface.withValues(
                                      alpha: .1,
                                    ),
                                  ),
                                if (!(homeIndex != 0 &&
                                    playerProvider.isLoaded))
                                  const Gap(5),
                                Row(
                                  children: [
                                    if (playerProvider.isLoaded)
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                            context.read<StateBloc>().add(
                                              const StateChangeIndex(0),
                                            );
                                          },
                                          child: Container(
                                            height: 55,
                                            decoration: BoxDecoration(
                                              color:
                                                  context
                                                      .scheme
                                                      .secondaryContainer,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                      20,
                                                    ),
                                                    bottomLeft: Radius.circular(
                                                      20,
                                                    ),
                                                  ),
                                            ),
                                            child: Icon(
                                              Ionicons.musical_note_outline,
                                              color:
                                                  _isActive(0, homeIndex)
                                                      ? context.primary
                                                      : context
                                                          .scheme
                                                          .onSecondaryContainer,
                                              size: 21,
                                            ),
                                          ),
                                        ),
                                      ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                          context.read<StateBloc>().add(
                                            const StateChangeIndex(1),
                                          );
                                        },
                                        child: Container(
                                          height: 55,
                                          decoration: BoxDecoration(
                                            color:
                                                context
                                                    .scheme
                                                    .secondaryContainer,
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  bottomLeft: Radius.circular(
                                                    20,
                                                  ),
                                                ),
                                          ),
                                          child: Icon(
                                            Icons.grid_view_outlined,
                                            color:
                                                _isActive(1, homeIndex)
                                                    ? context.primary
                                                    : context
                                                        .scheme
                                                        .onSecondaryContainer,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                          context.read<StateBloc>().add(
                                            const StateChangeIndex(2),
                                          );
                                          roomProvider.getRooms();
                                        },
                                        child: Container(
                                          height: 55,
                                          color:
                                              context.scheme.secondaryContainer,
                                          child: Icon(
                                            Icons.diversity_1_outlined,
                                            color:
                                                _isActive(2, homeIndex)
                                                    ? context.primary
                                                    : context
                                                        .scheme
                                                        .onSecondaryContainer,
                                            size: 19,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                          context.read<StateBloc>().add(
                                            const StateChangeIndex(3),
                                          );
                                        },
                                        child: Container(
                                          height: 55,
                                          color:
                                              context.scheme.secondaryContainer,
                                          child: Icon(
                                            Icons.search,
                                            color:
                                                _isActive(3, homeIndex)
                                                    ? context.primary
                                                    : context
                                                        .scheme
                                                        .onSecondaryContainer,
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                          context.read<StateBloc>().add(
                                            const StateChangeIndex(4),
                                          );
                                        },
                                        child: Container(
                                          height: 55,
                                          decoration: BoxDecoration(
                                            color:
                                                context
                                                    .scheme
                                                    .secondaryContainer,
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topRight: Radius.circular(20),
                                                  bottomRight: Radius.circular(
                                                    20,
                                                  ),
                                                ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Stack(
                                            children: [
                                              Icon(
                                                Icons.person_outline,
                                                color:
                                                    _isActive(4, homeIndex)
                                                        ? context.primary
                                                        : context
                                                            .scheme
                                                            .onSecondaryContainer,
                                                size: 22.5,
                                              ),
                                              if (chatProvider.unreadCount > 0)
                                                Positioned(
                                                  right: 0,
                                                  child: Badge(),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(5),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).padding.bottom + 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (stateProvider.isDrawerOpened)
                  GestureDetector(
                    onTap: () {
                      stateProvider.toggleDrawer();
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      transform:
                          Matrix4.identity()
                            ..translate(
                              stateProvider.isDrawerOpened ? -200.0 : 0.0,
                              stateProvider.isDrawerOpened ? 50.0 : 0.0,
                            )
                            ..scale(stateProvider.isDrawerOpened ? 0.85 : 1.0)
                            ..rotateZ(
                              stateProvider.isDrawerOpened ? pi / 50 : 0,
                            ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: context.bgColor.withValues(alpha: .001),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  bool _isActive(int index, int stateIndex) {
    return index == stateIndex;
  }
}
