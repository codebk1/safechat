import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/profile/cubit/profile_cubit.dart';
import 'package:safechat/user/user.dart';
import 'package:safechat/utils/form_helper.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.grey.shade800,
          ),
          title: Text(
            'Moje konto',
            style: TextStyle(
              color: Colors.grey.shade800,
            ),
          ),
        ),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overScroll) {
            overScroll.disallowIndicator();
            return true;
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _AvatarPicker(),
                  const SizedBox(
                    height: 25.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Dane konta',
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/profile/edit');
                          },
                          icon: const Icon(Icons.edit),
                          splashRadius: 20.0,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    child: BlocBuilder<UserCubit, UserState>(
                      builder: (context, state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Imię',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    Text(
                                      state.user.firstName,
                                      style: const TextStyle(fontSize: 18.0),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 35.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Nazwisko',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    Text(
                                      state.user.lastName,
                                      style: const TextStyle(fontSize: 18.0),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 15.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Email',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(
                                  state.user.email,
                                  style: const TextStyle(fontSize: 18.0),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      'Zarządzanie kontem',
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton.icon(
                          style: ButtonStyle(
                            overlayColor: MaterialStateColor.resolveWith(
                                (states) => Colors.red.shade50),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamed('/password/edit');
                          },
                          icon: Icon(
                            Icons.lock_rounded,
                            color: Colors.grey.shade800,
                          ),
                          label: Text(
                            'Zmień hasło',
                            style: TextStyle(
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          style: ButtonStyle(
                            overlayColor: MaterialStateColor.resolveWith(
                                (states) => Colors.red.shade50),
                          ),
                          onPressed: () async {
                            await context.read<UserCubit>().deleteAccount();

                            if (context.mounted) {
                              context.read<UserCubit>().unauthenticate();

                              Navigator.of(context).pushReplacementNamed(
                                '/login',
                              );
                            }
                          },
                          icon: BlocBuilder<UserCubit, UserState>(
                            builder: (context, state) {
                              return !state.formStatus.isLoading
                                  ? Icon(
                                      Icons.delete_forever,
                                      color: Colors.red.shade800,
                                    )
                                  : SizedBox(
                                      width: 23,
                                      height: 23,
                                      child: Transform.scale(
                                        scale: 0.5,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.red.shade800,
                                        ),
                                      ),
                                    );
                            },
                          ),
                          label: Text(
                            'Usuń konto',
                            style: TextStyle(
                              color: Colors.red.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarPicker extends StatefulWidget {
  const _AvatarPicker({
    Key? key,
  }) : super(key: key);

  @override
  _AvatarPickerState createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<_AvatarPicker> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            GestureDetector(
              onTap: () => context.read<ProfileCubit>().setAvatar(),
              child: Stack(
                children: [
                  BlocBuilder<ProfileCubit, ProfileState>(
                    builder: (context, state) {
                      return CircleAvatar(
                          radius: 55.0,
                          backgroundColor: Colors.grey.shade200,
                          child: state.loadingAvatar
                              ? CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.grey.shade900,
                                )
                              : BlocBuilder<UserCubit, UserState>(
                                  builder: (context, state) {
                                    return state.user.avatar != null
                                        ? ClipOval(
                                            child: Image.file(
                                              state.user.avatar,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.photo_library_outlined,
                                            size: 45.0,
                                            color: Colors.white,
                                          );
                                  },
                                ));
                    },
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 35.0,
                      height: 35.0,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade800,
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 2,
                          color: Colors.white,
                        ),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 15.0,
            ),
            BlocBuilder<UserCubit, UserState>(
              builder: (context, state) {
                if (state.user.avatar != null) {
                  return TextButton(
                    onPressed: () =>
                        context.read<ProfileCubit>().removeAvatar(),
                    child: Text(
                      'Usuń avatar',
                      style: TextStyle(
                        color: Colors.grey.shade900,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ],
    );
  }
}
