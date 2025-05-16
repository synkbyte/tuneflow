import 'dart:async';

import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/common/providers/banner_provider.dart';
import 'package:new_tuneflow/core/common/providers/room_provider.dart';
import 'package:new_tuneflow/core/common/singletones/user.dart';
import 'package:new_tuneflow/core/common/widget/name_with_batch.dart';
import 'package:new_tuneflow/core/common/widget/premium_cards.dart';
import 'package:new_tuneflow/core/common/widget/social_card.dart';
import 'package:new_tuneflow/core/common/widget/welcome_app_bar.dart';
import 'package:new_tuneflow/core/constants/constants.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/res/media.dart';
import 'package:new_tuneflow/core/services/api_service/deep_link/deep_link_api_service.dart';
import 'package:new_tuneflow/core/snackbar/snackbar.dart';
import 'package:new_tuneflow/core/utils/core_utils.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/src/other_profile/presentation/providers/other_profile_provider.dart';
import 'package:new_tuneflow/src/other_profile/presentation/screens/other_profile.dart';
import 'package:new_tuneflow/src/social/presentation/providers/social_provider.dart';
import 'package:new_tuneflow/src/social/presentation/screens/leaderboard_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  TextEditingController controller = TextEditingController();
  bool isLoading = false;

  PageController bannerController = PageController();
  int currentBannerIndex = 0;
  Timer? _timer;
  void startAutoScroll(int total) {
    if (_timer != null) return;
    _timer = Timer.periodic(Duration(seconds: 10), (Timer timer) {
      if (!mounted) return;
      if (bannerController.positions.isEmpty) return;
      setState(() {
        currentBannerIndex = (currentBannerIndex + 1) % total;
      });
      bannerController.animateToPage(
        currentBannerIndex,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    controller.dispose();
    bannerController.dispose();
  }

  PageController socialCard = PageController();
  int socialCardIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RoomProvider>(context);
    final otherProvider = Provider.of<OtherProfileProvider>(context);
    final socialProvider = Provider.of<SocialProvider>(context);

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top),
            WelcomeAppBar(title: 'TuneHub'),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                removeBottom: true,
                child: ListView(
                  children: [
                    if (roomProvider.isInRoom)
                      _buildAlreadyInRoomWidget()
                    else
                      _buildRoomActionButtonWidget(),
                    if (User.instance.user != null &&
                        !(User.instance.user?.isPremium ?? false))
                      _buildRoomLeftWidget(),
                    _buildBannerWidget(),
                    if (provider.popRooms.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Popular Rooms',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(height: 45),
                          ],
                        ),
                      ),
                    if (provider.popRooms.isNotEmpty)
                      Container(
                        height: 110,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ListView.separated(
                          itemCount: provider.popRooms.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, i) {
                            RoomModel model = provider.popRooms[i];
                            return InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () {
                                if (provider.isInRoom) {
                                  errorMessage(
                                    context,
                                    'You are already in a room. Please leave the current room to join another.',
                                  );
                                  return;
                                }
                                if (!provider.isInRoom &&
                                    !audioHandler.isLoading) {
                                  audioHandler.joinRoom(model.roomId);
                                }
                              },
                              child: BlurryContainer(
                                blur: 5,
                                color: context.scheme.surface.withValues(
                                  alpha: .5,
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(10),
                                  bottom: Radius.circular(10),
                                ),
                                padding: EdgeInsets.zero,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: context.scheme.primary.withValues(
                                      alpha: .1,
                                    ),
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(10),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          const Text(
                                            'Created By: ',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          NameWithBatch(
                                            name: Text(
                                              model.creator,
                                              style: const TextStyle(
                                                fontSize: 10,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            size: 12,
                                            topPadding: 1,
                                            batch: model.batch,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        '${model.usersCount} People Listing together.',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          CachedNetworkImage(
                                            imageUrl: model.creatorAvatar,
                                            imageBuilder: (
                                              context,
                                              imageProvider,
                                            ) {
                                              return CircleAvatar(
                                                radius: 15,
                                                backgroundImage: imageProvider,
                                              );
                                            },
                                            placeholder: (context, url) {
                                              return const CircleAvatar(
                                                radius: 15,
                                                backgroundImage: AssetImage(
                                                  Media.logo,
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 5),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 5,
                                            ),
                                            child: Text(model.creatorUserName),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return const SizedBox(width: 10);
                          },
                        ),
                      ),
                    if (socialProvider.batchedUsers.isNotEmpty)
                      Column(
                        children: [
                          SizedBox(height: 10),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Pro Members',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            height: 70,
                            child: ListView.separated(
                              itemCount: socialProvider.batchedUsers.length,
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              itemBuilder: (context, index) {
                                Map model = socialProvider.batchedUsers[index];
                                return GestureDetector(
                                  onTap: () {
                                    otherProvider.fetchProfile(model['id']);
                                    Navigator.push(
                                      context,
                                      PageTransition(
                                        child: const OtherProfile(),
                                        type: PageTransitionType.fade,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: context.scheme.primary.withValues(
                                        alpha: .2,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl:
                                              '$imageBaseUrl${model['avatar']}',
                                          imageBuilder: (
                                            context,
                                            imageProvider,
                                          ) {
                                            return Container(
                                              height: 50,
                                              width: 50,
                                              decoration: BoxDecoration(
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
                                              height: 50,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: AssetImage(Media.logo),
                                                ),
                                              ),
                                            );
                                          },
                                        ),

                                        Gap(10),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            NameWithBatch(
                                              name: Text(
                                                model['name'],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              batch: model,
                                              size: 15,
                                              topPadding: 1,
                                            ),
                                            Text(
                                              model['userName'],
                                              style: TextStyle(fontSize: 10),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return const Gap(10);
                              },
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    _buildSocialCards(),
                    if (socialProvider.leaderboards.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Vibe Masters',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    child: const LeaderboardScreen(),
                                    type: PageTransitionType.fade,
                                  ),
                                );
                              },
                              icon: Row(
                                children: [
                                  Text(
                                    'Top 10',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: context.primary,
                                    ),
                                  ),
                                  Gap(2),
                                  Icon(
                                    Icons.trending_flat,
                                    color: context.primary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (socialProvider.leaderboards.isNotEmpty)
                      ListView.builder(
                        itemCount:
                            socialProvider.leaderboards.length > 3
                                ? 3
                                : socialProvider.leaderboards.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          Map data = socialProvider.leaderboards[index];
                          return InkWell(
                            onTap: () {
                              otherProvider.fetchProfile(data['id']);
                              Navigator.push(
                                context,
                                PageTransition(
                                  child: const OtherProfile(),
                                  type: PageTransitionType.fade,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: '$imageBaseUrl${data['avatar']}',
                                    imageBuilder: (context, imageProvider) {
                                      return Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: context.primary,
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: imageProvider,
                                          ),
                                        ),
                                      );
                                    },
                                    placeholder: (context, url) {
                                      return Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: context.primary,
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: AssetImage(Media.logo),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  Gap(10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        NameWithBatch(
                                          name: Text(
                                            data['name'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          batch: data,
                                        ),
                                        Text(
                                          '${data['songCount']} Tunes Enjoyed',
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios, size: 12),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    const Gap(5),
                    if (socialProvider.leaderboards.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const Text(
                              'Invite your friends',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const Text(
                              'Copy download link, share with your friends',
                              style: TextStyle(fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/images/8596248.jpg',
                                height: 150,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    FlutterClipboard.copy(
                                      '''🎶 Discover $appName! 🎶
        
        $appName is a fantastic music app where you can explore new tracks, create playlists, and enjoy your favorite music like never before. It’s the perfect place for all your music needs!
        
        Tap the link below to download $appName and start your musical journey:
        
        $playStoreLink
        
        🎧 Dive into the rhythm with $appName! 🎵
        ''',
                                    );
                                  },
                                  child: const Text(
                                    'Copy link',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Share.share('''🎶 Discover $appName! 🎶
        
        $appName is a fantastic music app where you can explore new tracks, create playlists, and enjoy your favorite music like never before. It’s the perfect place for all your music needs!
        
        Tap the link below to download $appName and start your musical journey:
        
        $playStoreLink
        
        🎧 Dive into the rhythm with $appName! 🎵
        ''');
                                  },
                                  child: const Text(
                                    'Invite',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (audioHandler.isLoading)
          Container(
            color: context.scheme.primaryContainer.withValues(alpha: .5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: CircularProgressIndicator(
                    color: context.scheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  _buildRoomLeftWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap(10),
        Center(
          child: Text(
            '${User.instance.user?.leftRoomCredits ?? 0} Room Creation Credits Left \n(Free Tier - Monthly Limit)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color:
                  (User.instance.user?.leftRoomCredits ?? 0) <= 2
                      ? context.scheme.error
                      : null,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Gap(10),
        const Divider(height: 0),
        Gap(10),
      ],
    );
  }

  _buildBannerWidget() {
    return Consumer<BannerProvider>(
      builder: (context, provider, child) {
        if (provider.socialBanners.isEmpty) {
          return SizedBox();
        }
        startAutoScroll(provider.socialBanners.length);
        return Column(
          children: [
            Gap(10),
            Stack(
              children: [
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    controller: bannerController,
                    itemCount: provider.socialBanners.length,
                    onPageChanged: (value) {
                      setState(() {
                        currentBannerIndex = value;
                      });
                    },
                    itemBuilder: (context, index) {
                      Map model = provider.socialBanners[index];
                      if (model['type'] == 'premium') {
                        return PremiumCard();
                      }
                      return GestureDetector(
                        onTap: () {
                          provider.clickedOnBanner(model['id']);
                          launchUrl(Uri.parse(model['navigation']));
                        },
                        child: CachedNetworkImage(
                          imageUrl: 'https://evatech.in/img/ad2.png',
                          imageBuilder: (context, imageProvider) {
                            return Container(
                              height: 200,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: context.scheme.secondary.withValues(
                                  alpha: .4,
                                ),
                                image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: CachedNetworkImageProvider(
                                    'https://evatech.in/img/ad2.png',
                                  ),
                                ),
                              ),
                            );
                          },
                          placeholder: (context, url) {
                            return Container(
                              height: 200,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: context.scheme.secondary.withValues(
                                  alpha: .4,
                                ),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage(Media.logo),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 5,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: context.scheme.primaryContainer.withValues(
                            alpha: 0.8,
                          ),
                        ),
                        child: Row(
                          children: List.generate(
                            provider.socialBanners.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 5,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              width: currentBannerIndex == index ? 15 : 5,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color:
                                    currentBannerIndex == index
                                        ? context.scheme.primary
                                        : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Gap(10),
          ],
        );
      },
    );
  }

  _buildRoomActionButtonWidget() {
    return Column(
      children: [
        const Gap(15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: context.scheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (!audioHandler.isSocketIsConnect) {
                          errorMessage(
                            context,
                            'This feature is temporarily disabled',
                          );
                          return;
                        }
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Center(
                                child: Text(
                                  'Choose room type',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'If you choose the "Private" option, only users with the specific room ID will be able to join the room. This room will not be visible to any unknown users.',
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          if (isActive(
                                            playerProvider,
                                            'download',
                                            null,
                                            '1',
                                          )) {
                                            errorMessage(
                                              context,
                                              'Offline songs can\'t be played in rooms.',
                                            );
                                            return;
                                          }
                                          roomProvider.insertPayload(
                                            playerProvider.playingList
                                                .map((e) => e.toJson())
                                                .toList(),
                                            playerProvider.playingIndex,
                                            true,
                                          );
                                          audioHandler.createRoom();
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          'Private',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          if (isActive(
                                            playerProvider,
                                            'download',
                                            null,
                                            '1',
                                          )) {
                                            errorMessage(
                                              context,
                                              'Offline songs can\'t be played in rooms.',
                                            );
                                            return;
                                          }
                                          roomProvider.insertPayload(
                                            playerProvider.playingList
                                                .map((e) => e.toJson())
                                                .toList(),
                                            playerProvider.playingIndex,
                                            false,
                                          );
                                          audioHandler.createRoom();
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          'Public',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Container(
                                  //   height: 50,
                                  //   decoration: BoxDecoration(
                                  //     borderRadius: BorderRadius.circular(10),
                                  //     color: context.primary,
                                  //   ),
                                  //   child: Material(
                                  //     color: Colors.transparent,
                                  //     child: InkWell(
                                  //       borderRadius: BorderRadius.circular(10),
                                  //       onTap: () {
                                  //       },
                                  //       child: Container(
                                  //         height: 50,
                                  //         alignment: Alignment.center,
                                  //         child: Text(
                                  //           'VIP',
                                  //           style: TextStyle(
                                  //             fontSize: 16,
                                  //             fontWeight: FontWeight.bold,
                                  //             color: context.scheme.onPrimary,
                                  //           ),
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 45,
                        alignment: Alignment.center,
                        child: Text(
                          'Create Room',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: context.scheme.onPrimary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (!audioHandler.isSocketIsConnect) {
                      errorMessage(
                        context,
                        'This feature is temporarily disabled',
                      );
                      return;
                    }
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Center(child: Text('Enter room id')),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: controller,
                                decoration: const InputDecoration(
                                  labelText: 'Room ID',
                                ),
                              ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () {
                                  if (controller.text.isEmpty) {
                                    Fluttertoast.showToast(
                                      msg: 'Enter room id',
                                    );
                                    return;
                                  }
                                  if (roomProvider.isInRoom) {
                                    errorMessage(
                                      context,
                                      'You\'r already in a room',
                                    );
                                    return;
                                  }
                                  audioHandler.joinRoom(controller.text);
                                  Navigator.pop(context);
                                  controller.clear();
                                },
                                child: Container(
                                  height: 45,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: context.scheme.primary,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Join',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: context.scheme.onPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      border: Border.all(color: context.scheme.primary),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Join Room',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: context.scheme.primary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(15),
        Divider(height: 0),
      ],
    );
  }

  _buildSocialCards() {
    return Column(
      children: [
        SizedBox(
          height: 145,
          child: PageView.builder(
            controller: socialCard,
            itemCount: socialCardContent.length,
            onPageChanged: (value) {
              setState(() => socialCardIndex = value);
            },
            itemBuilder: (context, index) {
              Map content = socialCardContent[index];
              return SocialCard(
                title: content['title'],
                des: content['des'],
                url: content['link'],
              );
            },
          ),
        ),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(socialCardContent.length, (index) {
              return AnimatedContainer(
                height: 5,
                width: socialCardIndex == index ? 15 : 5,
                duration: Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color:
                      socialCardIndex == index
                          ? context.scheme.primary
                          : context.onBgColor.withValues(alpha: .7),
                ),
              );
            }),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  _buildAlreadyInRoomWidget() {
    return Column(
      children: [
        Gap(10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: InkWell(
            onTap: () async {
              Fluttertoast.cancel();
              Fluttertoast.showToast(msg: 'Please wait!');
              String message = '';
              DeepLinkApiService service = sl();
              String generated = await service.createDefferLink(
                'https://room.tuneflow.info?type=join&id=${roomProvider.roomId}',
              );
              if (generated.isNotEmpty) {
                message = '''🎶 Join My $appName Room! 🎶
        
        Hey! I’ve created a music room on $appName, and I’d love for you to join in on the fun. Just tap the link below to enter the room and vibe with me!
        $generated
        🎧 Let’s vibe to some great music together! 🎵''';
              } else {
                message = '''🎶 Join My $appName Room! 🎶
        
        Hey! I’ve created a music room on $appName, and I’d love for you to join in on the fun. Use the Room ID below to enter and enjoy the beats with me!
        
        Room ID: ${roomProvider.roomId}
        
        Join the Room on $appName
        https://play.google.com/store/apps/details?id=com.tuneflow
        
        🎧 Let’s vibe to some great music together! 🎵''';
              }

              Share.share(message);
            },
            borderRadius: BorderRadius.circular(10),
            child: Column(
              children: [
                Text(
                  'Joined Room ID: ${roomProvider.roomId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                Text(
                  'Tap to share',
                  style: TextStyle(fontSize: 12, color: context.scheme.primary),
                ),
              ],
            ),
          ),
        ),
        Gap(10),
        Divider(height: 0),
      ],
    );
  }
}
