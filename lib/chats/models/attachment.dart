import 'package:equatable/equatable.dart';

enum AttachmentType { PHOTO, VIDEO, FILE }

class Attachment extends Equatable {
  const Attachment({
    required this.path,
    required this.type,
  });

  final String path;
  final AttachmentType type;

  @override
  List<Object?> get props => [path, type];

  Attachment copyWith({
    String? path,
    AttachmentType? type,
  }) {
    return Attachment(
      path: path ?? this.path,
      type: type ?? this.type,
    );
  }
}
