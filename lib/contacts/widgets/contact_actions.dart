import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/user/user.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/chats/chats.dart';

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
                          contact.id, context.read<ChatsCubit>());
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
                  context.read<ContactsCubit>().startLoading(contact.id);

                  var chat = await context
                      .read<ChatsCubit>()
                      .findDirectChatByParticipants([
                    contact.id,
                    context.read<UserCubit>().state.user.id,
                  ]);

                  if (context.mounted) {
                    chat ??= await context.read<ChatsCubit>().createChat(
                      ChatType.direct,
                      context.read<UserCubit>().state.user,
                      [contact],
                    );
                  }

                  if (context.mounted) {
                    context.read<ContactsCubit>().stopLoading(contact.id);

                    Navigator.of(context).pushNamed(
                      '/chat',
                      arguments: chat!,
                    );
                  }
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
