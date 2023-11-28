import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:meal_recommender/main.dart';
import 'package:meal_recommender/notificationpage.dart';
import 'package:firebase_database/firebase_database.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class FirebaseAPI {

  Future <void> handleBackgroundMessage(RemoteMessage message) async{
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('PayLoad: ${message.data}');
  }
  final _firebasemessaging = FirebaseMessaging.instance;


  Future<void> initNotifications() async {
    await _firebasemessaging.requestPermission();
    final fCMToken = await _firebasemessaging.getToken();
    print ('Token : $fCMToken');
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      handleMessage(message);
    });

    // Listen to messages when the user taps on a notification when the app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleMessage(message);
    });
  }


  void handleMessage(RemoteMessage? message){
   // if(message == null) return;
   // navigatorKey.currentState?.pushNamed(
      //NotificationPage(),
      //arguments: message.data,
   // );
  }


}

