import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/common/providers/banner_provider.dart';
import 'package:new_tuneflow/core/common/providers/player_provider.dart';
import 'package:new_tuneflow/core/common/widget/loading.dart';
import 'package:new_tuneflow/core/common/widget/premium_cards.dart';
import 'package:new_tuneflow/core/common/widget/room_cards.dart';
import 'package:new_tuneflow/core/common/widget/welcome_app_bar.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/res/media.dart';
import 'package:new_tuneflow/core/utils/core_utils.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/src/album/data/models/album_model.dart';
import 'package:new_tuneflow/src/album/presentation/provider/album_provider.dart';
import 'package:new_tuneflow/src/album/presentation/screens/album.dart';
import 'package:new_tuneflow/src/artist_details/presentation/bloc/artist_details_bloc.dart';
import 'package:new_tuneflow/src/artist_details/presentation/screens/artist_details.dart';
import 'package:new_tuneflow/src/explore/domain/entites/discover_entiry.dart';
import 'package:new_tuneflow/src/explore/presentation/bloc/discover_bloc.dart';
import 'package:new_tuneflow/src/explore/presentation/providers/explore_provider.dart';
import 'package:new_tuneflow/src/playlist/data/models/playlist_model.dart';
import 'package:new_tuneflow/src/playlist/presentation/bloc/playlist_bloc.dart';
import 'package:new_tuneflow/src/playlist/presentation/screens/playlist.dart';
import 'package:new_tuneflow/src/song/presentation/bloc/song_details_bloc.dart';
import 'package:new_tuneflow/src/song/presentation/screens/songs.dart';
import 'package:page_transition/page_transition.dart';
import 'package:parallax_animation/parallax_area.dart';
import 'package:parallax_animation/parallax_widget.dart';
import 'package:provider/provider.dart';
import 'package:smooth_list_view/smooth_list_view.dart';
import 'package:url_launcher/url_launcher.dart';

class ExploreNew extends StatefulWidget {
  const ExploreNew({super.key});

  @override
  State<ExploreNew> createState() => _ExploreNewState();
}

class _ExploreNewState extends State<ExploreNew> {
  ScrollController discoverController = ScrollController();
  ScrollController cityModeController = ScrollController();

  int selectedPlaylistIndex = 0;

  late ExploreProvider exploreProvider;

  PageController advPageController = PageController();
  int currentBannerIndex = 0;
  Timer? _timer;

