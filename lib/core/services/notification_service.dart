import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    await _configureLocalNotifications();
    await _requestNotificationPermission();
    await _fetchAndStoreFCMToken();
    _listenForTokenUpdates();
    _listenForIncomingMessages();
  }

  static Future<void> _requestNotificationPermission() async {
    final settings = await _messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      _messaging.subscribeToTopic('updates');
    }
  }

  static Future<void> _fetchAndStoreFCMToken() async {
    final fcmToken = await _messaging.getToken();
    if (fcmToken != null) {
      Hive.box('app').put('fcm_token', fcmToken);
    }
  }

  static void _listenForTokenUpdates() {
    _messaging.onTokenRefresh.listen((newToken) {
      Hive.box('app').put('fcm_token', newToken);
    });
  }

  static void _listenForIncomingMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showLocalNotification(message);
    });
  }

  static Future<void> _configureLocalNotifications() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {},
    );
  }

  static Future<void> showLocalNotification(RemoteMessage message) async {
    if (message.data.isEmpty) return;

    String title = message.data['title'] ?? "New Notification";
    String body = message.data['body'] ?? "You have a new message";

    if (title.isEmpty || body.isEmpty) return;

    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'com.tuneflow.channel.notify',
      'Notify',
      importance: Importance.max,
      priority: Priority.high,
    );

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  static Future<bool> isServiceEnabled() async {
    NotificationSettings settings = await _messaging.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      return true;
    }
    return false;
  }
}
