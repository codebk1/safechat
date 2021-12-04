import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/router.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/chats/chats.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    Key? key,
    required this.chatId,
  }) : super(key: key);

  final String chatId;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        context.read<ChatsCubit>().closeChat(widget.chatId);

        return Future.value(true);
      },
      child: AnnotatedRegion(
        value: const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          appBar: AppBar(
            systemOverlayStyle: const SystemUiOverlayStyle(
              //statusBarColor: Colors.grey.shade300,
              statusBarIconBrightness: Brightness.dark,
            ),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    '/chat/info',
                    arguments: ChatPageArguments(
                      context
                          .read<ChatsCubit>()
                          .state
                          .chats
                          .firstWhere((c) => c.id == widget.chatId),
                      context.read<ContactsCubit>().state.contacts,
                    ),
                  );
                },
                icon: const Icon(Icons.info),
              ),
            ],
            backgroundColor: Colors.white,
            titleSpacing: 0,
            elevation: 0,
            iconTheme: IconThemeData(
              color: Colors.grey.shade800,
            ),
            title: BlocBuilder<ContactsCubit, ContactsState>(
              builder: (context, state) {
                // final contacts = state.contacts
                //     .where((contact) =>
                //         chat.participants.map((p) => p.id).contains(contact.id))
                //     .toList();

                return BlocBuilder<ChatsCubit, ChatsState>(
                  builder: (context, chatsState) {
                    final chat =
                        context.read<ChatsCubit>().state.chats.firstWhere(
                              (c) => c.id == widget.chatId,
                            );

                    final contactsTitle = state.contacts.isEmpty
                        ? 'Brak członków w grupie'
                        : state.contacts.length > 1
                            ? state.contacts.map((e) => e.firstName).join(', ')
                            : '${state.contacts.first.firstName} ${state.contacts.first.lastName}';

                    final chatTitle =
                        chat.name != null ? chat.name! : contactsTitle;

                    final formatedLastSeen = _formatLastSeen(state.contacts
                        .reduce((a, b) =>
                            a.lastSeen!.compareTo(b.lastSeen!) < 0 ? b : a)
                        .lastSeen!);

                    final lastActivityText =
                        state.contacts.any((c) => c.isOnline)
                            ? chat.type.isGroup
                                ? 'Aktywność teraz'
                                : 'Aktywny(a) teraz'
                            : chat.type.isGroup
                                ? 'Ostatnia aktywność $formatedLastSeen'
                                : 'Aktywny(a) $formatedLastSeen';

                    return Row(
                      children: [
                        state.contacts.isEmpty
                            ? ClipOval(
                                child: Container(
                                  width: 45,
                                  height: 45,
                                  color: Colors.grey.shade100,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              )
                            : ChatAvatar(
                                avatar: chat.avatar,
                              ),
                        const SizedBox(
                          width: 15.0,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chatTitle,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.headline6,
                              ),
                              if (state.contacts.isNotEmpty)
                                Text(
                                  lastActivityText,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2!
                                      .copyWith(fontSize: 12),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          body: GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus &&
                  currentFocus.focusedChild != null) {
                FocusManager.instance.primaryFocus!.unfocus();
              }
            },
            child: MessagesSection(chatId: widget.chatId),
          ),
        ),
      ),
    );
  }
}

String _formatLastSeen(DateTime date) {
  final difference = DateTime.now().difference(date);

  if (difference.inDays > 0) {
    var diff = difference.inDays;

    return diff == 1 ? '$diff dzień temu' : '$diff dni temu';
  } else if (difference.inHours > 0) {
    var diff = difference.inHours;
    return diff == 1 ? '$diff godzinę temu' : '$diff godzin temu';
  } else if (difference.inMinutes > 0) {
    var diff = difference.inMinutes;
    return diff == 1 ? '$diff minutę temu' : '$diff minut temu';
  } else {
    return 'przed chwilą';
  }
}
