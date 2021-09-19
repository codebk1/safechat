import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'package:flutter/material.dart';

import 'package:open_file/open_file.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart';
import 'package:safechat/chats/cubits/attachments/attachments_cubit.dart';

import 'package:safechat/chats/cubits/chat/chat_cubit.dart';
import 'package:safechat/chats/models/attachment.dart';
import 'package:safechat/chats/models/message.dart';
import 'package:safechat/chats/view/chats_panel.dart';
import 'package:safechat/chats/view/widgets/message_text_field.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/router.dart';
import 'package:safechat/user/user.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({
    Key? key,
    required this.chatCubit,
    required this.contactsCubit,
  }) : super(key: key);

  final ChatCubit chatCubit;
  final ContactsCubit contactsCubit;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: chatCubit
            ..emit(chatCubit.state.copyWith(
              opened: true,
            )),
        ),
        BlocProvider.value(
          value: contactsCubit,
        ),
      ],
      child: WillPopScope(
        onWillPop: () {
          chatCubit.emit(chatCubit.state.copyWith(
            opened: false,
          ));

          return Future.value(true);
        },
        child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () {},
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
                return Row(
                  children: [
                    const ChatAvatar(),
                    const SizedBox(
                      width: 15.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.contacts.length > 1
                              ? state.contacts
                                  .map((e) => e.firstName)
                                  .join(', ')
                              : '${state.contacts.first.firstName} ${state.contacts.first.lastName}',
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        Text(
                          'Ostatnia aktywność 5min temu',
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
            child: const MessagesSection(),
          ),
        ),
      ),
    );
  }
}

class MessagesSection extends StatelessWidget {
  const MessagesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        final currentUser = context.read<UserCubit>().state.user;

        final lastSenderMsg = state.messages.where(
          (msg) => msg.senderId == currentUser.id,
        );

        return Column(
          children: [
            Expanded(
              child: state.messages.isEmpty
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
                          itemCount: state.messages.length,
                          itemBuilder: (
                            BuildContext context,
                            int index,
                          ) {
                            final isLastInSet =
                                state.messages[index == 0 ? index : index - 1]
                                            .senderId !=
                                        state.messages[index].senderId ||
                                    index == 0;

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15.0,
                              ),
                              child: MessageBubble(
                                message: state.messages[index],
                                isLastInSet: isLastInSet,
                                isLastSentMsg: lastSenderMsg.isNotEmpty
                                    ? lastSenderMsg.first ==
                                        state.messages[index]
                                    : false,
                              ),
                            );
                          }),
            ),
            if (state.typing.isNotEmpty)
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
                      state.participants
                          .where((p) => state.typing.contains(p.id))
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
            const MessageTextField(),
          ],
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    Key? key,
    required this.message,
    required this.isLastInSet,
    required this.isLastSentMsg,
  }) : super(key: key);

  final Message message;
  final bool isLastInSet;
  final bool isLastSentMsg;

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<UserCubit>().state.user;

    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, chatState) {
        final isSender = message.senderId == currentUser.id;

        // TODO: refactor to use Contact object in Message model instead of just senderId
        final sender = chatState.participants.firstWhere(
          (e) => e.id == message.senderId,
        );

        final readBy = chatState.participants.where(
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
                                    child: Container(
                                      height: 12,
                                      width: 12,
                                      decoration: BoxDecoration(
                                        color: contact.status == Status.online
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
                          )
                        : const SizedBox(width: 28),
                    const SizedBox(width: 10.0),
                  ],
                ],
              ),
              Flex(
                direction: chatState.participants.length > 2
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
                          if (photos.isNotEmpty) PhotoMessage(photos: photos),
                          if (videos.isNotEmpty) VideosMessage(videos: videos),
                          if (files.isNotEmpty) FilesMessage(files: files),
                          const SizedBox(height: 5),
                          if (textMessage.isNotEmpty)
                            TextMessage(text: textMessage, sender: sender)
                        ]),
                  ),
                  if (isSender) ...[
                    if (chatState.participants.length == 2)
                      const SizedBox(width: 2.0),
                    isLastSentMsg
                        ? readBy.isNotEmpty
                            ? chatState.participants.length > 2
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
    required this.photos,
  }) : super(key: key);

  final List<Attachment> photos;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
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
              future: context.read<ChatCubit>().getAttachment(photos[index]),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        '/chat/media',
                        arguments: MediaPageArguments(
                          context.read<ChatCubit>(),
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
                        cacheWidth: (MediaQuery.of(context).size.width).round(),
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
        });
  }
}

class VideosMessage extends StatelessWidget {
  const VideosMessage({
    Key? key,
    required this.videos,
  }) : super(key: key);

  final List<Attachment> videos;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
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
              future: context.read<ChatCubit>().getAttachment(videos[index]),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
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
                            context.read<ChatCubit>(),
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
        });
  }
}

class FilesMessage extends StatelessWidget {
  const FilesMessage({
    Key? key,
    required this.files,
  }) : super(key: key);

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
                                          context.read<ChatCubit>().state,
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
