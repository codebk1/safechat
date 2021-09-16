import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'package:flutter/material.dart';

import 'package:open_file/open_file.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart';
import 'package:safechat/chats/cubits/attachment/attachment_cubit.dart';

import 'package:safechat/chats/cubits/chat/chat_cubit.dart';
import 'package:safechat/chats/cubits/message/message_cubit.dart';
import 'package:safechat/chats/view/chats_panel.dart';
import 'package:safechat/chats/view/widgets/message_text_field.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/router.dart';
import 'package:safechat/user/user.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({Key? key, required this.chatCubit}) : super(key: key);

  final ChatCubit chatCubit;

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<UserCubit>().state.user;

    return BlocProvider.value(
      value: chatCubit..readAllMessages(currentUser.id),
      child: WillPopScope(
        onWillPop: () {
          // chatCubit.emit(chatCubit.state.copyWith(
          //   isNewMessage: false,
          // ));

          return Future.value(true);
        },
        child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.info),
              ),
            ],
            backgroundColor: Colors.white,
            titleSpacing: 0,
            elevation: 0,
            iconTheme: IconThemeData(
              color: Colors.grey.shade800,
            ),
            title: BlocProvider(
              create: (context) => ContactsCubit(
                contactsState: ContactsState(
                    contacts: chatCubit.state.participants
                        .where((p) => p.id != currentUser.id)
                        .toList()),
              ),
              child: BlocBuilder<ContactsCubit, ContactsState>(
                builder: (context, state) {
                  return Row(
                    children: [
                      ChatAvatar(participants: state.contacts),
                      SizedBox(
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
          ),
          body: GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus &&
                  currentFocus.focusedChild != null) {
                FocusManager.instance.primaryFocus!.unfocus();
              }
            },
            child: MessagesSection(),
          ),
        ),
      ),
    );
  }
}

