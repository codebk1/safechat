import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/chats/cubits/chats/chats_cubit.dart';
import 'package:safechat/chats/models/chat.dart';

import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/contacts/cubit/cubits.dart';
import 'package:safechat/router.dart';
import 'package:safechat/user/cubit/user_cubit.dart';

class ContactsPanel extends StatelessWidget {
  const ContactsPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 15.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
        ),
        color: Colors.white,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 15.0,
                left: 15.0,
                right: 15.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Znajomi',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/contacts/add');
                    },
                    icon: const Icon(Icons.person_add),
                  ),
                ],
              ),
            ),
            const Divider(),
            BlocBuilder<ContactsCubit, ContactsState>(
              builder: (context, state) {
                return state.listStatus == ListStatus.loading
                    ? Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: Colors.grey.shade300,
                        ),
                      )
                    : Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Padding(
                            //   padding:
                            //       const EdgeInsets.symmetric(horizontal: 15.0),
                            //   child: Text(
                            //     'online - 2',
                            //     style: Theme.of(context).textTheme.subtitle2,
                            //   ),
                            // ),
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: () =>
                                    context.read<ContactsCubit>().getContacts(),
                                child: state.contacts.isEmpty
                                    ? Center(
                                        child: Text(
                                          'Brak znajomych',
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2,
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: state.contacts.length,
                                        itemBuilder: (
                                          BuildContext context,
                                          int index,
                                        ) {
                                          var contact = state.contacts[index];
                                          return ListTile(
                                            onLongPress: () {
                                              context
                                                  .read<ContactsCubit>()
                                                  .toggleActionsMenu(
                                                    contact.id,
                                                  );
                                            },
                                            leading: Stack(
                                              children: [
                                                CircleAvatar(
                                                  child: contact.avatar != null
                                                      ? ClipOval(
                                                          child: Image.file(
                                                            contact.avatar!,
                                                          ),
                                                        )
                                                      : Icon(
                                                          Icons.person,
                                                          color: Colors
                                                              .grey.shade50,
                                                        ),
                                                  backgroundColor:
                                                      Colors.grey.shade300,
                                                ),
                                                if (contact.currentState !=
                                                        CurrentState.inviting &&
                                                    contact.currentState !=
                                                        CurrentState.pending)
                                                  Positioned(
                                                    right: 0,
                                                    bottom: 0,
                                                    child: Container(
                                                      height: 14,
                                                      width: 14,
                                                      decoration: BoxDecoration(
                                                        color: contact.status ==
                                                                Status.online
                                                            ? Colors.green
                                                            : Colors.grey,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          width: 2,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            title: contact.currentState ==
                                                    CurrentState.pending
                                                ? Text(
                                                    contact.email,
                                                  )
                                                : Text(
                                                    '${contact.firstName} ${contact.lastName}',
                                                  ),
                                            trailing: _ContactActions(
                                              contact: contact,
                                            ),
                                          );
                                        }),
                              ),
                            ),
                          ],
                        ),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactActions extends StatelessWidget {
  const _ContactActions({
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
        return IconButton(
          onPressed: () async {
            Chat? chat;

            var newParticipants = [
              contact.id,
              context.read<UserCubit>().state.user.id,
            ];

            var checkChats = context.read<ChatsCubit>().state.chats.where(
                (dynamic c) =>
                    c.participants
                        .every((p) => newParticipants.contains(p.id)) &&
                    c.participants.length == newParticipants.length &&
                    c.type == ChatType.direct);

            if (checkChats.isNotEmpty) {
              chat = checkChats.first;
            } else {
              context.read<ContactsCubit>().startLoading(contact.id);

              chat = await context.read<ChatsCubit>().createChat(
                ChatType.direct,
                context.read<UserCubit>().state.user,
                [contact],
              );

              context.read<ContactsCubit>().stopLoading(contact.id);
            }

            if (chat != null) {
              Navigator.of(context).pushNamed(
                '/chat',
                arguments: ChatPageArguments(
                  chat,
                  [contact],
                ),
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

      case CurrentState.deleting:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.delete,
                color: Colors.red.shade800,
              ),
            ),
            IconButton(
              onPressed: () {
                context.read<ContactsCubit>().toggleActionsMenu(contact.id);
              },
              icon: const Icon(
                Icons.cancel,
              ),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _actionWidget(context);
  }
}
