import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:new_tuneflow/core/common/widget/edge_to_edge.dart';
import 'package:new_tuneflow/core/common/widget/name_with_batch.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/src/chat/presentation/providers/chat_provider.dart';
import 'package:new_tuneflow/src/chat/presentation/widgets/message_status.dart';
import 'package:new_tuneflow/src/other_profile/presentation/providers/other_profile_provider.dart';
import 'package:new_tuneflow/src/other_profile/presentation/screens/other_profile.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class ChatViewScreen extends StatefulWidget {
  const ChatViewScreen({super.key});

  @override
  State<ChatViewScreen> createState() => _ChatViewScreenState();
}

class _ChatViewScreenState extends State<ChatViewScreen> {
  TextEditingController controller = TextEditingController();
  late ChatProvider provider;
  Set<Map> selectedMessages = {};

  @override
  void dispose() {
    super.dispose();
    provider.deselectChat();
  }

  @override
  Widget build(BuildContext context) {
    provider = Provider.of<ChatProvider>(context);

    return EdgeToEdge(
      child: Scaffold(
        body: Column(
          children: [
            if (selectedMessages.isEmpty) ...[
              SizedBox(height: MediaQuery.of(context).padding.top),
              Row(
                children: [
                  Gap(10),
                  BackButton(),
                  Gap(10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        context.read<OtherProfileProvider>().fetchProfile(
                          provider.selectedChat['chat']['user']['id'],
                        );
                        Navigator.push(
                          context,
                          PageTransition(
                            child: OtherProfile(),
                            type: PageTransitionType.fade,
                          ),
                        );
                      },
                      child: Container(
                        color: context.bgColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            NameWithBatch(
                              name: Text(
                                provider.selectedChat['chat']['user']['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              batch: provider.selectedChat['chat']['user'],
                              size: 16,
                            ),
                            if (provider.selectedChat['chat']['user']['lastSeen'] !=
                                    null &&
                                provider.selectedChat['chat']['user']['lastSeen'] !=
                                    '')
                              Text(
                                provider
                                    .selectedChat['chat']['user']['lastSeen'],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: context.onBgColor.withValues(
                                    alpha: .7,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Divider(),
            ] else ...[
              SizedBox(height: MediaQuery.of(context).padding.top),
              Row(
                children: [
                  Gap(10),
                  CloseButton(
                    onPressed: () {
                      setState(() {
                        selectedMessages.clear();
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
                              '${selectedMessages.length} Selected',
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
                  if (selectedMessages.length == 1)
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(
                            text: selectedMessages.first['content'],
                          ),
                        );
                        Fluttertoast.showToast(msg: 'Copied to clipboard');
                        setState(() {
                          selectedMessages.clear();
                        });
                      },
                      icon: Icon(Icons.copy, size: 20),
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
                                    provider.deleteMessageForMe(
                                      selectedMessages.toList(),
                                    );
                                    setState(() {
                                      selectedMessages.clear();
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Text('Remove for Me'),
                                ),
                                if (selectedMessages.every(
                                  (e) =>
                                      e['role'] == 'You' &&
                                      e['isDeletedForEveryone'] == false,
                                ))
                                  TextButton(
                                    onPressed: () {
                                      provider.deleteMessageForEveryone(
                                        selectedMessages.toList(),
                                      );
                                      setState(() {
                                        selectedMessages.clear();
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Text('Erase for All'),
                                  ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      selectedMessages.clear();
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
              Divider(),
            ],
            MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeBottom: true,
              child: Expanded(
                child: ListView.separated(
                  itemCount:
                      List.from(provider.selectedChat['messages']).length,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemBuilder: (context, index) {
                    Map model = provider.selectedChat['messages'][index];
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
                            model['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                              color: context.scheme.onSecondary,
                            ),
                          ),
                        ),
                        Gap(10),
                        ListView.separated(
                          itemCount: List.from(model['messages']).length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, i) {
                            Map message = model['messages'][i];
                            bool isItsMe = message['role'] == 'You';
                            bool isSelected = selectedMessages.contains(
                              message,
                            );

                            return GestureDetector(
                              onLongPress: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedMessages.remove(message);
                                  } else {
                                    selectedMessages.add(message);
                                  }
                                });
                              },
                              onTap: () {
                                if (selectedMessages.isNotEmpty) {
                                  setState(() {
                                    if (isSelected) {
                                      selectedMessages.remove(message);
                                    } else {
                                      selectedMessages.add(message);
                                    }
                                  });
                                }
                              },
                              child: Container(
                                color: context.bgColor,
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
                                        Container(
                                          constraints: BoxConstraints(
                                            maxWidth:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width -
                                                100,
                                            minWidth: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                !isItsMe
                                                    ? context.scheme.primary
                                                        .withValues(alpha: 0.3)
                                                    : context
                                                        .scheme
                                                        .primaryContainer
                                                        .withValues(alpha: 0.4),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border:
                                                isSelected
                                                    ? Border.all(
                                                      color:
                                                          context
                                                              .scheme
                                                              .primary,
                                                      width: 2,
                                                    )
                                                    : null,
                                          ),
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                message['content'],
                                                style: TextStyle(
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
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (!(message['isDeletedForEveryone'] ??
                                            false))
                                          Gap(1),
                                        if (!(message['isDeletedForEveryone'] ??
                                            false))
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                message['at'],
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: context.onBgColor
                                                      .withValues(alpha: .8),
                                                ),
                                              ),
                                              Gap(2),
                                              if (isItsMe)
                                                MessageStatusWidget(
                                                  status: message['status'],
                                                ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return Gap(10);
                          },
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Gap(10);
                  },
                ),
              ),
            ),
            Gap(10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  bottom: const Radius.circular(10),
                  top: Radius.circular(10),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 100,
                        color: context.scheme.primary.withValues(alpha: .2),
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: controller,
                    maxLines: 4,
                    minLines: 1,
                    onChanged: (value) => setState(() => ()),
                    onSubmitted: (value) {},
                    decoration: InputDecoration(
                      hintText: 'Enter message here',
                      filled: true,
                      fillColor: context.scheme.primaryContainer.withValues(
                        alpha: .5,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                      border: InputBorder.none,
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Gap(10),
                          Container(
                            height: 30,
                            width: 2,
                            color: context.scheme.shadow.withValues(alpha: .3),
                          ),
                          const Gap(10),
                          GestureDetector(
                            onTap: () {
                              if (controller.text.isEmpty) return;
                              provider.sentMessage(
                                controller.text.trim(),
                                provider.selectedChat['chat']['user']['id'],
                              );
                              controller.clear();
                            },
                            child: Container(
                              height: 55,
                              width: 55,
                              decoration: BoxDecoration(shape: BoxShape.circle),
                              child: const Padding(
                                padding: EdgeInsets.only(left: 3),
                                child: Icon(Icons.send, size: 25),
                              ),
                            ),
                          ),
                          const Gap(10),
                        ],
                      ),
                      hintStyle: TextStyle(color: context.scheme.onSurface),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
          ],
        ),
      ),
    );
  }
}
