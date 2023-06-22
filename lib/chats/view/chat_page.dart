import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/common/methods/get_chat_title.dart';

import 'package:safechat/chats/chats.dart';
import 'package:safechat/user/user.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({
    Key? key,
    required this.chatId,
  }) : super(key: key);

  final String chatId;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        context.read<ChatsCubit>().closeChat(chatId);

        return Future.value(true);
      },
      child: AnnotatedRegion(
        value: const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: BlocBuilder<ChatsCubit, ChatsState>(
          builder: (context, state) {
            final chat = state.chats.firstWhere((c) => c.id == chatId);
            final participants = List.of(chat.participants)
              ..removeWhere(
                (p) => p.id == context.read<UserCubit>().state.user.id,
              );

            var lastActivityText = '';

            if (participants.isNotEmpty) {
              final formatedLastSeen = _formatLastSeen(participants
                  .reduce(
                      (a, b) => a.lastSeen!.compareTo(b.lastSeen!) < 0 ? b : a)
                  .lastSeen!);

              lastActivityText = participants.any((c) => c.isOnline)
                  ? chat.type.isGroup
                      ? 'Aktywność teraz'
                      : 'Aktywny(a) teraz'
                  : chat.type.isGroup
                      ? 'Ostatnia aktywność $formatedLastSeen'
                      : 'Aktywny(a) $formatedLastSeen';
            }

            return Scaffold(
              appBar: AppBar(
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.grey.shade300,
                  statusBarIconBrightness: Brightness.dark,
                ),
                actions: [
                  if (chat.participants.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          '/chat/info',
                          arguments: chat,
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
                title: Row(
                  children: [
                    participants.isEmpty
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
                            chat: chat,
                          ),
                    const SizedBox(
                      width: 15.0,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getChatTitle(chat, context),
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          if (participants.isNotEmpty)
                            Text(
                              lastActivityText,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  ],
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
                child: MessagesSection(chatId: chatId),
              ),
            );
          },
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
