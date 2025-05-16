import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:new_tuneflow/core/common/app/cache_helper.dart';
import 'package:new_tuneflow/core/common/bloc/state_bloc.dart';
import 'package:new_tuneflow/core/common/providers/state_provider.dart';
import 'package:new_tuneflow/core/common/singletones/user.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/res/media.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/src/auth/presentation/screens/signin.dart';
import 'package:new_tuneflow/src/chat/presentation/providers/chat_provider.dart';
import 'package:new_tuneflow/src/chat/presentation/screens/chat_screen.dart';
import 'package:new_tuneflow/src/explore/presentation/screen/search_people.dart';
import 'package:new_tuneflow/src/forum/presentation/screens/forum_screen.dart';
import 'package:new_tuneflow/src/notification/presentation/screens/notifications.dart';
import 'package:new_tuneflow/src/other_profile/presentation/providers/other_profile_provider.dart';
import 'package:new_tuneflow/src/other_profile/presentation/screens/other_profile.dart';
import 'package:new_tuneflow/src/profile/presentation/screens/premium.dart';
import 'package:new_tuneflow/src/settings/screens/settings.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class ThreedDrawer extends StatefulWidget {
  const ThreedDrawer({super.key});

  @override
  State<ThreedDrawer> createState() => _ThreedDrawerState();
}

class _ThreedDrawerState extends State<ThreedDrawer> {
  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      body: Container(
        alignment: Alignment.centerRight,
        color: context.bgColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 200,
                        height: MediaQuery.of(context).size.height,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).padding.top + 40,
                            ),
                            CachedNetworkImage(
                              imageUrl: User.instance.user!.avatar!,
                              imageBuilder: (context, imageProvider) {
                                return Container(
                                  height: 100,
                                  width: 100,
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
                                  height: 100,
                                  width: 100,
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
                            SizedBox(height: 20),
                            Text(
                              'Hi!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: context.scheme.outline,
                              ),
                            ),
                            Text(
                              User.instance.user!.name.replaceAll(' ', '\n'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: context.primary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 20),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    child: ChatScreen(),
                                    type: PageTransitionType.fade,
                                  ),
                                );
                              },
                              child: SizedBox(
                                height: 45,
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      Media.chat,
                                      colorFilter: ColorFilter.mode(
                                        context.onBgColor,
                                        BlendMode.srcIn,
                                      ),
                                      height: 24,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Chats',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Spacer(),
                                    Badge.count(
                                      count: chatProvider.unreadCount,
                                      isLabelVisible:
                                          chatProvider.unreadCount != 0,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                context
                                    .read<OtherProfileProvider>()
                                    .fetchProfile(User.instance.user!.id);
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    child: OtherProfile(),
                                    type: PageTransitionType.fade,
                                  ),
                                );
                              },
                              child: SizedBox(
                                height: 45,
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      Media.user,
                                      colorFilter: ColorFilter.mode(
                                        context.onBgColor,
                                        BlendMode.srcIn,
                                      ),
                                      height: 24,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Profile',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    child: SettingsScreen(),
                                    type: PageTransitionType.fade,
                                  ),
                                );
                              },
                              child: SizedBox(
                                height: 45,
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      Media.settings,
                                      colorFilter: ColorFilter.mode(
                                        context.onBgColor,
                                        BlendMode.srcIn,
                                      ),
                                      height: 24,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Settings',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    child: ForumScreen(),
                                    type: PageTransitionType.fade,
                                  ),
                                );
                              },
                              child: SizedBox(
                                height: 45,
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      Media.community,
                                      colorFilter: ColorFilter.mode(
                                        context.onBgColor,
                                        BlendMode.srcIn,
                                      ),
                                      height: 24,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Community',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    child: PremiumScreen(),
                                    type: PageTransitionType.fade,
                                  ),
                                );
                              },
                              child: SizedBox(
                                height: 45,
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      Media.premium,
                                      colorFilter: ColorFilter.mode(
                                        context.onBgColor,
                                        BlendMode.srcIn,
                                      ),
                                      height: 24,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Go Premium',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    child: NotificationScreen(),
                                    type: PageTransitionType.fade,
                                  ),
                                );
                              },
                              child: SizedBox(
                                height: 45,
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      Media.bell,
                                      colorFilter: ColorFilter.mode(
                                        context.onBgColor,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Notifications',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    child: SearchPeople(),
                                    type: PageTransitionType.fade,
                                  ),
                                );
                              },
                              child: SizedBox(
                                height: 45,
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      Media.musicLover,
                                      colorFilter: ColorFilter.mode(
                                        context.onBgColor,
                                        BlendMode.srcIn,
                                      ),
                                      height: 24,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Music Lovers',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Center(
                                        child: Text(
                                          'Are You Sure You Want to Log Out?',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'This action will sign you out of your current session. Click \'Logout\' to proceed or \'Cancel\' to return to your session.',
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              TextButton(
                                                onPressed: () {
                                                  context
                                                      .read<StateProvider>()
                                                      .toggleDrawer();
                                                  context.read<StateBloc>().add(
                                                    StateChangeIndex(1),
                                                  );
                                                  audioHandler.stop();
                                                  CacheHelper().resetSession();
                                                  Navigator.pushAndRemoveUntil(
                                                    context,
                                                    PageTransition(
                                                      child:
                                                          const SigninScreen(),
                                                      type:
                                                          PageTransitionType
                                                              .fade,
                                                    ),
                                                    (route) => false,
                                                  );
                                                },
                                                child: Text(
                                                  'Logout',
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
                                                  'Cancel',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
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
                              child: SizedBox(
                                height: 45,
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      Media.logout,
                                      colorFilter: ColorFilter.mode(
                                        context.scheme.error,
                                        BlendMode.srcIn,
                                      ),
                                      height: 24,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Logout',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: context.scheme.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).padding.bottom + 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
