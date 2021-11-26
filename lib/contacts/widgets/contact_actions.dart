import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/router.dart';
import 'package:safechat/user/user.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/chats/cubits/chats/chats_cubit.dart';
import 'package:safechat/chats/models/chat.dart';

class ContactActions extends StatelessWidget {
  const ContactActions({
    Key? key,
    required this.contact,
  }) : super(key: key);

  final Contact contact;

  Widget _actionWidget(BuildContext context) {
    if (contact.working) {
      return Padding(
        padding: const EdgeInsets.only(right: 7.0),
        child: Transform.scale(
          scale: 0.5,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.grey.shade800,
          ),
        ),
      );
    }

    switch (contact.currentState) {
      case CurrentState.inviting:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                context.read<ContactsCubit>().acceptInvitation(contact.id);
              },
              icon: Icon(
                Icons.check_circle,
                color: Colors.green.shade800,
              ),
            ),
            IconButton(
              onPressed: () {
                context.read<ContactsCubit>().cancelInvitation(
                      contact.id,
                    );
              },
              icon: const Icon(
                Icons.cancel,
              ),
            ),
          ],
        );

      case CurrentState.pending:
        return IconButton(
          onPressed: () {
            context.read<ContactsCubit>().cancelInvitation(
                  contact.id,
                );
          },
          icon: const Icon(Icons.cancel),
        );

      case CurrentState.accepted:
        return contact.showActions
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      context.read<ContactsCubit>().deleteContact(
                            contact.id,
                            context.read<UserCubit>().state.user.id,
                          );
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red.shade800,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      context
                          .read<ContactsCubit>()
                          .toggleActionsMenu(contact.id);
                    },
                    icon: const Icon(
                      Icons.cancel,
                    ),
                  ),
                ],
              )
            : IconButton(
                onPressed: () async {
                  final newParticipants = [
                    contact.id,
                    context.read<UserCubit>().state.user.id,
                  ];

                  Chat? chat = context
                      .read<ChatsCubit>()
                      .state
                      .chats
                      .firstWhereOrNull((c) =>
                          c.participants
                              .every((p) => newParticipants.contains(p.id)) &&
                          c.participants.length == newParticipants.length &&
                          c.type == ChatType.direct);

                  if (chat == null) {
                    context.read<ContactsCubit>().startLoading(contact.id);

                    chat = await context.read<ChatsCubit>().createChat(
                      ChatType.direct,
                      context.read<UserCubit>().state.user,
                      [contact],
                    );

                    context.read<ContactsCubit>().stopLoading(contact.id);
                  }

                  Navigator.of(context).pushNamed(
                    '/chat',
                    arguments: ChatPageArguments(
                      chat!,
                      [contact],
                    ),
                  );
                },
                icon: const Icon(
                  Icons.chat,
                ),
              );

      case CurrentState.rejected:
        return IconButton(
          onPressed: () {},
          icon: const Icon(Icons.done),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _actionWidget(context);
  }
}
