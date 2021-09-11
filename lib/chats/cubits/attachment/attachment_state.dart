part of 'attachment_cubit.dart';

enum AttachmentType { PHOTO, VIDEO, FILE }

class AttachmentState extends Equatable {
  const AttachmentState({
    required this.name,
    required this.type,
    this.downloading = false,
  });

  final String name;
  final AttachmentType type;
  final bool downloading;

  @override
  List<Object> get props => [downloading];

  AttachmentState copyWith({
    String? name,
    AttachmentType? type,
    bool? downloading,
  }) {
    return AttachmentState(
      name: name ?? this.name,
      type: type ?? this.type,
      downloading: downloading ?? this.downloading,
    );
  }
}
