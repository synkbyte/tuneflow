import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/common/providers/player_provider.dart';
import 'package:new_tuneflow/core/common/providers/room_provider.dart';
import 'package:new_tuneflow/core/common/singletones/cache.dart';
import 'package:new_tuneflow/core/common/widget/buttons.dart';
import 'package:new_tuneflow/core/common/widget/like_button.dart';
import 'package:new_tuneflow/core/common/widget/loading.dart';
import 'package:new_tuneflow/core/common/widget/more_vert_song_button.dart';
import 'package:new_tuneflow/core/common/widget/name_with_batch.dart';
import 'package:new_tuneflow/core/constants/constants.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/res/media.dart';
import 'package:new_tuneflow/core/utils/function.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/src/artist_details/presentation/bloc/artist_details_bloc.dart';
import 'package:new_tuneflow/src/artist_details/presentation/screens/artist_details.dart';
import 'package:new_tuneflow/src/player/presentation/screens/chats.dart';
import 'package:new_tuneflow/src/player/presentation/screens/lyrics_screen.dart';
import 'package:new_tuneflow/src/player/presentation/screens/room_users.dart';
import 'package:new_tuneflow/src/player/presentation/widget/artist_bottom_sheet.dart';
import 'package:new_tuneflow/src/player/presentation/widget/more_details_bottom_sheet.dart';
import 'package:new_tuneflow/src/player/presentation/widget/slider.dart';
import 'package:new_tuneflow/src/song/presentation/bloc/song_details_bloc.dart';
import 'package:new_tuneflow/src/song/presentation/screens/songs.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:ticker_text/ticker_text.dart';
import 'package:url_launcher/url_launcher.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlayerProvider>(context);

    if (provider.isInitiating) {
      return const LoadingWidget();
    }

    return Stack(
      children: [
        const VerticalPageView(),
        TopBar(model: provider.nowPlaying!),
        if (provider.isLoading)
          GestureDetector(
            onTap: () {
              provider.togglePlayer();
            },
            child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: context.scheme.primaryContainer.withValues(
                        alpha: 00.6,
                      ),
                      boxShadow: const [
                        BoxShadow(blurRadius: 10, color: Colors.black12),
                      ],
                    ),
                    child: Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                        color: context.scheme.onPrimaryContainer,
                        size: 25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (!provider.isLoading && !provider.isPlaying)
          GestureDetector(
            onTap: () {
              provider.togglePlayer();
            },
            child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: context.scheme.primaryContainer.withValues(
                        alpha: 00.6,
                      ),
                      boxShadow: const [
                        BoxShadow(blurRadius: 10, color: Colors.black12),
                      ],
                    ),
                    child: const Icon(Icons.play_arrow, size: 30),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class VerticalPageView extends StatelessWidget {
  const VerticalPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlayerProvider>(context);

    // void showLikeAnimation(TapDownDetails details) {
    //   final overlay = Overlay.of(context);
    //   final RenderBox box = context.findRenderObject() as RenderBox;
    //   final Offset position = box.localToGlobal(details.localPosition);

    //   final heartOverlay = OverlayEntry(
    //     builder: (context) => LikeAnimation(position: position),
    //   );

    //   overlay.insert(heartOverlay);

    //   Future.delayed(const Duration(milliseconds: 700), () {
    //     heartOverlay.remove();
    //   });
    // }

    return GestureDetector(
      onTap: () {
        provider.togglePlayer();
      },
      // onDoubleTapDown: (details) {
      //   showLikeAnimation(details);
      // },
      child: SizedBox(
        child: PageView.builder(
          controller: provider.controller,
          itemCount: provider.playingList.length,
          scrollDirection: Axis.vertical,
          physics:
              !roomProvider.hasPermissionToChange && !roomProvider.isHost
                  ? const NeverScrollableScrollPhysics()
                  : null,
          onPageChanged: (value) {
            provider.isUserScrolling = true;
          },
          itemBuilder: (context, index) {
            SongModel song = provider.playingList[index];
            return SongCard(song: song, index: index);
          },
        ),
      ),
    );
  }
}

class SongCard extends StatelessWidget {
  const SongCard({super.key, required this.song, required this.index});
  final SongModel song;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BackgroundImage(song: song),
        SongInfoOverlay(song: song, index: index),
      ],
    );
  }
}

class BackgroundImage extends StatelessWidget {
  const BackgroundImage({super.key, required this.song});
  final SongModel song;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: song.imagesUrl.excellent,
            placeholder: (context, url) {
              return Container(
                height: 500,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(Media.logo),
                  ),
                ),
              );
            },
            imageBuilder: (context, imageProvider) {
              return Container(
                height: 500,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: imageProvider,
                  ),
                ),
              );
            },
          ),
          const GradientOverlay(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          const GradientOverlay(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ],
      ),
    );
  }
}

class GradientOverlay extends StatelessWidget {
  const GradientOverlay({super.key, required this.begin, required this.end});

  final Alignment begin;
  final Alignment end;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 500,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.scheme.surface,
            context.scheme.surface.withValues(alpha: 0.8),
            Colors.transparent,
            Colors.transparent,
            Colors.transparent,
            Colors.transparent,
            Colors.transparent,
          ],
          begin: begin,
          end: end,
        ),
      ),
    );
  }
}

