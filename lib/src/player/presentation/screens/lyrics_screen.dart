import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/common/providers/player_provider.dart';
import 'package:new_tuneflow/core/common/widget/buttons.dart';
import 'package:new_tuneflow/core/common/widget/like_button.dart';
import 'package:new_tuneflow/core/common/widget/more_vert_song_button.dart';
import 'package:new_tuneflow/core/error/lyrics_error.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/utils/function.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/src/player/presentation/bloc/lyrics_bloc.dart';
import 'package:new_tuneflow/src/player/presentation/widget/slider.dart';
import 'package:provider/provider.dart';

class LyricsScreen extends StatefulWidget {
  const LyricsScreen({super.key});

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlayerProvider>(context);
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: LyricsBackground(
              url: provider.nowPlaying!.imagesUrl.excellent,
            ),
          ),
          const LyricsBottomSection(),
        ],
      ),
    );
  }
}

class LyricsBackground extends StatelessWidget {
  final String url;

  const LyricsBackground({required this.url, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: CachedNetworkImageProvider(url),
        ),
      ),
      child: Container(
        color: context.bgColor.withValues(alpha: .9),
        child: Column(
          children: [
            SizedBox(),
            SizedBox(height: MediaQuery.of(context).padding.top),
            const LyricsHeader(),
            const SizedBox(height: 20),
            const LyricsText(),
          ],
        ),
      ),
    );
  }
}

class LyricsHeader extends StatelessWidget {
  const LyricsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlayerProvider>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const CircleBackButton(),
        const Text('Lyrics', style: TextStyle(fontWeight: FontWeight.bold)),
        MoreVertSong(model: provider.nowPlaying!),
      ],
    );
  }
}

class LyricsText extends StatelessWidget {
  const LyricsText({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LyricsBloc, LyricsState>(
      builder: (context, state) {
        if (state is LyricsLoading) {
          return const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: CircularProgressIndicator()),
                Gap(10),
                Text('Please wait...'),
              ],
            ),
          );
        }

        if (state is LyricsError) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lyrics Unavailable😔',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                  Text(LyricsErrors.lyricsNotAvailable),
                  const Row(),
                ],
              ),
            ),
          );
        }

        if (state is LyricsLoaded) {
          return Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeBottom: true,
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      state.lyricsEntity!.lyrics.replaceAll('<br>', '\n'),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: CircularProgressIndicator()),
              Gap(10),
              Text('Please wait...'),
            ],
          ),
        );
      },
    );
  }
}

class LyricsBottomSection extends StatelessWidget {
  const LyricsBottomSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlayerProvider>(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(color: context.bgColor),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 5, right: 10),
            child: Row(
              children: [
                AlbumArt(url: provider.nowPlaying!.imagesUrl.good),
                const SizedBox(width: 10),
                Expanded(child: SongDetails(song: provider.nowPlaying!)),
                LikeButton(song: provider.nowPlaying!),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const MusicSliderSection(),
          const SizedBox(height: 5),
          const MusicDuration(),
          const SizedBox(height: 10),
          const PlaybackControls(),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class AlbumArt extends StatelessWidget {
  final String url;

  const AlbumArt({required this.url, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      width: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: CachedNetworkImageProvider(url),
        ),
      ),
    );
  }
}

class SongDetails extends StatelessWidget {
  const SongDetails({super.key, required this.song});
  final SongModel song;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          song.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          song.subtitle,
          style: const TextStyle(fontSize: 10),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class MusicSliderSection extends StatelessWidget {
  const MusicSliderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlayerProvider>(context);
    return MusicSlider(
      currentDuration: provider.currentDuration,
      bufferedDuration: provider.bufferedDuration,
      totalDuration: provider.totalDuration,
      onChanged: (value) {
        provider.seekPosition(value);
      },
    );
  }
}

class MusicDuration extends StatelessWidget {
  const MusicDuration({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlayerProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
    );
  }
}

class PlaybackControls extends StatelessWidget {
  const PlaybackControls({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlayerProvider>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {
            if (provider.currentDuration < const Duration(seconds: 10)) {
              provider.seekPosition(const Duration(seconds: 0));
              return;
            }
            provider.seekPosition(
              provider.currentDuration - const Duration(seconds: 10),
            );
          },
          icon: Icon(
            Icons.replay_10,
            size: 22,
            color:
                audioHandler.audioPlayer.hasPrevious
                    ? null
                    : context.scheme.outline,
          ),
        ),
        IconButton(
          onPressed: () {
            if (audioHandler.audioPlayer.hasPrevious) {
              provider.changeTrack(false);
            }
          },
          icon: Icon(
            Icons.skip_previous_outlined,
            size: 35,
            color:
                audioHandler.audioPlayer.hasPrevious
                    ? null
                    : context.scheme.outline,
          ),
        ),
        GestureDetector(
          onTap: () {
            provider.togglePlayer();
          },
          child: Container(
            height: 65,
            width: 65,
            decoration: BoxDecoration(
              color: context.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child:
                provider.isLoading
                    ? CircularProgressIndicator(color: context.scheme.onPrimary)
                    : Icon(
                      audioHandler.audioPlayer.playing
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: context.scheme.onPrimary,
                    ),
          ),
        ),
        IconButton(
          onPressed: () {
            if (audioHandler.audioPlayer.hasNext) {
              provider.changeTrack(true);
            }
          },
          icon: Icon(
            Icons.skip_next_outlined,
            size: 35,
            color:
                audioHandler.audioPlayer.hasNext
                    ? null
                    : context.scheme.outline,
          ),
        ),
        IconButton(
          onPressed: () {
            if (provider.currentDuration + const Duration(seconds: 10) >
                provider.totalDuration) {
              provider.seekPosition(provider.totalDuration);
              return;
            }
            provider.seekPosition(
              provider.currentDuration + const Duration(seconds: 10),
            );
          },
          icon: Icon(
            Icons.forward_10,
            size: 22,
            color:
                audioHandler.audioPlayer.hasPrevious
                    ? null
                    : context.scheme.outline,
          ),
        ),
      ],
    );
  }
}
