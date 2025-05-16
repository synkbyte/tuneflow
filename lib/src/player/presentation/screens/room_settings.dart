import 'package:flutter/material.dart';
import 'package:new_tuneflow/core/common/providers/room_provider.dart';
import 'package:new_tuneflow/core/common/singletones/user.dart';
import 'package:new_tuneflow/core/extensions/context_extenstions.dart';
import 'package:new_tuneflow/core/snackbar/snackbar.dart';
import 'package:new_tuneflow/injection_container.dart';
import 'package:new_tuneflow/src/profile/presentation/screens/premium.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class RoomSettings extends StatefulWidget {
  const RoomSettings({super.key});

  @override
  State<RoomSettings> createState() => _RoomSettingsState();
}

class _RoomSettingsState extends State<RoomSettings> {
  @override
  Widget build(BuildContext context) {
    final ws = Provider.of<RoomProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Room\'s Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          ListTile(
            onTap: () {
              audioHandler.changeRoomSetting(
                ws.isPrivate,
                !ws.hasPermissionToChange,
              );
            },
            title: const Text(
              'Manage Songs',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: const Text(
              'Admin Access Only',
              style: TextStyle(fontSize: 10),
            ),
            trailing: Switch(
              value: !ws.hasPermissionToChange,
              onChanged: (value) {
                if (!(User.instance.user?.isPremium ?? false)) {
                  errorMessage(
                    context,
                    'Premium subscription is required to access room settings.',
                  );
                  Navigator.push(
                    context,
                    PageTransition(
                      child: const PremiumScreen(),
                      type: PageTransitionType.fade,
                    ),
                  );
                  return;
                }
                audioHandler.changeRoomSetting(ws.isPrivate, !value);
              },
            ),
          ),
          ListTile(
            onTap: () {
              audioHandler.changeRoomSetting(
                !ws.isPrivate,
                ws.hasPermissionToChange,
              );
            },
            title: const Text(
              'Private Room',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: const Text(
              'Joinable via Room ID Only',
              style: TextStyle(fontSize: 10),
            ),
            trailing: Switch(
              value: ws.isPrivate,
              onChanged: (value) {
                if (!(User.instance.user?.isPremium ?? false)) {
                  errorMessage(
                    context,
                    'Premium subscription is required to access room settings.',
                  );
                  Navigator.push(
                    context,
                    PageTransition(
                      child: const PremiumScreen(),
                      type: PageTransitionType.fade,
                    ),
                  );
                  return;
                }
                audioHandler.changeRoomSetting(value, ws.hasPermissionToChange);
              },
            ),
          ),
          ListTile(
            onTap: () {
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
                          'Are you sure you want to close the room?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () {
                                audioHandler.closeRoom();
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Yes',
                                style: TextStyle(
                                  color: context.scheme.error,
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
                                style: TextStyle(fontWeight: FontWeight.bold),
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
            title: Text(
              'Close Room',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: context.scheme.error,
              ),
            ),
            subtitle: Text(
              'Permanently Delete Room and Chats',
              style: TextStyle(
                fontSize: 10,
                color: context.scheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
