import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:safechat/auth/models/user.dart';
import 'package:safechat/common/common.dart';
import 'package:safechat/friends/models/friend.dart';
import 'package:safechat/friends/repository/friends_repository.dart';
import 'package:safechat/utils/utils.dart';

part 'friends_state.dart';

class FriendsCubit extends Cubit<FriendsState> {
  FriendsCubit(this._friendsRepository) : super(FriendsState());

  final FriendsRepository _friendsRepository;

  Future<void> getFriends() async {
    print('GET FRIENDS');
    try {
      emit(state.copyWith(listStatus: ListStatus.loading));

      final friends = await _friendsRepository.getFriends();

      emit(state.copyWith(friends: friends, listStatus: ListStatus.success));
    } on DioError catch (e) {
      emit(state.copyWith(
        status: FormStatus.failure(e.response?.data['message']),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FormStatus.failure(e.toString()),
      ));
    }
  }

  Future<void> submit(User user) async {
    try {
      emit(state.copyWith(status: FormStatus.loading()));

      await _friendsRepository.addFriend(user, state.email.value);
      //await _authCubit.authenticate();

      emit(state.copyWith(status: FormStatus.success()));
    } on DioError catch (e) {
      emit(state.copyWith(
        status: FormStatus.failure(e.response?.data['message']),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FormStatus.failure(e.toString()),
      ));
    }
  }

  void emailChanged(String value) {
    emit(state.copyWith(
      email: Email(value),
      status: FormStatus.init(),
    ));
  }
}
