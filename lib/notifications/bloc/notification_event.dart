part of 'notification_bloc.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object> get props => [];
}

class NotificationRecieved extends NotificationsEvent {
  const NotificationRecieved(this.notification);

  final Notification notification;

  @override
  List<Object> get props => [notification];
}

class NotificationSelected extends NotificationsEvent {
  const NotificationSelected(this.payload);

  final String payload;

  @override
  List<Object> get props => [payload];
}
