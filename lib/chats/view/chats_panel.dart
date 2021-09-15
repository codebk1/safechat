import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:safechat/chats/cubits/chat/chat_cubit.dart';
import 'package:safechat/chats/cubits/chats/chats_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/chats/cubits/message/message_cubit.dart';
import 'package:safechat/contacts/contacts.dart';

import 'package:safechat/home/view/panels/side_panels.dart';
import 'package:safechat/user/user.dart';

class MainPanel extends StatelessWidget {
  const MainPanel({
    Key? key,
    required GlobalKey<SidePanelsState> sidePanelsKey,
  })  : _sidePanelsKey = sidePanelsKey,
        super(key: key);

  final GlobalKey<SidePanelsState> _sidePanelsKey;

  @override
  Widget build(BuildContext context) {
    context.read<ChatsCubit>().getChats();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/chats/create');
        },
        child: Icon(Icons.add_comment),
        elevation: 0,
        focusElevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 15.0,
              left: 15.0,
              right: 15.0,
              bottom: 10.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    onPressed: () {
                      _sidePanelsKey.currentState!
                          .open(direction: Direction.left);
                    },
                    icon: const Icon(Icons.menu)),
                const Text(
                  'Czaty',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                IconButton(
                    onPressed: () {
                      _sidePanelsKey.currentState!
                          .open(direction: Direction.right);
                    },
                    icon: const Icon(Icons.people)),
              ],
            ),
          ),
          Divider(
            height: 1,
          ),
          BlocBuilder<ChatsCubit, ChatsState>(
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
                      child: RefreshIndicator(
                        onRefresh: () => context.read<ChatsCubit>().getChats(),
                        child: state.chats.length == 0
                            ? Center(
                                child: Text(
                                  'Brak konwersacji',
                                  style: Theme.of(context).textTheme.subtitle2,
                                ),
                              )
                            : ListView.builder(
                                itemCount: state.chats.length,
                                itemBuilder: (context, index) {
                                  final currentUser =
                                      context.read<UserCubit>().state.user;

                                  final chatState = state.chats[index].copyWith(
                                    message: MessageState(
                                      senderId: currentUser.id,
                                    ),
                                  );

                                  final chatCubit = ChatCubit(
                                    chatState: chatState,
                                  );

                                  // final contactCubit = ContactCubit(
                                  //   contact: chatState.participants
                                  //       .where(
                                  //         (participant) =>
                                  //             participant.id != currentUser.id,
                                  //       )
                                  //       .last,
                                  // );

                                  final contactsCubit = ContactsCubit(
                                    contactsState: ContactsState(
                                      contacts: chatState.participants
                                          .where((p) => p.id != currentUser.id)
                                          .toList(),
                                    ),
                                  );

                                  return MultiBlocProvider(
                                    providers: [
                                      BlocProvider.value(value: chatCubit),
                                      BlocProvider.value(value: contactsCubit),
                                    ],
                                    child: BlocBuilder<ChatCubit, ChatState>(
                                      builder: (context, state) {
                                        return BlocBuilder<ContactsCubit,
                                            ContactsState>(
                                          builder: (context, contactsState) {
                                            return ListTile(
                                              onTap: () {
                                                Navigator.of(context).pushNamed(
                                                  '/chat',
                                                  arguments: chatCubit,
                                                );
                                              },
                                              leading: Stack(
                                                children: [
                                                  CircleAvatar(
                                                    child: contactsState
                                                                .contacts
                                                                .first
                                                                .avatar !=
                                                            null
                                                        ? ClipOval(
                                                            child: Image.memory(
                                                                contactsState
                                                                    .contacts
                                                                    .first
                                                                    .avatar!),
                                                          )
                                                        : Icon(
                                                            Icons.person,
                                                            color: Colors
                                                                .grey.shade50,
                                                          ),
                                                    backgroundColor:
                                                        Colors.grey.shade300,
                                                  ),
                                                  Positioned(
                                                    right: 0,
                                                    bottom: 0,
                                                    child: Container(
                                                      height: 14,
                                                      width: 14,
                                                      decoration: BoxDecoration(
                                                        color: contactsState
                                                                    .contacts
                                                                    .first
                                                                    .status ==
                                                                Status.ONLINE
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
                                              title: Text(
                                                '${contactsState.contacts.first.firstName} ${contactsState.contacts.first.lastName}',
                                                style: TextStyle(
                                                  fontWeight: state.isNewMessage
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                              subtitle: Text(
                                                state.messages.length > 0
                                                    ? state
                                                                .messages
                                                                .first
                                                                .content
                                                                .first
                                                                .type ==
                                                            MessageType.TEXT
                                                        ? state.messages.first
                                                            .content.first.data
                                                        : '${contactsState.contacts.first.firstName} wysłał załącznik(-i).'
                                                    : 'Wyślij pierwszą wiadomość',
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontWeight: state.isNewMessage
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                    );
            },
          ),
        ],
      ),
    );
  }
}
