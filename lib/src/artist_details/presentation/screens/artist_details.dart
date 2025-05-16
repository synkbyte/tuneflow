import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/common/providers/artist_provider.dart';
import 'package:new_tuneflow/core/common/providers/player_provider.dart';
import 'package:new_tuneflow/core/common/widget/buttons.dart';
import 'package:new_tuneflow/core/common/widget/loading.dart';
import 'package:new_tuneflow/core/common/widget/mini_player.dart';
import 'package:new_tuneflow/core/common/widget/more_vert_song_button.dart';
import 'package:new_tuneflow/core/config/list_config.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/res/media.dart';
import 'package:new_tuneflow/core/utils/core_utils.dart';
import 'package:new_tuneflow/src/album/data/models/album_model.dart';
import 'package:new_tuneflow/src/album/presentation/provider/album_provider.dart';
import 'package:new_tuneflow/src/album/presentation/screens/album.dart';
import 'package:new_tuneflow/src/artist_details/presentation/bloc/artist_details_bloc.dart';
import 'package:new_tuneflow/src/artist_details/presentation/providers/artist_provider.dart';
import 'package:new_tuneflow/src/artist_details/presentation/screens/artist_all_songs.dart';
import 'package:new_tuneflow/src/auth/domain/entites/artist_entity.dart';
import 'package:new_tuneflow/src/playlist/data/models/playlist_model.dart';
import 'package:new_tuneflow/src/playlist/presentation/bloc/playlist_bloc.dart';
import 'package:new_tuneflow/src/playlist/presentation/screens/playlist.dart';
import 'package:page_transition/page_transition.dart';
import 'package:parallax_animation/parallax_area.dart';
import 'package:parallax_animation/parallax_widget.dart';
import 'package:provider/provider.dart';

class ArtistDetailsScreen extends StatefulWidget {
  const ArtistDetailsScreen({super.key});

  @override
  State<ArtistDetailsScreen> createState() => _ArtistDetailsScreenState();
}

class _ArtistDetailsScreenState extends State<ArtistDetailsScreen> {
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

