part of 'chats_cubit.dart';

//enum ListStatus { unknow, loading, success, failure }

class ChatsState extends Equatable {
  const ChatsState({
    this.chats = const [],
    this.listStatus = ListStatus.unknow,
    this.newChat = const NewChat(),
    this.nextChat,
  });

  final List<Chat> chats;
  final ListStatus listStatus;
  final NewChat newChat;
  final Chat? nextChat;

  @override
  List<Object?> get props => [chats, listStatus, newChat, nextChat];

  ChatsState copyWith({
    ListStatus? listStatus,
    List<Chat>? chats,
    NewChat? newChat,
    Chat? nextChat,
  }) {
    return ChatsState(
      listStatus: listStatus ?? this.listStatus,
      chats: chats ?? this.chats,
      newChat: newChat ?? this.newChat,
      nextChat: nextChat,
    );
  }
}
