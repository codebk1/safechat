import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/chats/cubits/attachment/attachment_cubit.dart';
import 'package:safechat/chats/cubits/attachments/attachments_cubit.dart';

class PhotosGrid extends StatelessWidget {
  const PhotosGrid({
    Key? key,
    required this.attachments,
  }) : super(key: key);

  final List<AttachmentState> attachments;

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
                            File(attachments[index].name),
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
