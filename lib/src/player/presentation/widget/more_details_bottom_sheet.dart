import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ionicons/ionicons.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/common/providers/downloads_provider.dart';
import 'package:new_tuneflow/core/common/providers/player_provider.dart';
import 'package:new_tuneflow/core/common/providers/user_provider.dart';
import 'package:new_tuneflow/core/common/widget/like_button.dart';
import 'package:new_tuneflow/core/common/widget/more_vert_song_button.dart';
import 'package:new_tuneflow/core/res/media.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:provider/provider.dart';

class MoreDetailsSheet extends StatefulWidget {
  const MoreDetailsSheet({super.key});

  @override
  State<MoreDetailsSheet> createState() => _MoreDetailsSheetState();
}

class _MoreDetailsSheetState extends State<MoreDetailsSheet> {
  Timer? timer;
  int i = 0;
  runDots() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (i < 4) {
        i++;
      } else {
        i = 0;
      }
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    runDots();
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlayerProvider>(context);
    final downloadProvider = Provider.of<DownloadsProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height / 1.5, minHeight: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text('Playing now'),
              const Spacer(),
              if (!downloadProvider.isDownloading(provider.nowPlaying!.id))
                IconButton(
                  onPressed: () {
                    if (!downloadProvider.isDownloaded(provider.nowPlaying!)) {
                      downloadProvider.downloadFile(
                        provider.nowPlaying!,
                        userProvider.userModel!,
                      );
                    }
                  },
                  icon: Icon(
                    downloadProvider.isDownloaded(provider.nowPlaying!)
                        ? Ionicons.cloud_done_outline
                        : Ionicons.cloud_download_outline,
                    size: 25,
                  ),
                )
              else if (downloadProvider.isDownloading(provider.nowPlaying!.id))
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    4,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      height: 6,
                      width: 6,
                      margin: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: i > index
                            ? scheme.primary
                            : scheme.primary.withValues(alpha: .2),
                      ),
                    ),
                  ),
                ),
              if (!roomProvider.isInRoom)
                IconButton(
                  onPressed: () {
                    Fluttertoast.cancel();
                    if (provider.repeatMode == AudioServiceRepeatMode.one) {
                      provider.changeLoopMode(
                        AudioServiceRepeatMode.all,
                      );
                      Fluttertoast.showToast(msg: 'Playlist loop');
                    } else {
                      provider.changeLoopMode(
                        AudioServiceRepeatMode.one,
                      );
                      Fluttertoast.showToast(msg: 'Single loop');
                    }
                  },
                  icon: provider.repeatMode != AudioServiceRepeatMode.one
                      ? const Icon(
                          Ionicons.repeat_outline,
                          size: 30,
                        )
                      : Image.asset(
                          Media.repeatOne,
                          height: 24,
                          color: scheme.onSurface,
                        ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              CachedNetworkImage(
                imageUrl: provider.nowPlaying!.imagesUrl.good,
                imageBuilder: (context, imageProvider) {
                  return Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: imageProvider,
                      ),
                    ),
                  );
                },
                placeholder: (context, url) {
                  return Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                        image: AssetImage(Media.logo),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.nowPlaying!.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      provider.nowPlaying!.subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              LikeButton(song: provider.nowPlaying!),
            ],
          ),
          const Divider(),
          if (provider.getNextFiveOrRemaining().isNotEmpty)
            const Text(
              'Up Next',
            ),
          if (provider.getNextFiveOrRemaining().isNotEmpty)
            const SizedBox(
              height: 10,
            ),
          if (provider.getNextFiveOrRemaining().isNotEmpty)
            Flexible(
              child: ListView.builder(
                controller: controller,
                itemCount: provider.getNextFiveOrRemaining().length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  SongModel song = provider.getNextFiveOrRemaining()[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      Navigator.pop(context);
                      provider.changeToIndex(
                        provider.playingList.indexOf(song),
                      );
                      if (controller.positions.isNotEmpty) {
                        controller.jumpTo(0);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          CachedNetworkImage(
                            imageUrl: song.imagesUrl.good,
                            imageBuilder: (context, imageProvider) {
                              return Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: imageProvider,
                                  ),
                                ),
                              );
                            },
                            placeholder: (context, url) {
                              return Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: const DecorationImage(
                                    image: AssetImage(Media.logo),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  song.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  song.subtitle,
                                  style: const TextStyle(
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          MoreVertSong(model: song),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
