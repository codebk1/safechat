part of 'notification_bloc.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object> get props => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationReciveSuccess extends NotificationsState {
  const NotificationReciveSuccess(this.notification);

  final Notification notification;

  @override
  List<Object> get props => [notification];
}

class NotificationSelectSuccess extends NotificationsState {
  const NotificationSelectSuccess(this.payload);

  final String payload;

  @override
  List<Object> get props => [payload];
}
