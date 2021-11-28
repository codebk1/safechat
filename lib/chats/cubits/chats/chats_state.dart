part of 'chats_cubit.dart';

class ChatsState extends Equatable with ValidationMixin {
  const ChatsState({
    this.chats = const [],
    this.newChat = const NewChat(),
    this.nextChat,
    this.name = const Name(''),
    this.formStatus = FormStatus.init,
    this.listStatus = ListStatus.unknow,
    this.loadingAvatar = false,
  });

  final List<Chat> chats;
  final NewChat newChat;
  final Chat? nextChat;
  final Name name;
  final FormStatus formStatus;
  final bool loadingAvatar;
  final ListStatus listStatus;

  @override
  List<Object?> get props => [
        chats,
        newChat,
        nextChat,
        name,
        formStatus,
        loadingAvatar,
        listStatus,
      ];

  @override
  List<FormItem> get inputs => [name];

  ChatsState copyWith({
    List<Chat>? chats,
    NewChat? newChat,
    Chat? nextChat,
    Name? name,
    FormStatus? formStatus,
    bool? loadingAvatar,
    ListStatus? listStatus,
  }) {
    return ChatsState(
      chats: chats ?? this.chats,
      newChat: newChat ?? this.newChat,
      nextChat: nextChat,
      name: name ?? this.name,
      formStatus: formStatus ?? this.formStatus,
      loadingAvatar: loadingAvatar ?? this.loadingAvatar,
      listStatus: listStatus ?? this.listStatus,
    );
  }
}
