import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:safechat/chats/cubits/chat/chat_cubit.dart';
import 'package:safechat/chats/models/attachment.dart';
import 'package:safechat/chats/repository/chats_repository.dart';

part 'attachments_state.dart';

class AttachmentsCubit extends Cubit<AttachmentsState> {
  AttachmentsCubit({List<Attachment> attachments = const []})
      : super(AttachmentsState(attachments: attachments));

  final _chatsRepository = ChatsRepository();

  Future loadAttachments() async {
    print('GET PHOTOTSSSSSS');
    if (await Permission.storage.request().isGranted) {
      emit(state.copyWith(loading: true));

      List<Attachment> _attachments = [];

      var _downloadDirFiles = await this._listDirectory(
        Directory('/storage/emulated/0/Download'),
      );
      var _dcimDirFiles = await this._listDirectory(
        Directory('/storage/emulated/0/DCIM'),
      );

      [..._downloadDirFiles, ..._dcimDirFiles].forEach((entity) {
        var _mime = lookupMimeType(entity.path);
        AttachmentType _type;

        if (_mime != null) {
          switch (_mime.split('/')[0]) {
            case 'image':
              _type = AttachmentType.PHOTO;
              break;
            case 'video':
              _type = AttachmentType.VIDEO;
              break;
            default:
              _type = AttachmentType.FILE;
          }

          _attachments.add(Attachment(
            name: entity.absolute.path,
            type: _type,
          ));
        }
      });

      // _attachments.sort((a, b) => b.file
      //     .lastModifiedSync()
      //     .toLocal()
      //     .compareTo(a.file.lastModifiedSync().toLocal()));

      emit(state.copyWith(loading: false, attachments: _attachments));
    }
  }

  Future<File> downloadAttachment(String attachmentName, ChatState chat) async {
    emit(state.copyWith(
      attachments: List.of(state.attachments)
          .map((attachment) => attachment.name == attachmentName
              ? attachment.copyWith(downloading: true)
              : attachment)
          .toList(),
    ));

    final attachmentData = await _chatsRepository.getAttachment(
      chat.id,
      attachmentName,
      chat.sharedKey,
    );

    final attachment = await File(
      '/storage/emulated/0/Download/$attachmentName',
    ).writeAsBytes(attachmentData);

    emit(state.copyWith(
      attachments: List.of(state.attachments)
          .map((attachment) => attachment.name == attachmentName
              ? attachment.copyWith(downloading: false)
              : attachment)
          .toList(),
    ));

    return attachment;
  }

  toggleAttachment(Attachment attachment) {
    emit(state.copyWith(
      selectedAttachments: state.selectedAttachments.contains(attachment)
          ? [
              ...List.of(state.selectedAttachments)
                ..removeWhere((e) => e == attachment)
            ]
          : [...state.selectedAttachments, attachment],
    ));
  }

  Future<List<FileSystemEntity>> _listDirectory(Directory dir) {
    var files = <FileSystemEntity>[];
    var completer = Completer<List<FileSystemEntity>>();

    dir.list(recursive: true, followLinks: false).listen(
        (file) => files.add(file),
        onDone: () => completer.complete(files));

    return completer.future;
  }
}
