import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:new_tuneflow/core/common/widget/edge_to_edge.dart';
import 'package:new_tuneflow/core/common/widget/name_with_batch.dart';
import 'package:new_tuneflow/core/constants/constants.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/res/media.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/src/forum/presentation/providers/forum_provider.dart';
import 'package:new_tuneflow/src/forum/presentation/screens/post_view.dart';
import 'package:new_tuneflow/src/other_profile/presentation/screens/other_profile.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool hasNotification = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ForumProvider>(context);

    if (provider.notifications.isNotEmpty) {
      return EdgeToEdge(
        child: Scaffold(
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
                    'Notifications',
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
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom,
                    ),
                    child: ListView.builder(
                      itemCount: provider.notifications.length,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemBuilder: (context, index) {
                        Map notification = provider.notifications[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CachedNetworkImage(
                                imageUrl:
                                    '$imageBaseUrl${notification['secondUserDetails']['avatar']}',
                                imageBuilder: (context, imageProvider) {
                                  return Container(
                                    height: 45,
                                    width: 45,
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
                                    height: 45,
                                    width: 45,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: AssetImage(Media.logo),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              if (notification['secondUserDetails']['hasBatch'])
                                Positioned(
                                  right: -7,
                                  bottom: -7,
                                  child: CircleAvatar(
                                    backgroundColor: context.bgColor,
                                    radius: 13,
                                    child: GetBatchWidget(
                                      batch: notification['secondUserDetails'],
                                      size: 15,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Text(
                            notification['message'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            notification['date'],
                            style: const TextStyle(fontSize: 10),
                          ),
                          onTap: () {
                            if (notification['type'] == 'follow') {
                              otherProfileProvider.fetchProfile(
                                notification['externalId'],
                              );
                              Navigator.push(
                                context,
                                PageTransition(
                                  child: const OtherProfile(),
                                  type: PageTransitionType.fade,
                                ),
                              );
                              return;
                            }
                            if (notification['type'] == 'likePost' ||
                                notification['type'] == 'replyPost' ||
                                notification['type'] == 'likeReply') {
                              provider.fetchForumDetails(
                                notification['externalId'],
                              );
                              Navigator.push(
                                context,
                                PageTransition(
                                  child: const PostViewScreen(),
                                  type: PageTransitionType.fade,
                                ),
                              );
                              return;
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return EdgeToEdge(
      child: Scaffold(
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
                  'Notifications',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const Divider(),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      'No notification yet',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  Text(
                    'Your notifications will appear here once you\'ve received them.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Spacer(),
            const Gap(80),
          ],
        ),
      ),
    );
  }
}
