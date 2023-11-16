import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationPage extends StatefulWidget {
  static const String route = '/notificationPage'; // Named route

  final Map<String, dynamic>? data; // Expecting data to be passed in
  const NotificationPage({Key? key, this.data}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  @override
  void initState() {
    super.initState();
    // Initialize the plugin. app_icon needs to be a added as a drawable resource to the Android head project.
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    final databaseReference = FirebaseDatabase.instance.ref();
    databaseReference.child('notifications').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        _showLocalNotification(data); // Trigger a local notification
      }
    });
  }

  Future<void> _showLocalNotification(Map<dynamic, dynamic> data) async {
    // Customize your notification content
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'b123',
      'MealBuddy',
      channelDescription: 'Push Notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      data['title'], // Notification Title
      data['body'], // Notification Body
      platformChannelSpecifics,
      payload: data['payload'], // Additional data to pass
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: Center(
        child: widget.data != null
            ? Text('Data: ${widget.data}')
            : Text('No notification data'),
      ),
    );
  }
}
