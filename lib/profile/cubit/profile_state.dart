part of 'profile_cubit.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.firstName = const FirstName(''),
    this.lastName = const LastName(''),
    this.status = const FormStatus.init(),
    this.loadingAvatar = false,
  });

  final FirstName firstName;
  final LastName lastName;
  final FormStatus status;
  final bool loadingAvatar;

  ProfileState copyWith({
    FirstName? firstName,
    LastName? lastName,
    FormStatus? status,
    bool? loadingAvatar,
  }) {
    return ProfileState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      status: status ?? this.status,
      loadingAvatar: loadingAvatar ?? this.loadingAvatar,
    );
  }

  @override
  List<Object> get props => [firstName, lastName, status, loadingAvatar];
}
