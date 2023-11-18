import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:meal_recommender/dritool.dart';
import 'package:meal_recommender/BMIcalc.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);
  static const String route = '/notificationPage'; // Named route

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones(); // Make sure to initialize timezone data
    fetchAndScheduleNotificationsFromDatabase();
    initializeNotifications();
  }

  Future<void> scheduleNotification(NotificationDetails notificationDetails, String id, String title, String body, DateTime scheduledTime, String payload) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      int.parse(id),
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> onSelectNotification(String? payload) async {
    if (payload == null) return;
    if (payload == 'notification1') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => DRIToolPage()));
    } else if (payload == 'notification2') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => BMICalculatorPage()));
    }
  }

  void initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    //  onSelectNotification : onSelectNotification,
    );
  }


  void fetchAndScheduleNotificationsFromDatabase() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("notifications");
    DatabaseEvent event = await ref.once();
    Map<dynamic, dynamic> notifications = event.snapshot.value as Map<dynamic, dynamic>;
    var now = DateTime.now();

    notifications.forEach((key, value) {
      var timeParts = value['scheduledTime'].split(':');
      var scheduledTime = DateTime(
          now.year, now.month, now.day, int.parse(timeParts[0]),
          int.parse(timeParts[1]));
      var androidDetails = AndroidNotificationDetails(
        'channel_id', 'channel_name',
        importance: Importance.max,
        priority: Priority.high,
      );
      var platformDetails = NotificationDetails(android: androidDetails);

      // In your notification scheduling logic
      if (scheduledTime.isAfter(now)) {
        var payload = value['notificationType'] == 'driTool'
            ? 'notification1'
            : 'notification2';
        scheduleNotification(
            platformDetails, key, value['title'], value['body'], scheduledTime, payload);
      }
    }
      );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: Center(
        child: Text('Check your notifications at the scheduled times.'),
      ),
    );
  }
}