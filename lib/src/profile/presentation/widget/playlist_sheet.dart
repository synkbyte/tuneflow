import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/common/providers/downloads_provider.dart';
import 'package:new_tuneflow/core/common/providers/playlist_provider.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/res/media.dart';
import 'package:new_tuneflow/core/utils/function.dart';
import 'package:new_tuneflow/src/playlist/domain/entites/playlist_entity.dart';
import 'package:new_tuneflow/src/profile/presentation/screens/create_playlist.dart';
import 'package:page_transition/page_transition.dart';
import 'package:parallax_animation/parallax_area.dart';
import 'package:parallax_animation/parallax_widget.dart';
import 'package:provider/provider.dart';

class PlaylistSheet extends StatelessWidget {
  const PlaylistSheet({super.key, required this.model});
  final UserPlaylistModel model;

  @override
  Widget build(BuildContext context) {
    final playlistProvider = Provider.of<PlaylistProvider>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height,
        minHeight: 100,
      ),
      child: ParallaxArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                if (model.isMine || model.type != 'playlist')
                  CachedNetworkImage(
                    imageUrl: model.image,
                    imageBuilder: (context, imageProvider) {
                      return Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: CachedNetworkImageProvider(model.image),
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
                            image: AssetImage(
                              'assets/images/logo.png',
                            ),
                          ),
                        ),
                      );
                    },
                  )
                else
                  _buildParallaxImage(model.image, 45),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        capitalizeFirstLetter(model.type),
                        style: const TextStyle(
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // LikeButton(song: widget.model),
              ],
            ),
            const Divider(),
            if (model.isMine)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.edit,
                ),
                title: const Text(
                  'Edit Playlist',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    PageTransition(
                      child: CreatePlaylistScreen(
                        id: model.id,
                        image: model.image,
                        name: model.name,
                        isPublic: model.isPublic,
                      ),
                      type: PageTransitionType.fade,
                    ),
                  );
                },
              ),
            // ListTile(
            //   contentPadding: EdgeInsets.zero,
            //   leading: const Icon(Icons.share),
            //   title: const Text(
            //     'Share',
            //     style: TextStyle(
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            //   onTap: () {
            //     Navigator.pop(context);
            //   },
            // ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.delete_forever_outlined,
                color: context.scheme.error,
              ),
              title: Text(
                'Delete ${capitalizeFirstLetter(model.type)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.scheme.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Center(
                        child: Text(
                          'Are you sure?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Want to delete "${model.name}" ${capitalizeFirstLetter(model.type)}.',
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  Fluttertoast.showToast(msg: 'Deleting...');
                                  Navigator.pop(context);
                                  playlistProvider.deletePlaylist(model.id);
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
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildParallaxImage(String imageUrl, double size) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: ParallaxWidget(
          overflowWidthFactor: 1,
          background: Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          ),
          child: SizedBox(height: size, width: size),
        ),
      ),
      placeholder: (context, url) => Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: const DecorationImage(image: AssetImage(Media.logo)),
        ),
      ),
    );
  }
}

class PlaylistSheetDownloaded extends StatelessWidget {
  const PlaylistSheetDownloaded({super.key, required this.model});
  final PlaylistEntity model;

  @override
  Widget build(BuildContext context) {
    final downloadsProvider = Provider.of<DownloadsProvider>(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height,
        minHeight: 100,
      ),
      child: ParallaxArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                if (model.type == 'local')
                  CachedNetworkImage(
                    imageUrl: model.image,
                    imageBuilder: (context, imageProvider) {
                      return Container(
                        height: 45,
                        width: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: CachedNetworkImageProvider(model.image),
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
                            image: AssetImage(
                              'assets/images/logo.png',
                            ),
                          ),
                        ),
                      );
                    },
                  )
                else
                  _buildParallaxImage(model.image, 45),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        model.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'Playlist',
                        style: TextStyle(
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.delete_forever_outlined,
                color: context.scheme.error,
              ),
              title: Text(
                'Delete From Downloads',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.scheme.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Center(
                        child: Text(
                          'Are you sure?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Want to delete "${model.title}" Playlist from Downloads.',
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  Fluttertoast.showToast(msg: 'Deleting...');
                                  Navigator.pop(context);
                                  downloadsProvider.deletePlaylist(model);
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
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildParallaxImage(String imageUrl, double size) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: ParallaxWidget(
          overflowWidthFactor: 1,
          background: Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          ),
          child: SizedBox(height: size, width: size),
        ),
      ),
      placeholder: (context, url) => Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: const DecorationImage(image: AssetImage(Media.logo)),
        ),
      ),
    );
  }
}
