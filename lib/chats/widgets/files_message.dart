import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';

import 'package:safechat/chats/chats.dart';

class FilesMessage extends StatelessWidget {
  const FilesMessage({
    Key? key,
    required this.chat,
    required this.files,
    required this.borderRadius,
  }) : super(key: key);

  final Chat chat;
  final List<Attachment> files;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: borderRadius,
      ),
      child: BlocProvider(
        create: (context) => AttachmentsCubit(attachments: files),
        child: BlocBuilder<AttachmentsCubit, AttachmentsState>(
          builder: (context, state) {
            return Column(
              children:
                  List<Widget>.generate(state.attachments.length, (index) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          state.attachments[index].downloading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Transform.scale(
                                    scale: 0.5,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () async {
                                    final attachment = await context
                                        .read<AttachmentsCubit>()
                                        .downloadAttachment(
                                          state.attachments[index].name,
                                          chat,
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
                                              children: const <Widget>[
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
                                  child: const Icon(Icons.download),
                                ),
                          const SizedBox(width: 15.0),
                          Flexible(
                            child: Text(
                              context.read<AttachmentsCubit>().getDecryptedName(
                                    state.attachments[index].name,
                                    chat.sharedKey,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index != state.attachments.length - 1)
                      Divider(
                        color: Colors.grey.shade300,
                        height: 1,
                      ),
                  ],
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
