import 'dart:io';

import 'package:equatable/equatable.dart';

enum AttachmentType { PHOTO, VIDEO, FILE }

class Attachment extends Equatable {
  const Attachment({
    required this.file,
    required this.type,
  });

  final File file;
  final AttachmentType type;

  @override
  List<Object?> get props => [file, type];

  Attachment copyWith({
    File? file,
    AttachmentType? type,
  }) {
    return Attachment(
      file: file ?? this.file,
      type: type ?? this.type,
    );
  }
}
