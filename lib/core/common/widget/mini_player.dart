import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_seek_bar/circular_seek_bar.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:new_tuneflow/core/common/bloc/state_bloc.dart';
import 'package:new_tuneflow/core/common/providers/player_provider.dart';
import 'package:new_tuneflow/core/common/widget/like_button.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/res/media.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:provider/provider.dart';
import 'package:ticker_text/ticker_text.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);

    if (!playerProvider.isLoaded) {
      return const SizedBox();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 65,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: context.scheme.secondaryContainer,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  context.read<StateBloc>().add(const StateChangeIndex(0));
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: context.scheme.secondaryContainer,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 10),
                    child: Row(
                      children: [
                        CircularSeekBar(
                          width: 50,
                          height: 50,
                          minProgress: 0,
                          maxProgress:
                              (playerProvider.isLoading ||
                                      !playerProvider.isLoaded ||
                                      playerProvider.totalDuration ==
                                          Duration.zero ||
                                      playerProvider
                                              .totalDuration
                                              .inMilliseconds ==
                                          0)
                                  ? 100
                                  : playerProvider.totalDuration.inMilliseconds
                                      .toDouble(),

                          progress:
                              (playerProvider.isLoading ||
                                      !playerProvider.isLoaded ||
                                      playerProvider.currentDuration ==
                                          Duration.zero)
                                  ? 0
                                  : playerProvider
                                      .currentDuration
                                      .inMilliseconds
                                      .toDouble(),
                          animation: false,
                          startAngle: 360,
                          barWidth: 3,
                          progressColor: context.scheme.primary,
                          trackColor: context.scheme.onPrimary,
                          child: Center(
                            child: CachedNetworkImage(
                              imageUrl:
                                  playerProvider
                                      .nowPlaying!
                                      .imagesUrl
                                      .excellent,
                              placeholder: (context, url) {
                                return Container(
                                  height: 45,
                                  width: 45,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: AssetImage(Media.logo),
                                    ),
                                  ),
                                );
                              },
                              imageBuilder: (context, imageProvider) {
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TickerText(
                                scrollDirection: Axis.horizontal,
                                speed: 20,
                                startPauseDuration: const Duration(seconds: 3),
                                endPauseDuration: const Duration(seconds: 3),
                                returnDuration: const Duration(
                                  milliseconds: 10,
                                ),
                                primaryCurve: Curves.linear,
                                returnCurve: Curves.easeOut,
                                child: Text(
                                  playerProvider.nowPlaying?.title ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                playerProvider.nowPlaying?.subtitle ?? '',
                                style: const TextStyle(fontSize: 8),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                                    color: context.scheme.onSurface,
                                    size: 22,
                                  )
                                  : Icon(
                                    playerProvider.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    size: 22,
                                    color: context.onBgColor,
                                  ),
                        ),
                        if (audioHandler.audioPlayer.hasNext)
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
            ],
          ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 5),
      ],
    );
  }
}
