import 'package:equatable/equatable.dart';

enum AttachmentType { photo, video, file }

class Attachment extends Equatable {
  const Attachment({
    required this.name,
    required this.type,
    this.downloading = false,
  });

  final String name;
  final AttachmentType type;
  final bool downloading;

  @override
  List<Object> get props => [name, type, downloading];

  Attachment copyWith({
    String? name,
    AttachmentType? type,
    bool? downloading,
  }) {
    return Attachment(
      name: name ?? this.name,
      type: type ?? this.type,
      downloading: downloading ?? this.downloading,
    );
  }
}

extension AttachmentTypeExtension on AttachmentType {
  bool get isPhoto => this == AttachmentType.photo;
  bool get isVideo => this == AttachmentType.video;
  bool get isFile => this == AttachmentType.file;
}
