import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/chats/cubits/attachment/attachment_cubit.dart';
import 'package:safechat/chats/cubits/attachments/attachments_cubit.dart';

class FilesList extends StatelessWidget {
  const FilesList({
    Key? key,
    required this.attachments,
  }) : super(key: key);

  final List<AttachmentState> attachments;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: attachments.length,
      itemBuilder: (
        BuildContext context,
        int index,
      ) {
        final _file = File(attachments[index].name);

        return ListTile(
          onTap: () => context
              .read<AttachmentsCubit>()
              .toggleAttachment(attachments[index]),
          leading: BlocBuilder<AttachmentsCubit, AttachmentsState>(
            builder: (context, state) {
              return state.selectedAttachments.contains(attachments[index])
                  ? CircleAvatar(
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                      backgroundColor: Colors.blue.shade800,
                    )
                  : CircleAvatar(
                      child: Icon(
                        Icons.text_snippet,
                        color: Colors.white,
                      ),
                      backgroundColor: Colors.grey.shade300,
                    );
            },
          ),
          title: Text(
            '${_file.path.split('/').last}',
            style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  color: Colors.grey.shade900,
                ),
          ),
          subtitle: Text(
            '${(_file.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB',
            style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
        );
      },
    );
  }
}
