import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_tuneflow/core/common/app/cache_helper.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/common/providers/downloads_provider.dart';
import 'package:new_tuneflow/core/common/providers/player_provider.dart';
import 'package:new_tuneflow/core/common/providers/playlist_provider.dart';
import 'package:new_tuneflow/core/common/singletones/user.dart';
import 'package:new_tuneflow/core/common/widget/buttons.dart';
import 'package:new_tuneflow/core/common/widget/loading.dart';
import 'package:new_tuneflow/core/common/widget/mini_player.dart';
import 'package:new_tuneflow/core/common/widget/more_vert_song_button.dart';
import 'package:new_tuneflow/core/config/list_config.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/res/media.dart';
import 'package:new_tuneflow/core/snackbar/snackbar.dart';
import 'package:new_tuneflow/core/utils/core_utils.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/src/playlist/data/models/playlist_model.dart';
import 'package:new_tuneflow/src/playlist/domain/entites/playlist_entity.dart';
import 'package:new_tuneflow/src/playlist/presentation/bloc/playlist_bloc.dart';
import 'package:new_tuneflow/src/profile/presentation/screens/premium.dart';
import 'package:page_transition/page_transition.dart';
import 'package:parallax_animation/parallax_area.dart';
import 'package:parallax_animation/parallax_widget.dart';
import 'package:provider/provider.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  ScrollController controller = ScrollController();
  bool isOnContext = true;
  bool isGotData = false;

  @override
  void initState() {
    super.initState();
    controller.addListener(listenScroll);
  }

  listenScroll() {
    if (controller.offset >= 1) {
      setState(() => isOnContext = false);
    } else {
      setState(() => isOnContext = true);
    }
  }

  late PlaylistState storeState;

  @override
  void dispose() {
    super.dispose();
    controller.removeListener(listenScroll);
    controller.dispose();
  }

  bool isInit = true;
  bool isFiltered = false;
  List<SongModel> songs = [];
  List<SongModel> filtered = [];
  TextEditingController searchController = TextEditingController();
  String sort = '';

  sortItems(bool ascending) {
    filtered = List.from(songs);
    filtered.sort(
      (a, b) =>
          ascending ? a.title.compareTo(b.title) : b.title.compareTo(a.title),
    );
  }

  late PlaylistProvider playlistProvider;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlayerProvider>(context);
    playlistProvider = Provider.of<PlaylistProvider>(context);
    final downloadsProvider = Provider.of<DownloadsProvider>(context);

    return Scaffold(
      body: BlocBuilder<PlaylistBloc, PlaylistState>(
        builder: (context, state) {
          storeState = state;
          if (state is PlaylistLoading) {
            return Stack(
              children: [const LoadingWidget(), _buildAppBar(false)],
            );
          }

          if (state is PlaylistError) {
            return Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        state.error!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                _buildAppBar(false),
              ],
            );
          }

          if (state is PlaylistLoaded) {
            isGotData = true;
            if (isInit) {
              songs = state.playlist!.songs;
              isInit = false;
            }
            return Stack(
              children: [
                Container(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      Expanded(
                        child: MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          removeBottom: true,
                          child: ScrollConfiguration(
                            behavior: MyBehavior(),
                            child: ParallaxArea(
                              child: ListView(
                                controller: controller,
                                children: [
                                  if (state.playlist!.type != 'favorite' &&
                                      state.playlist!.type != 'recent')
                                    if (state.playlist!.type == 'local' ||
                                        state.playlist!.type == 'localSecond')
                                      _buildImage(
                                        state.playlist!.image,
                                        _buildPlaylistInfoWidget(
                                          state,
                                          provider,
                                          downloadsProvider,
                                        ),
                                      )
                                    else
                                      _buildParallaxImage(
                                        state.playlist!.image,
                                        _buildPlaylistInfoWidget(
                                          state,
                                          provider,
                                          downloadsProvider,
                                        ),
                                      ),
                                  if (state.playlist!.type == 'favorite' ||
                                      state.playlist!.type == 'recent')
                                    Container(
                                      height: 400,
                                      decoration: BoxDecoration(
                                        color:
                                            state.playlist!.type == 'favorite'
                                                ? context.scheme.onPrimary
                                                : context
                                                    .scheme
                                                    .secondaryContainer,
                                      ),
                                      child: _favoritePlaylistInfoWidget(
                                        state,
                                        provider,
                                        state.playlist!.type == 'favorite',
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: TextField(
                                      controller: searchController,
                                      onChanged: (value) {
                                        if (value.isNotEmpty) {
                                          isFiltered = true;
                                          filtered =
                                              songs
                                                  .where(
                                                    (model) => model.title
                                                        .toLowerCase()
                                                        .contains(
                                                          value.toLowerCase(),
                                                        ),
                                                  )
                                                  .toList();
                                        } else {
                                          isFiltered = false;
                                        }
                                        setState(() {});
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Search...',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        suffixIcon: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (searchController
                                                    .text
                                                    .isNotEmpty ||
                                                sort.isNotEmpty)
                                              IconButton(
                                                onPressed: () {
                                                  searchController.clear();
                                                  sort = '';
                                                  isFiltered = false;
                                                  setState(() {});
                                                },
                                                icon: Icon(Icons.close),
                                              ),
                                            IconButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: Center(
                                                        child: Text(
                                                          'Sort Tracks',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          ListTile(
                                                            title: Text(
                                                              'Sort by A-Z',
                                                            ),
                                                            subtitle: Text(
                                                              'Arrange items in alphabetical order (A to Z)',
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                              ),
                                                            ),
                                                            onTap: () {
                                                              sort = 'A-Z';
                                                              isFiltered = true;
                                                              sortItems(true);
                                                              setState(() {});
                                                              Navigator.pop(
                                                                context,
                                                              );
                                                            },
                                                          ),
                                                          ListTile(
                                                            title: Text(
                                                              'Sort by Z-A',
                                                            ),
                                                            subtitle: Text(
                                                              'Arrange items in reverse alphabetical order (Z to A)',
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                              ),
                                                            ),
                                                            onTap: () {
                                                              sort = 'Z-A';
                                                              isFiltered = true;
                                                              sortItems(false);
                                                              setState(() {});
                                                              Navigator.pop(
                                                                context,
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              icon: Icon(Icons.sort),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  ListView.builder(
                                    itemCount:
                                        isFiltered
                                            ? filtered.length
                                            : songs.length,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      SongModel model =
                                          isFiltered
                                              ? filtered[index]
                                              : songs[index];
                                      return _buildSongCardWidget(
                                        context,
                                        index,
                                        model,
                                        provider,
                                        state.playlist!.id,
                                        isFiltered ? filtered : songs,
                                      );
                                    },
                                  ),
                                  if (state.playlist!.songs.isEmpty)
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        child: Text(
                                          '${state.playlist!.title} Playlist is empty',
                                          style: TextStyle(
                                            color: context.scheme.error,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (playlistProvider
                                      .recommendedPlaylists
                                      .isNotEmpty)
                                    _buildRecommendedPlaylists(),
                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).padding.bottom,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildAppBar(
                  state.playlist!.type != 'local' &&
                      state.playlist!.type != 'localSecond' &&
                      state.playlist!.type != 'favorite' &&
                      state.playlist!.type != 'recent' &&
                      state.playlist!.type != 'downloaded',
                  playlistProvider,
                  state.playlist!,
                ),
              ],
            );
          }

          return Stack(children: [const LoadingWidget(), _buildAppBar(false)]);
        },
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }

  _buildSongCardWidget(
    BuildContext context,
    int index,
    SongModel model,
    PlayerProvider provider,
    String playlistId,
    List<SongModel> songs,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              (storeState.playlist!.type == 'downloaded'
                      ? isActive(
                        provider,
                        'downloadedPlaylist',
                        model.id,
                        playlistId,
                      )
                      : isActive(provider, 'playlist', model.id, playlistId))
                  ? [
                    Colors.transparent,
                    context.scheme.primary.withValues(alpha: 0.1),
                    context.scheme.primary.withValues(alpha: 0.3),
                    context.scheme.primary.withValues(alpha: 0.3),
                    context.scheme.primary.withValues(alpha: 0.1),
                    Colors.transparent,
                  ]
                  : [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.transparent,
                  ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (storeState.playlist!.type == 'downloaded') {
              if (roomProvider.isInRoom) {
                errorMessage(
                  context,
                  'Offline songs can\'t be played in rooms.',
                );
                return;
              }
            }

            if ((storeState.playlist!.type == 'downloaded'
                ? isActive(provider, 'downloadedPlaylist', model.id, playlistId)
                : isActive(provider, 'playlist', model.id, playlistId))) {
              !provider.isPlaying ? provider.togglePlayer() : null;
              return;
            }
            provider.startPlaying(
              source: songs,
              i: index,
              type:
                  storeState.playlist!.type == 'downloaded'
                      ? PlayingType.downloadedPlaylist
                      : PlayingType.playlist,
              id: playlistId,
            );
          },
          child: Container(
            padding: const EdgeInsets.only(
              left: 20,
              right: 10,
              top: 10,
              bottom: 10,
            ),
            child: Row(
              children: [
                CachedNetworkImage(
                  imageUrl: model.imagesUrl.good,
                  placeholder: (context, url) {
                    return Container(
                      height: 55,
                      width: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: const DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage(Media.logo),
                        ),
                      ),
                    );
                  },
                  imageBuilder: (context, imageProvider) {
                    return Container(
                      height: 55,
                      width: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: imageProvider,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              (storeState.playlist!.type == 'downloaded'
                                      ? isActive(
                                        provider,
                                        'downloadedPlaylist',
                                        model.id,
                                        playlistId,
                                      )
                                      : isActive(
                                        provider,
                                        'playlist',
                                        model.id,
                                        playlistId,
                                      ))
                                  ? context.scheme.primary
                                  : context.scheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        model.subtitle,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              (storeState.playlist!.type == 'downloaded'
                                      ? isActive(
                                        provider,
                                        'downloadedPlaylist',
                                        model.id,
                                        playlistId,
                                      )
                                      : isActive(
                                        provider,
                                        'playlist',
                                        model.id,
                                        playlistId,
                                      ))
                                  ? context.scheme.primary
                                  : context.scheme.onSurface,
                          fontSize: 8,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                MoreVertSong(model: model),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildAppBar(
    bool showBookmarBtn, [
    PlaylistProvider? provider,
    PlaylistEntity? playlist,
  ]) {
    return Container(
      padding: EdgeInsets.zero,
      child: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        height: MediaQuery.of(context).padding.top + 50,
        color:
            !isOnContext
                ? context.bgColor
                : context.scheme.surface.withValues(alpha: .3),
        alignment: Alignment.topCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CircleBackButton(),
            if (showBookmarBtn)
              CircleBookmark(
                isActive: provider!.isSavedPlaylist(playlist!.id),
                onTap: () async {
                  UserPlaylistModel model = UserPlaylistModel(
                    id: 0,
                    userId: await CacheHelper().getUserId(),
                    name: playlist.title,
                    songs: const [],
                    playlistId: playlist.id,
                    image: playlist.image,
                    isMine: false,
                    type: 'playlist',
                    isPublic: false,
                  );
                  if (provider.isSavedPlaylist(playlist.id)) {
                    provider.removeFromPlaylist(model);
                    Fluttertoast.showToast(msg: 'Removed from Bookmark');
                  } else {
                    provider.addToPlaylist(model);
                    Fluttertoast.showToast(msg: 'Saved to Bookmark');
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  _buildPlaylistInfoWidget(
    PlaylistLoaded state,
    PlayerProvider provider, [
    DownloadsProvider? downloadsProvider,
  ]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.transparent,
            Colors.transparent,
            Colors.transparent,
            context.scheme.surface.withValues(alpha: .1),
            context.scheme.surface.withValues(alpha: .3),
            context.scheme.surface.withValues(alpha: .5),
            context.scheme.surface.withValues(alpha: .7),
            context.scheme.surface.withValues(alpha: .8),
            context.scheme.surface,
            context.scheme.surface,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(),
              Text(
                state.playlist!.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                state.playlist!.subtitle,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  color: context.scheme.outline,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const Gap(10),
          Row(
            children: [
              if (!(state.playlist!.type == 'favorite' ||
                  state.playlist!.type == 'recent' ||
                  state.playlist!.type == 'downloaded'))
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (!(User.instance.user?.isPremium ?? false)) {
                        errorMessage(
                          context,
                          'Unlock offline access & enjoy your music anywhere. Upgrade now!',
                          title: 'Go Premium to Download Playlist!',
                        );
                        Navigator.push(
                          context,
                          PageTransition(
                            child: const PremiumScreen(),
                            type: PageTransitionType.fade,
                          ),
                        );
                        return;
                      }
                      if (downloadsProvider.isDownloadedPlaylist(
                        state.playlist!,
                      )) {
                        return;
                      }
                      if (downloadsProvider.isDownloadingPlaylist(
                        state.playlist!.id,
                      )) {
                        return;
                      }
                      downloadsProvider.downloadPlaylist(state.playlist!);
                    },
                    child: Container(
                      height: 55,
                      decoration: BoxDecoration(
                        color: context.scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.download_outlined,
                            size: 17,
                            color: context.scheme.onPrimaryContainer,
                          ),
                          const Gap(5),
                          Text(
                            downloadsProvider!.isDownloadingPlaylist(
                                  state.playlist!.id,
                                )
                                ? 'Downloading....'
                                : downloadsProvider.isDownloadedPlaylist(
                                  state.playlist!,
                                )
                                ? 'Downloaded'
                                : 'Download',
                            style: TextStyle(
                              color: context.scheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (!(state.playlist!.type == 'favorite' ||
                  state.playlist!.type == 'recent' ||
                  state.playlist!.type == 'downloaded'))
                const Gap(10),
              GestureDetector(
                onTap: () {
                  if (state.playlist!.type == 'downloaded') {
                    if (roomProvider.isInRoom) {
                      errorMessage(
                        context,
                        'Offline songs can\'t be played in rooms.',
                      );
                      return;
                    }
                  }
                  List<SongModel> shuffled = List.from(state.playlist!.songs);
                  shuffled.shuffle();
                  provider.startPlaying(
                    source: shuffled,
                    i: 0,
                    type:
                        state.playlist!.type == 'downloaded'
                            ? PlayingType.downloadedPlaylist
                            : PlayingType.playlist,
                    id: state.playlist!.id,
                  );
                },
                child: Container(
                  height: 55,
                  width: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: context.scheme.primary.withValues(alpha: .5),
                  ),
                  alignment: Alignment.center,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Icon(Icons.shuffle_outlined)],
                  ),
                ),
              ),
              const Gap(10),
              GestureDetector(
                onTap: () {
                  if (state.playlist!.type == 'downloaded') {
                    if (roomProvider.isInRoom) {
                      errorMessage(
                        context,
                        'Offline songs can\'t be played in rooms.',
                      );
                      return;
                    }
                  }
                  if ((state.playlist!.type == 'downloaded'
                      ? isActive(
                        provider,
                        'downloadedPlaylist',
                        null,
                        state.playlist!.id,
                      )
                      : isActive(
                        provider,
                        'playlist',
                        null,
                        state.playlist!.id,
                      ))) {
                    provider.togglePlayer();
                  } else {
                    provider.startPlaying(
                      source: state.playlist!.songs,
                      i: 0,
                      type:
                          state.playlist!.type == 'downloaded'
                              ? PlayingType.downloadedPlaylist
                              : PlayingType.playlist,
                      id: state.playlist!.id,
                    );
                  }
                },
                child: Container(
                  height: 55,
                  width: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: context.scheme.primary,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 100,
                        color: context.scheme.onSurface,
                      ),
                    ],
                  ),
                  child: Icon(
                    (state.playlist!.type == 'downloaded'
                                ? isActive(
                                  provider,
                                  'downloadedPlaylist',
                                  null,
                                  state.playlist!.id,
                                )
                                : isActive(
                                  provider,
                                  'playlist',
                                  null,
                                  state.playlist!.id,
                                )) &&
                            provider.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: context.scheme.onPrimary,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _favoritePlaylistInfoWidget(
    PlaylistLoaded state,
    PlayerProvider provider,
    bool isFavList,
  ) {
    return Column(
      children: [
        const SizedBox(height: 75),
        const Spacer(),
        Icon(
          isFavList ? Icons.favorite : Icons.history,
          color:
              isFavList
                  ? context.scheme.primary
                  : context.scheme.onSecondaryContainer,
          size: 100,
        ),
        const Spacer(),
        _buildPlaylistInfoWidget(state, provider),
      ],
    );
  }

  Widget _buildParallaxImage(String imageUrl, Widget child) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder:
          (context, imageProvider) => ClipRRect(
            child: ParallaxWidget(
              overflowWidthFactor: 1,
              background: Container(
                height: 400,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              child: SizedBox(height: 400, child: child),
            ),
          ),
      placeholder:
          (context, url) => Container(
            height: 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: const DecorationImage(image: AssetImage(Media.logo)),
            ),
          ),
    );
  }

  Widget _buildImage(String imageUrl, Widget child) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder:
          (context, imageProvider) => Container(
            height: 400,
            decoration: BoxDecoration(
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
            child: child,
          ),
      placeholder:
          (context, url) => Container(
            height: 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: const DecorationImage(image: AssetImage(Media.logo)),
            ),
            child: child,
          ),
    );
  }

  Widget _buildRecommendedPlaylists() {
    return Column(
      children: [
        SizedBox(height: 20),
        Row(
          children: [
            SizedBox(width: 20),
            Text(
              'Flowing Beats',
              style: GoogleFonts.dekko(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: context.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        SizedBox(
          height: 150,
          child: ParallaxArea(
            child: ListView.separated(
              itemCount: playlistProvider.recommendedPlaylists.length,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                PlaylistModel model =
                    playlistProvider.recommendedPlaylists[index];
                return _buildRecommendedItem(model);
              },
              separatorBuilder: (context, index) => const SizedBox(width: 15),
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRecommendedItem(PlaylistModel model) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        Widget widget = const SizedBox();
        context.read<PlaylistBloc>().add(
          PlaylistFetch(id: model.id, type: 'remote'),
        );
        widget = const PlaylistScreen();
        Navigator.pushReplacement(
          context,
          PageTransition(child: widget, type: PageTransitionType.fade),
        );
      },
      child: SizedBox(
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ParallaxWidget(
                background: CachedNetworkImage(
                  imageUrl: model.image,
                  placeholder:
                      (context, url) => Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: const DecorationImage(
                            image: AssetImage(Media.logo),
                          ),
                        ),
                      ),
                ),
                child: const SizedBox(height: 150, width: 150),
              ),
            ),
            Positioned(
              left: 5,
              right: 5,
              bottom: 5,
              child: Container(
                padding: EdgeInsets.zero,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.scheme.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildText(
                        model.title,
                        maxLines: 3,
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildText(
    String text, {
    bool isHighlighted = false,
    int maxLines = 1,
    double? fontSize,
    TextAlign textAlign = TextAlign.left,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: isHighlighted ? context.primary : context.scheme.onSurface,
        fontSize: fontSize,
      ),
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
    );
  }
}