  late ArtistDetailsState storeState;

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
    final artistProvider = Provider.of<ArtistProvider>(context);
    return Scaffold(
      body: BlocBuilder<ArtistDetailsBloc, ArtistDetailsState>(
        builder: (context, state) {
          storeState = state;
          if (state is ArtistDetailsLoading) {
            return Stack(
              children: [
                const LoadingWidget(),
                _buildAppBar(false, artistProvider),
              ],
            );
          }

          if (state is ArtistDetailsError) {
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
                _buildAppBar(false, artistProvider),
              ],
            );
          }
          if (state is ArtistDetailsLoaded) {
            isGotData = true;
            if (isInit) {
              songs = state.artistEntity!.songs;
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
                                  imageUrl: state.artistEntity!.image.excellent,
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
                                SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Top ${songs.length} Songs',
                                        style: GoogleFonts.dekko(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: context.primary,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          context
                                              .read<ArtistSongsProvider>()
                                              .artistAllSongs(
                                                artistId:
                                                    state.artistEntity!.id,
                                                page: 0,
                                                artistName:
                                                    state.artistEntity!.name,
                                              );
                                          Navigator.push(
                                            context,
                                            PageTransition(
                                              child: const ArtistAllSongs(),
                                              type: PageTransitionType.fade,
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'See All',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
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
                                    SongModel model =
                                        isFiltered
                                            ? filtered[index]
                                            : songs[index];
                                    return _buildSongCardWidget(
                                      context,
                                      index,
                                      model,
                                      provider,
                                      state.artistEntity!.id,
                                      isFiltered ? filtered : songs,
                                    );
                                  },
                                ),
                                const Divider(),
                                if (state
                                    .artistEntity!
                                    .latestRelease
                                    .isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: Text(
                                      'Newest Release',
                                      style: GoogleFonts.dekko(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: context.primary,
                                      ),
                                    ),
                                  ),
                                if (state
                                    .artistEntity!
                                    .latestRelease
                                    .isNotEmpty)
                                  const Gap(10),
                                if (state
                                    .artistEntity!
                                    .latestRelease
                                    .isNotEmpty)
                                  _buildSongsList(
                                    state.artistEntity!.latestRelease,
                                  ),
                                if (state.artistEntity!.topAlbums.isNotEmpty)
                                  Gap(
                                    state.artistEntity!.latestRelease.isNotEmpty
                                        ? 30
                                        : 0,
                                  ),
                                if (state.artistEntity!.topAlbums.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: Text(
                                      'Top Albums',
                                      style: GoogleFonts.dekko(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: context.primary,
                                      ),
                                    ),
                                  ),
                                if (state.artistEntity!.topAlbums.isNotEmpty)
                                  const Gap(10),
                                if (state.artistEntity!.topAlbums.isNotEmpty)
                                  _buildSongsList(
                                    state.artistEntity!.topAlbums,
                                  ),
                                if (state
                                    .artistEntity!
                                    .dedicatedArtistPlaylist
                                    .isNotEmpty)
                                  Gap(
                                    state
                                                .artistEntity!
                                                .latestRelease
                                                .isNotEmpty ||
                                            state
                                                .artistEntity!
                                                .topAlbums
                                                .isNotEmpty
                                        ? 30
                                        : 0,
                                  ),
                                if (state
                                    .artistEntity!
                                    .dedicatedArtistPlaylist
                                    .isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: Text(
                                      '${state.artistEntity!.name} Vibes',
                                      style: GoogleFonts.dekko(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: context.primary,
                                      ),
                                    ),
                                  ),
                                if (state
                                    .artistEntity!
                                    .dedicatedArtistPlaylist
                                    .isNotEmpty)
                                  const Gap(15),
                                if (state
                                    .artistEntity!
                                    .dedicatedArtistPlaylist
                                    .isNotEmpty)
                                  SizedBox(
                                    height: 150,
                                    child: ParallaxArea(
                                      child: ListView.separated(
                                        itemCount:
                                            state
                                                .artistEntity!
                                                .dedicatedArtistPlaylist
                                                .length +
                                            1,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) {
                                          if (index == 0) {
                                            return const Gap(5);
                                          }
                                          PlaylistModel model =
                                              state
                                                  .artistEntity!
                                                  .dedicatedArtistPlaylist[index -
                                                  1];
                                          return _buildTrendingItem(model);
                                        },
                                        separatorBuilder:
                                            (context, index) =>
                                                const SizedBox(width: 15),
                                      ),
                                    ),
                                  ),
                                if (state
                                    .artistEntity!
                                    .featuredArtistPlaylist
                                    .isNotEmpty)
                                  Gap(
                                    state
                                                .artistEntity!
                                                .latestRelease
                                                .isNotEmpty ||
                                            state
                                                .artistEntity!
                                                .topAlbums
                                                .isNotEmpty ||
                                            state
                                                .artistEntity!
                                                .dedicatedArtistPlaylist
                                                .isNotEmpty
                                        ? 30
                                        : 0,
                                  ),
                                if (state
                                    .artistEntity!
                                    .featuredArtistPlaylist
                                    .isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: Text(
                                      'Artist Spotlight',
                                      style: GoogleFonts.dekko(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: context.primary,
                                      ),
                                    ),
                                  ),
                                if (state
                                    .artistEntity!
                                    .featuredArtistPlaylist
                                    .isNotEmpty)
                                  const Gap(15),
                                if (state
                                    .artistEntity!
                                    .featuredArtistPlaylist
                                    .isNotEmpty)
                                  SizedBox(
                                    height: 150,
                                    child: ParallaxArea(
                                      child: ListView.separated(
                                        itemCount:
                                            state
                                                .artistEntity!
                                                .featuredArtistPlaylist
                                                .length +
                                            1,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) {
                                          if (index == 0) {
                                            return const Gap(5);
                                          }
                                          PlaylistModel model =
                                              state
                                                  .artistEntity!
                                                  .featuredArtistPlaylist[index -
                                                  1];
                                          return _buildTrendingItem(model);
                                        },
                                        separatorBuilder:
                                            (context, index) =>
                                                const SizedBox(width: 15),
                                      ),
                                    ),
                                  ),
                                if (state.artistEntity!.singles.isNotEmpty)
                                  Gap(
                                    state
                                                .artistEntity!
                                                .latestRelease
                                                .isNotEmpty ||
                                            state
                                                .artistEntity!
                                                .topAlbums
                                                .isNotEmpty ||
                                            state
                                                .artistEntity!
                                                .dedicatedArtistPlaylist
                                                .isNotEmpty ||
                                            state
                                                .artistEntity!
                                                .featuredArtistPlaylist
                                                .isNotEmpty
                                        ? 30
                                        : 0,
                                  ),
                                if (state.artistEntity!.singles.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: Text(
                                      'Top Tracks: Singles Edition',
                                      style: GoogleFonts.dekko(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: context.primary,
                                      ),
                                    ),
                                  ),
                                if (state.artistEntity!.singles.isNotEmpty)
                                  const Gap(10),
                                if (state.artistEntity!.singles.isNotEmpty)
                                  _buildSongsList(state.artistEntity!.singles),
                                const Gap(20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildAppBar(true, artistProvider, state.artistEntity),
              ],
            );
          }

