import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:base32/base32.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:safechat/chats/chats.dart';
import 'package:safechat/utils/encryption_service.dart';

part 'attachments_state.dart';

class AttachmentsCubit extends Cubit<AttachmentsState> {
  AttachmentsCubit({List<Attachment> attachments = const []})
      : super(AttachmentsState(attachments: attachments));

  final _chatsRepository = ChatsRepository();
  final _encryptionService = EncryptionService();

  Future<File> getAttachment(Chat chat, Attachment attachment,
      {bool thumbnail = true}) async {
    final cacheManager = DefaultCacheManager();

    var name = attachment.name;
    var decryptedName = getDecryptedName(attachment.name, chat.sharedKey);
    var cachedFile = await cacheManager.getFileFromCache(decryptedName);

    if (attachment.type != AttachmentType.file && thumbnail) {
      cachedFile =
          await cacheManager.getFileFromCache('thumb_$decryptedName') ??
              await cacheManager.getFileFromCache(decryptedName);

      name = 'thumb_$name';
      decryptedName = 'thumb_$decryptedName';
    }

    if (cachedFile != null) {
      emit(state.copyWith(downloadedAttachment: cachedFile));
      return cachedFile.file;
    }

    final attachmentFile = await _chatsRepository.getAttachment(
      chat.id,
      name,
      chat.sharedKey,
    );

    final file = await cacheManager.putFile(
      decryptedName,
      attachmentFile,
      key: decryptedName,
      eTag: decryptedName,
      maxAge: const Duration(days: 14),
    );

    if (thumbnail == false) {
      emit(state.copyWith(
        downloadedAttachment: await cacheManager.getFileFromCache(
          decryptedName,
        ),
      ));
    }

    return file;
  }

  Future loadAttachments() async {
    if (await Permission.storage.request().isGranted) {
      emit(state.copyWith(loading: true));

      List<Attachment> attachments = [];

      var downloadDirFiles = await _listDirectory(
        Directory('/storage/emulated/0/Download'),
      );
      var dcimDirFiles = await _listDirectory(
        Directory('/storage/emulated/0/DCIM'),
      );

      for (var entity in [...downloadDirFiles, ...dcimDirFiles]) {
        var mime = lookupMimeType(entity.path);
        AttachmentType type;

        if (mime != null) {
          switch (mime.split('/')[0]) {
            case 'image':
              type = AttachmentType.photo;
              break;
            case 'video':
              type = AttachmentType.video;
              break;
            default:
              type = AttachmentType.file;
          }

          attachments.add(Attachment(
            name: entity.absolute.path,
            type: type,
          ));
        }
      }

      attachments.sort(
        (a, b) => FileStat.statSync(b.name)
            .changed
            .compareTo(FileStat.statSync(a.name).changed),
      );

      emit(state.copyWith(
        loading: false,
        attachments: attachments,
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
      '/storage/emulated/0/Download/${getDecryptedName(attachmentName, chat.sharedKey)}',
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

  String getDecryptedName(String name, Uint8List sharedKey) {
    final decryptedName = _encryptionService.chachaDecrypt(
      base64.encode(base32.decode(name)),
      sharedKey,
    );

    return utf8.decode(decryptedName);
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

  resetSelectedAttachments() {
    emit(state.copyWith(
      selectedAttachments: [],
    ));
  }
}
