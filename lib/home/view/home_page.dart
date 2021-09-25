import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/home/view/panels/panels.dart';
import 'package:safechat/notifications/bloc/notification_bloc.dart';
import 'package:safechat/utils/notification_service.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final GlobalKey<SidePanelsState> _sidePanelsKey =
      GlobalKey<SidePanelsState>();

  final _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationsBloc, NotificationsState>(
      listener: (context, state) async {
        if (state is NotificationReciveSuccess) {
          const androidPlatformChannelSpecifics = AndroidNotificationDetails(
            'messages',
            'Messages',
            'New chat messages',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
          );

          await _notificationService.flutterLocalNotificationsPlugin.show(
            0,
            state.notification.title,
            state.notification.body,
            const NotificationDetails(android: androidPlatformChannelSpecifics),
            payload: 'item x',
          );
        }

        if (state is NotificationSelectSuccess) {
          print('payload: ${state.payload}');
        }
      },
      child: SafeArea(
        child: SidePanels(
          key: _sidePanelsKey,
          leftPanel: const LeftPanel(),
          rightPanel: const ContactsPanel(),
          mainPanel: MainPanel(sidePanelsKey: _sidePanelsKey),
        ),
      ),
    );
  }
}
