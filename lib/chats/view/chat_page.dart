import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart';
import 'package:open_file/open_file.dart';

import 'package:safechat/router.dart';
import 'package:safechat/user/user.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/chats/chats.dart';

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
      child: Scaffold(
        appBar: AppBar(
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
                        .firstWhere((c) => c.id == chatId),
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
                            (c) => c.id == chatId,
                          );

                  return Row(
                    children: [
                      ChatAvatar(
                        avatar: chat.avatar,
                      ),
                      const SizedBox(
                        width: 15.0,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chat.name != null
                                ? chat.name!
                                : state.contacts.length > 2
                                    ? state.contacts
                                        .map((e) => e.firstName)
                                        .join(', ')
                                    : '${state.contacts.first.firstName} ${state.contacts.first.lastName}',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          Text(
                            state.contacts.first.isOnline
                                ? 'Aktywny(a) teraz'
                                : 'Aktywny(a) ${_formatLastSeen(state.contacts.first.lastSeen!)} temu',
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle2!
                                .copyWith(fontSize: 12),
                          ),
                        ],
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
          child: MessagesSection(chatId: chatId),
        ),
      ),
    );
  }
}

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
        print('DUPA BLADA');
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

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    Key? key,
    required this.chat,
    required this.message,
    required this.isLastInSet,
    required this.isLastSentMsg,
  }) : super(key: key);

  final Chat chat;
  final Message message;
  final bool isLastInSet;
  final bool isLastSentMsg;

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<UserCubit>().state.user;

    return Builder(
      builder: (context) {
        final isSender = message.senderId == currentUser.id;

        // TODO: refactor to use Contact object in Message model instead of just senderId
        print(chat);
        final sender = chat.participants.firstWhere(
          (e) => e.id == message.senderId,
        );

        final readBy = chat.participants.where(
          (e) => !message.unreadBy.contains(e.id) && e.id != currentUser.id,
        );

        String textMessage = '';
        List<Attachment> photos = [];
        List<Attachment> videos = [];
        List<Attachment> files = [];

        for (var item in message.content) {
          switch (item.type) {
            case MessageType.text:
              textMessage = item.data;
              break;
            case MessageType.photo:
              photos.add(Attachment(
                name: item.data,
                type: AttachmentType.photo,
              ));
              break;
            case MessageType.video:
              videos.add(Attachment(
                name: item.data,
                type: AttachmentType.video,
              ));
              break;
            case MessageType.file:
              files.add(Attachment(
                name: item.data,
                type: AttachmentType.file,
              ));
              break;
          }
        }
        return Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Row(
            mainAxisAlignment:
                isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  if (!isSender) ...[
                    isLastInSet
                        ? BlocBuilder<ContactsCubit, ContactsState>(
                            builder: (context, state) {
                              final contact = state.contacts.firstWhere(
                                (p) => p.id == message.senderId,
                              );

                              return Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    child: contact.avatar != null
                                        ? ClipOval(
                                            child: Image.file(
                                              contact.avatar,
                                            ),
                                          )
                                        : Icon(
                                            Icons.person,
                                            color: Colors.grey.shade50,
                                          ),
                                    backgroundColor: Colors.grey.shade300,
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: StatusIndicator(
                                      isOnline: contact.isOnline,
                                      status: contact.status,
                                      size: 10,
                                    ),
                                  ),
                                ],
                              );
                            },
                          )
                        : const SizedBox(width: 28),
                    const SizedBox(width: 10.0),
                  ],
                ],
              ),
              Flex(
                direction: chat.participants.length > 2
                    ? Axis.vertical
                    : Axis.horizontal,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (photos.isNotEmpty)
                            PhotoMessage(chat: chat, photos: photos),
                          if (videos.isNotEmpty)
                            VideosMessage(chat: chat, videos: videos),
                          if (files.isNotEmpty)
                            FilesMessage(chat: chat, files: files),
                          const SizedBox(height: 5),
                          if (textMessage.isNotEmpty)
                            TextMessage(text: textMessage, sender: sender)
                        ]),
                  ),
                  if (isSender) ...[
                    if (chat.participants.length == 2)
                      const SizedBox(width: 2.0),
                    isLastSentMsg
                        ? readBy.isNotEmpty
                            ? chat.participants.length > 2
                                ? Row(
                                    children: readBy
                                        .map((e) => Padding(
                                              padding: const EdgeInsets.all(
                                                2.0,
                                              ),
                                              child: CircleAvatar(
                                                radius: 8,
                                                child: e.avatar != null
                                                    ? ClipOval(
                                                        child: Image.file(
                                                            e.avatar!),
                                                      )
                                                    : Icon(
                                                        Icons.person,
                                                        size: 12,
                                                        color:
                                                            Colors.grey.shade50,
                                                      ),
                                                backgroundColor:
                                                    Colors.grey.shade300,
                                              ),
                                            ))
                                        .toList(),
                                  )
                                : CircleAvatar(
                                    radius: 8,
                                    child: readBy.first.avatar != null
                                        ? ClipOval(
                                            child: Image.file(
                                                readBy.first.avatar!),
                                          )
                                        : Icon(
                                            Icons.person,
                                            size: 12,
                                            color: Colors.grey.shade50,
                                          ),
                                    backgroundColor: Colors.grey.shade300,
                                  )
                            : message.status == MessageStatus.deleting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: Padding(
                                      padding: EdgeInsets.all(2.0),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    message.status == MessageStatus.sending
                                        ? Icons.check_circle_outline
                                        : Icons.check_circle,
                                    size: 16,
                                    color: Colors.blue.shade800,
                                  )
                        : const SizedBox(width: 16)
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class TextMessage extends StatelessWidget {
  const TextMessage({
    Key? key,
    required this.text,
    required this.sender,
  }) : super(key: key);

  final String text;
  final Contact sender;

  @override
  Widget build(BuildContext context) {
    final isOwnMsg = sender.id == context.read<UserCubit>().state.user.id;

    return Container(
      padding: isOwnMsg
          ? const EdgeInsets.all(10.0)
          : const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade800.withOpacity(isOwnMsg ? 1 : 0.1),
        borderRadius: BorderRadius.circular(10),
        // borderRadius: BorderRadius.only(
        //     topLeft: Radius.circular(10),
        //     bottomLeft: Radius.circular(10),
        //     topRight: Radius.circular(10),
        //     bottomRight: Radius.circular(20))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isOwnMsg)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  sender.firstName,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2!
                      .copyWith(fontSize: 10),
                ),
              ],
            ),
          Text(
            text,
            style: TextStyle(
              color: isOwnMsg ? Colors.white : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

class PhotoMessage extends StatelessWidget {
  const PhotoMessage({
    Key? key,
    required this.chat,
    required this.photos,
  }) : super(key: key);

  final Chat chat;
  final List<Attachment> photos;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AttachmentsCubit(),
      child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: min(photos.length, 3),
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
          ),
          itemCount: photos.length,
          itemBuilder: (BuildContext context, index) {
            return FutureBuilder(
                future: context
                    .read<AttachmentsCubit>()
                    .getAttachment(chat, photos[index]),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/chat/media',
                          arguments: MediaPageArguments(
                            chat,
                            photos[index],
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                        child: Image.file(
                          snapshot.data!,
                          fit: BoxFit.cover,
                          frameBuilder: (BuildContext context, Widget child,
                              int? frame, bool wasSynchronouslyLoaded) {
                            if (wasSynchronouslyLoaded) {
                              return child;
                            }
                            return AnimatedOpacity(
                              child: child,
                              opacity: frame == null ? 0 : 1,
                              duration: const Duration(seconds: 1),
                              curve: Curves.easeOut,
                            );
                          },
                          cacheWidth:
                              (MediaQuery.of(context).size.width).round(),
                          filterQuality: FilterQuality.medium,
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }
                });
          }),
    );
  }
}

