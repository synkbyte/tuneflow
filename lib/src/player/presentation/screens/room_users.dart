import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:new_tuneflow/core/common/providers/room_provider.dart';
import 'package:new_tuneflow/core/common/widget/name_with_batch.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/res/media.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/src/other_profile/presentation/providers/other_profile_provider.dart';
import 'package:new_tuneflow/src/other_profile/presentation/screens/other_profile.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class RoomUsersList extends StatefulWidget {
  const RoomUsersList({super.key});

  @override
  State<RoomUsersList> createState() => _RoomUsersListState();
}

class _RoomUsersListState extends State<RoomUsersList> {
  @override
  Widget build(BuildContext context) {
    final ws = Provider.of<RoomProvider>(context);
    final otherProvider = Provider.of<OtherProfileProvider>(context);
    ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Listeners - ${ws.users.length}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body:
          ws.users.isEmpty
              ? Column(
                children: [
                  Text(
                    'No Listeners joined the room',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: scheme.error,
                    ),
                  ),
                  const Row(),
                ],
              )
              : ListView.builder(
                itemCount: ws.users.length,
                itemBuilder: (context, index) {
                  bool isAdmin = ws.users[index]['role'] == 'Admin';
                  return ListTile(
                    contentPadding: const EdgeInsets.only(left: 15, right: 5),
                    leading: CachedNetworkImage(
                      imageUrl: ws.users[index]['avatar'],
                      imageBuilder: (context, imageProvider) {
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
                    trailing:
                        ws.isHost && !isAdmin
                            ? PopupMenuButton<String>(
                              onSelected: (String item) {
                                if (item == '1') {
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
                                            Text(
                                              'Are you sure you want to make ${ws.users[index]['name']} the admin of the room?',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
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
                                                    Fluttertoast.showToast(
                                                      msg:
                                                          'Assigned ${ws.users[index]['name']} as the admin of the room.',
                                                    );
                                                    audioHandler.changeAdmin(
                                                      ws.users[index]['id'],
                                                    );
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text(
                                                    'Yes',
                                                    style: TextStyle(
                                                      color: scheme.error,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                }
                                if (item == '2') {
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
                                            Text(
                                              'Are you sure you want to remove ${ws.users[index]['name']} from the room?',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
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
                                                    Fluttertoast.showToast(
                                                      msg:
                                                          'You removed "${ws.users[index]['name']}" from the room',
                                                    );
                                                    audioHandler.removeUser(
                                                      ws.users[index]['id'],
                                                      ws.users[index]['name'],
                                                    );
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text(
                                                    'Yes',
                                                    style: TextStyle(
                                                      color: scheme.error,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                }
                              },
                              itemBuilder:
                                  (BuildContext context) =>
                                      <PopupMenuEntry<String>>[
                                        const PopupMenuItem<String>(
                                          value: '1',
                                          child: Text('Make Admin'),
                                        ),
                                        PopupMenuItem<String>(
                                          value: '2',
                                          child: Text(
                                            'Remove',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: context.scheme.error,
                                            ),
                                          ),
                                        ),
                                      ],
                            )
                            : null,
                    title: NameWithBatch(
                      name: Text(
                        ws.users[index]['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      size: 17,
                      batch: ws.users[index]['batch'],
                    ),
                    subtitle: Text(
                      ws.users[index]['userName'],
                      style: TextStyle(fontSize: 10),
                    ),
                    onTap: () {
                      otherProvider.fetchProfile(ws.users[index]['id']);
                      Navigator.push(
                        context,
                        PageTransition(
                          child: const OtherProfile(),
                          type: PageTransitionType.fade,
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
