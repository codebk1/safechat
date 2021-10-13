part of 'profile_cubit.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.firstName = const FirstName(''),
    this.lastName = const LastName(''),
    this.formStatus = FormStatus.init,
    this.loadingAvatar = false,
  });

  final FirstName firstName;
  final LastName lastName;
  final FormStatus formStatus;
  final bool loadingAvatar;

  ProfileState copyWith({
    FirstName? firstName,
    LastName? lastName,
    FormStatus? formStatus,
    bool? loadingAvatar,
  }) {
    return ProfileState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      formStatus: formStatus ?? this.formStatus,
      loadingAvatar: loadingAvatar ?? this.loadingAvatar,
    );
  }

  @override
  List<Object> get props => [firstName, lastName, formStatus, loadingAvatar];
}
