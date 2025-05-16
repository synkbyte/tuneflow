import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
import 'package:new_tuneflow/src/album/data/models/album_model.dart';
import 'package:new_tuneflow/src/album/presentation/provider/album_provider.dart';
import 'package:new_tuneflow/src/artist_details/presentation/bloc/artist_details_bloc.dart';
import 'package:new_tuneflow/src/artist_details/presentation/screens/artist_details.dart';
import 'package:new_tuneflow/src/profile/presentation/screens/premium.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key, this.isLocal = false});
  final bool isLocal;

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlayerProvider>(context);
    final playlistProvider = Provider.of<PlaylistProvider>(context);
    final downloadsProvider = Provider.of<DownloadsProvider>(context);

    return Scaffold(
      body: Consumer<AlbumProvider>(
        builder: (context, value, child) {
          if (value.isLoading) {
            return Stack(
              children: [const LoadingWidget(), _buildAppBar(false)],
            );
          }

          if (value.error.isNotEmpty) {
            return Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        value.error,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                _buildAppBar(false),
              ],
            );
          }

          isGotData = true;
          if (isInit) {
            songs = value.album.songs;
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
                          child: ListView(
                            controller: controller,
                            children: [
                              CachedNetworkImage(
                                imageUrl: value.album.image.excellent,
                                placeholder: (context, url) {
                                  return Container(
                                    height: 400,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: AssetImage(Media.logo),
                                      ),
                                    ),
                                    child: _buildPlaylistInfoWidget(
                                      value.album,
                                      provider,
                                      downloadsProvider,
                                    ),
                                  );
                                },
                                imageBuilder: (context, imageProvider) {
                                  return Container(
                                    height: 400,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: imageProvider,
                                      ),
                                    ),
                                    child: _buildPlaylistInfoWidget(
                                      value.album,
                                      provider,
                                      downloadsProvider,
                                    ),
                                  );
                                },
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
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    suffixIcon: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (searchController.text.isNotEmpty ||
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
                                    isFiltered ? filtered.length : songs.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
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
                                    isFiltered ? filtered : songs,
                                    value.album.id,
                                  );
                                },
                              ),
                              if (value.recommendedAlbums.isNotEmpty)
                                _buildRecommendedAlbums(
                                  value.recommendedAlbums,
                                ),
                              if (value.artists.isNotEmpty)
                                _buildArtists(value.artists),
                              SizedBox(
                                height: MediaQuery.of(context).padding.bottom,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _buildAppBar(!widget.isLocal, playlistProvider, value.album),
            ],
          );
        },
      ),
      bottomNavigationBar: const MiniPlayer(),
      // floatingActionButton: isGotData
      //     ? Column(
      //         mainAxisSize: MainAxisSize.min,
      //         children: [
      //           if (isGotData && !isOnContext)
      //             BlurryContainer(
      //               blur: 100,
      //               padding: EdgeInsets.zero,
      //               child: FloatingActionButton(
      //                 heroTag: 'tag1',
      //                 backgroundColor: context.primary.withValues(alpha: .1),
      //                 onPressed: () {
      //                   if (widget.isLocal) {
      //                     if (roomProvider.isInRoom) {
      //                       errorMessage(
      //                         context,
      //                         'Offline songs can\'t be played in rooms.',
      //                       );
      //                       return;
      //                     }
      //                   }

      //                   List<SongModel> shuffled =
      //                       List.from(storeState.album!.songs);
      //                   shuffled.shuffle();
      //                   provider.startPlaying(
      //                     source: shuffled,
      //                     i: 0,
      //                     type: widget.isLocal
      //                         ? PlayingType.downloadedAlbum
      //                         : PlayingType.album,
      //                     id: storeState.album!.id,
      //                   );
      //                 },
      //                 child: const Icon(Icons.shuffle),
      //               ),
      //             ),
      //           const Gap(10),
      //           if (isGotData && !isOnContext)
      //             BlurryContainer(
      //               blur: 100,
      //               padding: EdgeInsets.zero,
      //               child: FloatingActionButton(
      //                 heroTag: 'tag2',
      //                 backgroundColor: context.primary.withValues(alpha: .1),
      //                 onPressed: () {
      //                   if (widget.isLocal) {
      //                     if (roomProvider.isInRoom) {
      //                       errorMessage(
      //                         context,
      //                         'Offline songs can\'t be played in rooms.',
      //                       );
      //                       return;
      //                     }
      //                   }

      //                   if ((widget.isLocal
      //                       ? isActive(provider, 'downloadedAlbum', null,
      //                           storeState.album!.id)
      //                       : isActive(provider, 'album', null,
      //                           storeState.album!.id))) {
      //                     provider.togglePlayer();
      //                   } else {
      //                     provider.startPlaying(
      //                       source: storeState.album!.songs,
      //                       i: 0,
      //                       type: widget.isLocal
      //                           ? PlayingType.downloadedAlbum
      //                           : PlayingType.album,
      //                       id: storeState.album!.id,
      //                     );
      //                   }
      //                 },
      //                 child: Icon(
      //                   (widget.isLocal
      //                               ? isActive(provider, 'downloadedAlbum',
      //                                   null, storeState.album!.id)
      //                               : isActive(provider, 'album', null,
      //                                   storeState.album!.id)) &&
      //                           provider.isPlaying
      //                       ? Icons.pause
      //                       : Icons.play_arrow,
      //                 ),
      //               ),
      //             ),
      //         ],
      //       )
      //     : null,
    );
  }

  _buildSongCardWidget(
    BuildContext context,
    int index,
    SongModel model,
    PlayerProvider provider,
    List<SongModel> songs,
    String albumId,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              (widget.isLocal
                      ? isActive(provider, 'downloadedAlbum', model.id, albumId)
                      : isActive(provider, 'album', model.id, albumId))
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
            if (widget.isLocal) {
              if (roomProvider.isInRoom) {
                errorMessage(
                  context,
                  'Offline songs can\'t be played in rooms.',
                );
                return;
              }
            }

            if ((widget.isLocal
                ? isActive(provider, 'downloadedAlbum', model.id, albumId)
                : isActive(provider, 'album', model.id, albumId))) {
              !provider.isPlaying ? provider.togglePlayer() : null;
              return;
            }
            provider.startPlaying(
              source: songs,
              i: index,
              type:
                  widget.isLocal
                      ? PlayingType.downloadedAlbum
                      : PlayingType.album,
              id: albumId,
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
                              (widget.isLocal
                                      ? isActive(
                                        provider,
                                        'downloadedAlbum',
                                        model.id,
                                        albumId,
                                      )
                                      : isActive(
                                        provider,
                                        'album',
                                        model.id,
                                        albumId,
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
                              (widget.isLocal
                                      ? isActive(
                                        provider,
                                        'downloadedAlbum',
                                        model.id,
                                        albumId,
                                      )
                                      : isActive(
                                        provider,
                                        'album',
                                        model.id,
                                        albumId,
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
    AlbumModel? album,
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
                isActive: provider!.isSavedPlaylist(album!.id),
                onTap: () async {
                  UserPlaylistModel model = UserPlaylistModel(
                    id: 0,
                    userId: await CacheHelper().getUserId(),
                    name: album.title,
                    songs: const [],
                    playlistId: album.id,
                    image: album.image.excellent,
                    isMine: false,
                    type: 'album',
                    isPublic: false,
                  );
                  if (provider.isSavedPlaylist(album.id)) {
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
    AlbumModel state,
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
                state.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                state.subtitle,
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
              if (!widget.isLocal)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (!(User.instance.user?.isPremium ?? false)) {
                        errorMessage(
                          context,
                          'Unlock offline access & enjoy your music anywhere. Upgrade now!',
                          title: 'Go Premium to Download Albums!',
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
                      if (downloadsProvider.isDownloadedAlbum(state)) {
                        return;
                      }
                      if (downloadsProvider.isDownloadingAlbum(state.id)) {
                        return;
                      }
                      downloadsProvider.downloadAlbum(state);
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
                            downloadsProvider!.isDownloadingAlbum(state.id)
                                ? 'Downloading....'
                                : downloadsProvider.isDownloadedAlbum(state)
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
              if (!widget.isLocal) const Gap(10),
              GestureDetector(
                onTap: () {
                  if (widget.isLocal) {
                    if (roomProvider.isInRoom) {
                      errorMessage(
                        context,
                        'Offline songs can\'t be played in rooms.',
                      );
                      return;
                    }
                  }

                  List<SongModel> shuffled = List.from(state.songs);
                  shuffled.shuffle();

                  provider.startPlaying(
                    source: shuffled,
                    i: 0,
                    type:
                        widget.isLocal
                            ? PlayingType.downloadedAlbum
                            : PlayingType.album,
                    id: state.id,
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
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  if (widget.isLocal) {
                    if (roomProvider.isInRoom) {
                      errorMessage(
                        context,
                        'Offline songs can\'t be played in rooms.',
                      );
                      return;
                    }
                  }

                  if ((widget.isLocal
                      ? isActive(provider, 'downloadedAlbum', null, state.id)
                      : isActive(provider, 'album', null, state.id))) {
                    provider.togglePlayer();
                  } else {
                    provider.startPlaying(
                      source: state.songs,
                      i: 0,
                      type:
                          widget.isLocal
                              ? PlayingType.downloadedAlbum
                              : PlayingType.album,
                      id: state.id,
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
                    (widget.isLocal
                                ? isActive(
                                  provider,
                                  'downloadedAlbum',
                                  null,
                                  state.id,
                                )
                                : isActive(
                                  provider,
                                  'album',
                                  null,
                                  state.id,
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

  _buildRecommendedAlbums(List<AlbumModel> recommendedAlbums) {
    return Column(
      children: [
        SizedBox(height: 20),
        Row(
          children: [
            SizedBox(width: 20),
            Text(
              'You May Like',
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
          child: ListView.separated(
            itemCount: recommendedAlbums.length,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              AlbumModel model = recommendedAlbums[index];
              return _buildRecommendedItem(model);
            },
            separatorBuilder: (context, index) => const SizedBox(width: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedItem(AlbumModel model) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        Widget widget = const SizedBox();
        context.read<AlbumProvider>().setAlbum(model.id);
        widget = const AlbumScreen();
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
              child: CachedNetworkImage(
                imageUrl: model.image.excellent,
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
                        textAlign: TextAlign.start,
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

  _buildArtists(List<ArtistModel> artists) {
    return Column(
      children: [
        SizedBox(height: 20),
        Row(
          children: [
            SizedBox(width: 20),
            Text(
              'Artists',
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
          height: 130,
          child: ListView.separated(
            itemCount: artists.length,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              ArtistModel model = artists[index];
              return GestureDetector(
                onTap: () {
                  context.read<ArtistDetailsBloc>().add(
                    ArtistDetailsFetch(id: model.id),
                  );
                  Navigator.push(
                    context,
                    PageTransition(
                      child: const ArtistDetailsScreen(),
                      type: PageTransitionType.fade,
                    ),
                  );
                },
                child: SizedBox(
                  width: 80,
                  height: 130,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CachedNetworkImage(
                        imageUrl: model.image.good,
                        imageBuilder: (context, imageProvider) {
                          return Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 10,
                                  color: context.scheme.shadow,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: CachedNetworkImageProvider(
                                  model.image.good,
                                ),
                              ),
                            ),
                          );
                        },
                        placeholder: (context, url) {
                          return Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 10,
                                  color: context.scheme.shadow,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                              image: const DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage(Media.logo),
                              ),
                            ),
                          );
                        },
                      ),
                      const Gap(7),
                      Text(
                        model.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return const Gap(15);
            },
          ),
        ),
      ],
    );
  }
}
