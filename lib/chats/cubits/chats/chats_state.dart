part of 'chats_cubit.dart';

class ChatsState extends Equatable {
  const ChatsState({
    this.chats = const [],
    this.name = const Name(''),
    this.status = const FormStatus.init(),
    this.listStatus = ListStatus.unknow,
    this.newChat = const NewChat(),
    this.nextChat,
    this.loadingAvatar = false,
  });

  final List<Chat> chats;
  final Name name;
  final FormStatus status;
  final ListStatus listStatus;
  final NewChat newChat;
  final Chat? nextChat;
  final bool loadingAvatar;

  @override
  List<Object?> get props => [
        chats,
        name,
        status,
        listStatus,
        newChat,
        nextChat,
        loadingAvatar,
      ];

  ChatsState copyWith(
      {List<Chat>? chats,
      Name? name,
      FormStatus? status,
      ListStatus? listStatus,
      NewChat? newChat,
      Chat? nextChat,
      bool? loadingAvatar}) {
    return ChatsState(
      chats: chats ?? this.chats,
      name: name ?? this.name,
      status: status ?? this.status,
      listStatus: listStatus ?? this.listStatus,
      newChat: newChat ?? this.newChat,
      nextChat: nextChat,
      loadingAvatar: loadingAvatar ?? this.loadingAvatar,
    );
  }
}