class MessagesSection extends StatelessWidget {
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
              child: state.messages.length == 0
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
                      ? Center(
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
                                messageCubit: MessageCubit(
                                  messageState: state.messages[index],
                                ),
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
                    SizedBox(
                      width: 5.0,
                    ),
                    Container(
                      width: 30,
                      height: 15,
                      child: RiveAnimation.asset(
                        'assets/typing_indicator.riv',
                      ),
                    ),
                  ],
                ),
              ),
            MessageTextField(),
          ],
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    Key? key,
    required this.messageCubit,
    required this.isLastInSet,
    required this.isLastSentMsg,
  }) : super(key: key);

  final MessageCubit messageCubit;
  final bool isLastInSet;
  final bool isLastSentMsg;

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<UserCubit>().state.user;

    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, chatState) {
        return BlocProvider.value(
          value: messageCubit..readMessage(currentUser.id, chatState.id),
          child: BlocBuilder<MessageCubit, MessageState>(
            builder: (context, messageState) {
              //print({'data', messageState.content[0].data});

              final isSender = messageState.senderId == currentUser.id;

              final contact = !isSender
                  ? chatState.participants
                      .firstWhere((p) => p.id == messageState.senderId)
                  : null;

              final readBy = chatState.participants.where(
                (e) =>
                    !messageState.unreadBy.contains(e.id) &&
                    e.id != currentUser.id,
              );

              String textMessage = '';
              List<AttachmentState> photos = [];
              List<AttachmentState> videos = [];
              List<AttachmentState> files = [];

              messageState.content.forEach((item) {
                switch (item.type) {
                  case MessageType.TEXT:
                    textMessage = item.data;
                    break;
                  case MessageType.PHOTO:
                    photos.add(AttachmentState(
                      name: item.data,
                      type: AttachmentType.PHOTO,
                    ));
                    break;
                  case MessageType.VIDEO:
                    videos.add(AttachmentState(
                      name: item.data,
                      type: AttachmentType.VIDEO,
                    ));
                    break;
                  case MessageType.FILE:
                    files.add(AttachmentState(
                      name: item.data,
                      type: AttachmentType.FILE,
                    ));
                    break;
                }
              });
              return Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Row(
                  mainAxisAlignment: isSender
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        if (!isSender) ...[
                          isLastInSet
                              ? BlocProvider(
                                  create: (context) => ContactCubit(
                                    contact: contact!,
                                  ),
                                  child:
                                      BlocBuilder<ContactCubit, ContactState>(
                                    builder: (context, state) {
                                      return Stack(
                                        children: [
                                          CircleAvatar(
                                            radius: 14,
                                            child: state.avatar != null
                                                ? ClipOval(
                                                    child: Image.memory(
                                                        state.avatar!),
                                                  )
                                                : Icon(
                                                    Icons.person,
                                                    color: Colors.grey.shade50,
                                                  ),
                                            backgroundColor:
                                                Colors.grey.shade300,
                                          ),
                                          Positioned(
                                            right: 0,
                                            bottom: 0,
                                            child: Container(
                                              height: 12,
                                              width: 12,
                                              decoration: BoxDecoration(
                                                color: state.status ==
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
                                      );
                                    },
                                  ),
                                )
                              : SizedBox(
                                  width: 28,
                                ),
                          SizedBox(width: 10.0),
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
                                if (photos.isNotEmpty)
                                  PhotoMessage(photos: photos),
                                if (videos.isNotEmpty)
                                  VideosMessage(videos: videos),
                                if (files.isNotEmpty)
                                  FilesMessage(files: files),
                                SizedBox(height: 5),
                                if (textMessage.isNotEmpty)
                                  TextMessage(
                                      text: textMessage, sender: contact)
                              ]),
                        ),
                        if (isSender) ...[
                          if (chatState.participants.length == 2)
                            SizedBox(width: 2.0),
                          isLastSentMsg
                              ? readBy.isNotEmpty
                                  ? chatState.participants.length > 2
                                      ? Row(
                                          children: readBy
                                              .map((e) => Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                      2.0,
                                                    ),
                                                    child: CircleAvatar(
                                                      radius: 8,
                                                      child: e.avatar != null
                                                          ? ClipOval(
                                                              child:
                                                                  Image.memory(e
                                                                      .avatar!),
                                                            )
                                                          : Icon(
                                                              Icons.person,
                                                              size: 12,
                                                              color: Colors
                                                                  .grey.shade50,
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
                                                  child: Image.memory(
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
                                      messageState.status ==
                                              MessageStatus.SENDING
                                          ? Icons.check_circle_outline
                                          : Icons.check_circle,
                                      size: 16,
                                      color: Colors.blue.shade800,
                                    )
                              : SizedBox(
                                  width: 16,
                                )
                        ],
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class TextMessage extends StatelessWidget {
  const TextMessage({
    Key? key,
    this.text,
    required this.sender,
  }) : super(key: key);

  final String? text;
  final ContactState? sender;

  @override
  Widget build(BuildContext context) {
    //print({'MSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS', text, sender});

    return Container(
      // constraints: BoxConstraints(
      //   maxWidth: MediaQuery.of(context).size.width * 0.7,
      // ),
      padding: sender == null
          ? const EdgeInsets.all(10.0)
          : const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade800.withOpacity(sender == null ? 1 : 0.1),
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
          if (sender != null)
            Row(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  sender!.firstName,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2!
                      .copyWith(fontSize: 10),
                ),
                // Text(
                //   '16:49',
                //   style: Theme.of(context)
                //       .textTheme
                //       .subtitle2!
                //       .copyWith(fontSize: 10),
                // ),
              ],
            ),
          Text(
            text!,
            style: TextStyle(
              color: sender == null ? Colors.white : Colors.grey.shade800,
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

  final List<AttachmentState> photos;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
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
                        '/chat/video',
                        arguments: MediaPageArguments(
                          context.read<ChatCubit>(),
                          photos[index],
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(
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
                          return Container(
                            child: AnimatedOpacity(
                              child: child,
                              opacity: frame == null ? 0 : 1,
                              duration: const Duration(seconds: 1),
                              curve: Curves.easeOut,
                            ),
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

  final List<AttachmentState> videos;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
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
                    borderRadius: BorderRadius.all(
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
                              return Container(
                                child: AnimatedOpacity(
                                  child: child,
                                  opacity: frame == null ? 0 : 1,
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.easeOut,
                                ),
                              );
                            },
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black26,
                            ),
                          ),
                          Align(
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

  final List<AttachmentState> files;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Column(
        children: List<Widget>.generate(files.length, (index) {
          return BlocProvider(
            create: (context) => AttachmentCubit(attachmentState: files[index]),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      BlocBuilder<AttachmentCubit, AttachmentState>(
                        builder: (context, state) {
                          return state.downloading
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
                                        .read<AttachmentCubit>()
                                        .downloadAttachment(
                                          files[index].name,
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
                                              children: <Widget>[
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
                                  child: Icon(Icons.download),
                                );
                        },
                      ),
                      SizedBox(width: 15.0),
                      Text(files[index].name),
                    ],
                  ),
                ),
                if (index != files.length - 1)
                  Divider(
                    color: Colors.grey.shade300,
                    height: 1,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
