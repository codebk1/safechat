import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/chats/cubits/attachments/attachments_cubit.dart';
import 'package:safechat/chats/cubits/chat/chat_cubit.dart';
import 'package:safechat/chats/models/attachment.dart';
import 'package:safechat/chats/view/widgets/files_list.dart';
import 'package:safechat/chats/view/widgets/photos_grid.dart';
import 'package:safechat/chats/view/widgets/video_thumbnail.dart';
import 'package:safechat/chats/view/widgets/videos_grid.dart';
import 'package:safechat/user/cubit/user_cubit.dart';

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
                            Widget _attachmentThumbnail(Attachment attachment) {
                              final file = File(attachment.name);

                              switch (attachment.type) {
                                case AttachmentType.PHOTO:
                                  return Image.file(
                                    file,
                                    fit: BoxFit.cover,
                                  );
                                case AttachmentType.VIDEO:
                                  return VideoThumbnail(
                                    video: file,
                                  );

                                case AttachmentType.FILE:
                                  return Container(
                                    padding: EdgeInsets.all(5),
                                    color: Colors.grey.shade300,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(
                                          Icons.text_snippet,
                                          color: Colors.white,
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

                            return Container(
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
                    : SizedBox.shrink();
              },
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  _openAttachmentsPicker(context);
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
                    if (hasFocus) {
                      context.read<ChatCubit>().startTyping(
                            context.read<UserCubit>().state.user.id,
                          );
                    } else {
                      context.read<ChatCubit>().stopTyping(
                            context.read<UserCubit>().state.user.id,
                          );
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
                        context.read<UserCubit>().state.user.id,
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

  Future<dynamic> _openAttachmentsPicker(BuildContext context) {
    return showModalBottomSheet(
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
                              child: Stack(
                                children: [
                                  TabBarView(children: [
                                    PhotosGrid(
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
                                    FilesList(
                                      attachments: state.attachments
                                          .where((e) =>
                                              e.type == AttachmentType.FILE)
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
                                        child: Icon(Icons.add,
                                            color: Colors.white),
                                        style: ElevatedButton.styleFrom(
                                          shape: CircleBorder(),
                                          padding: EdgeInsets.all(
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
    );
  }
}
