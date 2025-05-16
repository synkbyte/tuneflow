import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/common/providers/player_provider.dart';
import 'package:new_tuneflow/core/common/widget/buttons.dart';
import 'package:new_tuneflow/core/common/widget/loading.dart';
import 'package:new_tuneflow/core/common/widget/mini_player.dart';
import 'package:new_tuneflow/core/common/widget/more_vert_song_button.dart';
import 'package:new_tuneflow/core/config/list_config.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/res/media.dart';
import 'package:new_tuneflow/core/utils/core_utils.dart';
import 'package:new_tuneflow/src/song/presentation/bloc/song_details_bloc.dart';
import 'package:provider/provider.dart';

class SongDetailsScreen extends StatefulWidget {
  const SongDetailsScreen({super.key, this.showFirstSong = false});
  final bool showFirstSong;

  @override
  State<SongDetailsScreen> createState() => _SongDetailsScreenState();
}

class _SongDetailsScreenState extends State<SongDetailsScreen> {
  late String dynamicId;
  ScrollController controller = ScrollController();
  bool isOnContext = true;
  bool isGotData = false;

  @override
  void initState() {
    super.initState();
    dynamicId = generateRandomId();
    controller.addListener(listenScroll);
  }

  listenScroll() {
    if (controller.offset >= 1) {
      setState(() => isOnContext = false);
    } else {
      setState(() => isOnContext = true);
    }
  }

  late SongDetailsState storeState;

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
    return Scaffold(
      body: BlocBuilder<SongDetailsBloc, SongDetailsState>(
        builder: (context, state) {
          storeState = state;
          if (state is SongDetailsLoading) {
            return Stack(
              children: [const LoadingWidget(), _buildAppBar(false)],
            );
          }

          if (state is SongDetailsError) {
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

          if (state is SongDetailsLoaded) {
            isGotData = true;
            if (isInit) {
              songs = state.songDetails!.songs;
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
                                  imageUrl:
                                      state
                                          .songDetails!
                                          .songs
                                          .first
                                          .imagesUrl
                                          .excellent,
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
                                        state,
                                        provider,
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
                                        state,
                                        provider,
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
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    if (index == 0 &&
                                        !widget.showFirstSong &&
                                        !isFiltered) {
                                      return const SizedBox();
                                    }
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
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildAppBar(false),
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
    List<SongModel> songs,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isActive(provider, 'song', model.id, dynamicId)
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
            if (isActive(provider, 'song', model.id, dynamicId)) {
              !provider.isPlaying ? provider.togglePlayer() : null;
              return;
            }
            provider.startPlaying(
              source: songs,
              i: index,
              type: PlayingType.song,
              id: dynamicId,
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
                              isActive(provider, 'song', model.id, dynamicId)
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
                              isActive(provider, 'song', model.id, dynamicId)
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

  _buildAppBar(bool showBookmarBtn) {
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
            if (showBookmarBtn) CircleBookmark(isActive: true, onTap: () {}),
          ],
        ),
      ),
    );
  }

  _buildPlaylistInfoWidget(SongDetailsLoaded state, PlayerProvider provider) {
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.songDetails!.songs.first.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Similar like ${state.songDetails!.songs.first.title}',
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
              ),
              GestureDetector(
                onTap: () {
                  List<SongModel> source = List.from(state.songDetails!.songs);
                  if (!widget.showFirstSong) source.removeAt(0);
                  List<SongModel> shuffled = List.from(source);
                  shuffled.shuffle();

                  provider.startPlaying(
                    source: shuffled,
                    i: 0,
                    type: PlayingType.song,
                    id: dynamicId,
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
                  if (isActive(provider, 'song', null, dynamicId)) {
                    provider.togglePlayer();
                  } else {
                    List<SongModel> source = List.from(
                      state.songDetails!.songs,
                    );
                    if (!widget.showFirstSong) source.removeAt(0);
                    provider.startPlaying(
                      source: source,
                      i: 0,
                      type: PlayingType.song,
                      id: dynamicId,
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
                    isActive(provider, 'song', null, dynamicId) &&
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
}