class SongInfoOverlay extends StatelessWidget {
  const SongInfoOverlay({super.key, required this.song, required this.index});
  final SongModel song;
  final int index;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlayerProvider>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {},
          child: Container(
            color: context.bgColor.withValues(alpha: .01),
            alignment: Alignment.bottomCenter,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(child: SongInfo(song: song)),
                      const SizedBox(width: 20),
                      SongActions(song: song),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 15, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatDuration(provider.currentDuration),
                        style: const TextStyle(fontSize: 10),
                      ),
                      Text(
                        formatDuration(provider.totalDuration),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
                Gap(5),
                MusicSliderSection(index: index),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SongInfo extends StatelessWidget {
  const SongInfo({super.key, required this.song});
  final SongModel song;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withValues(alpha: 0.001),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              context.read<SongDetailsBloc>().add(
                SongDetailsFetch(songId: song.id),
              );
              Navigator.push(
                context,
                PageTransition(
                  child: const SongDetailsScreen(),
                  type: PageTransitionType.fade,
                ),
              );
            },
            child: TickerText(
              scrollDirection: Axis.horizontal,
              speed: 20,
              startPauseDuration: const Duration(seconds: 3),
              endPauseDuration: const Duration(seconds: 3),
              returnDuration: const Duration(milliseconds: 10),
              primaryCurve: Curves.linear,
              returnCurve: Curves.easeOut,
              child: Text(
                song.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 5),
          GestureDetector(
            onTap: () {
              if (song.artistMap.length > 1) {
                List<SongArtingModel> artists = song.artistMap;
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return ArtistBottomSheet(artists: artists);
                  },
                );
                return;
              }
              context.read<ArtistDetailsBloc>().add(
                ArtistDetailsFetch(id: song.artistMap.first.id),
              );
              Navigator.push(
                context,
                PageTransition(
                  child: const ArtistDetailsScreen(),
                  type: PageTransitionType.fade,
                ),
              );
            },
            child: Text(
              song.subtitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class SongActions extends StatelessWidget {
  const SongActions({super.key, required this.song});
  final SongModel song;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        LikeButton(song: song),
        IconButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return const MoreDetailsSheet();
              },
            );
          },
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.sort, size: 30, color: context.scheme.onSurface),
              Positioned(
                right: -10,
                bottom: -5,
                child: Icon(
                  Icons.expand_less,
                  size: 30,
                  color: context.scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MusicSliderSection extends StatelessWidget {
  const MusicSliderSection({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlayerProvider>(context);
    return MusicSlider(
      currentDuration:
          provider.playingIndex == index
              ? provider.currentDuration
              : Duration.zero,
      bufferedDuration:
          provider.playingIndex == index
              ? provider.bufferedDuration
              : Duration.zero,
      totalDuration:
          provider.playingIndex == index
              ? provider.totalDuration
              : Duration.zero,
      onChanged: (value) {
        provider.seekPosition(value);
      },
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.model});
  final SongModel model;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RoomProvider>(context);
    return SizedBox(
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 10),
            child: GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  const Text(
                    'Playing Now',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Spacer(),
                  if (provider.isInRoom)
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            child: const RoomUsersList(),
                            type: PageTransitionType.fade,
                          ),
                        );
                      },
                      icon: const Icon(Icons.group_outlined, size: 25),
                    ),
                  const SizedBox(width: 5),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          child: const LyricsScreen(),
                          type: PageTransitionType.fade,
                        ),
                      );
                    },
                    icon: const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(Icons.lyrics_outlined, size: 22),
                    ),
                  ),
                  MoreVertSong(model: model),
                ],
              ),
            ),
          ),
          if (provider.isInRoom) const SizedBox(height: 10),
          if (provider.isInRoom)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    child: const ChatViewScreen(),
                    type: PageTransitionType.fade,
                  ),
                );
              },
              child: Container(
                height: 150,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                color: context.bgColor.withValues(alpha: .01),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: context.primary.withValues(alpha: .2),
                          ),
                        ),
                        const Gap(10),
                        Text(
                          'Tap to begin chatting',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.primary.withValues(alpha: .9),
                          ),
                        ),
                        const Gap(10),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: context.primary.withValues(alpha: .2),
                          ),
                        ),
                      ],
                    ),
                    const Gap(10),
                    Expanded(
                      child: MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: ListView.separated(
                          itemCount: provider.messages.length,
                          reverse: true,
                          itemBuilder: (context, index) {
                            Map message = provider.messages[index];
                            if (message['type'] == 'action') {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: context.scheme.secondary,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    padding: const EdgeInsets.all(5),
                                    child: Text(
                                      message['message'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 9,
                                        color: context.scheme.onSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                            bool isItsMe =
                                message['userId'] == Cache.instance.userId;
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment:
                                  isItsMe
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width - 100,
                                    minWidth: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isItsMe
                                            ? context.scheme.primary.withValues(
                                              alpha: .3,
                                            )
                                            : context.scheme.primaryContainer
                                                .withValues(alpha: .4),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      NameWithBatch(
                                        name: Text(
                                          message['user'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color:
                                                isItsMe
                                                    ? context.scheme.onSurface
                                                    : context
                                                        .scheme
                                                        .onPrimaryContainer,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        size: 15,
                                        batch: message['batch'],
                                      ),
                                      Text(
                                        message['message'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              isItsMe
                                                  ? context.scheme.onSurface
                                                  : context
                                                      .scheme
                                                      .onPrimaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 10);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (!provider.isInRoom && provider.isNewUpdateAvailable)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: context.scheme.primary.withValues(alpha: .1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Expanded(
                        child: Text(
                          'New Update Available!\nEnhance Your Experience',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'A new version of $appName is now available. Update to enjoy the latest features and improvements. Don’t miss out!',
                    style: TextStyle(fontSize: 11),
                  ),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    title: 'Update Now',
                    color: context.scheme.primary,
                    height: 45,
                    fontSize: 14,
                    onPressed: () {
                      launchUrl(
                        Uri.parse(
                          'https://play.google.com/store/apps/details?id=com.tuneflow',
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
