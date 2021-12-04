import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart';

import 'package:safechat/user/user.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/chats/chats.dart';
import 'package:safechat/utils/form_helper.dart';

class MessagesSection extends StatelessWidget {
  const MessagesSection({
    Key? key,
    required this.chatId,
  }) : super(key: key);

  final String chatId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatsCubit, ChatsState>(
      buildWhen: (previous, current) {
        return previous.chats.firstWhere((c) => c.id == chatId) !=
            current.chats.firstWhere((c) => c.id == chatId);
      },
      builder: (context, state) {
        final currentUser = context.read<UserCubit>().state.user;
        final chat = state.chats.firstWhere((c) => c.id == chatId);

        final lastSenderMsg = chat.messages.where(
          (msg) => msg.senderId == currentUser.id,
        );

        return Column(
          children: [
            Expanded(
              child: chat.messages.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.forum,
                          size: 100,
                          color: Colors.grey.shade300,
                        ),
                        Text(
                          'Brak wiadomości',
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                      ],
                    )
                  : state.listStatus == ListStatus.loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : ListView.builder(
                          reverse: true,
                          itemCount: chat.messages.length,
                          itemBuilder: (
                            BuildContext context,
                            int index,
                          ) {
                            final message = chat.messages[index];

                            final isNextText = chat.messages.length - 1 == index
                                ? false
                                : chat.messages[index + 1].content.first.type
                                        .isText &&
                                    chat.messages[index + 1].content.length ==
                                        1 &&
                                    message.senderId ==
                                        chat.messages[index + 1].senderId;

                            final isPrevText = index == 0
                                ? false
                                : chat.messages[index - 1].content.first.type
                                        .isText &&
                                    chat.messages[index - 1].content.length ==
                                        1 &&
                                    message.senderId ==
                                        chat.messages[index - 1].senderId;

                            final isLastInSet =
                                chat.messages[index == 0 ? index : index - 1]
                                            .senderId !=
                                        message.senderId ||
                                    index == 0;

                            return Padding(
                              padding: EdgeInsets.only(
                                top: isNextText && message.content.length == 1
                                    ? 2
                                    : 10,
                                left: 15.0,
                                right: 15.0,
                              ),
                              child: GestureDetector(
                                onLongPress: () {
                                  SystemChrome.setSystemUIOverlayStyle(
                                    SystemUiOverlayStyle(
                                      statusBarColor: Colors.grey.shade700,
                                    ),
                                  );
                                  showModalBottomSheet(
                                      context: context,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(
                                            10.0,
                                          ),
                                        ),
                                      ),
                                      builder: (BuildContext _) {
                                        return BlocProvider.value(
                                          value: context.read<ChatsCubit>(),
                                          child: BlocBuilder<ChatsCubit,
                                              ChatsState>(
                                            builder: (context, state) {
                                              return SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.4,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              15.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            'Opcje wiadomości',
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .headline5,
                                                          ),
                                                          if (state.formStatus
                                                              .isLoading)
                                                            Transform.scale(
                                                              scale: 0.5,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                                color: Colors
                                                                    .grey
                                                                    .shade800,
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                    ListTile(
                                                      onTap: () {
                                                        if (!state.formStatus
                                                            .isLoading) {
                                                          context
                                                              .read<
                                                                  ChatsCubit>()
                                                              .updateMessageDeletedBy(
                                                                chat.id,
                                                                message.id,
                                                              );
                                                        }
                                                      },
                                                      leading: const Icon(
                                                        Icons.delete,
                                                      ),
                                                      title: const Text(
                                                        'Usuń dla siebie',
                                                      ),
                                                    ),
                                                    if (message.senderId ==
                                                        currentUser.id)
                                                      ListTile(
                                                        onTap: () {
                                                          if (!state.formStatus
                                                              .isLoading) {
                                                            context
                                                                .read<
                                                                    ChatsCubit>()
                                                                .deleteMessage(
                                                                  chat.id,
                                                                  message.id,
                                                                );
                                                          }
                                                        },
                                                        leading: const Icon(
                                                          Icons.delete_forever,
                                                        ),
                                                        title: const Text(
                                                          'Usuń dla wszystkich',
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
                                          statusBarColor: Colors.grey.shade300,
                                        ),
                                      ));
                                },
                                child: MessageBubble(
                                  chat: chat,
                                  message: message,
                                  isNextText: isNextText,
                                  isPrevText: isPrevText,
                                  isLastInSet: isLastInSet,
                                  isLastSentMsg: lastSenderMsg.isNotEmpty
                                      ? lastSenderMsg.first == message
                                      : false,
                                ),
                              ),
                            );
                          }),
            ),
            if (chat.typing.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 15.0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 5.0,
                ),
                //color: Colors.grey.shade100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      chat.participants
                          .where((p) => chat.typing.contains(p.id))
                          .map((p) => p.firstName)
                          .join(', '),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(fontSize: 12.0),
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    const SizedBox(
                      width: 30,
                      height: 15,
                      child: RiveAnimation.asset(
                        'assets/typing_indicator.riv',
                      ),
                    ),
                  ],
                ),
              ),
            MessageTextField(
              chat: chat,
            ),
          ],
        );
      },
    );
  }
}
