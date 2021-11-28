import 'dart:async';
import 'dart:io';

import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:safechat/chats/chats.dart';

part 'attachments_state.dart';

class AttachmentsCubit extends Cubit<AttachmentsState> {
  AttachmentsCubit({List<Attachment> attachments = const []})
      : super(AttachmentsState(attachments: attachments));

  final _chatsRepository = ChatsRepository();

  Future<File> getAttachment(Chat chat, Attachment attachment,
      {bool thumbnail = true}) async {
    final cacheManager = DefaultCacheManager();
    var attachmentName = attachment.name;

    if (attachment.type != AttachmentType.file && thumbnail) {
      attachmentName = '${attachment.name.split('.').first}_thumb.jpg';
    }

    var cachedFile = await cacheManager.getFileFromCache(attachmentName);

    if (cachedFile != null) {
      return cachedFile.file;
    }

    final attachmentFile = await _chatsRepository.getAttachment(
      chat.id,
      attachmentName,
      chat.sharedKey,
    );

    return await cacheManager.putFile(attachmentName, attachmentFile);
  }

  Future loadAttachments() async {
    if (await Permission.storage.request().isGranted) {
      emit(state.copyWith(loading: true));

      List<Attachment> _attachments = [];

      var _downloadDirFiles = await _listDirectory(
        Directory('/storage/emulated/0/Download'),
      );
      var _dcimDirFiles = await _listDirectory(
        Directory('/storage/emulated/0/DCIM'),
      );

      for (var entity in [..._downloadDirFiles, ..._dcimDirFiles]) {
        var _mime = lookupMimeType(entity.path);
        AttachmentType _type;

        if (_mime != null) {
          switch (_mime.split('/')[0]) {
            case 'image':
              _type = AttachmentType.photo;
              break;
            case 'video':
              _type = AttachmentType.video;
              break;
            default:
              _type = AttachmentType.file;
          }

          _attachments.add(Attachment(
            name: entity.absolute.path,
            type: _type,
          ));
        }
      }

      emit(state.copyWith(
        loading: false,
        attachments: _attachments,
      ));
    }
  }

  Future<File> downloadAttachment(String attachmentName, Chat chat) async {
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
