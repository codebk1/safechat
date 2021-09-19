import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:safechat/chats/cubits/chat/chat_cubit.dart';
import 'package:safechat/chats/cubits/chats/chats_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/chats/models/message.dart';
import 'package:safechat/contacts/contacts.dart';

import 'package:safechat/home/view/panels/side_panels.dart';
import 'package:safechat/router.dart';
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
        child: const Icon(Icons.add_comment),
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
          const Divider(
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
                        child: state.chats.isEmpty
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

                                  final contacts =
                                      List.of(state.chats[index].participants)
                                        ..removeWhere(
                                          (p) => p.id == currentUser.id,
                                        );

                                  return MultiBlocProvider(
                                    providers: [
                                      BlocProvider(
                                        create: (_) => ChatCubit(
                                          chatState:
                                              state.chats[index].copyWith(
                                            message: Message(
                                              senderId: currentUser.id,
                                            ),
                                          ),
                                          currentUser: currentUser,
                                        ),
                                      ),
                                      BlocProvider(
                                        create: (_) => ContactsCubit(
                                          contactsState:
                                              ContactsState(contacts: contacts),
                                        ),
                                      ),
                                    ],
                                    child: BlocBuilder<ChatCubit, ChatState>(
                                      builder: (context, chatState) {
                                        var isUnreadMsg =
                                            chatState.messages.any(
                                          (e) => e.unreadBy.contains(
                                            currentUser.id,
                                          ),
                                        );

                                        return ListTile(
                                          onTap: () {
                                            context
                                                .read<ChatCubit>()
                                                .readAllMessages(
                                                  currentUser.id,
                                                );

                                            Navigator.of(context).pushNamed(
                                              '/chat',
                                              arguments: ChatPageArguments(
                                                context.read<ChatCubit>(),
                                                context.read<ContactsCubit>(),
                                              ),
                                            );
                                          },
                                          leading: const ChatAvatar(),
                                          title: Text(
                                            contacts.length > 1
                                                ? contacts
                                                    .map((e) => e.firstName)
                                                    .join(', ')
                                                : '${contacts.first.firstName} ${contacts.first.lastName}',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: isUnreadMsg
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                          subtitle: Text(
                                            chatState.messages.isNotEmpty
                                                ? chatState
                                                            .messages
                                                            .first
                                                            .content
                                                            .first
                                                            .type ==
                                                        MessageType.text
                                                    ? chatState.messages.first
                                                        .content.first.data
                                                    : '${contacts.first.firstName} wysłał załącznik(-i).'
                                                : 'Wyślij pierwszą wiadomość',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontWeight: isUnreadMsg
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
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

class ChatAvatar extends StatelessWidget {
  const ChatAvatar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactsCubit, ContactsState>(
      builder: (context, state) {
        return Stack(
          children: [
            ClipOval(
              child: Container(
                width: 45,
                height: 45,
                color: Colors.grey.shade100,
                child: Flex(
                  direction: Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Flexible(
                      //fit: FlexFit.tight,
                      child: Flex(
                        direction: Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: state.contacts
                            .take(2)
                            .map(
                              (contact) => Flexible(
                                fit: FlexFit.tight,
                                child: FittedBox(
                                  fit: BoxFit.cover,
                                  clipBehavior: Clip.antiAlias,
                                  child: contact.avatar != null
                                      ? Image.file(
                                          contact.avatar!,
                                        )
                                      : Icon(
                                          Icons.person,
                                          color: Colors.grey.shade300,
                                        ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    if (state.contacts.length > 2)
                      Flexible(
                        fit: FlexFit.tight,
                        child: Flex(
                          direction: Axis.horizontal,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: state.contacts
                              .skip(2)
                              .take(2)
                              .map(
                                (contact) => Flexible(
                                  fit: FlexFit.tight,
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    clipBehavior: Clip.antiAlias,
                                    child: contact.avatar != null
                                        ? Image.file(
                                            contact.avatar!,
                                          )
                                        : Icon(
                                            Icons.person,
                                            color: Colors.grey.shade300,
                                          ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                height: 14,
                width: 14,
                decoration: BoxDecoration(
                  color: state.contacts.any(
                    (contact) => contact.status == Status.online,
                  )
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
        );
      },
    );
  }
}
