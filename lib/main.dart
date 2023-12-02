import 'package:flutter/material.dart';
import 'package:meal_recommender/firebase_api.dart';
import 'package:meal_recommender/home.dart';
import 'package:meal_recommender/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:meal_recommender/splash.dart';
import 'firebase_options.dart';
import 'firebase_api.dart';
import 'notificationpage.dart';
import 'package:meal_recommender/home.dart';
import 'notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dcdg/dcdg.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    NotificationService notificationService = NotificationService();
    await notificationService.init();

    //await FirebaseAPI().initNotifications();
  }catch (e) {
    print('Error during initialization: $e');
  }
  runApp(MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {

  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Flutter login UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}

