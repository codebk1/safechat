import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/user/user.dart';
import 'package:safechat/chats/chats.dart';

class MessageTextField extends StatefulWidget {
  const MessageTextField({
    Key? key,
    required this.chat,
  }) : super(key: key);

  final Chat chat;

  @override
  _MessageTextFieldState createState() => _MessageTextFieldState();
}

class _MessageTextFieldState extends State<MessageTextField> {
  final _messageController = TextEditingController();
  final _attachmentsCubit = AttachmentsCubit();

  String _prevValue = '';

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
                            Widget _attachmentThumbnail(Attachment attachment) {
                              final file = File(attachment.name);

                              switch (attachment.type) {
                                case AttachmentType.photo:
                                  return Image.file(
                                    file,
                                    fit: BoxFit.cover,
                                  );
                                case AttachmentType.video:
                                  return VideoThumbnail(
                                    video: file,
                                  );

                                case AttachmentType.file:
                                  return Container(
                                    padding: const EdgeInsets.all(5),
                                    color: Colors.grey.shade200,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Align(
                                          alignment: Alignment.topLeft,
                                          child: Icon(
                                            Icons.text_snippet,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const Divider(
                                          color: Colors.white,
                                          height: 10,
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              attachment.name.split('/').last,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                              }
                            }

                            return SizedBox(
                              width: 100,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Transform.scale(
                                    scale: 0.9,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: _attachmentThumbnail(
                                        state.selectedAttachments[index],
                                      ),
                                    ),
                                  ),
                                  // if (state.selectedAttachments.contains(
                                  //     state.selectedAttachments[index]))
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
                    : const SizedBox.shrink();
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Focus(
                  onFocusChange: (hasFocus) {
                    if (hasFocus && _messageController.value.text.isNotEmpty) {
                      context.read<ChatsCubit>().startTyping(widget.chat.id);
                    } else {
                      context.read<ChatsCubit>().stopTyping(widget.chat.id);
                    }
                  },
                  child: TextFormField(
                    controller: _messageController,
                    onChanged: (value) {
                      context.read<ChatsCubit>().textMessageChanged(
                            widget.chat.id,
                            value,
                            _prevValue,
                          );

                      _prevValue = value;
                    },
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 15,
                    decoration: InputDecoration(
                      hintText: "Napisz wiadomość...",
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      prefixIcon: IconButton(
                        onPressed: () {
                          _openAttachmentsPicker(context);
                        },
                        icon: Icon(
                          Icons.attach_file,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          if (_messageController.value.text.isNotEmpty ||
                              _attachmentsCubit
                                  .state.selectedAttachments.isNotEmpty) {
                            _prevValue = '';

                            context.read<ChatsCubit>().sendMessage(
                                  widget.chat,
                                  context.read<UserCubit>().state.user.id,
                                  _attachmentsCubit.state.selectedAttachments,
                                );

                            _attachmentsCubit.resetSelectedAttachments();
                            _messageController.clear();
                          }
                        },
                        color: Colors.white,
                        icon: Icon(
                          Icons.send_rounded,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<dynamic> _openAttachmentsPicker(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.grey.shade700,
      ),
    );
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10.0),
        ),
      ),
      builder: (context) {
        return BlocProvider.value(
          value: _attachmentsCubit..loadAttachments(),
          child: BlocBuilder<AttachmentsCubit, AttachmentsState>(
            builder: (context, state) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                //padding: EdgeInsets.all(10.0),
                child: state.loading
                    ? const Center(
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
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(10),
                                ),
                              ),
                              child: const TabBar(
                                tabs: [
                                  Tab(icon: Icon(Icons.photo_library)),
                                  Tab(icon: Icon(Icons.video_library)),
                                  Tab(icon: Icon(Icons.file_present)),
                                ],
                              ),
                            ),
                            Flexible(
                              child: Stack(
                                children: [
                                  TabBarView(children: [
                                    PhotosGrid(
                                      attachments: state.attachments
                                          .where((e) =>
                                              e.type == AttachmentType.photo)
                                          .toList(),
                                    ),
                                    VideosGrid(
                                      attachments: state.attachments
                                          .where((e) =>
                                              e.type == AttachmentType.video)
                                          .toList(),
                                    ),
                                    FilesList(
                                      attachments: state.attachments
                                          .where((e) =>
                                              e.type == AttachmentType.file)
                                          .toList(),
                                    ),
                                  ]),
                                  if (state.selectedAttachments.isNotEmpty)
                                    Positioned(
                                      right: 10,
                                      bottom: 15,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Icon(Icons.add,
                                            color: Colors.white),
                                        style: ElevatedButton.styleFrom(
                                          shape: const CircleBorder(),
                                          padding: const EdgeInsets.all(
                                            15,
                                          ),
                                          primary: Colors.blue.shade800,
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
    ).whenComplete(() => SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.grey.shade300,
          ),
        ));
  }
}
