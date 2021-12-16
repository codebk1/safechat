import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:safechat/user/user.dart';
import 'package:safechat/chats/chats.dart';

String getChatTitle(Chat chat, BuildContext context) {
  final otherParticipants = List.of(chat.participants)
    ..removeWhere((p) => p.id == context.read<UserCubit>().state.user.id);

  if (chat.name != null) return chat.name!;

  return otherParticipants.isEmpty
      ? 'Brak członków w grupie'
      : chat.type.isGroup
          ? otherParticipants.map((e) => e.firstName).join(', ')
          : '${otherParticipants.first.firstName} ${otherParticipants.first.lastName}';
}
