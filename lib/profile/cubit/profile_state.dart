part of 'profile_cubit.dart';

class ProfileState extends Equatable with ValidationMixin {
  const ProfileState({
    this.firstName = const FirstName(''),
    this.lastName = const LastName(''),
    this.currentPassword = const Password(''),
    this.newPassword = const Password('', restrict: true),
    this.confirmNewPassword = const ConfirmPassword(value: '', password: ''),
    this.formStatus = FormStatus.init,
    this.loadingAvatar = false,
  });

  final FirstName firstName;
  final LastName lastName;
  final Password currentPassword;
  final Password newPassword;
  final ConfirmPassword confirmNewPassword;
  final FormStatus formStatus;
  final bool loadingAvatar;

  @override
  List<Object> get props => [
        firstName,
        lastName,
        currentPassword,
        newPassword,
        confirmNewPassword,
        formStatus,
        loadingAvatar,
      ];

  @override
  List<FormItem> get inputs => [
        firstName,
        lastName,
        currentPassword,
        newPassword,
        confirmNewPassword,
      ];

  ProfileState copyWith({
    FirstName? firstName,
    LastName? lastName,
    Password? currentPassword,
    Password? newPassword,
    ConfirmPassword? confirmNewPassword,
    FormStatus? formStatus,
    bool? loadingAvatar,
  }) {
    return ProfileState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      currentPassword: currentPassword ?? this.currentPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmNewPassword: confirmNewPassword ?? this.confirmNewPassword,
      formStatus: formStatus ?? this.formStatus,
      loadingAvatar: loadingAvatar ?? this.loadingAvatar,
    );
  }
}
