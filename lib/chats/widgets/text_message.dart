import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/user/user.dart';
import 'package:safechat/contacts/contacts.dart';

class TextMessage extends StatelessWidget {
  const TextMessage({
    Key? key,
    required this.text,
    required this.sender,
    required this.isGroupChat,
    required this.borderRadius,
  }) : super(key: key);

  final String text;
  final Contact? sender;
  final bool isGroupChat;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final isOwnMsg = sender == null
        ? false
        : sender!.id == context.read<UserCubit>().state.user.id;

    return Container(
      padding: isOwnMsg || !isGroupChat
          ? const EdgeInsets.all(10.0)
          : const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade800.withOpacity(isOwnMsg ? 1 : 0.1),
        borderRadius: borderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isOwnMsg && isGroupChat && sender != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  sender!.firstName,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2!
                      .copyWith(fontSize: 10),
                ),
              ],
            ),
          Text(
            text,
            style: TextStyle(
              color: isOwnMsg ? Colors.white : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
