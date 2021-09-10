import 'dart:io';
import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart';
import 'package:safechat/chats/cubits/attachments/attachments_cubit.dart';

import 'package:safechat/chats/cubits/chat/chat_cubit.dart';
import 'package:safechat/chats/models/attachment.dart';
import 'package:safechat/chats/models/message.dart';
import 'package:safechat/contacts/contacts.dart';
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
              contact: chatCubit.state.participants[0],
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
                              color: state.status == Status.ONLINE
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
                          '${state.firstName} ${state.lastName}',
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
                                            .sender !=
                                        state.messages[index].sender ||
                                    index == 0;

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
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
                        if (state.typing.contains(e.id)) return e.firstName;
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
  AttachmentsCubit _attachmentsCubit = AttachmentsCubit();

  @override
  void dispose() {
    _attachmentsCubit.close();
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocProvider.value(
            value: _attachmentsCubit,
            child: BlocBuilder<AttachmentsCubit, AttachmentsState>(
              builder: (context, state) {
                return state.selectedAttachments.isNotEmpty
                    ? SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.selectedAttachments.length,
                          itemBuilder: (
                            BuildContext context,
                            int index,
                          ) {
                            Widget test(Attachment attachment) {
                              switch (attachment.type) {
                                case AttachmentType.PHOTO:
                                  return Image.file(
                                    File(attachment.file),
                                    fit: BoxFit.cover,
                                    //cacheWidth: 100,
                                    //filterQuality: FilterQuality.medium,
                                  );
                                case AttachmentType.VIDEO:
                                  return VideoThumbnail(
                                    video: File(attachment.file),
                                  );

                                case AttachmentType.FILE:
                                  return Image.file(
                                    File(attachment.file),
                                    fit: BoxFit.cover,
                                    //cacheWidth: 100,
                                    //filterQuality: FilterQuality.medium,
                                  );
                              }
                            }

                            return Container(
                              width: 100,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Transform.scale(
                                    scale: 0.9,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: test(
                                          state.selectedAttachments[index]),
                                    ),
                                  ),
                                  if (state.selectedAttachments.contains(
                                      state.selectedAttachments[index]))
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: GestureDetector(
                                        onTap: () => context
                                            .read<AttachmentsCubit>()
                                            .toggleAttachment(
                                              state.selectedAttachments[index],
                                            ),
                                        child: CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Colors.white,
                                          child: Icon(
                                            Icons.cancel,
                                            color: Colors.grey.shade900,
                                          ),
                                        ),
                                      ),
                                    )
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    : SizedBox.shrink();
              },
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(10.0),
                      ),
                    ),
                    builder: (context) {
                      return BlocProvider.value(
                        value: _attachmentsCubit..loadAttachments(),
                        child: BlocBuilder<AttachmentsCubit, AttachmentsState>(
                          builder: (context, state) {
                            return Container(
                              height: MediaQuery.of(context).size.height * 0.4,
                              //padding: EdgeInsets.all(10.0),
                              child: state.loading
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : DefaultTabController(
                                      length: 3,
                                      child: Column(
                                        children: [
                                          Container(
                                            //margin: EdgeInsets.only(bottom: 5.0),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade900,
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                top: Radius.circular(10),
                                              ),
                                            ),
                                            child: TabBar(
                                              tabs: [
                                                Tab(
                                                    icon: Icon(
                                                        Icons.photo_library)),
                                                Tab(
                                                    icon: Icon(
                                                        Icons.video_library)),
                                                Tab(
                                                    icon: Icon(
                                                        Icons.file_present)),
                                              ],
                                            ),
                                          ),
                                          Flexible(
                                            child: Stack(
                                              children: [
                                                TabBarView(children: [
                                                  PhotosGrid(
                                                    attachments: state
                                                        .attachments
                                                        .where((e) =>
                                                            e.type ==
                                                            AttachmentType
                                                                .PHOTO)
                                                        .toList(),
                                                  ),
                                                  VideosGrid(
                                                    attachments: state
                                                        .attachments
                                                        .where((e) =>
                                                            e.type ==
                                                            AttachmentType
                                                                .VIDEO)
                                                        .toList(),
                                                  ),
                                                  FilesList(
                                                    attachments: state
                                                        .attachments
                                                        .where((e) =>
                                                            e.type ==
                                                            AttachmentType.FILE)
                                                        .toList(),
                                                  ),
                                                ]),
                                                if (state.selectedAttachments
                                                    .isNotEmpty)
                                                  Positioned(
                                                    right: 10,
                                                    bottom: 15,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Icon(Icons.add,
                                                          color: Colors.white),
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        shape: CircleBorder(),
                                                        padding:
                                                            EdgeInsets.all(15),
                                                        primary: Colors
                                                            .blue.shade800,
                                                        elevation: 0,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
                icon: Icon(
                  Icons.attach_file,
                  color: Colors.grey.shade500,
                ),
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
                  context.read<ChatCubit>().sendMessage(
                        _attachmentsCubit.state.selectedAttachments,
                      );

                  // TODO: zrobić to lepiej
                  _attachmentsCubit.emit(_attachmentsCubit.state.copyWith(
                    selectedAttachments: [],
                  ));

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
        ],
      ),
    );
  }
}

class PhotosGrid extends StatelessWidget {
  const PhotosGrid({
    Key? key,
    required this.attachments,
  }) : super(key: key);

  final List<Attachment> attachments;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 150,
        ),
        itemCount: attachments.length,
        itemBuilder: (BuildContext _, index) {
          return GestureDetector(
            onTap: () => context
                .read<AttachmentsCubit>()
                .toggleAttachment(attachments[index]),
            child: BlocBuilder<AttachmentsCubit, AttachmentsState>(
              builder: (context, state) {
                return Container(
                  margin: EdgeInsets.all(5.0),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Transform.scale(
                        scale: state.selectedAttachments
                                .contains(attachments[index])
                            ? 0.9
                            : 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(attachments[index].file),
                            fit: BoxFit.cover,
                            cacheWidth: 150,
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                      ),
                      if (state.selectedAttachments
                          .contains(attachments[index]))
                        Align(
                          alignment: Alignment.topRight,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.blue.shade800,
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                            ),
                          ),
                        )
                    ],
                  ),
                );
              },
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
        ),
        itemCount: attachments.length,
        itemBuilder: (BuildContext ctx, index) {
          return GestureDetector(
            onTap: () => context
                .read<AttachmentsCubit>()
                .toggleAttachment(attachments[index]),
            child: BlocBuilder<AttachmentsCubit, AttachmentsState>(
              builder: (context, state) {
                return Container(
                  margin: EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Transform.scale(
                        scale: state.selectedAttachments
                                .contains(attachments[index])
                            ? 0.9
                            : 1,
                        child: VideoThumbnail(
                          video: File(attachments[index].file),
                        ),
                      ),
                      if (state.selectedAttachments
                          .contains(attachments[index]))
                        Align(
                          alignment: Alignment.topRight,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.blue.shade800,
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        });
  }
}

class VideoThumbnail extends StatefulWidget {
  const VideoThumbnail({
    Key? key,
    required this.video,
  }) : super(key: key);

  final File video;

  @override
  _VideoThumbnailState createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.video)..initialize();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      VideoPlayer(_controller),
      Align(
        alignment: Alignment.bottomRight,
        child: Container(
          margin: EdgeInsets.all(5.0),
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.black54,
          ),
          child: Text(
            '${_controller.value.duration.inSeconds}s',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    ]);
  }
}

class FilesList extends StatelessWidget {
  const FilesList({
    Key? key,
    required this.attachments,
  }) : super(key: key);

  final List<Attachment> attachments;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: attachments.length,
      itemBuilder: (
        BuildContext context,
        int index,
      ) {
        final file = File(attachments[index].file);
        return ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                child: Icon(
                  Icons.text_snippet,
                  color: Colors.white,
                ),
                backgroundColor: Colors.grey.shade300,
              ),
            ],
          ),
          title: Text(
            '${file.path.split('/').last}',
            style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  color: Colors.grey.shade900,
                ),
          ),
          // subtitle: Text(
          //     '${File(attachments[index].path).lastModifiedSync().toLocal()}'),
          subtitle: Text(
            '${(file.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB',
            style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
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
  }) : super(key: key);

  final Message message;
  final bool isLastInSet;

  @override
  Widget build(BuildContext context) {
    final isSender = message.sender == context.read<UserCubit>().state.user.id;

    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: BlocListener<ChatCubit, ChatState>(
        listener: (context, state) {
          print({'DUPA'});
        },
        child: BlocBuilder<ChatCubit, ChatState>(builder: (context, state) {
          final contact = !isSender
              ? state.participants.firstWhere((p) => p.id == message.sender)
              : null;

          //print(message.unreadBy);

          final readBy = state.participants.where(
            (e) => !message.unreadBy.contains(e.id),
          );
          //&& e.contact.id != context.read<UserCubit>().state.user.id

          String textMessage = '';
          List<String> photos = [];
          List<String> videos = [];

          message.content.forEach((item) {
            print(item.data);
            switch (item.type) {
              case MessageType.TEXT:
                textMessage = item.data;
                break;
              case MessageType.PHOTO:
                photos.add(item.data);
                break;
              case MessageType.VIDEO:
                videos.add(item.data);
                break;
              default:
                break;
            }
          });
          return Row(
            mainAxisAlignment:
                isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isSender) ...[
                isLastInSet
                    ? BlocProvider(
                        create: (context) => ContactCubit(
                          contact: contact!,
                        ),
                        child: BlocBuilder<ContactCubit, ContactState>(
                          builder: (context, state) {
                            return Stack(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  child: state.avatar != null
                                      ? ClipOval(
                                          child: Image.memory(state.avatar!),
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
                                      color: state.status == Status.ONLINE
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
              ConstrainedBox(
                // decoration: BoxDecoration(
                //   color: Colors.grey.shade100,
                //   borderRadius: BorderRadius.all(
                //     Radius.circular(10),
                //   ),
                // ),
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (photos.isNotEmpty)
                        PhotoMessage(photos: photos, sender: contact),
                      if (videos.isNotEmpty)
                        VideosMessage(videos: videos, sender: contact),
                      SizedBox(height: 5),
                      if (textMessage.isNotEmpty)
                        TextMessage(text: textMessage, sender: contact)
                    ]
                    // children: message.content
                    //     .asMap()
                    //     .map((i, element) => MapEntry(
                    //           i,
                    //           GestureDetector(
                    //             onTap: () => {},
                    //             child: messageContaint(
                    //               message.content[i],
                    //               contact,
                    //             ),
                    //           ),
                    //         ))
                    //     .values
                    //     .toList(),
                    ),
              ),
              if (isSender) ...[
                SizedBox(width: 2.0),
                readBy.isNotEmpty
                    ? CircleAvatar(
                        radius: 10,
                        child: readBy.first.avatar != null
                            ? ClipOval(
                                child: Image.memory(readBy.first.avatar!),
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
    this.text,
    required this.sender,
  }) : super(key: key);

  final String? text;
  final ContactState? sender;

  @override
  Widget build(BuildContext context) {
    print({'MSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS', text, sender});

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

class PhotoMessage extends StatefulWidget {
  const PhotoMessage({
    Key? key,
    required this.photos,
    required this.sender,
  }) : super(key: key);

  final List<String> photos;
  final ContactState? sender;

  @override
  State<PhotoMessage> createState() => _PhotoMessageState();
}

class _PhotoMessageState extends State<PhotoMessage> {
  AsyncMemoizer _memoizer = AsyncMemoizer();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: min(widget.photos.length, 3),
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
        ),
        itemCount: widget.photos.length,
        itemBuilder: (BuildContext context, index) {
          return FutureBuilder(
              future:
                  context.read<ChatCubit>().getAttachment(widget.photos[index]),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  return GestureDetector(
                    onTap: () => {},
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
                            // decoration: BoxDecoration(
                            //   color: Colors.grey.shade100,
                            //   borderRadius: BorderRadius.circular(10),
                            // ),
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
                      // child: Image.file(
                      //   photos[index],
                      //   // loadingBuilder: (BuildContext context, Widget child,
                      //   //     ImageChunkEvent? loadingProgress) {
                      //   //   if (loadingProgress == null) {
                      //   //     return child;
                      //   //   }
                      //   //   return Center(
                      //   //     child: CircularProgressIndicator(
                      //   //       value: loadingProgress.expectedTotalBytes != null
                      //   //           ? loadingProgress.cumulativeBytesLoaded /
                      //   //               loadingProgress.expectedTotalBytes!
                      //   //           : null,
                      //   //     ),
                      //   //   );
                      //   // },
                      //   frameBuilder: (BuildContext context, Widget child, int? frame,
                      //       bool wasSynchronouslyLoaded) {
                      //     if (wasSynchronouslyLoaded) {
                      //       return child;
                      //     }
                      //     return Container(
                      //       color: Colors.grey.shade100,
                      //       child: AnimatedOpacity(
                      //         child: child,
                      //         opacity: frame == null ? 0 : 1,
                      //         duration: const Duration(seconds: 1),
                      //         curve: Curves.easeOut,
                      //       ),
                      //     );
                      //   },

                      //   fit: BoxFit.cover,
                      //   cacheWidth: (MediaQuery.of(context).size.width * 0.7).round(),
                      //   filterQuality: FilterQuality.medium,
                      // ),
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

class VideoMessageThumbnail extends StatefulWidget {
  const VideoMessageThumbnail({
    Key? key,
    required this.video,
  }) : super(key: key);

  final File video;

  @override
  _VideoMessageThumbnailState createState() => _VideoMessageThumbnailState();
}

class _VideoMessageThumbnailState extends State<VideoMessageThumbnail> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.video)..initialize();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      VideoPlayer(_controller),
      Align(
        alignment: Alignment.center,
        child: Icon(
          Icons.play_circle,
          color: Colors.white,
          size: 55,
        ),
      ),
    ]);
  }
}

class VideosMessage extends StatefulWidget {
  const VideosMessage({
    Key? key,
    required this.videos,
    required this.sender,
  }) : super(key: key);

  final List<String> videos;
  final ContactState? sender;

  @override
  State<VideosMessage> createState() => _VideosMessageState();
}

class _VideosMessageState extends State<VideosMessage> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: min(widget.videos.length, 3),
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
        ),
        itemCount: widget.videos.length,
        itemBuilder: (BuildContext context, index) {
          return FutureBuilder(
              future:
                  context.read<ChatCubit>().getAttachment(widget.videos[index]),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  return GestureDetector(
                    onTap: () => {},
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      child: VideoMessageThumbnail(video: snapshot.data),
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
