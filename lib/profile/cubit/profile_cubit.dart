import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safechat/common/common.dart';
import 'package:safechat/user/user.dart';
import 'package:safechat/utils/utils.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._userCubit) : super(ProfileState());

  final UserCubit _userCubit;

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

      Uint8List data = await pickedPhoto.readAsBytes();
      List<int> processedAvatar = await computeCropAvatar(data);

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
    try {
      emit(state.copyWith(status: FormStatus.loading()));

      await _userCubit.updateProfile(
        state.firstName.value,
        state.lastName.value,
      );

      emit(state.copyWith(status: FormStatus.success()));
    } on DioError catch (e) {
      emit(state.copyWith(
        status: FormStatus.failure(e.response!.data['message']),
      ));
    }
  }

  void firstNameChanged(String value) {
    emit(state.copyWith(
      firstName: FirstName(value),
      status: FormStatus.init(),
    ));
  }

  void lastNameChanged(String value) {
    emit(state.copyWith(
      lastName: LastName(value),
      status: FormStatus.init(),
    ));
  }

  Future<List<int>> computeCropAvatar(Uint8List photo) async {
    return await compute(cropAvatar, photo);
  }
}

List<int> cropAvatar(Uint8List data) {
  Image croppedPhoto = copyCropCircle(decodeImage(data)!);
  croppedPhoto = copyResize(
    croppedPhoto,
    height: 150,
    width: 150,
    interpolation: Interpolation.average,
  );

  List<int> avatar = encodePng(croppedPhoto);

  return avatar;
}
