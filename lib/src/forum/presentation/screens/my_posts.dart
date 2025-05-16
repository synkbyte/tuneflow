import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:new_tuneflow/core/common/widget/edge_to_edge.dart';
import 'package:new_tuneflow/core/common/widget/loading.dart';
import 'package:new_tuneflow/core/common/widget/name_with_batch.dart';
import 'package:new_tuneflow/core/constants/constants.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/res/media.dart';
import 'package:new_tuneflow/core/snackbar/snackbar.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/src/forum/domain/forum_model.dart';
import 'package:new_tuneflow/src/forum/presentation/providers/forum_provider.dart';
import 'package:new_tuneflow/src/forum/presentation/screens/create_post.dart';
import 'package:new_tuneflow/src/forum/presentation/screens/post_view.dart';
import 'package:new_tuneflow/src/other_profile/presentation/screens/other_profile.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';

class MyPostsScreen extends StatefulWidget {
  const MyPostsScreen({super.key});

  @override
  State<MyPostsScreen> createState() => _MyPostsScreenState();
}

class _MyPostsScreenState extends State<MyPostsScreen> {
  late ForumProvider provider;

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<ForumProvider>(context);

    if (provider.isFetchingMine) {
      return EdgeToEdge(
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'My Posts',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [LoadingWidget(), Gap(100)],
          ),
        ),
      );
    }

    if (provider.mineFeed.isEmpty) {
      return EdgeToEdge(
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'My Posts',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Center(
                  child: Text(
                    'No posts yet',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                ),
                const Text(
                  'Your posts will appear here once you\'ve created them.',
                  textAlign: TextAlign.center,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageTransition(
                        child: const CreatePostScreen(),
                        type: PageTransitionType.fade,
                      ),
                    );
                  },
                  child: const Text(
                    'Create Post',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return EdgeToEdge(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Posts',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageTransition(
                    child: const CreatePostScreen(),
                    type: PageTransitionType.fade,
                  ),
                );
              },
              icon: const Icon(Icons.add),
            ),
            const Gap(10),
          ],
        ),
        body: ListView(
          controller: provider.mineController,
          children: [
            const Gap(20),
            ListView.separated(
              itemCount: provider.mineFeed.length + 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemBuilder: (context, index) {
                if (index < provider.mineFeed.length) {
                  ForumModel model = provider.mineFeed[index];
                  return _buildPostCard(model);
                } else {
                  if (provider.currentPageMine < provider.totalPageMine) {
                    return const Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else {
                    return const SizedBox();
                  }
                }
              },
              separatorBuilder: (context, index) {
                return const Gap(20);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(ForumModel model) {
    return Container(
      decoration: BoxDecoration(
        color: context.onBgColor.withValues(alpha: .1),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: InkWell(
        onTap: () {
          provider.fetchForumDetails(model.id);
          Navigator.push(
            context,
            PageTransition(
              child: const PostViewScreen(),
              type: PageTransitionType.fade,
            ),
          );
        },
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  otherProfileProvider.fetchProfile(model.userId);
                  Navigator.push(
                    context,
                    PageTransition(
                      child: const OtherProfile(),
                      type: PageTransitionType.fade,
                    ),
                  );
                },
                child: Container(
                  color: context.onBgColor.withValues(alpha: .001),
                  child: Row(
                    children: [
                      CachedNetworkImage(
                        imageUrl: model.userAvatar,
                        imageBuilder: (context, imageProvider) {
                          return Container(
                            height: 40,
                            width: 40,
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
                            height: 40,
                            width: 40,
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
                      const Gap(10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            NameWithBatch(
                              name: Text(
                                model.userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              batch: model.batch,
                              size: 17,
                            ),
                            Text(
                              model.date,
                              style: TextStyle(
                                color: context.onBgColor.withValues(alpha: .6),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Center(
                                  child: Text(
                                    'Confirm Deletion',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Are you sure you want to delete this post? This action cannot be undone.',
                                    ),
                                    const Gap(10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            provider.deleteForum(model);
                                            Navigator.of(context).pop();
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
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            'No',
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
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.scheme.error.withValues(alpha: .2),
                          ),
                          child: Icon(
                            Icons.delete_forever_outlined,
                            color: context.scheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(10),
              Text(
                model.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              ReadMoreText(
                model.content,
                style: const TextStyle(fontSize: 12),
                trimCollapsedText: 'Read More',
                trimExpandedText: 'Read Less',
                moreStyle: TextStyle(
                  color: context.primary,
                  fontWeight: FontWeight.bold,
                ),
                lessStyle: TextStyle(
                  color: context.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      provider.likeForum(model.id);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            model.likedStatus
                                ? Icons.thumb_up
                                : Icons.thumb_up_outlined,
                            size: 20,
                          ),
                          const Gap(5),
                          Text(
                            '${model.likeCount} Likes',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      provider.fetchForumDetails(model.id);
                      Navigator.push(
                        context,
                        PageTransition(
                          child: const PostViewScreen(showKeyboard: true),
                          type: PageTransitionType.fade,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.chat_bubble_outline, size: 18),
                          const Gap(5),
                          Text(
                            '${model.repliedCount} Replies',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
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
                            contentPadding: EdgeInsets.zero,
                            title: const Center(
                              child: Text(
                                'Reason for Reporting',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            content: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height / 2,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: ListView.builder(
                                  itemCount: reportReasons.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(
                                        reportReasons[index]['title'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        reportReasons[index]['subTitle'],
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      onTap: () {
                                        provider.reportPost(
                                          model.id,
                                          reportReasons[index]['title'],
                                        );
                                        successMessage(
                                          context,
                                          'Report successfully',
                                        );
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.report_outlined, size: 18),
                          Gap(5),
                          Text(
                            'Report',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
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
