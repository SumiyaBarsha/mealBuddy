import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseAPI {
  final _firebasemessaging = FirebaseMessaging.instance;

  Future <void> handleBackgroundMessage(RemoteMessage message) async{
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('PayLoad: ${message.data}');
  }

  Future<void> initNotifications() async {
    await _firebasemessaging.requestPermission();
    final fCMToken = await _firebasemessaging.getToken();
    print ('Token : $fCMToken');
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}