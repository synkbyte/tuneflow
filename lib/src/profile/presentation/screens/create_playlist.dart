// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:new_tuneflow/core/common/app/cache_helper.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/common/providers/playlist_provider.dart';
import 'package:new_tuneflow/core/constants/constants.dart';
import 'package:new_tuneflow/core/services/api_service/app/upload_api_service.dart';
import 'package:new_tuneflow/core/snackbar/snackbar.dart';
import 'package:new_tuneflow/core/utils/function.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:provider/provider.dart';

class CreatePlaylistScreen extends StatefulWidget {
  const CreatePlaylistScreen({
    super.key,
    this.name,
    this.image,
    this.id,
    this.isPublic,
  });
  final String? name;
  final String? image;
  final int? id;
  final bool? isPublic;

  @override
  State<CreatePlaylistScreen> createState() => _CreatePlaylistScreenState();
}

class _CreatePlaylistScreenState extends State<CreatePlaylistScreen> {
  File? image;
  String? imageLink;
  int? id;
  TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();
  bool isLoading = false;
  UploadApiService service = sl();

  bool isPublic = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Future.delayed(Durations.short1);
      focusNode.requestFocus();
      controller.text = widget.name ?? '';
      imageLink = widget.image;
      id = widget.id;
      isPublic = widget.isPublic ?? false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme scheme = Theme.of(context).colorScheme;
    final playlistProvider = Provider.of<PlaylistProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Playlist',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: () async {
                      image = await pickImage();
                      setState(() {});
                    },
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: scheme.onSecondary,
                        borderRadius: BorderRadius.circular(10),
                        image: image == null
                            ? imageLink == null
                                ? const DecorationImage(
                                    fit: BoxFit.cover,
                                    image: AssetImage('assets/images/logo.png'),
                                  )
                                : DecorationImage(
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider(
                                      widget.image!,
                                    ),
                                  )
                            : DecorationImage(
                                fit: BoxFit.cover,
                                image: FileImage(File(image!.path)),
                              ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      height: 35,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scheme.primary,
                      ),
                      child: IconButton(
                        onPressed: () async {
                          image = await pickImage();
                          setState(() {});
                        },
                        icon: Icon(
                          Icons.edit,
                          size: 15,
                          color: scheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: const TextStyle(fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Playlist Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            value: isPublic,
            onChanged: (value) {
              setState(() => isPublic = value);
            },
            title: Text(
              'Allow Public Access',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Anyone can see this playlist and its content on your profile.',
              style: TextStyle(fontSize: 10),
            ),
          ),
          const SizedBox(height: 20),
          if (!isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          border: Border.all(color: scheme.primary, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: scheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        if (controller.text.isEmpty) {
                          errorMessage(context, 'Please enter playlist name');
                          return;
                        }

                        setState(() => isLoading = true);

                        String? imageUrl;
                        if (image != null) {
                          DefaultResponse res = await service.uploadFile(
                            image!.path,
                          );
                          if (res.status) {
                            imageUrl = res.value;
                          }
                        } else if (id != null) {
                          imageUrl = imageLink?.replaceAll(imageBaseUrl, '');
                        }

                        UserPlaylistModel playlist = UserPlaylistModel(
                          id: id ?? 0,
                          userId: await CacheHelper().getUserId(),
                          name: controller.text,
                          image: imageUrl ?? '',
                          songs: const [],
                          isMine: true,
                          playlistId: '',
                          type: 'playlist',
                          isPublic: isPublic,
                        );

                        DefaultResponse response = id != null
                            ? await playlistProvider.updatePlaylist(playlist)
                            : await playlistProvider.createPlaylist(playlist);

                        if (!response.status) {
                          errorMessage(context, response.message);
                          setState(() => isLoading = false);
                          return;
                        }

                        Navigator.pop(context);
                        successMessage(context, response.message);
                      },
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          border: Border.all(color: scheme.primary, width: 2),
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          id != null ? 'Update' : 'Create',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: scheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(),
            )
        ],
      ),
    );
  }
}
