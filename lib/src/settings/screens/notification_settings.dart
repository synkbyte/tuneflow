import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:new_tuneflow/core/common/providers/state_provider.dart';
import 'package:new_tuneflow/core/common/widget/buttons.dart';
import 'package:new_tuneflow/core/services/notification_service.dart';
import 'package:provider/provider.dart';

class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  @override
  Widget build(BuildContext context) {
    final stateProvider = Provider.of<StateProvider>(context);

    if (!stateProvider.hasPermission) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Notification Settings',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Push Notifications are currently turned off.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Text(
                'Turn on notifications for updates, announcements, likes, replies, follows, and messages—stay in the loop! 🎶🔥',
                style: TextStyle(fontSize: 12),
              ),
              Gap(20),
              PrimaryButton(
                title: 'Enable Notification',
                onPressed: () async {
                  stateProvider.checkPermissionStatus();
                  await NotificationService.initialize();
                  stateProvider.checkPermissionStatus();
                },
              ),
              Gap(MediaQuery.of(context).padding.bottom + 20),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notification Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(
              'Allow Notifications',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            value: true,
            onChanged: (value) {},
          ),
          Divider(height: 0),
          SwitchListTile(
            title: Text(
              'New Updates & Announcements',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Text(
              'Stay updated with the latest news and feature releases.',
              style: TextStyle(fontSize: 10),
            ),
            value: true,
            onChanged: (value) {},
          ),
          Divider(height: 0),
          SwitchListTile(
            title: Text(
              'Community Activity Alerts',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Text(
              'Get notified when someone likes, replies, or follows you.',
            ),
            value: true,
            onChanged: (value) {},
          ),
          Divider(height: 0),
          SwitchListTile(
            title: Text(
              'Chats & Message Alerts',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Text('Never miss important messages and conversations.'),
            value: true,
            onChanged: (value) {},
          ),
          Divider(height: 0),
        ],
      ),
    );
  }
}
