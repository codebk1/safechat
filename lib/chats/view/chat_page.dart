import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart';

import 'package:safechat/chats/cubits/chat/chat_cubit.dart';
import 'package:safechat/chats/models/attachment.dart';
import 'package:safechat/chats/models/message.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/contacts/models/contact.dart';
import 'package:safechat/user/user.dart';
import 'package:video_player/video_player.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({Key? key, required this.chatCubit}) : super(key: key);

  final ChatCubit chatCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: chatCubit..readAllMessages(),
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
            create: (context) => ContactCubit(
              contact: chatCubit.state.participants[0].contact,
              currentState: chatCubit.state.participants[0].currentState,
            ),
            child: BlocBuilder<ContactCubit, ContactState>(
              builder: (context, state) {
                return Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          child: Icon(
                            Icons.person,
                            color: Colors.grey.shade50,
                          ),
                          backgroundColor: Colors.grey.shade300,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            height: 14,
                            width: 14,
                            decoration: BoxDecoration(
                              color: state.contact.status == Status.ONLINE
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
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${state.contact.firstName} ${state.contact.lastName}',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        Text(
                          'Aktywny 5min temu',
                          style: Theme.of(context).textTheme.subtitle2,
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
    );
  }
}

class MessagesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
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
                  : ListView.builder(
                      reverse: true,
                      itemCount: state.messages.length,
                      itemBuilder: (
                        BuildContext context,
                        int index,
                      ) {
                        final isLastInSet = state
                                    .messages[index == 0 ? index : index - 1]
                                    .sender !=
                                state.messages[index].sender ||
                            index == 0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: MessageBubble(
                            message: state.messages[index],
                            isLastInSet: isLastInSet,
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
                      state.participants.map((e) {
                        if (state.typing.contains(e.contact.id))
                          return e.contact.firstName;
                      }).join(', '),
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

class MessageTextField extends StatefulWidget {
  const MessageTextField({
    Key? key,
  }) : super(key: key);

  @override
  _MessageTextFieldState createState() => _MessageTextFieldState();
}

class _MessageTextFieldState extends State<MessageTextField> {
  TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 10.0,
      ),
      child: Row(
        children: [
          BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              return IconButton(
                onPressed: () async {
                  await context.read<ChatCubit>().getPhotos();

                  showModalBottomSheet<void>(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(10.0),
                      ),
                    ),
                    builder: (_) {
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.4,
                        //padding: EdgeInsets.all(10.0),
                        child: DefaultTabController(
                          length: 3,
                          child: Column(
                            children: [
                              Container(
                                //margin: EdgeInsets.only(bottom: 5.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade900,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(10),
                                  ),
                                ),
                                child: TabBar(
                                  tabs: [
                                    Tab(icon: Icon(Icons.photo_library)),
                                    Tab(icon: Icon(Icons.video_library)),
                                    Tab(icon: Icon(Icons.file_present)),
                                  ],
                                ),
                              ),
                              Flexible(
                                child: TabBarView(children: [
                                  AttachmentsGrid(
                                    attachments: state.attachments
                                        .where((e) =>
                                            e.type == AttachmentType.PHOTO)
                                        .toList(),
                                  ),
                                  VideosGrid(
                                    attachments: state.attachments
                                        .where((e) =>
                                            e.type == AttachmentType.VIDEO)
                                        .toList(),
                                  ),
                                  AttachmentsGrid(
                                    attachments: state.attachments
                                        .where((e) =>
                                            e.type == AttachmentType.FILE)
                                        .toList(),
                                  ),
                                ]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                icon: Icon(
                  Icons.attach_file,
                  color: Colors.grey.shade500,
                ),
              );
            },
          ),
          SizedBox(width: 15.0),
          Expanded(
            child: Focus(
              onFocusChange: (hasFocus) {
                final userId = context.read<UserCubit>().state.user.id;
                if (hasFocus) {
                  context.read<ChatCubit>().startTyping(userId);
                } else {
                  context.read<ChatCubit>().stopTyping(userId);
                }
              },
              child: TextFormField(
                controller: _messageController,
                onChanged: (value) {
                  context.read<ChatCubit>().textMessageChanged(value);
                },
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 15,
                decoration: InputDecoration(
                  hintText: "Napisz wiadomość...",
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              //context.read<ChatCubit>().setMessageType(MessageType.TEXT);
              context.read<ChatCubit>().sendMessage();

              _messageController.clear();
            },
            child: Icon(Icons.send_outlined, color: Colors.white),
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.all(10),
              primary: Colors.blue.shade800,
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class AttachmentsGrid extends StatelessWidget {
  const AttachmentsGrid({
    Key? key,
    required this.attachments,
  }) : super(key: key);

  final List<Attachment> attachments;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 150,
          //crossAxisSpacing: 5,
          //mainAxisSpacing: 5,
        ),
        itemCount: attachments.length,
        itemBuilder: (BuildContext ctx, index) {
          return Container(
            margin: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              // image: DecorationImage(
              //   fit: BoxFit.cover,
              //   alignment: Alignment.center,
              //   image: FileImage(
              //     File(
              //       attachments[index].path,
              //     ),
              //   ),
              // ),
            ),
            child: Image.file(
              File(
                attachments[index].path,
              ),
              fit: BoxFit.cover,
            ),
          );
        });
  }
}

class VideosGrid extends StatelessWidget {
  const VideosGrid({
    Key? key,
    required this.attachments,
  }) : super(key: key);

  final List<Attachment> attachments;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 150,
          //crossAxisSpacing: 5,
          //mainAxisSpacing: 5,
        ),
        itemCount: attachments.length,
        itemBuilder: (BuildContext ctx, index) {
          return Container(
            margin: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: VideoPlayer(
              VideoPlayerController.file(
                File(attachments[index].path),
              )..initialize(),
            ),
          );
        });
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    Key? key,
    required this.message,
    required this.isLastInSet,
  }) : super(key: key);

  final Message message;
  final bool isLastInSet;

  @override
  Widget build(BuildContext context) {
    // Widget messageContaint(ChatMessage message) {
    //   switch (message.messageType) {
    //     case ChatMessageType.text:
    //       return TextMessage(message: message);
    //     case ChatMessageType.audio:
    //       return AudioMessage(message: message);
    //     case ChatMessageType.video:
    //       return VideoMessage();
    //     default:
    //       return SizedBox();
    //   }
    // }

    final isSender = message.sender == context.read<UserCubit>().state.user.id;

    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: BlocListener<ChatCubit, ChatState>(
        listener: (context, state) {
          print({'DUPA'});
        },
        child: BlocBuilder<ChatCubit, ChatState>(builder: (context, state) {
          final contact = !isSender
              ? state.participants
                  .firstWhere((p) => p.contact.id == message.sender)
              : null;

          //print(message.unreadBy);

          final readBy = state.participants.where(
            (e) => !message.unreadBy.contains(e.contact.id),
          );
          //&& e.contact.id != context.read<UserCubit>().state.user.id

          //print({'READBY:', readBy.toList()});

          return Row(
            mainAxisAlignment:
                isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isSender) ...[
                isLastInSet
                    ? BlocProvider(
                        create: (context) => ContactCubit(
                          contact: contact!.contact,
                          currentState: contact.currentState,
                        ),
                        child: BlocBuilder<ContactCubit, ContactState>(
                          builder: (context, state) {
                            return Stack(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  child: state.contact.avatar != null
                                      ? ClipOval(
                                          child:
                                              Image.file(state.contact.avatar!),
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
                                      color:
                                          state.contact.status == Status.ONLINE
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
              TextMessage(
                message: message.data,
                sender: contact,
              ),
              if (isSender) ...[
                SizedBox(width: 2.0),
                readBy.isNotEmpty
                    ? CircleAvatar(
                        radius: 10,
                        child: readBy.first.contact.avatar != null
                            ? ClipOval(
                                child: Image.file(readBy.first.contact.avatar!),
                              )
                            : Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.grey.shade50,
                              ),
                        backgroundColor: Colors.grey.shade300,
                      )
                    : Icon(
                        message.status == MessageStatus.SENDING
                            ? Icons.check_circle_outline
                            : Icons.check_circle,
                        size: 15,
                        color: Colors.blue.shade800,
                      )
              ],
            ],
          );
        }),
      ),
    );
  }
}

class TextMessage extends StatelessWidget {
  const TextMessage({
    Key? key,
    this.message,
    required this.sender,
  }) : super(key: key);

  final String? message;
  final ContactState? sender;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
      ),
      padding: sender == null
          ? const EdgeInsets.all(10.0)
          : const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade800.withOpacity(sender == null ? 1 : 0.1),
        borderRadius: BorderRadius.circular(10),
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
                  sender!.contact.firstName,
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
            message!,
            style: TextStyle(
              color: sender == null ? Colors.white : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
