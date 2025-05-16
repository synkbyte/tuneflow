import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:new_tuneflow/core/common/widget/edge_to_edge.dart';
import 'package:new_tuneflow/core/common/widget/name_with_batch.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/src/chat/presentation/providers/chat_provider.dart';
import 'package:new_tuneflow/src/chat/presentation/widgets/message_status.dart';
import 'package:provider/provider.dart';

class ChatViewScreen extends StatefulWidget {
  const ChatViewScreen({super.key});

  @override
  State<ChatViewScreen> createState() => _ChatViewScreenState();
}

class _ChatViewScreenState extends State<ChatViewScreen> {
  TextEditingController controller = TextEditingController();
  late ChatProvider provider;

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
            SizedBox(height: MediaQuery.of(context).padding.top),
            Row(
              children: [
                Gap(10),
                BackButton(),
                Gap(10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
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
                              provider.selectedChat['chat']['user']['lastSeen'],
                              style: TextStyle(
                                fontSize: 10,
                                color: context.onBgColor.withValues(alpha: .7),
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
                            return Row(
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
                                            MediaQuery.of(context).size.width -
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
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SelectableText(
                                            message['content'],
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
                                    Gap(1),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          message['at'],
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: context.onBgColor.withValues(
                                              alpha: .8,
                                            ),
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
