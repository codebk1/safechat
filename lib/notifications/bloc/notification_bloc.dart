import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:safechat/notifications/models/notification.dart';
import 'package:safechat/notifications/repositories/notifications_repository.dart';
import 'package:safechat/utils/notification_service.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc({
    required NotificationsRepository notificationsRepository,
  })  : _notificationRepository = notificationsRepository,
        super(NotificationsInitial()) {
    on<NotificationRecieved>((event, emit) {
      emit(NotificationReciveSuccess(event.notification));
    });

    on<NotificationSelected>((event, emit) {
      emit(NotificationSelectSuccess(event.payload));
    });

    _notificationRepository.notification.listen((event) {
      print('akakakak $event');
      add(NotificationRecieved(event));
    });

    _notificationService.selectNotification.listen((event) {
      add(NotificationSelected(event));
    });
  }

  final NotificationsRepository _notificationRepository;
  final NotificationService _notificationService = NotificationService();
  //late final StreamSubscription<Notification> _notificationSubscription;

  @override
  Future<void> close() {
    _notificationRepository.dispose();
    //_notificationSubscription.cancel();
    return super.close();
  }
}
