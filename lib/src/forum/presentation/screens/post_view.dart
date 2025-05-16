import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:new_tuneflow/core/common/widget/loading.dart';
import 'package:new_tuneflow/core/common/widget/name_with_batch.dart';
import 'package:new_tuneflow/core/constants/constants.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/res/media.dart';
import 'package:new_tuneflow/core/snackbar/snackbar.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/src/forum/domain/forum_model.dart';
import 'package:new_tuneflow/src/forum/presentation/providers/forum_provider.dart';
import 'package:new_tuneflow/src/other_profile/presentation/screens/other_profile.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';

class PostViewScreen extends StatefulWidget {
  const PostViewScreen({super.key, this.showKeyboard = false});
  final bool showKeyboard;

  @override
  State<PostViewScreen> createState() => _PostViewScreenState();
}

class _PostViewScreenState extends State<PostViewScreen> {
  late ForumProvider provider;
  TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();

  bool isInit = true;

  updateKeyboardStatus() {
    if (widget.showKeyboard) {
      focusNode.requestFocus();
    }
    isInit = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<ForumProvider>(context);

    if (provider.isFetchingForumDetails) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'View Post',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingWidget(),
            Gap(100),
          ],
        ),
      );
    }

    if (provider.gotErrorWhileDetails) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'View Post',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(provider.errorMsgWhileDetails),
              ),
              Gap(100),
            ],
          ),
        ),
      );
    }

    if (isInit) {
      updateKeyboardStatus();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'View Post',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            child: Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: context.onBgColor.withValues(alpha: .1),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            otherProfileProvider
                                .fetchProfile(provider.model.userId);
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
                                  imageUrl: provider.model.userAvatar,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      NameWithBatch(
                                        name: Text(
                                          provider.model.userName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        batch: provider.model.batch,
                                        size: 17,
                                      ),
                                      Text(
                                        provider.model.date,
                                        style: TextStyle(
                                          color: context.onBgColor
                                              .withValues(alpha: .6),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Gap(10),
                        Text(
                          provider.model.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          provider.model.content,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const Gap(5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                provider.likeForum(provider.model.id, true);
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      provider.model.likedStatus
                                          ? Icons.thumb_up
                                          : Icons.thumb_up_outlined,
                                      size: 20,
                                    ),
                                    const Gap(5),
                                    Text(
                                      '${provider.model.likeCount} Likes',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                focusNode.requestFocus();
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.chat_bubble_outline,
                                      size: 18,
                                    ),
                                    const Gap(5),
                                    Text(
                                      '${provider.model.repliedCount} Replies',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    )
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
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      content: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                2,
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
                                                  reportReasons[index]
                                                      ['subTitle'],
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                                onTap: () {
                                                  provider.reportPost(
                                                    provider.model.id,
                                                    reportReasons[index]
                                                        ['title'],
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
                                    Icon(
                                      Icons.report_outlined,
                                      size: 18,
                                    ),
                                    Gap(5),
                                    Text(
                                      'Report',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Replies (${provider.model.repliedCount})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListView.separated(
                    itemCount: provider.model.postReplies.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      PostReplyModel model = provider.model.postReplies[index];
                      return _buildReplyCard(model);
                    },
                    separatorBuilder: (context, index) {
                      return const Gap(10);
                    },
                  ),
                ],
              ),
            ),
          ),
          const Gap(10),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: context.primary.withValues(alpha: .2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 4,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 20,
                      ),
                      hintText: 'Well, i think....',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    if (controller.text.isNotEmpty) {
                      provider.replyOfForum(provider.model.id, controller.text);
                      controller.clear();
                    }
                  },
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: context.primary.withValues(alpha: .4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.near_me),
                  ),
                ),
              ],
            ),
          ),
          Gap(MediaQuery.of(context).padding.bottom + 10),
        ],
      ),
    );
  }

  Widget _buildReplyCard(PostReplyModel model) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.onBgColor.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(10),
      ),
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
                  if (model.isMineComment)
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Center(
                                child: Text(
                                  'Confirm Deletion',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Are you sure you want to delete this reply? This action cannot be undone.',
                                  ),
                                  const Gap(10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          provider.deleteReply(model);
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
                  provider.likeForumReply(model.id);
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
                        '${model.likeCount}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
