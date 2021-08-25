import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:safechat/chats/cubits/chat/cubit/chat_cubit.dart';
import 'package:safechat/chats/repository/chats_repository.dart';
import 'package:safechat/contacts/contacts.dart';

part 'chats_state.dart';

class ChatsCubit extends Cubit<ChatsState> {
  ChatsCubit() : super(ChatsState());

  final _chatsRepository = ChatsRepository();

  Future<void> getChats() async {
    try {
      emit(state.copyWith(listStatus: ListStatus.loading));

      final chats = await _chatsRepository.getChats();

      emit(state.copyWith(chats: chats, listStatus: ListStatus.success));
    } on DioError catch (e) {
      print(e);
      emit(state.copyWith(listStatus: ListStatus.failure));
    } catch (e) {
      print(e);
      emit(state.copyWith(listStatus: ListStatus.failure));
    }
  }
}
