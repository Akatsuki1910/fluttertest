import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushPage extends StatefulWidget {
  const PushPage({super.key});

  @override
  PushPageState createState() => PushPageState();
}

class PushPageState extends State<PushPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: _onPressed,
          child: const Text('test'),
        ),
      ),
    );
  }

  void _onPressed() {
    showLocalNotification('Notification title', DateTime.now().toString());
  }

  void showLocalNotification(String title, String message) {
    const androidNotificationDetail = AndroidNotificationDetails(
        'channel_id', // channel Id
        'channel_name' // channel Name
        );
    const iosNotificationDetail = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      iOS: iosNotificationDetail,
      android: androidNotificationDetail,
    );
    FlutterLocalNotificationsPlugin()
        .show(0, title, message, notificationDetails);
  }
}
