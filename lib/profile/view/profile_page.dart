import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/profile/cubit/profile_cubit.dart';
import 'package:safechat/user/user.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.grey.shade800, //change your color here
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
          overScroll.disallowGlow();
          return true;
        },
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AvatarPicker(),
                    SizedBox(
                      height: 25.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Dane konta',
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/profile/edit');
                            },
                            icon: Icon(Icons.edit),
                            splashRadius: 20.0,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      child: BlocBuilder<UserCubit, UserState>(
                        builder: (context, state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //SizedBox(height: 15.0),
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Imię',
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2,
                                      ),
                                      Text(
                                        state.user.firstName,
                                        style: TextStyle(fontSize: 18.0),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 35.0),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Nazwisko',
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2,
                                      ),
                                      Text(
                                        state.user.lastName,
                                        style: TextStyle(fontSize: 18.0),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // SizedBox(height: 15.0),
                              // Column(
                              //   crossAxisAlignment: CrossAxisAlignment.start,
                              //   children: [
                              //     Text(
                              //       'Email',
                              //       style: Theme.of(context).textTheme.subtitle2,
                              //     ),
                              //     Text(
                              //       state.user.email,
                              //       style: TextStyle(fontSize: 18.0),
                              //     ),
                              //   ],
                              // ),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 25.0),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        'Zarządzanie kontem',
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.all(
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
                            onPressed: () {},
                            icon: Icon(
                              Icons.delete_forever,
                              color: Colors.red.shade800,
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
          ],
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
  __AvatarPickerState createState() => __AvatarPickerState();
}

class __AvatarPickerState extends State<_AvatarPicker> {
  @override
  Widget build(BuildContext context) {
    return Row(
      //mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: context.read<ProfileCubit>().setAvatar,
          child: Stack(
            children: [
              BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, state) {
                  return state.loadingAvatar
                      ? CircularProgressIndicator(
                          strokeWidth: 2,
                        )
                      : BlocBuilder<UserCubit, UserState>(
                          builder: (context, state) {
                            return CircleAvatar(
                              radius: 45.0,
                              backgroundColor: Colors.grey.shade200,
                              child: state.user.avatar != null
                                  ? ClipOval(
                                      child: Image.file(state.user.avatar!),
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 45.0,
                                      color: Colors.white,
                                    ),
                            );
                          },
                        );
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
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 15.0,
        ),
        BlocBuilder<UserCubit, UserState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.user.email,
                  style: TextStyle(fontSize: 18.0),
                ),
                TextButton(
                  onPressed: context.read<ProfileCubit>().removeAvatar,
                  child: Text(
                    'Usuń avatar',
                    style: TextStyle(
                      color: Colors.grey.shade900,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
