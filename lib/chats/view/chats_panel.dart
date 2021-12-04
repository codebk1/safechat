import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/common/common.dart';

import 'package:safechat/router.dart';
import 'package:safechat/user/user.dart';
import 'package:safechat/home/view/panels/side_panels.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/chats/chats.dart';
import 'package:safechat/utils/form_helper.dart';

class MainPanel extends StatelessWidget {
  const MainPanel({
    Key? key,
    required GlobalKey<SidePanelsState> sidePanelsKey,
  })  : _sidePanelsKey = sidePanelsKey,
        super(key: key);

  final GlobalKey<SidePanelsState> _sidePanelsKey;

  @override
  Widget build(BuildContext context) {
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
          BlocConsumer<ChatsCubit, ChatsState>(
            listenWhen: (prev, curr) => prev.formStatus != curr.formStatus,
            listener: (context, state) {
              if (state.formStatus.isSuccess) {
                Navigator.of(
                  context,
                ).pop();

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    getSuccessSnackBar(
                      context,
                      successText: state.formStatus.message!,
                    ),
                  );
              }
            },
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
                                      builder: (context, contactsState) {
                                        final contactsTitle = contacts.isEmpty
                                            ? 'Brak członków w grupie'
                                            : contacts.length > 1
                                                ? contacts
                                                    .map((e) => e.firstName)
                                                    .join(', ')
                                                : '${contacts.first.firstName} ${contacts.first.lastName}';

                                        final chatTitle = chat.name != null
                                            ? chat.name!
                                            : contactsTitle;

                                        return ListTile(
                                          onLongPress: () {
                                            SystemChrome
                                                .setSystemUIOverlayStyle(
                                              SystemUiOverlayStyle(
                                                statusBarColor:
                                                    Colors.grey.shade700,
                                              ),
                                            );
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
                                                  return BlocProvider.value(
                                                    value: context
                                                        .read<ChatsCubit>(),
                                                    child: BlocBuilder<
                                                        ChatsCubit, ChatsState>(
                                                      builder:
                                                          (context, state) {
                                                        return SizedBox(
                                                          height: MediaQuery.of(
                                                                      context)
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
                                                                            .all(
                                                                        15.0),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                      'Opcje czatu',
                                                                      style: Theme.of(
                                                                              context)
                                                                          .textTheme
                                                                          .headline5,
                                                                    ),
                                                                    if (state
                                                                        .formStatus
                                                                        .isLoading)
                                                                      Transform
                                                                          .scale(
                                                                        scale:
                                                                            0.5,
                                                                        child:
                                                                            CircularProgressIndicator(
                                                                          strokeWidth:
                                                                              2,
                                                                          color: Colors
                                                                              .grey
                                                                              .shade800,
                                                                        ),
                                                                      ),
                                                                  ],
                                                                ),
                                                              ),
                                                              if (chat.type ==
                                                                  ChatType
                                                                      .group)
                                                                ListTile(
                                                                  onTap: () {
                                                                    if (!state
                                                                        .formStatus
                                                                        .isLoading) {
                                                                      context
                                                                          .read<
                                                                              ChatsCubit>()
                                                                          .leaveChat(
                                                                            chat.id,
                                                                          );
                                                                    }
                                                                  },
                                                                  leading:
                                                                      const Icon(
                                                                    Icons
                                                                        .logout,
                                                                  ),
                                                                  title:
                                                                      const Text(
                                                                    'Opuść grupe',
                                                                  ),
                                                                ),
                                                              ListTile(
                                                                onTap: () {
                                                                  if (!state
                                                                      .formStatus
                                                                      .isLoading) {
                                                                    context
                                                                        .read<
                                                                            ChatsCubit>()
                                                                        .deleteChat(
                                                                          chat.id,
                                                                        );
                                                                  }
                                                                },
                                                                leading:
                                                                    const Icon(
                                                                  Icons.delete,
                                                                ),
                                                                title:
                                                                    const Text(
                                                                  'Usuń czat',
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  );
                                                }).whenComplete(() => SystemChrome
                                                    .setSystemUIOverlayStyle(
                                                  SystemUiOverlayStyle(
                                                    statusBarColor:
                                                        Colors.grey.shade300,
                                                  ),
                                                ));
                                          },
                                          onTap: () {
                                            Navigator.of(context).pushNamed(
                                              '/chat',
                                              arguments: ChatPageArguments(
                                                chat,
                                                contactsState.contacts,
                                              ),
                                            );
                                          },
                                          leading: contactsState
                                                  .contacts.isEmpty
                                              ? ClipOval(
                                                  child: Container(
                                                    width: 45,
                                                    height: 45,
                                                    color: Colors.grey.shade100,
                                                    child: Icon(
                                                      Icons.person,
                                                      color:
                                                          Colors.grey.shade300,
                                                    ),
                                                  ),
                                                )
                                              : ChatAvatar(
                                                  avatar: chat.avatar,
                                                ),
                                          title: Text(
                                            chatTitle,
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
  const ChatAvatar({
    Key? key,
    this.avatar,
  }) : super(key: key);

  final File? avatar;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactsCubit, ContactsState>(
      builder: (context, state) {
        final firstOnline = state.contacts.firstWhereOrNull((c) => c.isOnline);
        return Stack(
          children: [
            ClipOval(
              child: Container(
                width: 45,
                height: 45,
                color: Colors.grey.shade100,
                child: avatar != null
                    ? ClipOval(
                        child: Image.file(
                          avatar!,
                        ),
                      )
                    : Flex(
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
              child: StatusIndicator(
                isOnline: firstOnline != null,
                status:
                    firstOnline != null ? firstOnline.status : Status.visible,
              ),
            ),
          ],
        );
      },
    );
  }
}
