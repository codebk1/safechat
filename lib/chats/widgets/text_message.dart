import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/user/user.dart';
import 'package:safechat/contacts/contacts.dart';

class TextMessage extends StatelessWidget {
  const TextMessage({
    Key? key,
    required this.text,
    required this.sender,
  }) : super(key: key);

  final String text;
  final Contact sender;

  @override
  Widget build(BuildContext context) {
    final isOwnMsg = sender.id == context.read<UserCubit>().state.user.id;

    return Container(
      padding: isOwnMsg
          ? const EdgeInsets.all(10.0)
          : const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade800.withOpacity(isOwnMsg ? 1 : 0.1),
        borderRadius: BorderRadius.circular(10),
        // borderRadius: BorderRadius.only(
        //     topLeft: Radius.circular(10),
        //     bottomLeft: Radius.circular(10),
        //     topRight: Radius.circular(10),
        //     bottomRight: Radius.circular(20))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isOwnMsg)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  sender.firstName,
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
