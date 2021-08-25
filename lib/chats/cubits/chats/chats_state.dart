part of 'chats_cubit.dart';

//enum ListStatus { unknow, loading, success, failure }

class ChatsState extends Equatable {
  const ChatsState({
    this.chats = const [],
    this.listStatus = ListStatus.unknow,
  });

  final List<ChatState> chats;
  final ListStatus listStatus;

  @override
  List<Object> get props => [chats, listStatus];

  ChatsState copyWith({
    ListStatus? listStatus,
    List<ChatState>? chats,
  }) {
    return ChatsState(
      listStatus: listStatus ?? this.listStatus,
      chats: chats ?? this.chats,
    );
  }
}