class VideosMessage extends StatelessWidget {
  const VideosMessage({
    Key? key,
    required this.chat,
    required this.videos,
  }) : super(key: key);

  final Chat chat;
  final List<Attachment> videos;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AttachmentsCubit(),
      child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: min(videos.length, 3),
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
          ),
          itemCount: videos.length,
          itemBuilder: (BuildContext context, index) {
            return FutureBuilder(
                future: context
                    .read<AttachmentsCubit>()
                    .getAttachment(chat, videos[index]),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    return ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/chat/video',
                            arguments: MediaPageArguments(
                              chat,
                              videos[index],
                            ),
                          );
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              snapshot.data!,
                              fit: BoxFit.cover,
                              frameBuilder: (
                                BuildContext context,
                                Widget child,
                                int? frame,
                                bool wasSynchronouslyLoaded,
                              ) {
                                if (wasSynchronouslyLoaded) {
                                  return child;
                                }
                                return AnimatedOpacity(
                                  child: child,
                                  opacity: frame == null ? 0 : 1,
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.easeOut,
                                );
                              },
                            ),
                            const DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.black26,
                              ),
                            ),
                            const Align(
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.play_circle,
                                color: Colors.white,
                                size: 60,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }
                });
          }),
    );
  }
}

class FilesMessage extends StatelessWidget {
  const FilesMessage({
    Key? key,
    required this.chat,
    required this.files,
  }) : super(key: key);

  final Chat chat;
  final List<Attachment> files;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: BlocProvider(
        create: (context) => AttachmentsCubit(attachments: files),
        child: BlocBuilder<AttachmentsCubit, AttachmentsState>(
          builder: (context, state) {
            return Column(
              children:
                  List<Widget>.generate(state.attachments.length, (index) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          state.attachments[index].downloading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.blue.shade800,
                                    strokeWidth: 1,
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () async {
                                    final attachment = await context
                                        .read<AttachmentsCubit>()
                                        .downloadAttachment(
                                          state.attachments[index].name,
                                          chat,
                                        );

                                    if (attachment.existsSync()) {
                                      ScaffoldMessenger.of(context)
                                        ..hideCurrentSnackBar()
                                        ..showSnackBar(
                                          SnackBar(
                                            action: SnackBarAction(
                                              onPressed: () => OpenFile.open(
                                                attachment.path,
                                              ),
                                              label: 'Wyświetl',
                                            ),
                                            content: Row(
                                              children: const <Widget>[
                                                Icon(
                                                  Icons.error,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(
                                                  width: 10.0,
                                                ),
                                                Text('Pobrano załącznik'),
                                              ],
                                            ),
                                          ),
                                        );
                                    }
                                  },
                                  child: const Icon(Icons.download),
                                ),
                          const SizedBox(width: 15.0),
                          Text(state.attachments[index].name),
                        ],
                      ),
                    ),
                    if (index != state.attachments.length - 1)
                      Divider(
                        color: Colors.grey.shade300,
                        height: 1,
                      ),
                  ],
                );
              }),
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

    return diff == 1 ? '$diff dzień' : '$diff dni';
  } else if (difference.inHours > 0) {
    var diff = difference.inHours;
    return diff == 1 ? '$diff godzinę' : '$diff godzin';
  } else if (difference.inMinutes > 0) {
    var diff = difference.inMinutes;
    return diff == 1 ? '$diff minutę' : '$diff minut';
  } else {
    return 'przed chwilą';
  }
}
