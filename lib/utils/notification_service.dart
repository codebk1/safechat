import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _notificationService = NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final _selectNotificationStreamController = StreamController<String>();

  Stream<String> get selectNotification async* {
    yield* _selectNotificationStreamController.stream;
  }

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      if (payload != null) {
        print('notification payload: ' + payload);
        _selectNotificationStreamController.add(payload);
      }
    });
  }
}
