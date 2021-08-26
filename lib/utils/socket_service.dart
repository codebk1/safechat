import 'package:socket_io_client/socket_io_client.dart';

class SocketService {
  static final SocketService _singleton = SocketService._internal();

  factory SocketService() {
    return _singleton;
  }

  SocketService._internal() {
    socket = io(
      'https://1b6c-77-114-138-177.ngrok.io',
      OptionBuilder().disableAutoConnect().setTransports(['websocket']).build(),
    );
  }

  late Socket socket;
}
