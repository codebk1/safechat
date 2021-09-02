import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:safechat/chats/repository/chats_repository.dart';
import 'package:safechat/contacts/models/contact.dart';
import 'package:safechat/utils/utils.dart';

part 'create_chat_state.dart';

class CreateChatCubit extends Cubit<CreateChatState> {
  CreateChatCubit() : super(CreateChatState());

  final ChatsRepository _chatsRepository = ChatsRepository();

  toggleParticipant(Contact participant) {
    emit(state.copyWith(
      selectedParticipants: state.selectedParticipants.contains(participant)
          ? [
              ...List.of(state.selectedParticipants)
                ..removeWhere((e) => e == participant)
            ]
          : [...state.selectedParticipants, participant],
    ));
  }

  Future<void> createChat() async {
    try {
      await _chatsRepository.createChat(state.selectedParticipants);
    } on DioError catch (e) {
      print(e);
      emit(state.copyWith(
        status: FormStatus.failure(e.response?.data['message']),
      ));
    } catch (e) {
      print(e);
      emit(state.copyWith(
        status: FormStatus.failure(e.toString()),
      ));
    }
  }
}