import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // await Firebase.initializeApp();

  // final token = await FirebaseMessaging.instance.getToken();
  // print(token);

  _streamController.add(message);

  const androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'messages',
    'Messages',
    'New chat messages',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: true,
    ledColor: Color.fromARGB(255, 255, 0, 0),
    ledOnMs: 2000,
    ledOffMs: 1000,
  );

  await _flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecond,
    'Nowa wiadomość',
    'Kliknij aby zobaczyć zaszyfrowaną wiadomość.',
    const NotificationDetails(android: androidPlatformChannelSpecifics),
    payload: message.data['chatId'],
  );
}

final _streamController = StreamController<RemoteMessage>();
final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class NotificationService {
  static final _notificationService = NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final _selectNotificationStreamController = StreamController<String>();

  Stream<RemoteMessage> get notification async* {
    yield* _streamController.stream;
  }

  Stream<String> get selectNotification async* {
    yield* _selectNotificationStreamController.stream;
  }

  Future<void> init() async {
    await Firebase.initializeApp();
    final token = await FirebaseMessaging.instance.getToken();
    print(token);

    FirebaseMessaging.onMessage.listen((message) async {
      _streamController.add(message);
    });

    FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler,
    );

    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   print('DUPA');
    //   _streamController.add(message);
    // });

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      if (payload != null) {
        _selectNotificationStreamController.add(payload);
      }
    });
  }

  void showNotification(notification) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'messages',
      'Messages',
      'New chat messages',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      largeIcon: FilePathAndroidBitmap(notification.image.path),
      ledColor: const Color.fromARGB(255, 255, 0, 0),
      ledOnMs: 2000,
      ledOffMs: 1000,
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      notification.title,
      notification.body,
      NotificationDetails(android: androidPlatformChannelSpecifics),
      payload: notification.id,
    );
  }

  void dispose() {
    //_foregroundStream.cancel();
    _streamController.close();
  }
}
