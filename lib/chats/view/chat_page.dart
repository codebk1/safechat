import 'dart:io';
import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';
import 'package:flutter/material.dart';

import 'package:open_file/open_file.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart';
import 'package:safechat/chats/cubits/attachment/attachment_cubit.dart';

import 'package:safechat/chats/cubits/chat/chat_cubit.dart';
import 'package:safechat/chats/models/message.dart';
import 'package:safechat/chats/view/widgets/message_text_field.dart';
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
          List<AttachmentState> photos = [];
          List<AttachmentState> videos = [];
          List<AttachmentState> files = [];

          message.content.forEach((item) {
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
                      if (photos.isNotEmpty) PhotoMessage(photos: photos),
                      if (videos.isNotEmpty) VideosMessage(videos: videos),
                      if (files.isNotEmpty) FilesMessage(files: files),
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
  }) : super(key: key);

  final List<AttachmentState> photos;

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
              future: context
                  .read<ChatCubit>()
                  .getAttachment(widget.photos[index].name),
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
  }) : super(key: key);

  final List<AttachmentState> videos;

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
              future: context
                  .read<ChatCubit>()
                  .getAttachment(widget.videos[index].name),
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