          return Stack(
            children: [
              const LoadingWidget(),
              _buildAppBar(false, artistProvider),
            ],
          );
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
    String artistId,
    List<SongModel> songs,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isActive(provider, 'artist', model.id, artistId)
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
            if (isActive(provider, 'artist', model.id, artistId)) {
              !provider.isPlaying ? provider.togglePlayer() : null;
              return;
            }
            provider.startPlaying(
              source: songs,
              i: index,
              type: PlayingType.artist,
              id: artistId,
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
                              isActive(provider, 'artist', model.id, artistId)
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
                              isActive(provider, 'artist', model.id, artistId)
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
    bool showBookmarBtn,
    ArtistProvider artistProvider, [
    ArtistEntity? artist,
  ]) {
    return Container(
      padding: EdgeInsets.zero,
      child: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        height: MediaQuery.of(context).padding.top + 50,
        color:
            !isOnContext
                ? context.bgColor
                : context.bgColor.withValues(alpha: .3),
        alignment: Alignment.topCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CircleBackButton(),
            if (showBookmarBtn)
              CircleBookmark(
                isActive: artistProvider.isSavedArtist(artist!.toModel()),
                onTap: () {
                  artistProvider.toggleArtistBookmark(artist.toModel());
                },
              ),
          ],
        ),
      ),
    );
  }

  _buildPlaylistInfoWidget(ArtistDetailsLoaded state, PlayerProvider provider) {
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
                      state.artistEntity!.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Top ${state.artistEntity!.songs.length} Songs',
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
                  List<SongModel> source = List.from(state.artistEntity!.songs);
                  source.removeAt(0);
                  List<SongModel> shuffled = List.from(source);
                  shuffled.shuffle();
                  provider.startPlaying(
                    source: shuffled,
                    i: 0,
                    type: PlayingType.artist,
                    id: state.artistEntity!.id,
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
                  if (isActive(
                    provider,
                    'artist',
                    null,
                    state.artistEntity!.id,
                  )) {
                    provider.togglePlayer();
                  } else {
                    provider.startPlaying(
                      source: state.artistEntity!.songs,
                      i: 0,
                      type: PlayingType.artist,
                      id: state.artistEntity!.id,
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
                    isActive(
                              provider,
                              'artist',
                              null,
                              state.artistEntity!.id,
                            ) &&
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

  Widget _buildSongsList(List<AlbumModel> model) {
    return SizedBox(
      height: 170,
      child: ListView.separated(
        itemCount: model.length + 1,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Gap(5);
          }
          AlbumModel album = model[index - 1];
          return _buildSongCard(album, context);
        },
        separatorBuilder: (context, index) => const Gap(15),
      ),
    );
  }

  Widget _buildSongCard(AlbumModel model, BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        context.read<AlbumProvider>().setAlbum(model.id);
        Navigator.push(
          context,
          PageTransition(
            child: const AlbumScreen(),
            type: PageTransitionType.fade,
          ),
        );
      },
      child: SizedBox(
        height: 170,
        width: 130,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildSongImage(model.image.excellent)),
            const Gap(5),
            _buildSongText(model.subtitle, model.id, context),
            _buildSongText(model.title, model.id, context, isTitle: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSongImage(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(fit: BoxFit.cover, image: imageProvider),
          ),
        );
      },
      placeholder: (context, url) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: const DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(Media.logo),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSongText(
    String text,
    String songId,
    BuildContext context, {
    bool isTitle = false,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontSize: isTitle ? null : 8,
        fontWeight: isTitle ? FontWeight.bold : null,
        color: null,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTrendingItem(PlaylistModel model) {
    return GestureDetector(
      onTap: () {
        context.read<PlaylistBloc>().add(
          PlaylistFetch(id: model.id, type: 'remote'),
        );
        Navigator.push(
          context,
          PageTransition(
            child: const PlaylistScreen(),
            type: PageTransitionType.fade,
          ),
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
                    // color: context.scheme.primary.withValues(alpha: .1),
                    // borderRadius:
                    //     const BorderRadius.vertical(top: Radius.circular(10)),
                    color: context.scheme.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: context.scheme.onSurface,
                        ),
                        maxLines: 3,
                        // textAlign: textAlign,
                        overflow: TextOverflow.ellipsis,
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
}
