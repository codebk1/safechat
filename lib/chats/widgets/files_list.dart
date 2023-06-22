import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/chats/chats.dart';

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
        final file = File(attachments[index].name);

        return ListTile(
          onTap: () => context
              .read<AttachmentsCubit>()
              .toggleAttachment(attachments[index]),
          leading: BlocBuilder<AttachmentsCubit, AttachmentsState>(
            builder: (context, state) {
              return state.selectedAttachments.contains(attachments[index])
                  ? CircleAvatar(
                      backgroundColor: Colors.blue.shade800,
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                    )
                  : CircleAvatar(
                      backgroundColor: Colors.grey.shade300,
                      child: const Icon(
                        Icons.text_snippet,
                        color: Colors.white,
                      ),
                    );
            },
          ),
          title: Text(
            file.path.split('/').last,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Colors.grey.shade900,
                ),
          ),
          subtitle: Text(
            _formatBytes(file.lengthSync()),
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
        );
      },
    );
  }
}

String _formatBytes(int bytes) {
  if (bytes == 0) return '0 B';

  const sizes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

  final i = (log(bytes) / log(1024)).floor();

  return '${(bytes / pow(1024, i)).toStringAsFixed(2)}  ${sizes[i]}';
}
