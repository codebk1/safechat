import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart';

import 'package:safechat/user/user.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/chats/chats.dart';

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
                            final isLastInSet =
                                chat.messages[index == 0 ? index : index - 1]
                                            .senderId !=
                                        message.senderId ||
                                    index == 0;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                              ),
                              child: GestureDetector(
                                onLongPress: () {
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
                                                    const EdgeInsets.all(15.0),
                                                child: Text(
                                                  'Opcje wiadomości',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline5,
                                                ),
                                              ),
                                              ListTile(
                                                onTap: () {
                                                  Navigator.of(context).pop();
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
                                                    context
                                                        .read<ChatsCubit>()
                                                        .deleteMessage(
                                                          chat.id,
                                                          message.id,
                                                        );

                                                    Navigator.of(context).pop();
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
                                      });
                                },
                                child: MessageBubble(
                                  chat: chat,
                                  message: message,
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
