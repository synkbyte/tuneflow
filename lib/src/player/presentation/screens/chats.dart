import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:new_tuneflow/core/common/providers/room_provider.dart';
import 'package:new_tuneflow/core/common/singletones/cache.dart';
import 'package:new_tuneflow/core/common/singletones/user.dart';
import 'package:new_tuneflow/core/common/widget/name_with_batch.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/src/other_profile/presentation/providers/other_profile_provider.dart';
import 'package:new_tuneflow/src/other_profile/presentation/screens/other_profile.dart';
import 'package:new_tuneflow/src/player/presentation/screens/room_settings.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class ChatViewScreen extends StatefulWidget {
  const ChatViewScreen({super.key});

  @override
  State<ChatViewScreen> createState() => _ChatViewScreenState();
}

class _ChatViewScreenState extends State<ChatViewScreen> {
  TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();

  Set<String> highlightedMessages = {};

  Future<void> scrollToMessage(String id, List messages) async {
    int index = messages.indexWhere((msg) => msg['id'] == id);
    if (index != -1) {
      if (!_isItemVisible(index)) {
        _scrollController.animateTo(
          index * 100.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        await Future.delayed(const Duration(milliseconds: 250));
      }
      highlightedMessages.add(id);
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 50));
      highlightedMessages.remove(id);
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 50));
      highlightedMessages.add(id);
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 50));
      highlightedMessages.remove(id);
      setState(() {});
    }
  }

  bool _isItemVisible(int index) {
    double itemOffset = index * 100.0;
    double viewportStart = _scrollController.offset;
    double viewportEnd =
        viewportStart + _scrollController.position.viewportDimension;

    return itemOffset >= viewportStart && itemOffset <= viewportEnd;
  }

  selectReplyItem(Map message) {
    roomProvider.updateReplyingMessage(message);
  }

  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final ws = Provider.of<RoomProvider>(context);
    final otherProvider = Provider.of<OtherProfileProvider>(context);

    ColorScheme scheme = context.scheme;
    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: scheme.surface.withValues(alpha: .2),
            child: Column(
              children: [
                Expanded(
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    removeBottom: true,
                    child: ListView.separated(
                      controller: _scrollController,
                      itemCount: ws.messages.length + 1,
                      reverse: true,
                      itemBuilder: (context, index) {
                        if (index == ws.messages.length) {
                          return const SizedBox(height: 100);
                        }
                        Map message = ws.messages[index];
                        if (message['type'] == 'action') {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: context.scheme.secondary,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                padding: const EdgeInsets.all(5),
                                child: Text(
                                  message['message'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 9,
                                    color: context.scheme.onSecondary,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        bool isItsMe =
                            message['userId'] == Cache.instance.userId;
                        final isHighlighted = highlightedMessages.contains(
                          message['id'],
                        );

                        return Dismissible(
                          key: ValueKey(message),
                          direction:
                              isItsMe
                                  ? DismissDirection.endToStart
                                  : DismissDirection.startToEnd,
                          confirmDismiss: (direction) async {
                            selectReplyItem({...message, 'isItsMe': isItsMe});
                            return false;
                          },
                          background:
                              isItsMe
                                  ? Container()
                                  : Container(
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.only(left: 20),
                                    color: Colors.grey.withValues(alpha: 0.2),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.reply,
                                          color: context.scheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Reply",
                                          style: TextStyle(
                                            color: context.scheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          secondaryBackground:
                              isItsMe
                                  ? Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    color: Colors.grey.withValues(alpha: 0.2),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(
                                          Icons.reply,
                                          color: context.scheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Reply",
                                          style: TextStyle(
                                            color: context.scheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  : Container(),
                          child: Row(
                            mainAxisAlignment:
                                isItsMe
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment:
                                    isItsMe
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                children: [
                                  if (message['isReplied'])
                                    GestureDetector(
                                      onTap: () {
                                        scrollToMessage(
                                          message['repliedId'],
                                          ws.messages,
                                        );
                                      },
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxWidth:
                                              MediaQuery.of(
                                                context,
                                              ).size.width -
                                              100,
                                          minWidth: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: context.scheme.onPrimary
                                              .withValues(alpha: .4),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(5),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              message['repliedOnMessage'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: context.scheme.onSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width -
                                          100,
                                      minWidth: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isHighlighted
                                              ? context.scheme.primaryContainer
                                                  .withValues(alpha: .1)
                                              : isItsMe
                                              ? context.scheme.primary
                                                  .withValues(alpha: 0.3)
                                              : context.scheme.primaryContainer
                                                  .withValues(alpha: 0.4),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            otherProvider.fetchProfile(
                                              message['userId'],
                                            );
                                            Navigator.push(
                                              context,
                                              PageTransition(
                                                child: const OtherProfile(),
                                                type: PageTransitionType.fade,
                                              ),
                                            );
                                          },
                                          child: NameWithBatch(
                                            name: Text(
                                              message['user'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color:
                                                    isItsMe
                                                        ? context
                                                            .scheme
                                                            .onSurface
                                                        : context
                                                            .scheme
                                                            .onPrimaryContainer,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            size: 15,
                                            batch: message['batch'],
                                          ),
                                        ),
                                        SelectableText(
                                          message['message'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                isItsMe
                                                    ? context.scheme.onSurface
                                                    : context
                                                        .scheme
                                                        .onPrimaryContainer,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 10);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (ws.isInRoom)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (ws.replyingMessage != null)
                        Container(
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer.withValues(
                              alpha: .5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 100,
                                color: scheme.primary.withValues(alpha: .2),
                                offset: const Offset(0, 5),
                              ),
                            ],
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(10),
                            ),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(
                            left: 10,
                            top: 5,
                            bottom: 5,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ws.replyingMessage!['isItsMe']
                                          ? 'Replying to yourself'
                                          : 'Replying to ${ws.replyingMessage!['user']}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: context.onBgColor,
                                      ),
                                    ),
                                    Text(
                                      ws.replyingMessage!['message'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  ws.clearReplyingMessage();
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: context.scheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          bottom: const Radius.circular(10),
                          top: Radius.circular(
                            ws.replyingMessage == null ? 10 : 0,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 100,
                                color: scheme.primary.withValues(alpha: .2),
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: TextField(
                            maxLines: 4,
                            minLines: 1,
                            controller: controller,
                            focusNode: focusNode,
                            onChanged: (value) => setState(() => ()),
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                audioHandler.sendMessage(
                                  controller.text.trim(),
                                  ws.replyingMessage != null,
                                  ws.replyingMessage?['id'] ?? '',
                                  ws.replyingMessage?['message'] ?? '',
                                );
                                ws.clearReplyingMessage();
                                controller.clear();
                                focusNode.requestFocus();
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Enter message here',
                              filled: true,
                              fillColor: scheme.primaryContainer.withValues(
                                alpha: .5,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 25,
                              ),
                              border: InputBorder.none,
                              prefixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Gap(10),
                                  Container(
                                    height: 45,
                                    width: 45,
                                    decoration: BoxDecoration(
                                      color: scheme.primary.withValues(
                                        alpha: .3,
                                      ),
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: CachedNetworkImageProvider(
                                          User.instance.user!.avatar!,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Gap(10),
                                ],
                              ),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Gap(10),
                                  Container(
                                    height: 30,
                                    width: 2,
                                    color: scheme.shadow.withValues(alpha: .3),
                                  ),
                                  const Gap(10),
                                  GestureDetector(
                                    onTap: () {
                                      if (controller.text.isNotEmpty) {
                                        audioHandler.sendMessage(
                                          controller.text.trim(),
                                          ws.replyingMessage != null,
                                          ws.replyingMessage?['id'] ?? '',
                                          ws.replyingMessage?['message'] ?? '',
                                        );
                                        ws.clearReplyingMessage();
                                        controller.clear();
                                      }
                                    },
                                    child: Container(
                                      height: 55,
                                      width: 55,
                                      decoration: BoxDecoration(
                                        color:
                                            controller.text.isEmpty
                                                ? scheme.shadow.withValues(
                                                  alpha: .3,
                                                )
                                                : scheme.onPrimary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.only(left: 3),
                                        child: Icon(Icons.send, size: 25),
                                      ),
                                    ),
                                  ),
                                  const Gap(10),
                                ],
                              ),
                              hintStyle: TextStyle(color: scheme.onSurface),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
              ],
            ),
          ),
          Container(
            color: scheme.primaryContainer,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top),
                Row(
                  children: [
                    BackButton(
                      onPressed: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        Get.back();
                      },
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Room\'s Chats',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (ws.isInRoom)
                          Text(
                            '${ws.users.length} Listeners in the room',
                            style: const TextStyle(fontSize: 10),
                          ),
                      ],
                    ),
                    const Spacer(),
                    if (ws.isInRoom)
                      IconButton(
                        onPressed: () {
                          ws.toggleMute();
                        },
                        icon: Icon(
                          ws.isMuted
                              ? Icons.notifications_active_outlined
                              : Icons.notifications_off_outlined,
                        ),
                      ),
                    if (ws.isInRoom && !ws.isHost)
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Center(
                                  child: Text('Are you are?'),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Are you sure you want to leave the room?',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            audioHandler.leaveRoom();
                                            Navigator.of(context).pop();
                                          },
                                          child: Text(
                                            'Yes',
                                            style: TextStyle(
                                              color: scheme.error,
                                              fontWeight: FontWeight.bold,
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
                        child: Text(
                          'Leave Room',
                          style: TextStyle(
                            color: scheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (ws.isInRoom && ws.isHost)
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageTransition(
                                child: const RoomSettings(),
                                type: PageTransitionType.fade,
                              ),
                            );
                          },
                          icon: const Icon(Icons.settings),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
