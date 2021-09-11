import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:safechat/chats/cubits/chat/chat_cubit.dart';
import 'package:safechat/chats/repository/chats_repository.dart';

part 'attachment_state.dart';

class AttachmentCubit extends Cubit<AttachmentState> {
  AttachmentCubit({required AttachmentState attachmentState})
      : super(attachmentState);

  final _chatsRepository = ChatsRepository();

  Future<File> downloadAttachment(String attachmentName, ChatState chat) async {
    emit(state.copyWith(downloading: true));

    final attachmentData = await _chatsRepository.getAttachment(
      chat.id,
      attachmentName,
      chat.sharedKey,
    );

    final attachment = await File(
      '/storage/emulated/0/Download/$attachmentName',
    ).writeAsBytes(attachmentData);

    emit(state.copyWith(downloading: false));

    return attachment;
  }
}
