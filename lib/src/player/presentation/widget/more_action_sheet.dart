// ignore_for_file: use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:ionicons/ionicons.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/common/providers/downloads_provider.dart';
import 'package:new_tuneflow/core/common/providers/player_provider.dart';
import 'package:new_tuneflow/core/common/providers/playlist_provider.dart';
import 'package:new_tuneflow/core/common/providers/user_provider.dart';
import 'package:new_tuneflow/core/common/widget/like_button.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/snackbar/snackbar.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/src/equalizer/presentation/providers/equalizer_provider.dart';
import 'package:new_tuneflow/src/equalizer/presentation/screens/equalizer_screen.dart';
import 'package:new_tuneflow/src/player/presentation/screens/audio_clipper_screen.dart';
import 'package:new_tuneflow/src/profile/presentation/screens/create_playlist.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class ShowMoreVert extends StatefulWidget {
  const ShowMoreVert({super.key, required this.model});
  final SongModel model;

  @override
  State<ShowMoreVert> createState() => _ShowMoreVertState();
}

class _ShowMoreVertState extends State<ShowMoreVert> {
  ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final playlistProvider = Provider.of<PlaylistProvider>(context);
    final playerProvider = Provider.of<PlayerProvider>(context);
    final downProvider = Provider.of<DownloadsProvider>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height,
        minHeight: 100,
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              CachedNetworkImage(
                imageUrl: widget.model.imagesUrl.good,
                imageBuilder: (context, imageProvider) {
                  return Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        fit: BoxFit.cover,
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
                        image: AssetImage('assets/images/logo.png'),
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
                      widget.model.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.model.subtitle,
                      style: const TextStyle(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              LikeButton(song: widget.model),
            ],
          ),
          const Divider(),
          if (!roomProvider.isInRoom)
            InkWell(
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return const SpeedSheet();
                  },
                );
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: const Row(
                  children: [
                    Icon(Icons.speed_outlined),
                    SizedBox(width: 20),
                    Text(
                      'Speed',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          InkWell(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                PageTransition(
                  child: EqualizerScreen(),
                  type: PageTransitionType.fade,
                ),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  const Icon(Ionicons.pulse_outline),
                  const SizedBox(width: 20),
                  Text(
                    'Equalizer',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          if (!downProvider.isDownloaded(widget.model))
            InkWell(
              onTap: () {
                Fluttertoast.showToast(msg: 'Downloading');
                downProvider.downloadFile(
                  widget.model,
                  userProvider.userModel!,
                );
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: const Row(
                  children: [
                    Icon(Ionicons.cloud_download_outline, size: 23),
                    SizedBox(width: 20),
                    Text(
                      'Download',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            )
          else
            InkWell(
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Center(
                        child: Text(
                          'Are you sure?',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Want to delete "${widget.model.title}" from Downloads.',
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  downProvider.deleteDownloadedFile(
                                    widget.model,
                                    userProvider.userModel!,
                                  );
                                },
                                child: Text(
                                  'Yes',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: context.scheme.error,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'No',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_forever_outlined,
                      size: 23,
                      color: context.scheme.error,
                    ),
                    const SizedBox(width: 20),
                    Text(
                      'Remove from Downloads',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: context.scheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          InkWell(
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return const ShowSleepTimerSheet();
                },
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.bedtime_outlined),
                  const SizedBox(width: 20),
                  Text(
                    audioHandler.isSleepTimerActive()
                        ? 'Sleep Timer: ${audioHandler.getRemainingTime()!.inMinutes} min left'
                        : 'Sleep Timer',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          if (!roomProvider.isInRoom && playerProvider.isLoaded)
            InkWell(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.fade,
                    child: AudioClipperScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.all_inclusive),
                    const SizedBox(width: 20),
                    const Text(
                      'Duration Loop',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: context.scheme.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Beta',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: context.scheme.onError,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          InkWell(
            onTap: () {
              Navigator.pop(context);
              if (!roomProvider.hasPermissionToChange && !roomProvider.isHost) {
                errorMessage(
                  context,
                  'Hold up! Only the room admin has the player controls. 🎧',
                );
                return;
              }
              audioHandler.addQueueItems([
                widget.model.toMediaItem(
                  playerProvider.playingModel.type == PlayingType.download ||
                      playerProvider.playingModel.type ==
                          PlayingType.downloadedAlbum ||
                      playerProvider.playingModel.type ==
                          PlayingType.downloadedPlaylist,
                ),
              ]);
              Fluttertoast.showToast(msg: 'Added to Queue');
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: const Row(
                children: [
                  Icon(Icons.queue_music),
                  SizedBox(width: 20),
                  Text(
                    'Add to Queue',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.pop(context);
              if (playlistProvider.playlists.isEmpty) {
                Navigator.push(
                  context,
                  PageTransition(
                    child: const CreatePlaylistScreen(),
                    type: PageTransitionType.fade,
                  ),
                );
                return;
              }
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return ShowPlaylistSheet(model: widget.model);
                },
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: const Row(
                children: [
                  Icon(Icons.bookmark_add_outlined),
                  SizedBox(width: 20),
                  Text(
                    'Add to Playlist',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.pop(context);
              if (!roomProvider.hasPermissionToChange && !roomProvider.isHost) {
                errorMessage(
                  context,
                  'Hold up! Only the room admin has the player controls. 🎧',
                );
                return;
              }
              audioHandler.insertQueueItem(
                playerProvider.playingIndex + 1,
                widget.model.toMediaItem(
                  playerProvider.playingModel.type == PlayingType.download ||
                      playerProvider.playingModel.type ==
                          PlayingType.downloadedAlbum ||
                      playerProvider.playingModel.type ==
                          PlayingType.downloadedPlaylist,
                ),
              );
              Fluttertoast.showToast(
                msg: 'Added to queue: Will play after current songs.',
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: const Row(
                children: [
                  Icon(Icons.queue_play_next),
                  SizedBox(width: 20),
                  Text(
                    'Play Next After Queue',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShowPlaylistSheet extends StatefulWidget {
  const ShowPlaylistSheet({super.key, required this.model});
  final SongModel model;

  @override
  State<ShowPlaylistSheet> createState() => _ShowPlaylistSheetState();
}

class _ShowPlaylistSheetState extends State<ShowPlaylistSheet> {
  @override
  Widget build(BuildContext context) {
    final playlistProvider = Provider.of<PlaylistProvider>(context);
    ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                CachedNetworkImage(
                  imageUrl: widget.model.imagesUrl.good,
                  imageBuilder: (context, imageProvider) {
                    return Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(
                            widget.model.imagesUrl.good,
                          ),
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
                          image: AssetImage('assets/images/logo.png'),
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
                        widget.model.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.model.subtitle,
                        style: const TextStyle(fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                LikeButton(song: widget.model),
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Select Playlist',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView.builder(
                itemCount: playlistProvider.playlists.length,
                itemBuilder: (context, index) {
                  UserPlaylistModel model = playlistProvider.playlists[index];
                  if (model.isMine) {
                    return InkWell(
                      onTap: () {
                        if (playlistProvider.isFromThis(
                          model.songs,
                          widget.model,
                        )) {
                          playlistProvider.removeSongFromPlaylist(
                            widget.model,
                            index,
                          );
                        } else {
                          playlistProvider.addSongToPlaylist(
                            widget.model,
                            index,
                          );
                        }
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            CachedNetworkImage(
                              imageUrl: model.image,
                              placeholder: (context, url) {
                                return Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: const DecorationImage(
                                      fit: BoxFit.cover,
                                      image: AssetImage(
                                        'assets/images/logo.png',
                                      ),
                                    ),
                                  ),
                                );
                              },
                              imageBuilder: (context, imageProvider) {
                                return Container(
                                  height: 50,
                                  width: 50,
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
                                    model.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Text(
                                    'Playlist',
                                    style: TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              height: 20,
                              width: 20,
                              decoration: BoxDecoration(
                                color:
                                    playlistProvider.isFromThis(
                                          model.songs,
                                          widget.model,
                                        )
                                        ? scheme.primary
                                        : null,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: scheme.primary),
                              ),
                              child:
                                  !playlistProvider.isFromThis(
                                        model.songs,
                                        widget.model,
                                      )
                                      ? null
                                      : Icon(
                                        Icons.done,
                                        size: 15,
                                        color: scheme.onPrimary,
                                      ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShowSleepTimerSheet extends StatefulWidget {
  const ShowSleepTimerSheet({super.key});

  @override
  State<ShowSleepTimerSheet> createState() => _ShowSleepTimerSheetState();
}

class _ShowSleepTimerSheetState extends State<ShowSleepTimerSheet> {
  List durations = [
    {'lable': '15 Minutes', 'value': const Duration(minutes: 15)},
    {'lable': '30 Minutes', 'value': const Duration(minutes: 30)},
    {'lable': '1 Hour', 'value': const Duration(hours: 1)},
    {'lable': '2 Hour', 'value': const Duration(hours: 2)},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 100,
        maxHeight: MediaQuery.of(context).size.height,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Gap(20),
          const Center(
            child: Text(
              'Sleep Timer',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
          const Gap(10),
          const Divider(),
          const Gap(10),
          for (int i = 0; i < durations.length; i++)
            ListTile(
              onTap: () {
                audioHandler.startSleepTimer(durations[i]['value']);
                Navigator.pop(context);
                successMessage(
                  context,
                  'Sleep timer set for ${durations[i]['lable']}.',
                );
              },
              title: Text(
                durations[i]['lable'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ListTile(
            onTap: () async {
              TimeOfDay selectedDateTime = TimeOfDay.now();
              DateTime now = DateTime.now();

              TimeOfDay? selected = await showTimePicker(
                context: context,
                initialTime: selectedDateTime,
              );
              if (selected != null) {
                DateTime selectedDateTime = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  selected.hour,
                  selected.minute,
                );
                DateTime currentDateTime = DateTime.now();
                Duration difference = selectedDateTime.difference(
                  currentDateTime,
                );
                if (difference.isNegative) {
                  errorMessage(context, 'Please select a future time.');
                  return;
                }
                audioHandler.startSleepTimer(difference);
                successMessage(
                  context,
                  'Sleep timer set for ${difference.inMinutes} Minutes.',
                );
                Navigator.pop(context);
              }
            },
            title: const Text(
              'Custom',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (audioHandler.isSleepTimerActive())
            ListTile(
              onTap: () {
                audioHandler.cancelSleepTimer();
                successMessage(context, 'Sleep timer canceled.');
                Navigator.pop(context);
              },
              title: Text(
                'Cancel sleep timer',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.scheme.error,
                ),
              ),
            ),
          Gap(MediaQuery.of(context).padding.bottom + 20),
        ],
      ),
    );
  }
}

class SpeedSheet extends StatefulWidget {
  const SpeedSheet({super.key});

  @override
  State<SpeedSheet> createState() => _SpeedSheetState();
}

class _SpeedSheetState extends State<SpeedSheet> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EqualizerProvider>(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: 40),
              Text(
                'Playback Speed',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.done,
                    size: 15,
                    color:
                        provider.speedString.contains('Custom')
                            ? null
                            : Colors.transparent,
                  ),
                  title: Text(
                    provider.speedString.contains('Custom')
                        ? provider.speedString
                        : 'Custom (${provider.speed.toStringAsFixed(2)}x)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Slider(
                    min: 0.1,
                    max: 2.0,
                    value: provider.speed,
                    onChanged: (value) {
                      provider.speed = value;
                      provider.speedString =
                          'Custom (${value.toStringAsFixed(2)}x)';
                      setState(() {});
                    },
                    onChangeEnd: (value) {
                      provider.setSpeed();
                    },
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.done,
                    size: 15,
                    color:
                        provider.speedString == '0.25x'
                            ? null
                            : Colors.transparent,
                  ),
                  title: Text(
                    '0.25x',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  onTap: () {
                    provider.speedString = '0.25x';
                    provider.speed = 0.25;
                    provider.setSpeed();
                    setState(() {});
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.done,
                    size: 15,
                    color:
                        provider.speedString == '0.50x'
                            ? null
                            : Colors.transparent,
                  ),
                  title: Text(
                    '0.50x',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  onTap: () {
                    provider.speedString = '0.50x';
                    provider.speed = 0.50;
                    provider.setSpeed();
                    setState(() {});
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.done,
                    size: 15,
                    color:
                        provider.speedString == '0.75x'
                            ? null
                            : Colors.transparent,
                  ),
                  title: Text(
                    '0.75x',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  onTap: () {
                    provider.speedString = '0.75x';
                    provider.speed = 0.75;
                    provider.setSpeed();
                    setState(() {});
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.done,
                    size: 15,
                    color:
                        provider.speedString == '1.0x'
                            ? null
                            : Colors.transparent,
                  ),
                  title: Text(
                    'Normal',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  onTap: () {
                    provider.speedString = '1.0x';
                    provider.speed = 1.0;
                    provider.setSpeed();
                    setState(() {});
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.done,
                    size: 15,
                    color:
                        provider.speedString == '1.25x'
                            ? null
                            : Colors.transparent,
                  ),
                  title: Text(
                    '1.25x',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  onTap: () {
                    provider.speedString = '1.25x';
                    provider.speed = 1.25;
                    provider.setSpeed();
                    setState(() {});
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.done,
                    size: 15,
                    color:
                        provider.speedString == '1.50x'
                            ? null
                            : Colors.transparent,
                  ),
                  title: Text(
                    '1.50x',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  onTap: () {
                    provider.speedString = '1.50x';
                    provider.speed = 1.50;
                    provider.setSpeed();
                    setState(() {});
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.done,
                    size: 15,
                    color:
                        provider.speedString == '1.75x'
                            ? null
                            : Colors.transparent,
                  ),
                  title: Text(
                    '1.75x',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  onTap: () {
                    provider.speedString = '1.75x';
                    provider.speed = 1.75;
                    provider.setSpeed();
                    setState(() {});
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.done,
                    size: 15,
                    color:
                        provider.speedString == '2.00x'
                            ? null
                            : Colors.transparent,
                  ),
                  title: Text(
                    '2x',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  onTap: () {
                    provider.speedString = '2.00x';
                    provider.speed = 2.00;
                    provider.setSpeed();
                    setState(() {});
                  },
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
