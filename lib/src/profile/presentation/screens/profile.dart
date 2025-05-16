import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/common/providers/artist_provider.dart';
import 'package:new_tuneflow/core/common/providers/downloads_provider.dart';
import 'package:new_tuneflow/core/common/providers/player_provider.dart';
import 'package:new_tuneflow/core/common/providers/playlist_provider.dart';
import 'package:new_tuneflow/core/common/providers/profile_provider.dart';
import 'package:new_tuneflow/core/common/singletones/cache.dart';
import 'package:new_tuneflow/core/common/singletones/user.dart';
import 'package:new_tuneflow/core/common/widget/modern_text.dart';
import 'package:new_tuneflow/core/common/widget/more_vert_song_button.dart';
import 'package:new_tuneflow/core/common/widget/welcome_app_bar.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/res/media.dart';
import 'package:new_tuneflow/core/snackbar/snackbar.dart';
import 'package:new_tuneflow/core/utils/core_utils.dart';
import 'package:new_tuneflow/core/utils/function.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/src/album/data/models/album_model.dart';
import 'package:new_tuneflow/src/album/domain/entites/album_entity.dart';
import 'package:new_tuneflow/src/album/presentation/provider/album_provider.dart';
import 'package:new_tuneflow/src/album/presentation/screens/album.dart';
import 'package:new_tuneflow/src/artist_details/presentation/bloc/artist_details_bloc.dart';
import 'package:new_tuneflow/src/artist_details/presentation/screens/artist_details.dart';
import 'package:new_tuneflow/src/auth/presentation/bloc/artist_bloc.dart';
import 'package:new_tuneflow/src/auth/presentation/screens/select_artist.dart';
import 'package:new_tuneflow/src/other_profile/presentation/providers/other_profile_provider.dart';
import 'package:new_tuneflow/src/other_profile/presentation/screens/follow_data_screen.dart';
import 'package:new_tuneflow/src/playlist/data/models/playlist_model.dart';
import 'package:new_tuneflow/src/playlist/domain/entites/playlist_entity.dart';
import 'package:new_tuneflow/src/playlist/presentation/bloc/playlist_bloc.dart';
import 'package:new_tuneflow/src/playlist/presentation/screens/playlist.dart';
import 'package:new_tuneflow/src/profile/presentation/screens/create_playlist.dart';
import 'package:new_tuneflow/src/profile/presentation/screens/edit_profile.dart';
import 'package:new_tuneflow/src/profile/presentation/screens/premium.dart';
import 'package:new_tuneflow/src/profile/presentation/widget/album_sheet.dart';
import 'package:new_tuneflow/src/profile/presentation/widget/playlist_sheet.dart';
import 'package:new_tuneflow/src/settings/screens/settings.dart';
import 'package:page_transition/page_transition.dart';
import 'package:parallax_animation/parallax_area.dart';
import 'package:parallax_animation/parallax_widget.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileProvider profileProvider;
  late PlaylistProvider playlistProvider;
  late OtherProfileProvider otherProfileProvider;

  @override
  Widget build(BuildContext context) {
    profileProvider = Provider.of<ProfileProvider>(context);
    final artistProvider = Provider.of<ArtistProvider>(context);
    playlistProvider = Provider.of<PlaylistProvider>(context);
    final downloadsProvider = Provider.of<DownloadsProvider>(context);
    final playerProvider = Provider.of<PlayerProvider>(context);
    otherProfileProvider = Provider.of<OtherProfileProvider>(context);

    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).padding.top),
        WelcomeAppBar(title: 'Profile'),
        MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: Expanded(
            child: ListView(
              children: [
                Column(
                  children: [
                    _buildProfileHeader(context),
                    const SizedBox(height: 15),
                    _buildActionButtons(context),
                    const SizedBox(height: 10),
                    const Divider(height: 0),
                    _buildNavigationButtons(context),
                    const Divider(height: 0),
                    if (profileProvider.selectedIndex == 0)
                      _buildPlaylistTab(context, playlistProvider),
                    if (profileProvider.selectedIndex == 1)
                      _buildArtistTab(context, artistProvider),
                    if (profileProvider.selectedIndex == 2)
                      if (downloadsProvider.userDownloads.isEmpty &&
                          downloadsProvider.userDownloadsPlaylist.isEmpty &&
                          downloadsProvider.downloadingNowPlaylist.isEmpty &&
                          downloadsProvider.downloadingNow.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              'Downloads is empty',
                              style: TextStyle(
                                color: context.scheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      else
                        _buildDownloadTab(
                          context,
                          playerProvider,
                          downloadsProvider,
                        ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _buildProfileHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(10),
          Text(
            User.instance.user!.bio,
            style: TextStyle(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Gap(15),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: context.scheme.primary.withValues(alpha: .1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${playlistProvider.playlists.where((element) => element.isPublic).toList().length}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      Gap(5),
                      Text(
                        'Playlists',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      otherProfileProvider.fetchFollowers(User.instance.user!);
                      Navigator.push(
                        context,
                        PageTransition(
                          child: const FollowDataScreen(selectedIndex: 0),
                          type: PageTransitionType.fade,
                        ),
                      );
                    },
                    child: Container(
                      color: context.scheme.primary.withValues(alpha: .001),
                      child: Column(
                        children: [
                          Text(
                            formatFollowersCount(User.instance.user!.followers),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          Gap(5),
                          Text(
                            'Followers',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      otherProfileProvider.fetchFollowers(User.instance.user!);
                      Navigator.push(
                        context,
                        PageTransition(
                          child: const FollowDataScreen(selectedIndex: 1),
                          type: PageTransitionType.fade,
                        ),
                      );
                    },
                    child: Container(
                      color: context.scheme.primary.withValues(alpha: .001),
                      child: Column(
                        children: [
                          Text(
                            formatFollowersCount(User.instance.user!.following),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          Gap(5),
                          Text(
                            'Following',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
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
        ],
      ),
    );
  }

  _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    child: const UpdateProfile(),
                    type: PageTransitionType.fade,
                  ),
                );
              },
              child: Container(
                alignment: Alignment.center,
                height: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: context.scheme.primary.withValues(alpha: .2),
                ),
                child: Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.scheme.primary,
                  ),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageTransition(
                  child: const SettingsScreen(),
                  type: PageTransitionType.fade,
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(left: 10),
              height: 45,
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: context.scheme.primary.withValues(alpha: .2),
              ),
              child: Icon(
                Icons.settings,
                color: context.scheme.primary,
                size: 20,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageTransition(
                  child: const PremiumScreen(),
                  type: PageTransitionType.fade,
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(left: 10),
              height: 45,
              width: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: context.scheme.secondaryContainer,
              ),
              child: Icon(
                Icons.diamond_outlined,
                color: context.scheme.onPrimaryContainer,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildNavigationButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ModernText(
            text: 'Play-lists',
            isActive: profileProvider.selectedIndex == 0,
            onPressed: () {
              setState(() => profileProvider.selectedIndex = 0);
            },
          ),
          ModernText(
            text: 'Art-ists',
            isActive: profileProvider.selectedIndex == 1,
            onPressed: () {
              setState(() => profileProvider.selectedIndex = 1);
            },
          ),
          ModernText(
            text: 'Down-loads',
            isActive: profileProvider.selectedIndex == 2,
            onPressed: () {
              setState(() => profileProvider.selectedIndex = 2);
            },
          ),
          // ModernText(
          //   text: 'Lo-cal',
          //   isActive: profileProvider.selectedIndex == 3,
          //   onPressed: () {
          //     setState(() => profileProvider.selectedIndex = 3);
          //   },
          // ),
        ],
      ),
    );
  }

  _buildCreateNewPlaylistWidget(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageTransition(
            child: const CreatePlaylistScreen(),
            type: PageTransitionType.fade,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.only(left: 20, right: 10, top: 5, bottom: 5),
        child: Row(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: context.scheme.onSecondary,
              ),
              child: Icon(Icons.add, color: context.scheme.secondary),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('a new playlist', style: TextStyle(fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildLikedPlaylistWidget(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<PlaylistBloc>().add(
          const PlaylistFetch(id: '0', type: 'favorite'),
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
        padding: const EdgeInsets.only(left: 20, right: 10, bottom: 5, top: 5),
        child: Row(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: context.scheme.onPrimary,
              ),
              child: Icon(Icons.favorite, color: context.scheme.primary),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Liked Songs',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('Default', style: TextStyle(fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildRecentPlaylistWidget(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<PlaylistBloc>().add(
          const PlaylistFetch(id: '0', type: 'recent'),
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
        padding: const EdgeInsets.only(left: 20, right: 10, bottom: 5, top: 5),
        child: Row(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: context.scheme.secondaryContainer,
              ),
              child: Icon(
                Icons.history,
                color: context.scheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Played',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('Default', style: TextStyle(fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildArtistWidget(BuildContext context, ArtistModel artist) {
    return InkWell(
      onTap: () {
        context.read<ArtistDetailsBloc>().add(
          ArtistDetailsFetch(id: artist.id),
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundImage: CachedNetworkImageProvider(artist.image.good),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artist.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text('Artist', style: TextStyle(fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildPlaylistTab(BuildContext context, PlaylistProvider provider) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildCreateNewPlaylistWidget(context),
        _buildLikedPlaylistWidget(context),
        _buildRecentPlaylistWidget(context),
        ParallaxArea(
          child: ListView.builder(
            itemCount: provider.playlists.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              UserPlaylistModel model = provider.playlists[index];
              return _buildPlaylistWidget(context, model);
            },
          ),
        ),
      ],
    );
  }

  _buildPlaylistWidget(BuildContext context, UserPlaylistModel model) {
    return InkWell(
      onTap: () {
        Widget widget = const SizedBox();

        if (model.type == 'playlist') {
          if (model.isMine) {
            context.read<PlaylistBloc>().add(
              PlaylistFetch(
                id: model.playlistId,
                type: 'local',
                playlist: model,
              ),
            );
            widget = const PlaylistScreen();
          } else {
            context.read<PlaylistBloc>().add(
              PlaylistFetch(id: model.playlistId, type: 'remote'),
            );
            widget = const PlaylistScreen();
          }
        } else if (model.type == 'album') {
          context.read<AlbumProvider>().setAlbum(model.playlistId);
          widget = const AlbumScreen();
        }
        Navigator.push(
          context,
          PageTransition(child: widget, type: PageTransitionType.fade),
        );
      },
      child: Container(
        padding: const EdgeInsets.only(left: 20, right: 10, bottom: 5, top: 5),
        child: Row(
          children: [
            if (model.isMine || model.type != 'playlist')
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: context.scheme.secondaryContainer,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(model.image),
                  ),
                ),
              )
            else
              _buildParallaxImage(model.image, 60),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    capitalizeFirstLetter(model.type),
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return PlaylistSheet(model: model);
                  },
                );
              },
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
    );
  }

  _buildPlaylistWidgetDownloading(
    BuildContext context,
    PlaylistEntity model,
    double progress,
  ) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.only(
            left: 20,
            right: 10,
            bottom: 5,
            top: 5,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  isActive(playerProvider, 'downloadedPlaylist', null, model.id)
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
          child: Row(
            children: [
              if (model.type == 'local')
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: context.scheme.secondaryContainer,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(model.image),
                    ),
                  ),
                )
              else
                _buildParallaxImage(model.image, 60),
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
                            (playerProvider.playingModel.type ==
                                        PlayingType.downloadedPlaylist &&
                                    playerProvider.playingModel.id == model.id)
                                ? context.primary
                                : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Playlist',
                      style: TextStyle(
                        fontSize: 10,
                        color:
                            (playerProvider.playingModel.type ==
                                        PlayingType.downloadedPlaylist &&
                                    playerProvider.playingModel.id == model.id)
                                ? context.primary
                                : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          color: context.scheme.error.withValues(alpha: .4),
          padding: const EdgeInsets.only(
            left: 20,
            right: 10,
            top: 10,
            bottom: 10,
          ),
          width: (MediaQuery.of(context).size.width) * (progress / 100),
          child: Container(height: 55),
        ),
      ],
    );
  }

  _buildPlaylistWidgetDownloded(BuildContext context, PlaylistEntity model) {
    return InkWell(
      onTap: () {
        context.read<PlaylistBloc>().add(
          PlaylistFetch(
            id: model.id,
            type: 'downloaded',
            playlist: UserPlaylistModel(
              id: 0,
              userId: Cache.instance.userId,
              name: model.title,
              image: model.image,
              songs: model.songs,
              isMine: false,
              playlistId: model.id,
              type: 'downloaded',
              isPublic: false,
            ),
          ),
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
        padding: const EdgeInsets.only(left: 20, right: 10, bottom: 5, top: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isActive(playerProvider, 'downloadedPlaylist', null, model.id)
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
        child: Row(
          children: [
            if (model.type == 'local')
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: context.scheme.secondaryContainer,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(model.image),
                  ),
                ),
              )
            else
              _buildParallaxImage(model.image, 60),
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
                          (playerProvider.playingModel.type ==
                                      PlayingType.downloadedPlaylist &&
                                  playerProvider.playingModel.id == model.id)
                              ? context.primary
                              : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Playlist',
                    style: TextStyle(
                      fontSize: 10,
                      color:
                          (playerProvider.playingModel.type ==
                                      PlayingType.downloadedPlaylist &&
                                  playerProvider.playingModel.id == model.id)
                              ? context.primary
                              : null,
                    ),
                  ),
                ],
              ),
            ),
            if (!(playerProvider.playingModel.type ==
                    PlayingType.downloadedPlaylist &&
                playerProvider.playingModel.id == model.id))
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return PlaylistSheetDownloaded(model: model);
                    },
                  );
                },
                icon: const Icon(Icons.more_vert),
              ),
          ],
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

  _buildDownloadingAlbum(
    BuildContext context,
    AlbumEntity model,
    double progress,
  ) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.only(
            left: 20,
            right: 10,
            bottom: 5,
            top: 5,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  isActive(playerProvider, 'downloadedPlaylist', null, model.id)
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
          child: Row(
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: context.scheme.secondaryContainer,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(model.image.good),
                  ),
                ),
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
                            (playerProvider.playingModel.type ==
                                        PlayingType.downloadedPlaylist &&
                                    playerProvider.playingModel.id == model.id)
                                ? context.primary
                                : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Album',
                      style: TextStyle(
                        fontSize: 10,
                        color:
                            (playerProvider.playingModel.type ==
                                        PlayingType.downloadedPlaylist &&
                                    playerProvider.playingModel.id == model.id)
                                ? context.primary
                                : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          color: context.scheme.error.withValues(alpha: .4),
          padding: const EdgeInsets.only(
            left: 20,
            right: 10,
            top: 10,
            bottom: 10,
          ),
          width: (MediaQuery.of(context).size.width) * (progress / 100),
          child: Container(height: 55),
        ),
      ],
    );
  }

  _buildAlbumDownloded(BuildContext context, AlbumModel model) {
    return InkWell(
      onTap: () {
        context.read<AlbumProvider>().setAlbum(model.id);
        Navigator.push(
          context,
          PageTransition(
            child: const AlbumScreen(isLocal: true),
            type: PageTransitionType.fade,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.only(left: 20, right: 10, bottom: 5, top: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isActive(playerProvider, 'downloadedAlbum', null, model.id)
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
        child: Row(
          children: [
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: context.scheme.secondaryContainer,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(model.image.good),
                ),
              ),
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
                          (playerProvider.playingModel.type ==
                                      PlayingType.downloadedPlaylist &&
                                  playerProvider.playingModel.id == model.id)
                              ? context.primary
                              : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Album',
                    style: TextStyle(
                      fontSize: 10,
                      color:
                          (playerProvider.playingModel.type ==
                                      PlayingType.downloadedPlaylist &&
                                  playerProvider.playingModel.id == model.id)
                              ? context.primary
                              : null,
                    ),
                  ),
                ],
              ),
            ),
            if (!(playerProvider.playingModel.type ==
                    PlayingType.downloadedPlaylist &&
                playerProvider.playingModel.id == model.id))
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return AlbumSheetDownloaded(model: model);
                    },
                  );
                },
                icon: const Icon(Icons.more_vert),
              ),
          ],
        ),
      ),
    );
  }

  _buildArtistTab(BuildContext context, ArtistProvider artistProvider) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: artistProvider.savedArtists.length + 1,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (index == 0) {
          return InkWell(
            onTap: () {
              context.read<ArtistBloc>().add(ArtistGetTop());
              Navigator.push(
                context,
                PageTransition(
                  child: const SelectArtistScreen(isNewUser: false),
                  type: PageTransitionType.fade,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: context.scheme.secondaryContainer,
                    child: Icon(
                      Icons.add,
                      size: 30,
                      color: context.scheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expand Your List',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Add more artists to your collection.',
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return _buildArtistWidget(
          context,
          artistProvider.savedArtists[index - 1],
        );
      },
    );
  }

  _buildDownloadTab(
    BuildContext context,
    PlayerProvider playerProvider,
    DownloadsProvider downloadsProvider,
  ) {
    return Column(
      children: [
        const SizedBox(height: 10),
        if (downloadsProvider.userDownloads.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (roomProvider.isInRoom) {
                        errorMessage(
                          context,
                          'Offline songs can\'t be played in rooms.',
                        );
                        return;
                      }
                      List<SongModel> shuffled = List.from(
                        downloadsProvider.userDownloads,
                      );
                      shuffled.shuffle();

                      playerProvider.startPlaying(
                        source: shuffled,
                        i: 0,
                        type: PlayingType.download,
                        id: '1',
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
                      if (roomProvider.isInRoom) {
                        errorMessage(
                          context,
                          'Offline songs can\'t be played in rooms.',
                        );
                        return;
                      }
                      if (isActive(playerProvider, 'download', null, '1')) {
                        playerProvider.togglePlayer();
                      } else {
                        playerProvider.startPlaying(
                          source: downloadsProvider.userDownloads,
                          i: 0,
                          type: PlayingType.download,
                          id: '1',
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
                            isActive(playerProvider, 'download', null, '1') &&
                                    playerProvider.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: context.scheme.onPrimary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isActive(playerProvider, 'download', null, '1') &&
                                    playerProvider.isPlaying
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
        const SizedBox(height: 10),
        ParallaxArea(
          child: ListView.builder(
            itemCount: downloadsProvider.downloadingNowPlaylist.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              PlaylistEntity model =
                  downloadsProvider.downloadingNowPlaylist[index];
              return _buildPlaylistWidgetDownloading(
                context,
                model,
                downloadsProvider.downloadingPercentagePlaylist[model.id]!,
              );
            },
          ),
        ),
        if (downloadsProvider.downloadingNowPlaylist.isNotEmpty)
          const SizedBox(height: 10),
        ListView.builder(
          itemCount: downloadsProvider.downloadingNowAlbum.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            AlbumEntity model = downloadsProvider.downloadingNowAlbum[index];
            double progress =
                downloadsProvider.downloadingPercentageAlbum[model.id] ?? 0.0;
            return _buildDownloadingAlbum(context, model, progress);
          },
        ),
        if (downloadsProvider.downloadingNow.isNotEmpty)
          const SizedBox(height: 10),
        ListView.builder(
          itemCount: downloadsProvider.downloadingNow.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            SongModel model = downloadsProvider.downloadingNow[index];
            double progress =
                downloadsProvider.downloadingPercentage[model.id] ?? 0.0;
            return _buildDownloadingSongCardWidget(
              context,
              index,
              model,
              playerProvider,
              downloadsProvider.userDownloads,
              progress,
            );
          },
        ),
        if (downloadsProvider.downloadingNow.isNotEmpty)
          const SizedBox(height: 10),
        ParallaxArea(
          child: ListView.builder(
            itemCount: downloadsProvider.currentUserDown.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              Map details = downloadsProvider.currentUserDown[index];
              if (details['type'] == 'song') {
                SongModel model = SongModel.fromJson(
                  downloadsProvider.currentUserDown[index]['song'],
                );
                return _buildSongCardWidget(
                  context,
                  index,
                  model,
                  playerProvider,
                  downloadsProvider.userDownloads,
                );
              }
              if (details['type'] == 'album') {
                AlbumModel model = AlbumModel.fromJson(
                  downloadsProvider.currentUserDown[index]['song'],
                );
                return _buildAlbumDownloded(context, model);
              }
              PlaylistModel model = PlaylistModel.fromJson(
                downloadsProvider.currentUserDown[index]['song'],
              );
              return _buildPlaylistWidgetDownloded(context, model);
            },
          ),
        ),
      ],
    );
  }

  _buildDownloadingSongCardWidget(
    BuildContext context,
    int index,
    SongModel model,
    PlayerProvider provider,
    List<SongModel> songs,
    double progress,
  ) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  isActive(provider, 'download', model.id, '1')
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
              onTap: () {},
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
                                  isActive(provider, 'download', model.id, null)
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
                                  isActive(provider, 'download', model.id, null)
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
        ),
        Container(
          color: context.scheme.error.withValues(alpha: .4),
          padding: const EdgeInsets.only(
            left: 20,
            right: 10,
            top: 10,
            bottom: 10,
          ),
          width: (MediaQuery.of(context).size.width) * (progress / 100),
          child: Container(height: 55),
        ),
      ],
    );
  }

  _buildSongCardWidget(
    BuildContext context,
    int index,
    SongModel model,
    PlayerProvider provider,
    List<SongModel> songs,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isActive(provider, 'download', model.id, '1')
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
          onTap: () async {
            if (roomProvider.isInRoom) {
              errorMessage(context, 'Offline songs can\'t be played in rooms.');
              return;
            }
            if (isActive(provider, 'download', model.id, '1')) {
              !provider.isPlaying ? provider.togglePlayer() : null;
              return;
            }
            provider.startPlaying(
              source: songs,
              i: index,
              type: PlayingType.download,
              id: '1',
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
                              isActive(provider, 'download', model.id, null)
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
                              isActive(provider, 'download', model.id, null)
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
