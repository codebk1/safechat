import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:safechat/chats/cubits/chats/chats_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/chats/models/chat.dart';
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
    //context.read<ChatsCubit>().getChats();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/chats/create');
        },
        child: const Icon(Icons.add_comment),
        backgroundColor: Colors.blue.shade800,
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
                                  final chat = state.chats[index];
                                  final currentUser =
                                      context.read<UserCubit>().state.user;

                                  final contacts = List.of(chat.participants)
                                    ..removeWhere(
                                      (p) => p.id == currentUser.id,
                                    );

                                  final isUnreadMsg = chat.messages.any(
                                    (e) => e.unreadBy.contains(
                                      currentUser.id,
                                    ),
                                  );

                                  return BlocProvider(
                                    create: (_) => ContactsCubit(
                                      contacts: contacts,
                                    ),
                                    child: BlocBuilder<ContactsCubit,
                                        ContactsState>(
                                      builder: (context, state) {
                                        return ListTile(
                                          onLongPress: () {
                                            showModalBottomSheet(
                                                context: context,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                    top: Radius.circular(
                                                      10.0,
                                                    ),
                                                  ),
                                                ),
                                                builder: (BuildContext _) {
                                                  return SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.4,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(15.0),
                                                          child: Text(
                                                            'Opcje czatu',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .headline5,
                                                          ),
                                                        ),
                                                        if (chat.type ==
                                                            ChatType.group)
                                                          ListTile(
                                                            onTap: () {},
                                                            leading: const Icon(
                                                              Icons.logout,
                                                            ),
                                                            title: const Text(
                                                              'Opuść grupe',
                                                            ),
                                                          ),
                                                        ListTile(
                                                          onTap: () {
                                                            context
                                                                .read<
                                                                    ChatsCubit>()
                                                                .deleteChat(
                                                                    chat.id);

                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          leading: const Icon(
                                                            Icons.delete,
                                                          ),
                                                          title: const Text(
                                                            'Usuń czat',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                });
                                          },
                                          onTap: () {
                                            Navigator.of(context).pushNamed(
                                              '/chat',
                                              arguments: ChatPageArguments(
                                                chat,
                                                state.contacts,
                                              ),
                                            );
                                          },
                                          leading: const ChatAvatar(),
                                          title: Text(
                                            chat.name != null
                                                ? chat.name!
                                                : contacts.length > 1
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
                                            chat.messages.isNotEmpty
                                                ? chat.messages.first.content
                                                            .first.type ==
                                                        MessageType.text
                                                    ? chat.messages.first
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
  const ChatAvatar({Key? key}) : super(key: key);

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
