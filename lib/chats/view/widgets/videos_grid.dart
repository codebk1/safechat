import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/chats/cubits/attachments/attachments_cubit.dart';
import 'package:safechat/chats/models/attachment.dart';
import 'package:safechat/chats/view/widgets/video_thumbnail.dart';

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
                          video: File(attachments[index].name),
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
