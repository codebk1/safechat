import 'package:flutter/material.dart';
import 'package:safechat/contacts/contacts.dart';

class StatusIndicator extends StatelessWidget {
  const StatusIndicator({
    Key? key,
    required this.isOnline,
    required this.status,
    this.size,
  }) : super(key: key);

  final bool isOnline;
  final Status status;
  final double? size;

  Color _getStatusColor() {
    if (isOnline) {
      switch (status) {
        case Status.visible:
          return Colors.green;
        case Status.idle:
          return Colors.orange;
        case Status.busy:
          return Colors.red;
        case Status.invisible:
          return Colors.grey;
      }
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size ?? 14,
      width: size ?? 14,
      decoration: BoxDecoration(
        color: _getStatusColor(),
        shape: BoxShape.circle,
        border: Border.all(
          width: 2,
          color: Colors.white,
        ),
      ),
    );
  }
}
