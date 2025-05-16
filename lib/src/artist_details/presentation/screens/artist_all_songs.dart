import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/common/providers/player_provider.dart';
import 'package:new_tuneflow/core/common/widget/more_vert_song_button.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/res/media.dart';
import 'package:new_tuneflow/core/utils/core_utils.dart';
import 'package:new_tuneflow/src/artist_details/presentation/providers/artist_provider.dart';
import 'package:provider/provider.dart';

class ArtistAllSongs extends StatefulWidget {
  const ArtistAllSongs({super.key});

  @override
  State<ArtistAllSongs> createState() => _ArtistAllSongsState();
}

class _ArtistAllSongsState extends State<ArtistAllSongs> {
  ScrollController scrollController = ScrollController();
  late ArtistModel artist;
  late ArtistSongsProvider artistSongsProvider;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() async {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent) {
      if (!artistSongsProvider.isLastPage &&
          artistSongsProvider.songs.isNotEmpty) {
        artistSongsProvider.artistAllSongs(
          artistId: artistSongsProvider.artistId,
          page: artistSongsProvider.currentPage + 1,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    artistSongsProvider = Provider.of<ArtistSongsProvider>(context);
    final provider = Provider.of<PlayerProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          Row(
            children: [
              const Gap(10),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.keyboard_backspace),
              ),
              Expanded(
                child: Text(
                  artistSongsProvider.artistName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      List<SongModel> source = List.from(
                        artistSongsProvider.songs,
                      );
                      source.removeAt(0);
                      List<SongModel> shuffled = List.from(source);
                      shuffled.shuffle();
                      provider.startPlaying(
                        source: shuffled,
                        i: 0,
                        type: PlayingType.artist,
                        id: artistSongsProvider.artistId,
                      );
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: context.scheme.primary.withValues(alpha: .5),
                      ),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shuffle_outlined, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Shuffle',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (isActive(
                        provider,
                        'artist',
                        null,
                        artistSongsProvider.artistId,
                      )) {
                        provider.togglePlayer();
                      } else {
                        provider.startPlaying(
                          source: artistSongsProvider.songs,
                          i: 0,
                          type: PlayingType.artist,
                          id: artistSongsProvider.artistId,
                        );
                      }
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: context.scheme.primary,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isActive(
                                      provider,
                                      'artist',
                                      null,
                                      artistSongsProvider.artistId,
                                    ) &&
                                    provider.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: context.scheme.onPrimary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isActive(
                                      provider,
                                      'artist',
                                      null,
                                      artistSongsProvider.artistId,
                                    ) &&
                                    provider.isPlaying
                                ? 'Pause'
                                : 'Play',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: context.scheme.onPrimary,
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
          SizedBox(height: 10),
          MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  ListView.builder(
                    itemCount: artistSongsProvider.songs.length + 1,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      if (index == (artistSongsProvider.songs.length)) {
                        if (artistSongsProvider.isLastPage) return SizedBox();
                        return Center(child: CircularProgressIndicator());
                      }
                      SongModel model = artistSongsProvider.songs[index];
                      return _buildSongCardWidget(
                        context,
                        index,
                        model,
                        provider,
                        artistSongsProvider.artistId,
                        artistSongsProvider.songs,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
}
