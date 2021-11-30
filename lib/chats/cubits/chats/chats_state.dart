part of 'chats_cubit.dart';

class ChatsState extends Equatable with ValidationMixin {
  const ChatsState({
    this.chats = const [],
    this.nextChat,
    this.name = const Name(''),
    this.formStatus = FormStatus.init,
    this.listStatus = ListStatus.unknow,
    this.loadingAvatar = false,
    this.selectedContacts = const [],
  });

  final List<Chat> chats;
  final Chat? nextChat;
  final Name name;
  final FormStatus formStatus;
  final bool loadingAvatar;
  final ListStatus listStatus;
  final List<Contact> selectedContacts;

  @override
  List<Object?> get props => [
        chats,
        nextChat,
        name,
        formStatus,
        loadingAvatar,
        listStatus,
        selectedContacts,
      ];

  @override
  List<FormItem> get inputs => [name];

  ChatsState copyWith({
    List<Chat>? chats,
    Chat? nextChat,
    Name? name,
    FormStatus? formStatus,
    bool? loadingAvatar,
    ListStatus? listStatus,
    List<Contact>? selectedContacts,
  }) {
    return ChatsState(
      chats: chats ?? this.chats,
      nextChat: nextChat,
      name: name ?? this.name,
      formStatus: formStatus ?? this.formStatus,
      loadingAvatar: loadingAvatar ?? this.loadingAvatar,
      listStatus: listStatus ?? this.listStatus,
      selectedContacts: selectedContacts ?? this.selectedContacts,
    );
  }
}
