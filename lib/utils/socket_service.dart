import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketService {
  static final _singleton = SocketService._internal();

  factory SocketService() {
    return _singleton;
  }

  SocketService._internal() {
    socket = io(
      dotenv.env['BASE_URL'],
      OptionBuilder().disableAutoConnect().setTransports(['websocket']).build(),
    );
  }

  late Socket socket;
}
