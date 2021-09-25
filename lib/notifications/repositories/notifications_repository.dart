import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:safechat/notifications/models/notification.dart';

final _streamController = StreamController<Notification>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print(message.data);
  final notification = Notification(
    title: message.data['title'],
    body: message.data['body'],
  );

  _streamController.add(notification);
}

class NotificationsRepository {
  Stream<Notification> get notification async* {
    yield* _streamController.stream;
  }

  late final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  init() async {
    await Firebase.initializeApp();

    FirebaseMessaging.instance.setAutoInitEnabled(true);

    FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler,
    );

    _foregroundStream = FirebaseMessaging.onMessage.listen((
      RemoteMessage message,
    ) {
      final notification = Notification(
        title: message.data['title'],
        body: message.data['body'],
      );

      _streamController.add(notification);
    });
  }

  Future selectNotification(String? payload) async {
    if (payload != null) {
      print('notification payload: $payload');
    }
  }

  late final StreamSubscription _foregroundStream;

  void dispose() {
    _foregroundStream.cancel();

    _streamController.close();
  }
}
