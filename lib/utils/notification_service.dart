import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:safechat/common/models/notification.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final notification = NotificationData(
    id: message.data['chatId'],
    title: 'Nowa wiadomość',
    body: 'Kliknij aby zobaczyć zaszyfrowaną wiadomość.',
  );

  NotificationService().showNotification(notification);
}

class NotificationService {
  static final _notificationService = NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final _streamController = StreamController<RemoteMessage>();
  final _selectNotificationStreamController = StreamController<String>();

  Stream<RemoteMessage> get notification async* {
    yield* _streamController.stream;
  }

  Stream<String> get selectNotification async* {
    yield* _selectNotificationStreamController.stream;
  }

  Future<void> init() async {
    await Firebase.initializeApp();
    await FirebaseMessaging.instance.getToken();

    FirebaseMessaging.onMessage.listen((message) async {
      _streamController.add(message);
    });

    FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler,
    );

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

  void showNotification(NotificationData notification) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'messages',
      'Messages',
      'New chat messages',
      importance: Importance.max,
      priority: Priority.high,
      largeIcon: notification.image != null
          ? FilePathAndroidBitmap(notification.image!.path)
          : null,
      showWhen: true,
      when: DateTime.now().millisecondsSinceEpoch - 120 * 1000,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 0, 0, 255),
      ledOnMs: 1000,
      ledOffMs: 500,
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
    _streamController.close();
  }
}
