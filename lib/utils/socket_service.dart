import 'package:socket_io_client/socket_io_client.dart';

class SocketService {
  static final SocketService _singleton = SocketService._internal();

  factory SocketService() {
    return _singleton;
  }

  SocketService._internal() {
    socket = io(
      'https://ecae-95-40-109-89.ngrok.io',
      OptionBuilder().disableAutoConnect().setTransports(['websocket']).build(),
    );
  }

  late Socket socket;
}
