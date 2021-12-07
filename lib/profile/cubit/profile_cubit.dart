import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image/image.dart';
import 'package:image_picker/image_picker.dart';

import 'package:safechat/utils/utils.dart';
import 'package:safechat/common/common.dart';
import 'package:safechat/user/user.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._userCubit, this._userRepository)
      : super(const ProfileState());

  final UserCubit _userCubit;
  final UserRepository _userRepository;

  initForm() {
    emit(state.copyWith(
      firstName: FirstName(_userCubit.state.user.firstName),
      lastName: LastName(_userCubit.state.user.lastName),
    ));
  }

  Future<File?> setAvatar() async {
    final XFile? pickedPhoto = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedPhoto != null) {
      emit(state.copyWith(loadingAvatar: true));

      var data = await pickedPhoto.readAsBytes();
      var processedAvatar = await computeCropAvatar(data) as Uint8List;

      await _userCubit.updateAvatar(processedAvatar);

      emit(state.copyWith(loadingAvatar: false));
    }
  }

  removeAvatar() async {
    emit(state.copyWith(loadingAvatar: true));

    await _userCubit.removeAvatar();

    emit(state.copyWith(loadingAvatar: false));
  }

  Future<void> editProfileSubmit() async {
    emit(state.copyWith(formStatus: FormStatus.submiting));

    if (state.validate([state.firstName, state.lastName]).isValid) {
      try {
        emit(state.copyWith(formStatus: FormStatus.loading));

        await _userCubit.updateProfile(
          state.firstName.value,
          state.lastName.value,
        );

        emit(state.copyWith(
          formStatus: const FormStatus.success('Zaktualizowano dane.'),
        ));
      } on DioError catch (e) {
        emit(state.copyWith(
          formStatus: FormStatus.failure(e.response!.data['message']),
        ));
      }
    }
  }

  Future<void> editPasswordSubmit() async {
    emit(state.copyWith(formStatus: FormStatus.submiting));

    if (state
        .validate([state.currentPassword, state.confirmNewPassword]).isValid) {
      try {
        emit(state.copyWith(formStatus: FormStatus.loading));

        await _userRepository.updatePassword(
          _userCubit.state.user.email,
          state.currentPassword.value,
          state.confirmNewPassword.value,
        );

        emit(state.copyWith(
          formStatus: const FormStatus.success('Zmieniono hasło.'),
        ));
      } on DioError catch (e) {
        emit(state.copyWith(
          formStatus: FormStatus.failure(e.response!.data['message']),
        ));
      } catch (e) {
        emit(state.copyWith(
          formStatus: const FormStatus.failure('Wystąpił błąd.'),
        ));
      }
    }
  }

  void firstNameChanged(String value) {
    emit(state.copyWith(
      firstName: FirstName(value),
    ));
  }

  void lastNameChanged(String value) {
    emit(state.copyWith(
      lastName: LastName(value),
    ));
  }

  void currentPasswordChanged(String value) {
    emit(state.copyWith(
      currentPassword: Password(value),
    ));
  }

  void newPasswordChanged(String value) {
    emit(state.copyWith(
      newPassword: Password(value, restrict: true),
    ));
  }

  void confirmNewPasswordChanged(String value) {
    emit(state.copyWith(
      confirmNewPassword: ConfirmPassword(
        value: value,
        password: state.newPassword.value,
      ),
    ));
  }

  Future<List<int>> computeCropAvatar(Uint8List photo) async {
    return await compute(cropAvatar, photo);
  }
}

List<int> cropAvatar(Uint8List data) {
  //Image croppedPhoto = copyCropCircle(decodeImage(data)!);
  //Image image = decodeImage(data)!;

  Image croppedPhoto = copyResizeCropSquare(
    decodeImage(data)!,
    150,
  );

  List<int> avatar = encodeJpg(croppedPhoto);

  return avatar;
}