  void startAutoScroll(int total) {
    if (_timer != null) return;
    _timer = Timer.periodic(Duration(seconds: 10), (Timer timer) {
      if (!mounted) return;
      if (advPageController.positions.isEmpty) return;
      setState(() {
        currentBannerIndex = (currentBannerIndex + 1) % total;
      });
      advPageController.animateToPage(
        currentBannerIndex,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    discoverController.dispose();
    cityModeController.dispose();
    advPageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    exploreProvider = Provider.of<ExploreProvider>(context);
    final playerProvider = Provider.of<PlayerProvider>(context);

    if (exploreProvider.isLoading) {
      return const LoadingWidget();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: MediaQuery.of(context).padding.top),
        WelcomeAppBar(title: 'Explore', showBatch: true),
        MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Expanded(
            child: SmoothListView(
              duration: Duration.zero,
              children: [
                // Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 20),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Gap(10),
                //       Text(
                //         'Hey ${getFirstName(User.instance.user!.name)}!',
                //         style: TextStyle(
                //           fontSize: 25,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //       Text(
                //         'your next favorite song is waiting! Press play & dive in.',
                //         style: TextStyle(
                //           fontSize: 16,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //       const Gap(15),
                //       ClipRRect(
                //         borderRadius: BorderRadius.circular(10),
                //         child: TextField(
                //           readOnly: true,
                //           onTap: () {
                //             FocusManager.instance.primaryFocus?.unfocus();
                //             context.read<StateBloc>().add(StateChangeIndex(3));
                //           },
                //           decoration: InputDecoration(
                //             filled: true,
                //             border: InputBorder.none,
                //             hintStyle: TextStyle(fontSize: 14),
                //             contentPadding: EdgeInsets.symmetric(
                //               vertical: 20,
                //               horizontal: 15,
                //             ),
                //             fillColor: context.scheme.primary.withValues(
                //               alpha: .1,
                //             ),
                //             hintText:
                //                 'Search for songs, artists, albums, or playlist!...',
                //             suffixIcon: Icon(Icons.arrow_outward),
                //           ),
                //         ),
                //       ),
                //       const Gap(10),
                //     ],
                //   ),
                // ),
                Consumer<BannerProvider>(
                  builder: (context, value, child) {
                    if (value.homeBanners.isEmpty) {
                      return SizedBox();
                    }

                    startAutoScroll(value.homeBanners.length);

                    return Column(
                      children: [
                        Gap(10),
                        if (value.homeBanners.isNotEmpty)
                          SizedBox(
                            height: 100,
                            child: PageView.builder(
                              controller: advPageController,
                              itemCount: value.homeBanners.length,
                              onPageChanged: (v) {
                                setState(() => currentBannerIndex = v);
                              },
                              itemBuilder: (context, index) {
                                Map model = value.homeBanners[index];
                                if (model['type'] == 'room') {
                                  return RoomCardsMini();
                                }
                                if (model['type'] == 'premium') {
                                  return PremiumCardsMini();
                                }
                                return GestureDetector(
                                  onTap: () {
                                    value.clickedOnBanner(model['id']);
                                    launchUrl(Uri.parse(model['navigation']));
                                  },
                                  child: CachedNetworkImage(
                                    imageUrl: model['content'],
                                    imageBuilder: (context, imageProvider) {
                                      return Container(
                                        height: 100,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          color: context.scheme.secondary
                                              .withValues(alpha: .4),
                                          image: DecorationImage(
                                            fit: BoxFit.fill,
                                            image: CachedNetworkImageProvider(
                                              model['content'],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    placeholder: (context, url) {
                                      return Container(
                                        height: 100,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          color: context.scheme.secondary
                                              .withValues(alpha: .4),
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: AssetImage(Media.logo),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        Gap(10),
                        if (value.homeBanners.isNotEmpty)
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: context.scheme.primaryContainer
                                        .withValues(alpha: 0.8),
                                  ),
                                  child: Row(
                                    children: List.generate(
                                      value.homeBanners.length,
                                      (index) => AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        height: 5,
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 2,
                                        ),
                                        width:
                                            currentBannerIndex == index
                                                ? 15
                                                : 5,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          ),
                                          color:
                                              currentBannerIndex == index
                                                  ? context.scheme.primary
                                                  : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
                if (exploreProvider.modes.isNotEmpty) _buildMoodWidget(),
                Stack(
                  children: [
                    SizedBox(
                      height: 220,
                      child: ParallaxArea(
                        child: ListView.separated(
                          controller: discoverController,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          scrollDirection: Axis.horizontal,
                          itemCount: exploreProvider.discover.length,
                          itemBuilder: (context, index) {
                            PlaylistModel model =
                                exploreProvider.discover[index];

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
                              child: AnimatedBuilder(
                                animation: discoverController,
                                builder: (context, child) {
                                  final itemPosition = index * 160.0;
                                  final scrollOffset =
                                      discoverController.offset;
                                  final difference =
                                      (itemPosition - scrollOffset).abs();

                                  double height =
                                      difference < 160.0
                                          ? 200 - (difference / 160.0 * 50)
                                          : 150;

                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: ParallaxWidget(
                                              background: CachedNetworkImage(
                                                imageUrl: model.image,
                                                imageBuilder: (
                                                  context,
                                                  imageProvider,
                                                ) {
                                                  return Container(
                                                    margin:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 20,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: imageProvider,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                placeholder: (context, url) {
                                                  return Container(
                                                    margin:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 20,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          blurRadius: 10,
                                                          color:
                                                              context
                                                                  .scheme
                                                                  .shadow,
                                                          offset: const Offset(
                                                            0,
                                                            5,
                                                          ),
                                                        ),
                                                      ],
                                                      image:
                                                          const DecorationImage(
                                                            fit: BoxFit.cover,
                                                            image: AssetImage(
                                                              Media.logo,
                                                            ),
                                                          ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              child: SizedBox(
                                                width: 150,
                                                height: height,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 5,
                                            right: 5,
                                            bottom: 5,
                                            child: Container(
                                              // blur: 5,
                                              // color: context.scheme.surface
                                              //     .withValues(alpha: .6),
                                              // borderRadius:
                                              //     const BorderRadius.vertical(
                                              //   top: Radius.circular(10),
                                              //   bottom: Radius.circular(10),
                                              // ),
                                              padding: EdgeInsets.zero,
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  10,
                                                ),
                                                decoration: BoxDecoration(
                                                  // color: context.scheme.primary
                                                  //     .withValues(alpha: .1),
                                                  // borderRadius:
                                                  //     const BorderRadius
                                                  //         .vertical(
                                                  //         top: Radius.circular(
                                                  //             10)),
                                                  color: context.scheme.surface
                                                      .withValues(alpha: .9),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          _buildText(
                                                            model.title,
                                                            maxLines: 1,
                                                            fontSize: 10,
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                          ),
                                                          _buildText(
                                                            '${model.songCount} Tracks',
                                                            fontSize: 7,
                                                            maxLines: 1,
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                            );
                          },
                          separatorBuilder:
                              (context, index) => const SizedBox(width: 10),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 20,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 190,
                        child: FittedBox(
                          child: Text(
                            'Discover',
                            // 'Discover⟶',
                            style: GoogleFonts.niconne(
                              color: context.onBgColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              letterSpacing: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(30),

                if (exploreProvider.trendingSongs.length >= 3)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Today\'s Hottest Tracks',
                      style: GoogleFonts.dekko(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                if (exploreProvider.trendingSongs.length >= 3) const Gap(10),
                if (exploreProvider.trendingSongs.length >= 3)
                  MasonryGridView.builder(
                    itemCount: 3,
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    itemBuilder: (context, index) {
                      SongModel model = exploreProvider.trendingSongs[index];
                      return GestureDetector(
                        onTap: () {
                          context.read<SongDetailsBloc>().add(
                            SongDetailsFetch(songId: model.id),
                          );
                          Navigator.push(
                            context,
                            PageTransition(
                              child: const SongDetailsScreen(
                                showFirstSong: true,
                              ),
                              type: PageTransitionType.fade,
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl: model.imagesUrl.excellent,
                              imageBuilder: (context, imageProvider) {
                                return Container(
                                  height: index % 3 == 0 ? 310 : 150,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: imageProvider,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                );
                              },
                              placeholder: (context, url) {
                                return Container(
                                  height: index % 3 == 0 ? 310 : 150,
                                  decoration: BoxDecoration(
                                    image: const DecorationImage(
                                      fit: BoxFit.cover,
                                      image: AssetImage(Media.logo),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: context.scheme.surface.withValues(
                                    alpha: .8,
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(),
                                    Text(
                                      model.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: context.scheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      model.subtitle,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: context.scheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              right: 10,
                              top: 10,
                              child: Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                  color: context.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    if (isActive(
                                      playerProvider,
                                      'song',
                                      null,
                                      exploreProvider
                                          .trendingSongsDynamicID[index],
                                    )) {
                                      playerProvider.togglePlayer();
                                      return;
                                    }
                                    playerProvider.startPlaying(
                                      source: [model],
                                      i: 0,
                                      type: PlayingType.song,
                                      hasToAddMoreSource: true,
                                      id:
                                          exploreProvider
                                              .trendingSongsDynamicID[index],
                                    );
                                  },
                                  icon: Icon(
                                    isActive(
                                              playerProvider,
                                              'song',
                                              null,
                                              exploreProvider
                                                  .trendingSongsDynamicID[index],
                                            ) &&
                                            playerProvider.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: context.scheme.onPrimary,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                if (exploreProvider.trendingSongs.length >= 3) const Gap(30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Popular Artists',
                    style: GoogleFonts.dekko(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const Gap(10),
                SizedBox(
                  height: 130,
                  child: ListView.separated(
                    itemCount: exploreProvider.popularArtists.length,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      ArtistModel model = exploreProvider.popularArtists[index];
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
                if (exploreProvider.cityMode.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exploreProvider.cityModeSubTitle,
                          style: GoogleFonts.dekko(fontSize: 12),
                        ),
                        Text(
                          exploreProvider.cityModeTitle,
                          style: GoogleFonts.dekko(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (exploreProvider.cityMode.isNotEmpty) const Gap(10),
                if (exploreProvider.cityMode.isNotEmpty)
                  SizedBox(
                    height: 160,
                    child: ParallaxArea(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: exploreProvider.cityMode.length,
                        itemBuilder: (context, index) {
                          PlaylistModel model = exploreProvider.cityMode[index];

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
                            child: AnimatedBuilder(
                              animation: cityModeController,
                              builder: (context, child) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: ParallaxWidget(
                                            background: CachedNetworkImage(
                                              imageUrl: model.image,
                                              imageBuilder: (
                                                context,
                                                imageProvider,
                                              ) {
                                                return Container(
                                                  margin:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 20,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: imageProvider,
                                                    ),
                                                  ),
                                                );
                                              },
                                              placeholder: (context, url) {
                                                return Container(
                                                  margin:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 20,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        blurRadius: 10,
                                                        color:
                                                            context
                                                                .scheme
                                                                .shadow,
                                                        offset: const Offset(
                                                          0,
                                                          5,
                                                        ),
                                                      ),
                                                    ],
                                                    image:
                                                        const DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: AssetImage(
                                                            Media.logo,
                                                          ),
                                                        ),
                                                  ),
                                                );
                                              },
                                            ),
                                            child: const SizedBox(
                                              width: 150,
                                              height: 160,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 5,
                                          right: 5,
                                          bottom: 5,
                                          child: Container(
                                            // blur: 5,
                                            // color: context.scheme.surface
                                            //     .withValues(alpha: .6),
                                            // borderRadius:
                                            //     const BorderRadius.vertical(
                                            //   top: Radius.circular(10),
                                            //   bottom: Radius.circular(10),
                                            // ),
                                            padding: EdgeInsets.zero,
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                // color: context.scheme.primary
                                                //     .withValues(alpha: .1),
                                                // borderRadius:
                                                //     const BorderRadius.vertical(
                                                //         top: Radius.circular(10)),
                                                color: context.scheme.surface
                                                    .withValues(alpha: .9),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        _buildText(
                                                          model.title,
                                                          maxLines: 1,
                                                          fontSize: 10,
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        _buildText(
                                                          model.subtitle,
                                                          fontSize: 7,
                                                          maxLines: 1,
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        },
                        separatorBuilder:
                            (context, index) => const SizedBox(width: 10),
                      ),
                    ),
                  ),
                if (exploreProvider.cityMode.isNotEmpty) const Gap(15),
                SmoothListView.separated(
                  duration: Duration.zero,
                  itemCount: exploreProvider.homeModules.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    if (exploreProvider.homeModules[index]['type'] == 'ad') {
                      return const SizedBox();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            exploreProvider.homeModules[index]['title'],
                            style: GoogleFonts.dekko(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const Gap(10),
                        SizedBox(
                          height:
                              exploreProvider.homeModules[index]['layout'] ==
                                      'optimal'
                                  ? 220
                                  : exploreProvider
                                          .homeModules[index]['layout'] ==
                                      'advanced'
                                  ? 250
                                  : 160,
                          child: ParallaxArea(
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              scrollDirection: Axis.horizontal,
                              itemCount:
                                  List.from(
                                    exploreProvider.homeModules[index]['data'],
                                  ).toList().length,
                              itemBuilder: (context, i) {
                                Map item =
                                    exploreProvider
                                        .homeModules[index]['data'][i];
                                bool isPlaylist = item['type'] == 'playlist';
                                PlaylistModel? playlistModel;
                                AlbumModel? albumModel;
                                if (isPlaylist) {
                                  playlistModel = item['data'];
                                } else {
                                  albumModel = item['data'];
                                }

                                if (exploreProvider
                                        .homeModules[index]['layout'] ==
                                    'optimal') {
                                  return GestureDetector(
                                    onTap: () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      Widget widget = const SizedBox();

                                      if (isPlaylist) {
                                        context.read<PlaylistBloc>().add(
                                          PlaylistFetch(
                                            id: playlistModel!.id,
                                            type: 'remote',
                                          ),
                                        );
                                        widget = const PlaylistScreen();
                                      } else {
                                        context.read<AlbumProvider>().setAlbum(
                                          albumModel!.id,
                                        );
                                        widget = const AlbumScreen();
                                      }
                                      Navigator.push(
                                        context,
                                        PageTransition(
                                          child: widget,
                                          type: PageTransitionType.fade,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 150,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: context.primary.withValues(
                                          alpha: .2,
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          Column(
                                            children: [
                                              if (isPlaylist)
                                                Expanded(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    child: ParallaxWidget(
                                                      background: CachedNetworkImage(
                                                        imageUrl:
                                                            playlistModel!
                                                                .image,
                                                        imageBuilder: (
                                                          context,
                                                          imageProvider,
                                                        ) {
                                                          return Container(
                                                            margin:
                                                                const EdgeInsets.symmetric(
                                                                  vertical: 20,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              image: DecorationImage(
                                                                fit:
                                                                    BoxFit
                                                                        .cover,
                                                                image:
                                                                    imageProvider,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        placeholder: (
                                                          context,
                                                          url,
                                                        ) {
                                                          return Container(
                                                            margin:
                                                                const EdgeInsets.symmetric(
                                                                  vertical: 20,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  blurRadius:
                                                                      10,
                                                                  color:
                                                                      context
                                                                          .scheme
                                                                          .shadow,
                                                                  offset:
                                                                      const Offset(
                                                                        0,
                                                                        5,
                                                                      ),
                                                                ),
                                                              ],
                                                              image: const DecorationImage(
                                                                fit:
                                                                    BoxFit
                                                                        .cover,
                                                                image:
                                                                    AssetImage(
                                                                      Media
                                                                          .logo,
                                                                    ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      child: const Column(
                                                        children: [
                                                          Expanded(
                                                            child: SizedBox(
                                                              width: 150,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              else
                                                Expanded(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    child: CachedNetworkImage(
                                                      imageUrl:
                                                          albumModel!
                                                              .image
                                                              .excellent,
                                                      imageBuilder: (
                                                        context,
                                                        imageProvider,
                                                      ) {
                                                        return Container(
                                                          decoration: BoxDecoration(
                                                            image: DecorationImage(
                                                              fit: BoxFit.cover,
                                                              image:
                                                                  imageProvider,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      placeholder: (
                                                        context,
                                                        url,
                                                      ) {
                                                        return Container(
                                                          decoration: BoxDecoration(
                                                            boxShadow: [
                                                              BoxShadow(
                                                                blurRadius: 10,
                                                                color:
                                                                    context
                                                                        .scheme
                                                                        .shadow,
                                                                offset:
                                                                    const Offset(
                                                                      0,
                                                                      5,
                                                                    ),
                                                              ),
                                                            ],
                                                            image: const DecorationImage(
                                                              fit: BoxFit.cover,
                                                              image: AssetImage(
                                                                Media.logo,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),

                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  10,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Row(),
                                                    _buildText(
                                                      isPlaylist
                                                          ? playlistModel!.title
                                                          : albumModel!.title,
                                                      maxLines: 1,
                                                      fontSize: 10,
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    _buildText(
                                                      isPlaylist
                                                          ? playlistModel!
                                                              .subtitle
                                                          : albumModel!
                                                              .subtitle,
                                                      fontSize: 7,
                                                      maxLines: 1,
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                if (exploreProvider
                                        .homeModules[index]['layout'] ==
                                    'advanced') {
                                  return GestureDetector(
                                    onTap: () {
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      Widget widget = const SizedBox();

                                      if (isPlaylist) {
                                        context.read<PlaylistBloc>().add(
                                          PlaylistFetch(
                                            id: playlistModel!.id,
                                            type: 'remote',
                                          ),
                                        );
                                        widget = const PlaylistScreen();
                                      } else {
                                        context.read<AlbumProvider>().setAlbum(
                                          albumModel!.id,
                                        );
                                        widget = const AlbumScreen();
                                      }
                                      Navigator.push(
                                        context,
                                        PageTransition(
                                          child: widget,
                                          type: PageTransitionType.fade,
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width: 180,
                                      child: Stack(
                                        children: [
                                          Column(
                                            children: [
                                              if (isPlaylist)
                                                Expanded(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          50,
                                                        ),
                                                    child: ParallaxWidget(
                                                      background: CachedNetworkImage(
                                                        imageUrl:
                                                            playlistModel!
                                                                .image,
                                                        imageBuilder: (
                                                          context,
                                                          imageProvider,
                                                        ) {
                                                          return Container(
                                                            margin:
                                                                const EdgeInsets.symmetric(
                                                                  vertical: 20,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              image: DecorationImage(
                                                                fit:
                                                                    BoxFit
                                                                        .cover,
                                                                image:
                                                                    imageProvider,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        placeholder: (
                                                          context,
                                                          url,
                                                        ) {
                                                          return Container(
                                                            margin:
                                                                const EdgeInsets.symmetric(
                                                                  vertical: 20,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  blurRadius:
                                                                      10,
                                                                  color:
                                                                      context
                                                                          .scheme
                                                                          .shadow,
                                                                  offset:
                                                                      const Offset(
                                                                        0,
                                                                        5,
                                                                      ),
                                                                ),
                                                              ],
                                                              image: const DecorationImage(
                                                                fit:
                                                                    BoxFit
                                                                        .cover,
                                                                image:
                                                                    AssetImage(
                                                                      Media
                                                                          .logo,
                                                                    ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                      child: const Column(
                                                        children: [
                                                          Expanded(
                                                            child: SizedBox(
                                                              width: 180,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              else
                                                Expanded(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          50,
                                                        ),
                                                    child: CachedNetworkImage(
                                                      imageUrl:
                                                          albumModel!
                                                              .image
                                                              .excellent,
                                                      imageBuilder: (
                                                        context,
                                                        imageProvider,
                                                      ) {
                                                        return Container(
                                                          decoration: BoxDecoration(
                                                            image: DecorationImage(
                                                              fit: BoxFit.cover,
                                                              image:
                                                                  imageProvider,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      placeholder: (
                                                        context,
                                                        url,
                                                      ) {
                                                        return Container(
                                                          decoration: BoxDecoration(
                                                            boxShadow: [
                                                              BoxShadow(
                                                                blurRadius: 10,
                                                                color:
                                                                    context
                                                                        .scheme
                                                                        .shadow,
                                                                offset:
                                                                    const Offset(
                                                                      0,
                                                                      5,
                                                                    ),
                                                              ),
                                                            ],
                                                            image: const DecorationImage(
                                                              fit: BoxFit.cover,
                                                              image: AssetImage(
                                                                Media.logo,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  10,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Row(),
                                                    _buildText(
                                                      isPlaylist
                                                          ? playlistModel!.title
                                                          : albumModel!.title,
                                                      maxLines: 1,
                                                      fontSize: 10,
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    _buildText(
                                                      isPlaylist
                                                          ? playlistModel!
                                                              .subtitle
                                                          : albumModel!
                                                              .subtitle,
                                                      fontSize: 7,
                                                      maxLines: 1,
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                return GestureDetector(
                                  onTap: () {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    Widget widget = const SizedBox();

                                    if (isPlaylist) {
                                      context.read<PlaylistBloc>().add(
                                        PlaylistFetch(
                                          id: playlistModel!.id,
                                          type: 'remote',
                                        ),
                                      );
                                      widget = const PlaylistScreen();
                                    } else {
                                      context.read<AlbumProvider>().setAlbum(
                                        albumModel!.id,
                                      );
                                      widget = const AlbumScreen();
                                    }
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        child: widget,
                                        type: PageTransitionType.fade,
                                      ),
                                    );
                                  },
                                  child: AnimatedBuilder(
                                    animation: cityModeController,
                                    builder: (context, child) {
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Stack(
                                            children: [
                                              if (isPlaylist)
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: ParallaxWidget(
                                                    background: CachedNetworkImage(
                                                      imageUrl:
                                                          isPlaylist
                                                              ? playlistModel!
                                                                  .image
                                                              : albumModel!
                                                                  .image
                                                                  .excellent,
                                                      imageBuilder: (
                                                        context,
                                                        imageProvider,
                                                      ) {
                                                        return Container(
                                                          margin:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 20,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            image: DecorationImage(
                                                              fit: BoxFit.cover,
                                                              image:
                                                                  imageProvider,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      placeholder: (
                                                        context,
                                                        url,
                                                      ) {
                                                        return Container(
                                                          margin:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 20,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            boxShadow: [
                                                              BoxShadow(
                                                                blurRadius: 10,
                                                                color:
                                                                    context
                                                                        .scheme
                                                                        .shadow,
                                                                offset:
                                                                    const Offset(
                                                                      0,
                                                                      5,
                                                                    ),
                                                              ),
                                                            ],
                                                            image: const DecorationImage(
                                                              fit: BoxFit.cover,
                                                              image: AssetImage(
                                                                Media.logo,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    child: const SizedBox(
                                                      width: 150,
                                                      height: 160,
                                                    ),
                                                  ),
                                                )
                                              else
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        isPlaylist
                                                            ? playlistModel!
                                                                .image
                                                            : albumModel!
                                                                .image
                                                                .excellent,
                                                    imageBuilder: (
                                                      context,
                                                      imageProvider,
                                                    ) {
                                                      return Container(
                                                        height: 160,
                                                        width: 150,
                                                        decoration: BoxDecoration(
                                                          image: DecorationImage(
                                                            fit: BoxFit.cover,
                                                            image:
                                                                imageProvider,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    placeholder: (
                                                      context,
                                                      url,
                                                    ) {
                                                      return Container(
                                                        height: 160,
                                                        width: 150,
                                                        decoration: BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                              blurRadius: 10,
                                                              color:
                                                                  context
                                                                      .scheme
                                                                      .shadow,
                                                              offset:
                                                                  const Offset(
                                                                    0,
                                                                    5,
                                                                  ),
                                                            ),
                                                          ],
                                                          image:
                                                              const DecorationImage(
                                                                fit:
                                                                    BoxFit
                                                                        .cover,
                                                                image:
                                                                    AssetImage(
                                                                      Media
                                                                          .logo,
                                                                    ),
                                                              ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              Positioned(
                                                left: 5,
                                                right: 5,
                                                bottom: 5,
                                                child: Container(
                                                  // blur: 5,
                                                  // color: context.scheme.surface
                                                  //     .withValues(alpha: .6),
                                                  // borderRadius:
                                                  //     const BorderRadius
                                                  //         .vertical(
                                                  //   top: Radius.circular(10),
                                                  //   bottom: Radius.circular(10),
                                                  // ),
                                                  padding: EdgeInsets.zero,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          10,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      // color: context
                                                      //     .scheme.primary
                                                      //     .withValues(
                                                      //         alpha: .1),
                                                      // borderRadius:
                                                      //     const BorderRadius
                                                      //         .vertical(
                                                      //         top: Radius
                                                      //             .circular(
                                                      //                 10)),
                                                      color: context
                                                          .scheme
                                                          .surface
                                                          .withValues(
                                                            alpha: .9,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              _buildText(
                                                                isPlaylist
                                                                    ? playlistModel!
                                                                        .title
                                                                    : albumModel!
                                                                        .title,
                                                                maxLines: 1,
                                                                fontSize: 10,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                              _buildText(
                                                                isPlaylist
                                                                    ? playlistModel!
                                                                        .subtitle
                                                                    : albumModel!
                                                                        .subtitle,
                                                                fontSize: 7,
                                                                maxLines: 1,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (context, index) => const SizedBox(width: 10),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Gap(15);
                  },
                ),
                const Gap(20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodWidget() {
    return BlocBuilder<DiscoverBloc, DiscoverState>(
      builder: (context, state) {
        if (state is DiscoverFetched) {
          List<DiscoverEntiry> entries = state.discoverItems!;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'What’s Your Mood?',
                  style: GoogleFonts.dekko(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const Gap(10),
              SizedBox(
                height: 50,
                child: ListView.separated(
                  itemCount: entries.length,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    DiscoverEntiry model = entries[index];
                    return GestureDetector(
                      onTap: () {
                        if (isActive(
                          playerProvider,
                          'discover',
                          null,
                          model.id,
                        )) {
                          !playerProvider.isPlaying
                              ? playerProvider.togglePlayer()
                              : null;
                          return;
                        }
                        playerProvider.startPlaying(
                          source: model.songs,
                          i: 0,
                          type: PlayingType.discover,
                          id: model.id,
                          discoverPlaylist: model.playlist,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color:
                              isActive(
                                    playerProvider,
                                    'discover',
                                    null,
                                    model.id,
                                  )
                                  ? context.scheme.primary
                                  : context.scheme.onSecondaryContainer
                                      .withValues(alpha: .05),
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          model.title,
                          style: TextStyle(
                            color:
                                isActive(
                                      playerProvider,
                                      'discover',
                                      null,
                                      model.id,
                                    )
                                    ? context.scheme.onPrimary
                                    : null,
                            fontWeight:
                                isActive(
                                      playerProvider,
                                      'discover',
                                      null,
                                      model.id,
                                    )
                                    ? FontWeight.bold
                                    : null,
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Gap(10);
                  },
                ),
              ),
              const Gap(10),
            ],
          );
        }
        return const SizedBox();
      },
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
