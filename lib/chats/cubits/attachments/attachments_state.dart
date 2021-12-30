part of 'attachments_cubit.dart';

class AttachmentsState extends Equatable {
  const AttachmentsState({
    this.loading = false,
    this.attachments = const [],
    this.selectedAttachments = const [],
    this.downloadedAttachment,
  });

  final bool loading;
  final List<Attachment> attachments;
  final List<Attachment> selectedAttachments;
  final FileInfo? downloadedAttachment;

  @override
  List<Object?> get props => [
        loading,
        attachments,
        selectedAttachments,
      ];

  AttachmentsState copyWith({
    bool? loading,
    List<Attachment>? attachments,
    List<Attachment>? selectedAttachments,
    FileInfo? downloadedAttachment,
  }) {
    return AttachmentsState(
      loading: loading ?? this.loading,
      attachments: attachments ?? this.attachments,
      selectedAttachments: selectedAttachments ?? this.selectedAttachments,
      downloadedAttachment: downloadedAttachment ?? this.downloadedAttachment,
    );
  }
}
