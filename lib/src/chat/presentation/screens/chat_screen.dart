import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:new_tuneflow/core/common/models/models.dart';
import 'package:new_tuneflow/core/common/widget/name_with_batch.dart';
import 'package:new_tuneflow/core/constants/constants.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/res/media.dart';
import 'package:new_tuneflow/src/chat/presentation/providers/chat_provider.dart';
import 'package:new_tuneflow/src/chat/presentation/screens/chat_view_screen.dart';
import 'package:new_tuneflow/src/chat/presentation/widgets/message_status.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Set<ChatModel> selectedChats = {};

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChatProvider>(context);

    if (provider.chats.isEmpty) {
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
                  'Chats',
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
                      'No messages yet',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  Text(
                    'Start a conversation and your messages will appear here.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Spacer(),
            const Gap(80),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          if (selectedChats.isEmpty)
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
                  'Chats',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          else
            Row(
              children: [
                Gap(10),
                CloseButton(
                  onPressed: () {
                    setState(() {
                      selectedChats.clear();
                    });
                  },
                ),
                Gap(10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      color: context.bgColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${selectedChats.length} Selected',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text('Delete Message'),
                            content: Text(
                              'Are you sure you want to delete this message?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  provider.deleteChat(selectedChats.toList());
                                  setState(() {
                                    selectedChats.clear();
                                  });
                                  Navigator.pop(context);
                                },
                                child: Text('Remove Chat'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    selectedChats.clear();
                                  });
                                },
                                child: Text('Dismiss'),
                              ),
                            ],
                          ),
                    );
                  },
                  icon: Icon(
                    Icons.delete_forever_outlined,
                    color: context.scheme.error,
                    size: 22,
                  ),
                ),
                Gap(10),
              ],
            ),

          const Divider(height: 0),
          MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Expanded(
              child: ListView(
                children: [
                  ListView.builder(
                    itemCount: provider.chats.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      ChatModel model = provider.chats[index];
                      return ListTile(
                        leading: CachedNetworkImage(
                          imageUrl: '$imageBaseUrl${model.user['avatar']}',
                          imageBuilder: (context, imageProvider) {
                            return Container(
                              height: 50,
                              width: 50,
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
                              height: 50,
                              width: 50,
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
                        title: NameWithBatch(
                          name: Text(
                            model.user['name'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          batch: model.user,
                        ),
                        subtitle: Row(
                          children: [
                            if (model.lastMessage.role == 'You' &&
                                model.lastMessage.status != 'deleted')
                              MessageStatusWidget(
                                status: model.lastMessage.status,
                              ),
                            if (model.lastMessage.role == 'You' &&
                                model.lastMessage.status != 'deleted')
                              Gap(5),
                            Expanded(
                              child: Text(
                                model.lastMessage.content,
                                style: TextStyle(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(model.lastMessage.at),
                            if (model.unreadCount != 0)
                              Badge.count(count: model.unreadCount),
                          ],
                        ),
                        onTap: () {
                          if (selectedChats.isNotEmpty) {
                            if (selectedChats.contains(model)) {
                              setState(() {
                                selectedChats.remove(model);
                              });
                            } else {
                              setState(() {
                                selectedChats.add(model);
                              });
                            }
                            return;
                          }
                          provider.getChatById(model.id, model.user);
                          Navigator.push(
                            context,
                            PageTransition(
                              child: const ChatViewScreen(),
                              type: PageTransitionType.fade,
                            ),
                          );
                        },
                        tileColor:
                            selectedChats.contains(model)
                                ? context.scheme.onSurface.withValues(alpha: .2)
                                : null,
                        onLongPress: () {
                          setState(() {
                            selectedChats.add(model);
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
