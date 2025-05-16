import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:new_tuneflow/core/common/bloc/state_bloc.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/common/providers/player_provider.dart';
import 'package:new_tuneflow/core/common/providers/search_suggestions_provider.dart';
import 'package:new_tuneflow/core/common/widget/modern_text.dart';
import 'package:new_tuneflow/core/common/widget/more_vert_song_button.dart';
import 'package:new_tuneflow/core/common/widget/welcome_app_bar.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/helpers/ad_helper.dart';
import 'package:new_tuneflow/core/res/media.dart';
import 'package:new_tuneflow/core/utils/core_utils.dart';
import 'package:new_tuneflow/core/utils/function.dart';
import 'package:new_tuneflow/src/album/data/models/album_model.dart';
import 'package:new_tuneflow/src/album/presentation/provider/album_provider.dart';
import 'package:new_tuneflow/src/album/presentation/screens/album.dart';
import 'package:new_tuneflow/src/artist_details/presentation/bloc/artist_details_bloc.dart';
import 'package:new_tuneflow/src/artist_details/presentation/screens/artist_details.dart';
import 'package:new_tuneflow/src/explore/domain/entites/for_you_entiry.dart';
import 'package:new_tuneflow/src/explore/domain/entites/trending_entity.dart';
import 'package:new_tuneflow/src/explore/presentation/bloc/foryou_bloc.dart';
import 'package:new_tuneflow/src/explore/presentation/bloc/search_bloc.dart';
import 'package:new_tuneflow/src/explore/presentation/bloc/trending_bloc.dart';
import 'package:new_tuneflow/src/explore/presentation/screen/search_people.dart';
import 'package:new_tuneflow/src/explore/presentation/widget/shimmer.dart';
import 'package:new_tuneflow/src/explore/presentation/widget/shimmer.trending.dart';
import 'package:new_tuneflow/src/playlist/data/models/playlist_model.dart';
import 'package:new_tuneflow/src/playlist/presentation/bloc/playlist_bloc.dart';
import 'package:new_tuneflow/src/playlist/presentation/screens/playlist.dart';
import 'package:new_tuneflow/src/song/presentation/bloc/song_details_bloc.dart';
import 'package:new_tuneflow/src/song/presentation/screens/songs.dart';
import 'package:page_transition/page_transition.dart';
import 'package:parallax_animation/parallax_animation.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();
  int selectedIndex = 0;
  bool isAutoScrolling = false;
  bool isOnFocused = false;

  int _adLoadCount = 0;
  static const int maxLoadRequests = 5;
  late NativeAd? nativeAd;
  bool isAdLoaded = false;
  bool isLoadingAds = false;
  Timer? _adRefreshTimer;
  Timer? _retryTimer;
  static const int adRefreshIntervalMinutes = 20;
  static const int adResetIntervalHours = 2;
  int _retryDelaySeconds = 30;

  bool canLoadAd() {
    if (isLoadingAds || isAdLoaded) return false;

    final box = Hive.box('app');

    int? lastAdLoadTime = box.get('lastAdLoadTime');
    if (lastAdLoadTime != null) {
      final resetThreshold =
          DateTime.now()
              .subtract(const Duration(hours: adResetIntervalHours))
              .millisecondsSinceEpoch;

      if (lastAdLoadTime < resetThreshold) {
        _adLoadCount = 0;
        _retryDelaySeconds = 30;
        box.put('lastAdLoadTime', DateTime.now().millisecondsSinceEpoch);
      }
    }

    final cooldownThreshold =
        DateTime.now()
            .subtract(const Duration(minutes: adRefreshIntervalMinutes))
            .millisecondsSinceEpoch;

    List<int> adTimestamps =
        box.get('adTimestamps', defaultValue: <int>[]).cast<int>();

    adTimestamps = adTimestamps.where((ts) => ts > cooldownThreshold).toList();
    box.put('adTimestamps', adTimestamps);

    if (adTimestamps.isNotEmpty) {
      return false;
    }

    if (_adLoadCount >= maxLoadRequests) {
      return false;
    }

    isLoadingAds = true;
    setState(() {});
    return true;
  }

  Future<void> loadNativeAd() async {
    if (!Platform.isAndroid) {
      isLoadingAds = false;
      setState(() {});
      return;
    }

    bool isAdblocking = await isAdBlockEnabled();
    if (isAdblocking) {
      isLoadingAds = false;
      setState(() {});
      return;
    }

    if (!canLoadAd()) {
      isLoadingAds = false;
      return;
    }

    final box = Hive.box('app');
    box.put('lastAdLoadTime', DateTime.now().millisecondsSinceEpoch);

    nativeAd = NativeAd(
      adUnitId: AdHelper.nativeAdUnit,
      factoryId: 'listTile',
      listener: NativeAdListener(
        onAdLoaded: (ad) async {
          nativeAd = ad as NativeAd;
          _adLoadCount++;
          isAdLoaded = true;
          isLoadingAds = false;
          _retryDelaySeconds = 30;

          _recordAdInteraction();
          setState(() {});
          _scheduleAdRefresh();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          nativeAd = null;
          isAdLoaded = false;
          isLoadingAds = false;

          _recordAdInteraction();

          _scheduleRetry();

          setState(() {});
        },
        onAdClosed: (ad) {
          ad.dispose();
          nativeAd = null;
          isAdLoaded = false;
          isLoadingAds = false;

          _recordAdInteraction();
          setState(() {});
        },
        onAdImpression: (ad) {
          _recordAdInteraction();
        },
        onPaidEvent: (ad, valueMicros, precision, currencyCode) {},
      ),
      request: const AdRequest(),
    );

    try {
      await nativeAd!.load();
    } catch (e) {
      nativeAd = null;
      isLoadingAds = false;
      _recordAdInteraction();
      _scheduleRetry();
      setState(() {});
    }
  }

  void _recordAdInteraction() {
    final box = Hive.box('app');
    List<int> adTimestamps =
        box.get('adTimestamps', defaultValue: <int>[]).cast<int>();
    final now = DateTime.now().millisecondsSinceEpoch;

    if (!adTimestamps.contains(now)) {
      adTimestamps.add(now);
      box.put('adTimestamps', adTimestamps);
    }
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();

    if (_retryDelaySeconds < 3600) {
      _retryTimer = Timer(Duration(seconds: _retryDelaySeconds), () {
        if (mounted && !isAdLoaded && !isLoadingAds) {
          loadNativeAd();
        }
      });

      _retryDelaySeconds = _retryDelaySeconds * 2;
    }
  }

  void _scheduleAdRefresh() {
    _adRefreshTimer?.cancel();

    if (isAdLoaded) {
      _adRefreshTimer = Timer(
        const Duration(minutes: adRefreshIntervalMinutes),
        () {
          if (mounted) {
            if (isAdLoaded && nativeAd != null) {
              nativeAd!.dispose();
              nativeAd = null;
              isAdLoaded = false;
            }
            loadNativeAd();
          }
        },
      );
    }
  }

  void _checkAndLoadAd() {
    if (mounted) {
      final box = Hive.box('app');
      final cooldownThreshold =
          DateTime.now()
              .subtract(const Duration(minutes: adRefreshIntervalMinutes))
              .millisecondsSinceEpoch;

      List<int> adTimestamps =
          box.get('adTimestamps', defaultValue: <int>[]).cast<int>();

      adTimestamps =
          adTimestamps.where((ts) => ts > cooldownThreshold).toList();
      box.put('adTimestamps', adTimestamps);

      bool canTryLoading = adTimestamps.isEmpty;

      if (canTryLoading && !isAdLoaded && !isLoadingAds) {
        box.put('lastAdLoadTime', DateTime.now().millisecondsSinceEpoch);
        loadNativeAd();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    nativeAd = null;
    Future.delayed(const Duration(seconds: 2), _checkAndLoadAd);
  }

  static const _kAdIndex = 2;
  int _getDestinationItemIndex(int rawIndex) {
    if (rawIndex >= _kAdIndex && isAdLoaded) {
      return rawIndex - 1;
    }
    return rawIndex;
  }

  @override
  void dispose() {
    _adRefreshTimer?.cancel();
    _retryTimer?.cancel();
    if (nativeAd != null) {
      nativeAd!.dispose();
      nativeAd = null;
      isAdLoaded = false;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlayerProvider>(context);
    final suggestionProvider = Provider.of<SearchSuggestionsProvider>(context);
    return BlocBuilder<StateBloc, StateState>(
      builder: (context, state) {
        return Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top),
            WelcomeAppBar(
              title: 'Search',
              surfix: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      child: const SearchPeople(),
                      type: PageTransitionType.fade,
                    ),
                  );
                },
                icon: SizedBox(
                  height: 35,
                  width: 35,
                  child: const Icon(Icons.person_search_outlined, size: 26),
                ),
              ),
            ),
            const Gap(15),
            _buildSearchField(suggestionProvider),
            const SizedBox(height: 10),
            if (controller.text.isNotEmpty) ...[
              const Divider(height: 0),
              _buildSearchTabBar(),
              const Divider(height: 0),
            ],
            _buildBody(provider, suggestionProvider),
          ],
        );
      },
    );
  }

  Widget _buildSearchField(SearchSuggestionsProvider suggestionProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Focus(
        onFocusChange: (value) {
          setState(() => isOnFocused = value);
        },
        child: TextField(
          controller: controller,
          onChanged: (value) {
            setState(() {});
            if (value.isNotEmpty) {
              context.read<SearchBloc>().add(SearchQueryChanged(value));
              isAutoScrolling = true;
              scrollController.jumpTo(0);
              isAutoScrolling = false;
            }
            if (!isAdLoaded) {
              loadNativeAd();
            }
          },
          decoration: InputDecoration(
            filled: true,
            hintText: 'Search...',
            prefixIcon: const Icon(Icons.search, size: 27),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 15,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(width: 1, color: context.scheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(width: 2, color: context.scheme.primary),
            ),
            suffixIcon:
                controller.text.isNotEmpty
                    ? IconButton(
                      onPressed: () {
                        controller.clear();
                        suggestionProvider.clearSuggestions();
                        setState(() {});
                      },
                      icon: const Icon(Icons.close),
                    )
                    : null,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTabBarItem('Son-gs', 0),
          _buildTabBarItem('Play-lists', 1),
          _buildTabBarItem('Alb-ums', 2),
          _buildTabBarItem('Art-ists', 3),
        ],
      ),
    );
  }

  Widget _buildTabBarItem(String text, int index) {
    return ModernText(
      text: text,
      isActive: selectedIndex == index,
      onPressed: () {
        scrollController.jumpTo(0);
        setState(() => selectedIndex = index);
      },
    );
  }

  Widget _buildBody(
    PlayerProvider provider,
    SearchSuggestionsProvider searchSuggestionsProvider,
  ) {
    return Expanded(
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            // if (isAutoScrolling) return false;
            // if (notification is ScrollStartNotification) {
            //   FocusManager.instance.primaryFocus?.unfocus();
            // }
            return false;
          },
          child: ListView(
            controller: scrollController,
            children: [
              if (isOnFocused && controller.text.isEmpty)
                _buildOnFocus(searchSuggestionsProvider),
              if (controller.text.isNotEmpty) const SizedBox(height: 10),
              if (controller.text.isNotEmpty) _buildSearchResults(provider),
              if (isOnFocused && controller.text.isEmpty)
                const SizedBox(height: 10),
              if (controller.text.isNotEmpty) const SizedBox(height: 10),
              _buildOffFocus(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOffFocus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Trending Now',
            style: GoogleFonts.dekko(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        const SizedBox(height: 15),
        _buildTrendingSection(),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'New Releases',
            style: GoogleFonts.dekko(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        const SizedBox(height: 15),
        _buildForYouSection(),
      ],
    );
  }

  Widget _buildOnFocus(SearchSuggestionsProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          // if (provider.suggestions.isNotEmpty)
          //   Text(
          //     'Suggested Options',
          //     style: TextStyle(
          //       fontWeight: FontWeight.bold,
          //       fontSize: 16,
          //       color: context.primary,
          //     ),
          //   ),
          // if (provider.suggestions.isNotEmpty) const SizedBox(height: 15),
          // if (provider.suggestions.isNotEmpty)
          //   Wrap(
          //     spacing: 10,
          //     runSpacing: 10,
          //     children: List.generate(
          //       provider.suggestions.length,
          //       (index) {
          //         return InkWell(
          //           onTap: () {
          //             String value = provider.suggestions[index]['title'];
          //             controller.text = value;
          //             context.read<SearchBloc>().add(SearchQueryChanged(value));
          //             isAutoScrolling = true;
          //             scrollController.jumpTo(0);
          //             isAutoScrolling = false;
          //             FocusManager.instance.primaryFocus?.unfocus();
          //           },
          //           borderRadius: BorderRadius.circular(10),
          //           child: Container(
          //             padding: const EdgeInsets.all(7),
          //             decoration: BoxDecoration(
          //               borderRadius: BorderRadius.circular(10),
          //               border: Border.all(
          //                 color: context.onBgColor.withValues(alpha: .5),
          //               ),
          //             ),
          //             child: Row(
          //               mainAxisSize: MainAxisSize.min,
          //               children: [
          //                 Container(
          //                   height: 20,
          //                   width: 20,
          //                   decoration: BoxDecoration(
          //                     border: Border.all(
          //                       color: context.onBgColor.withValues(alpha: .5),
          //                     ),
          //                     image: DecorationImage(
          //                       image: CachedNetworkImageProvider(
          //                         provider.suggestions[index]['image'],
          //                       ),
          //                     ),
          //                     borderRadius: BorderRadius.circular(5),
          //                   ),
          //                 ),
          //                 const SizedBox(width: 7),
          //                 Flexible(
          //                   child: Text(
          //                     provider.suggestions[index]['title'],
          //                     style: const TextStyle(
          //                       fontWeight: FontWeight.bold,
          //                       fontSize: 10,
          //                     ),
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         );
          //       },
          //     ),
          //   ),
          // if (provider.suggestions.isNotEmpty) const SizedBox(height: 20),
          if (provider.trending.isNotEmpty)
            Text(
              'Trending Search',
              style: GoogleFonts.dekko(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: context.primary,
              ),
            ),
          if (provider.trending.isNotEmpty) const SizedBox(height: 15),
          if (provider.trending.isNotEmpty)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(provider.trending.length, (index) {
                return InkWell(
                  onTap: () {
                    String value = provider.trending[index]['title'];
                    controller.text = value;
                    context.read<SearchBloc>().add(SearchQueryChanged(value));
                    isAutoScrolling = true;
                    scrollController.jumpTo(0);
                    isAutoScrolling = false;
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: context.onBgColor.withValues(alpha: .5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: context.onBgColor.withValues(alpha: .5),
                            ),
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                provider.trending[index]['image'],
                              ),
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          provider.trending[index]['title'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(PlayerProvider provider) {
    if (selectedIndex == 0) {
      return BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) => _buildSearchSongs(provider, state),
      );
    } else if (selectedIndex == 1) {
      return BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) => _buildSearchPlaylists(state),
      );
    } else if (selectedIndex == 2) {
      return BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) => _buildSearchAlbum(state),
      );
    } else if (selectedIndex == 3) {
      return BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) => _buildSearchArtists(state),
      );
    }
    return const SizedBox();
  }

  Widget _buildSearchSongs(PlayerProvider provider, SearchState state) {
    if (state is SearchLoading) {
      return _buildSearchSongShimmer();
    } else if (state is SearchError) {
      return Center(
        child: Text(
          state.error!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    } else if (state is SearchResults) {
      if (state.results!.songs.isEmpty) {
        return Center(
          child: Text(
            'Not matching with "${controller.text}"',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }
      return ListView.separated(
        itemCount: state.results!.songs.length + (isAdLoaded ? 1 : 0),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          if (isAdLoaded && index == _kAdIndex) {
            return Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              child:
                  nativeAd != null ? AdWidget(ad: nativeAd!) : const SizedBox(),
            );
          }
          SongModel model =
              state.results!.songs[_getDestinationItemIndex(index)];
          return _buildSongItem(provider, model);
        },
        separatorBuilder: (context, index) => const Gap(10),
      );
    }
    return _buildSearchSongShimmer();
  }

  Widget _buildSongItem(PlayerProvider provider, SongModel model) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            if (isActive(provider, 'search', model.id, 'id')) {
              !provider.isPlaying ? provider.togglePlayer() : null;
              return;
            }
            provider.startPlaying(
              source: [model],
              i: 0,
              type: PlayingType.search,
              hasToAddMoreSource: true,
            );
          },
          child: Container(
            padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
            child: Row(
              children: [
                _buildImage(model.imagesUrl.regular, 40, 10),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildText(
                        model.title,
                        isHighlighted: isActive(
                          provider,
                          'search',
                          model.id,
                          'id',
                        ),
                        maxLines: 1,
                      ),
                      _buildText(
                        model.subtitle,
                        isHighlighted: isActive(
                          provider,
                          'search',
                          model.id,
                          'id',
                        ),
                        maxLines: 1,
                        fontSize: 10,
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

  Widget _buildImage(String imageUrl, double size, double radius) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder:
          (context, imageProvider) => Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              image: DecorationImage(image: imageProvider),
            ),
          ),
      placeholder:
          (context, url) => Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              image: const DecorationImage(image: AssetImage(Media.logo)),
            ),
          ),
    );
  }

  Widget _buildSearchPlaylists(SearchState state) {
    if (state is SearchLoading) {
      return _buildSearchPlaylistShimmer();
    } else if (state is SearchError) {
      return Center(
        child: Text(
          state.error!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    } else if (state is SearchResults) {
      if (state.results!.playlist.isEmpty) {
        return Center(
          child: Text(
            'Not matching with "${controller.text}"',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }
      return ParallaxArea(
        child: ListView.separated(
          itemCount: state.results!.playlist.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            PlaylistModel model = state.results!.playlist[index];
            return _buildPlaylistItem(model);
          },
          separatorBuilder: (p0, p1) => const SizedBox(height: 10),
        ),
      );
    }
    return _buildSearchPlaylistShimmer();
  }

  Widget _buildPlaylistItem(PlaylistModel model) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
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
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                _buildParallaxImage(model.image, 70),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildText(model.title, maxLines: 2),
                      _buildText('${model.songCount} Songs', fontSize: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParallaxImage(String imageUrl, double size) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder:
          (context, imageProvider) => ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: ParallaxWidget(
              overflowWidthFactor: 1,
              background: Container(
                height: size,
                width: size,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              child: SizedBox(height: size, width: size),
            ),
          ),
      placeholder:
          (context, url) => Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: const DecorationImage(image: AssetImage(Media.logo)),
            ),
          ),
    );
  }

  Widget _buildSearchAlbum(SearchState state) {
    if (state is SearchLoading) {
      return _buildSearchAlbumShimmer();
    } else if (state is SearchError) {
      return Center(
        child: Text(
          state.error!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    } else if (state is SearchResults) {
      if (state.results!.album.isEmpty) {
        return Center(
          child: Text(
            'Not matching with "${controller.text}"',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }
      return ListView.separated(
        itemCount: state.results!.album.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          AlbumModel model = state.results!.album[index];
          return _buildAlbumItem(model);
        },
        separatorBuilder: (context, index) => const Gap(10),
      );
    }
    return _buildSearchAlbumShimmer();
  }

  Widget _buildAlbumItem(AlbumModel model) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
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
          child: Container(
            padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
            child: Row(
              children: [
                _buildImage(model.image.good, 60, 10),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildText(model.title, maxLines: 1),
                      _buildText('Album', fontSize: 10, maxLines: 1),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchArtists(SearchState state) {
    if (state is SearchLoading) {
      return _buildSearchArtistShimmer();
    } else if (state is SearchError) {
      return Center(
        child: Text(
          state.error!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    } else if (state is SearchResults) {
      if (state.results!.artists.isEmpty) {
        return Center(
          child: Text(
            'Not matching with "${controller.text}"',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      }
      return ListView.separated(
        itemCount: state.results!.artists.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          ArtistModel model = state.results!.artists[index];
          return _buildArtistItem(model);
        },
        separatorBuilder: (context, index) => const Gap(10),
      );
    }
    return _buildSearchArtistShimmer();
  }

  Widget _buildArtistItem(ArtistModel model) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
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
          child: Container(
            padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
            child: Row(
              children: [
                _buildCircleImage(model.image.good, 35),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildText(model.name, maxLines: 1),
                      _buildText('Artist', fontSize: 10, maxLines: 1),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircleImage(String imageUrl, double radius) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder:
          (context, imageProvider) =>
              CircleAvatar(radius: radius, backgroundImage: imageProvider),
      placeholder:
          (context, url) => CircleAvatar(
            radius: radius,
            backgroundImage: const AssetImage(Media.logo),
          ),
    );
  }

  Widget _buildTrendingSection() {
    return BlocBuilder<TrendingBloc, TrendingState>(
      builder: (context, state) {
        if (state is TrendingInitial) {
          return const TrendingShimmerView();
        } else if (state is TrendingFetched) {
          return _buildTrendingCard(state);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildTrendingCard(TrendingFetched state) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: SizedBox(
        height: 150,
        child: ParallaxArea(
          child: ListView.separated(
            itemCount: state.trendingItems!.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              TrendingEntity model = state.trendingItems![index];
              return _buildTrendingItem(model);
            },
            separatorBuilder: (context, index) => const SizedBox(width: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingItem(TrendingEntity model) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        Widget widget = const SizedBox();

        if (model.type == 'playlist') {
          context.read<PlaylistBloc>().add(
            PlaylistFetch(id: model.id!, type: 'remote'),
          );
          widget = const PlaylistScreen();
        } else if (model.type == 'album') {
          context.read<AlbumProvider>().setAlbum(model.id!);
          widget = const AlbumScreen();
        } else if (model.type == 'song') {
          context.read<SongDetailsBloc>().add(
            SongDetailsFetch(songId: model.id!),
          );
          widget = const SongDetailsScreen(showFirstSong: true);
        }
        Navigator.push(
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
                  imageUrl: model.image!.excellent,
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
                // blur: 5,
                // color: context.scheme.surface.withValues(alpha: .6),
                // borderRadius: const BorderRadius.vertical(
                //   top: Radius.circular(10),
                //   bottom: Radius.circular(10),
                // ),
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
                      _buildText(
                        model.title!,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                      _buildText(
                        model.type!,
                        fontSize: 8,
                        maxLines: 1,
                        textAlign: TextAlign.center,
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

  Widget _buildForYouSection() {
    return BlocBuilder<ForyouBloc, ForyouState>(
      builder: (context, state) {
        if (state is ForyouInitial) {
          return _buildForYouShimmer();
        } else if (state is ForyouFetched) {
          return _buildForYouCard(state);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildForYouShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: MasonryGridView.builder(
        itemCount: 8,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        itemBuilder: (context, index) {
          return MyShimmer(
            child: Container(
              height: index == 1 ? 220 : 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: context.primary,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForYouCard(ForyouFetched state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: MasonryGridView.builder(
        itemCount: state.forYouItems!.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        itemBuilder: (context, index) {
          ForYouEntity model = state.forYouItems![index];
          return _buildForYouItem(model, index);
        },
      ),
    );
  }

  Widget _buildForYouItem(ForYouEntity model, int index) {
    return CachedNetworkImage(
      imageUrl: model.image!.excellent,
      imageBuilder: (context, imageProvider) {
        return Container(
          height: index == 1 ? 220 : 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(fit: BoxFit.cover, image: imageProvider),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black54,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  Widget widget = const SizedBox();
                  if (model.type == 'album') {
                    context.read<AlbumProvider>().setAlbum(model.id!);
                    widget = const AlbumScreen();
                  } else if (model.type == 'song') {
                    context.read<SongDetailsBloc>().add(
                      SongDetailsFetch(songId: model.id!),
                    );
                    widget = const SongDetailsScreen(showFirstSong: true);
                  } else {
                    return;
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
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        model.title!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      placeholder:
          (context, url) => Container(
            height: index == 1 ? 220 : 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: const DecorationImage(image: AssetImage(Media.logo)),
            ),
          ),
    );
  }

  Widget _buildSearchSongShimmer() {
    return ListView.separated(
      itemCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return MyShimmer(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                _buildShimmerContainer(40, 40, 10),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildShimmerContainer(170, 14, 10),
                      const SizedBox(height: 5),
                      _buildShimmerContainer(100, 10, 10),
                    ],
                  ),
                ),
                _buildShimmerContainer(5, 25, 10),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const Gap(10),
    );
  }

  Widget _buildSearchPlaylistShimmer() {
    return ListView.separated(
      itemCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return MyShimmer(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                _buildShimmerContainer(70, 70, 10),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildShimmerContainer(170, 14, 10),
                      const SizedBox(height: 5),
                      _buildShimmerContainer(100, 10, 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const Gap(10),
    );
  }

  Widget _buildSearchAlbumShimmer() {
    return ListView.separated(
      itemCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return MyShimmer(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                _buildShimmerContainer(60, 60, 10),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildShimmerContainer(170, 14, 10),
                      const SizedBox(height: 5),
                      _buildShimmerContainer(100, 10, 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const Gap(10),
    );
  }

  Widget _buildSearchArtistShimmer() {
    return ListView.separated(
      itemCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return MyShimmer(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                CircleAvatar(radius: 35, backgroundColor: context.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildShimmerContainer(170, 14, 10),
                      const SizedBox(height: 5),
                      _buildShimmerContainer(100, 10, 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => const Gap(10),
    );
  }

  Widget _buildShimmerContainer(double width, double height, double radius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: context.primary,
      ),
    );
  }
}
