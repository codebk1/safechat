part of 'chats_cubit.dart';

class ChatsState extends Equatable {
  const ChatsState({
    this.chats = const [],
    this.name = const Name(''),
    this.form = FormStatus.init,
    this.listStatus = ListStatus.unknow,
    this.newChat = const NewChat(),
    this.nextChat,
    this.loadingAvatar = false,
  });

  final List<Chat> chats;
  final Name name;
  final FormStatus form;
  final ListStatus listStatus;
  final NewChat newChat;
  final Chat? nextChat;
  final bool loadingAvatar;

  @override
  List<Object?> get props => [
        chats,
        name,
        form,
        listStatus,
        newChat,
        nextChat,
        loadingAvatar,
      ];

  ChatsState copyWith(
      {List<Chat>? chats,
      Name? name,
      FormStatus? form,
      ListStatus? listStatus,
      NewChat? newChat,
      Chat? nextChat,
      bool? loadingAvatar}) {
    return ChatsState(
      chats: chats ?? this.chats,
      name: name ?? this.name,
      form: form ?? this.form,
      listStatus: listStatus ?? this.listStatus,
      newChat: newChat ?? this.newChat,
      nextChat: nextChat,
      loadingAvatar: loadingAvatar ?? this.loadingAvatar,
    );
  }
}
