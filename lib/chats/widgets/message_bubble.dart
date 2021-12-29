import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/user/user.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/chats/chats.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    Key? key,
    required this.chat,
    required this.message,
    required this.isNextText,
    required this.isPrevText,
    required this.isLastInSet,
    required this.isLastSentMsg,
  }) : super(key: key);

  final Chat chat;
  final Message message;
  final bool isNextText;
  final bool isPrevText;
  final bool isLastInSet;
  final bool isLastSentMsg;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatsCubit, ChatsState>(
      builder: (context, state) {
        final currentUser = context.read<UserCubit>().state.user;

        // final participants = List.of(chat.participants)
        //   ..removeWhere((p) => p.id == currentUser.id);

        final isSender = message.senderId == currentUser.id;

        final sender = chat.participants.firstWhereOrNull(
          (e) => e.id == message.senderId,
        );

        final readBy = chat.participants.where(
          (e) => !message.unreadBy.contains(e.id) && e.id != currentUser.id,
        );

        final isGroup = message.content.length > 1 &&
            message.content.any((item) => item.type.isText);

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
        return Row(
          mainAxisAlignment:
              isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                if (!isSender) ...[
                  isLastInSet
                      ? sender == null
                          ? CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.grey.shade100,
                            )
                          : Stack(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  child: sender.avatar != null
                                      ? ClipOval(
                                          child: Image.file(
                                            sender.avatar,
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
                                    isOnline: sender.isOnline,
                                    status: sender.status,
                                    size: 10,
                                  ),
                                ),
                              ],
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
                          PhotoMessage(
                            chat: chat,
                            photos: photos,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(
                                10,
                              ),
                              topRight: const Radius.circular(
                                10,
                              ),
                              bottomLeft: Radius.circular(
                                videos.isNotEmpty || files.isNotEmpty ? 5 : 10,
                              ),
                              bottomRight: Radius.circular(
                                videos.isNotEmpty ||
                                        files.isNotEmpty ||
                                        textMessage.isNotEmpty
                                    ? 5
                                    : 10,
                              ),
                            ),
                          ),
                        SizedBox(height: videos.isNotEmpty ? 2 : 0),
                        if (videos.isNotEmpty)
                          VideosMessage(
                            chat: chat,
                            videos: videos,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(
                                photos.isNotEmpty ? 5 : 10,
                              ),
                              topRight: Radius.circular(
                                photos.isNotEmpty ? 5 : 10,
                              ),
                              bottomLeft: const Radius.circular(10),
                              bottomRight: Radius.circular(isGroup ? 5 : 10),
                            ),
                          ),
                        SizedBox(height: files.isNotEmpty ? 2 : 0),
                        if (files.isNotEmpty)
                          FilesMessage(
                            chat: chat,
                            files: files,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(
                                videos.isNotEmpty || photos.isNotEmpty ? 5 : 10,
                              ),
                              topRight: Radius.circular(
                                videos.isNotEmpty || photos.isNotEmpty ? 5 : 10,
                              ),
                              bottomLeft: const Radius.circular(10),
                              bottomRight: Radius.circular(isGroup ? 5 : 10),
                            ),
                          ),
                        SizedBox(height: message.content.length > 1 ? 2 : 0),
                        if (textMessage.isNotEmpty)
                          TextMessage(
                            text: textMessage,
                            sender: sender,
                            isGroupChat: chat.type.isGroup,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(isGroup ? 5 : 10),
                              topRight: Radius.circular(
                                  isGroup || isNextText ? 5 : 10),
                              bottomLeft: const Radius.circular(10),
                              bottomRight: Radius.circular(isGroup
                                  ? 20
                                  : isPrevText
                                      ? 5
                                      : 10),
                            ),
                          )
                      ]),
                ),
                if (isSender) ...[
                  if (chat.participants.length == 2) const SizedBox(width: 2.0),
                  if (chat.participants.length > 2) const SizedBox(height: 2.0),
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
                                                      child:
                                                          Image.file(e.avatar!),
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
                                          child:
                                              Image.file(readBy.first.avatar!),
                                        )
                                      : Icon(
                                          Icons.person,
                                          size: 12,
                                          color: Colors.grey.shade50,
                                        ),
                                  backgroundColor: Colors.grey.shade300,
                                )
                          : message.status == MessageStatus.sending
                              ? const _DelayedLoader(
                                  delay: Duration(seconds: 3),
                                )
                              : Icon(
                                  Icons.check_circle_rounded,
                                  size: 16,
                                  color: Colors.blue.shade800,
                                )
                      : const SizedBox(width: 16)
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}

class _DelayedLoader extends StatefulWidget {
  const _DelayedLoader({
    Key? key,
    this.delay = Duration.zero,
  }) : super(key: key);

  final Duration delay;

  @override
  _DelayedLoaderState createState() => _DelayedLoaderState();
}

class _DelayedLoaderState extends State<_DelayedLoader> {
  Timer? _timer;
  bool showLoader = false;

  @override
  void initState() {
    super.initState();

    _timer = Timer(widget.delay, () {
      setState(() {
        showLoader = true;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return showLoader
        ? SizedBox(
            width: 16,
            height: 16,
            child: Transform.scale(
              scale: 0.5,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.blue.shade800,
              ),
            ),
          )
        : Icon(
            Icons.check_circle_outline_rounded,
            size: 16,
            color: Colors.blue.shade800,
          );
  }
}
