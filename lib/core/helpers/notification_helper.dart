// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:hive_flutter/hive_flutter.dart';

// class NotificationHelper {
//   static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static Future<void> configureNotification() async {
//     try {
//       const initializationSettingsAndroid = AndroidInitializationSettings(
//         'ic_launcher',
//       );
//       const initializationSettingsIOS = DarwinInitializationSettings();
//       const initializationSettings = InitializationSettings(
//         android: initializationSettingsAndroid,
//         iOS: initializationSettingsIOS,
//       );
//       await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//     } catch (error) {
//       return;
//     }
//   }

//   static void showLocalNotification(RemoteMessage message) async {
//     const androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       'com.tuneflow.channel.updates',
//       'Updates',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//     const platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//     );

//     await NotificationHelper.flutterLocalNotificationsPlugin.show(
//       0,
//       message.data['title'],
//       message.data['body'],
//       platformChannelSpecifics,
//     );
//   }

//   static askNotificationPermission() async {
//     try {
//       FirebaseMessaging messaging = FirebaseMessaging.instance;
//       await messaging.requestPermission();
//       messaging.setForegroundNotificationPresentationOptions(
//         alert: true,
//         badge: true,
//         sound: true,
//       );
//       await messaging.setAutoInitEnabled(true);
//       messaging.subscribeToTopic('updates');
//       String? token = await messaging.getToken();
//       Hive.box('app').put('token', token);
//       FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//         NotificationHelper.showLocalNotification(message);
//       });
//     } catch (error) {
//       return;
//     }
//   }
// }
