import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/common/singletones/cache.dart';
import 'package:new_tuneflow/core/common/widget/loading.dart';
import 'package:new_tuneflow/core/common/widget/name_with_batch.dart';
import 'package:new_tuneflow/core/config/list_config.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/res/media.dart';
import 'package:new_tuneflow/core/snackbar/snackbar.dart';
import 'package:new_tuneflow/core/utils/core_utils.dart';
import 'package:new_tuneflow/core/utils/function.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/src/chat/presentation/providers/chat_provider.dart';
import 'package:new_tuneflow/src/chat/presentation/screens/chat_view_screen.dart';
import 'package:new_tuneflow/src/other_profile/presentation/providers/other_profile_provider.dart';
import 'package:new_tuneflow/src/other_profile/presentation/screens/follow_data_screen.dart';
import 'package:new_tuneflow/src/playlist/presentation/bloc/playlist_bloc.dart';
import 'package:new_tuneflow/src/playlist/presentation/screens/playlist.dart';
import 'package:new_tuneflow/src/profile/presentation/screens/edit_profile.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class OtherProfile extends StatefulWidget {
  const OtherProfile({super.key});

  @override
  State<OtherProfile> createState() => _OtherProfileState();
}

class _OtherProfileState extends State<OtherProfile> {
  late OtherProfileProvider otherProfileProvider;

  @override
  Widget build(BuildContext context) {
    otherProfileProvider = Provider.of<OtherProfileProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    if (otherProfileProvider.isGetting) {
      return const Scaffold(body: Center(child: LoadingWidget()));
    }

    if (otherProfileProvider.gotError) {
      return Scaffold(
        body: Center(
          child: Text(
            otherProfileProvider.errorMessage,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

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
              Text(
                otherProfileProvider.profile.userNameF!,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const Divider(),
          MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Expanded(
              child: ScrollConfiguration(
                behavior: MyBehavior(),
                child: ListView(
                  children: [
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              showImageViewer(
                                context,
                                CachedNetworkImageProvider(
                                  otherProfileProvider.profile.avatar!,
                                ),
                                useSafeArea: false,
                                swipeDismissible: true,
                                doubleTapZoomable: true,
                              );
                            },
                            child: CachedNetworkImage(
                              imageUrl: otherProfileProvider.profile.avatar!,
                              imageBuilder: (context, imageProvider) {
                                return Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: context.primary,
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: imageProvider,
                                    ),
                                  ),
                                );
                              },
                              placeholder: (context, url) {
                                return Container(
                                  height: 80,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: context.primary,
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: AssetImage(Media.logo),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Gap(5),
                          NameWithBatch(
                            name: Text(
                              otherProfileProvider.profile.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            batch: otherProfileProvider.profile.getBatch(),
                            size: 18,
                          ),
                          Divider(height: 30),
                          Text(
                            otherProfileProvider.profile.bio,
                            style: TextStyle(fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Gap(15),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: context.scheme.primary.withValues(
                                alpha: .1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text(
                                        '${otherProfileProvider.playlists.length}',
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
                                      otherProfileProvider.fetchFollowers(
                                        otherProfileProvider.profile,
                                      );
                                      Navigator.push(
                                        context,
                                        PageTransition(
                                          child: const FollowDataScreen(
                                            selectedIndex: 0,
                                          ),
                                          type: PageTransitionType.fade,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      color: context.scheme.primary.withValues(
                                        alpha: .001,
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            formatFollowersCount(
                                              otherProfileProvider
                                                  .profile
                                                  .followers,
                                            ),
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
                                      otherProfileProvider.fetchFollowers(
                                        otherProfileProvider.profile,
                                      );
                                      Navigator.push(
                                        context,
                                        PageTransition(
                                          child: const FollowDataScreen(
                                            selectedIndex: 1,
                                          ),
                                          type: PageTransitionType.fade,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      color: context.scheme.primary.withValues(
                                        alpha: .001,
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            formatFollowersCount(
                                              otherProfileProvider
                                                  .profile
                                                  .following,
                                            ),
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

                          Gap(15),
                          if (!(otherProfileProvider.profile.id ==
                              Cache.instance.userId))
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      otherProfileProvider.toggleFollow();
                                    },
                                    child: Container(
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color:
                                            otherProfileProvider.followedByMe
                                                ? null
                                                : context.primary,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: context.primary,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        otherProfileProvider.followedByMe
                                            ? 'Unfollow'
                                            : 'Follow',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              otherProfileProvider.followedByMe
                                                  ? context.primary
                                                  : context.scheme.onPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Gap(10),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (!audioHandler.isSocketIsConnect) {
                                        errorMessage(
                                          context,
                                          'This feature is temporarily disabled',
                                        );
                                        return;
                                      }

                                      chatProvider.getChatById(
                                        0,
                                        otherProfileProvider.profile.toJson(),
                                        friendId:
                                            otherProfileProvider.profile.id,
                                      );
                                      Navigator.push(
                                        context,
                                        PageTransition(
                                          child: const ChatViewScreen(),
                                          type: PageTransitionType.fade,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color:
                                            !otherProfileProvider.followedByMe
                                                ? null
                                                : context.primary,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: context.primary,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Message',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color:
                                              !otherProfileProvider.followedByMe
                                                  ? context.primary
                                                  : context.scheme.onPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    child: const UpdateProfile(),
                                    type: PageTransitionType.bottomToTop,
                                  ),
                                );
                              },
                              child: Container(
                                alignment: Alignment.center,
                                height: 45,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: context.scheme.primary.withValues(
                                    alpha: .2,
                                  ),
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
                          Gap(15),
                          Text(
                            'Playlists',
                            style: GoogleFonts.dekko(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Gap(5),
                          if (otherProfileProvider.playlists.isEmpty)
                            Text(
                              'Looks like ${getFirstName(otherProfileProvider.profile.name)} hasn’t created any playlists yet. Stay tuned for their music collection!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: context.onBgColor.withValues(alpha: .7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                    if (otherProfileProvider.playlists.isNotEmpty)
                      ListView.builder(
                        itemCount: otherProfileProvider.playlists.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          UserPlaylistModel model =
                              otherProfileProvider.playlists[index];
                          return InkWell(
                            onTap: () {
                              if (model.isMine) {
                                context.read<PlaylistBloc>().add(
                                  PlaylistFetch(
                                    id: model.playlistId,
                                    type: 'localSecond',
                                    playlist: model,
                                    user: otherProfileProvider.profile,
                                  ),
                                );
                              } else {
                                context.read<PlaylistBloc>().add(
                                  PlaylistFetch(
                                    id: model.playlistId,
                                    type: 'remote',
                                  ),
                                );
                              }
                              Navigator.push(
                                context,
                                PageTransition(
                                  child: const PlaylistScreen(),
                                  type: PageTransitionType.fade,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 10,
                                bottom: 5,
                                top: 5,
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
                                        image: CachedNetworkImageProvider(
                                          model.image,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          model.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Playlist',
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
