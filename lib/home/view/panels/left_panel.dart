import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/user/user.dart';

class LeftPanel extends StatelessWidget {
  const LeftPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 15.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(10.0),
        ),
        color: Colors.white,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 15.0,
                left: 15.0,
                right: 15.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BlocSelector<UserCubit, UserState, User>(
                    selector: (state) {
                      return state.user;
                    },
                    builder: (context, state) {
                      return Flex(
                        direction: Axis.horizontal,
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey.shade200,
                                child: state.avatar != null
                                    ? ClipOval(
                                        child: Image.file(state.avatar!),
                                      )
                                    : const Icon(
                                        Icons.person,
                                      ),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  height: 14,
                                  width: 14,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 15.0),
                          Text('${state.firstName} ${state.lastName}')
                        ],
                      );
                    },
                  ),
                  IconButton(
                    onPressed: () async {
                      await context.read<UserCubit>().unauthenticate();
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: Column(
                children: [
                  ListTile(
                    title: const Text(
                      "Status",
                      style: TextStyle(fontSize: 16),
                    ),
                    leading: const Icon(Icons.online_prediction_sharp),
                    onTap: () {},
                  ),
                  ListTile(
                    title: const Text(
                      "Moje konto",
                      style: TextStyle(fontSize: 16),
                    ),
                    leading: const Icon(Icons.account_box),
                    onTap: () {
                      Navigator.of(context).pushNamed('/profile');
                    },
                  ),
                  ListTile(
                    title: const Text(
                      "Ustawienia",
                      style: TextStyle(fontSize: 16),
                    ),
                    leading: const Icon(Icons.settings),
                    onTap: () {},
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Icon(
                            Icons.copyright_sharp,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 10.0),
                          Text(
                            "Bartek Kaczmarek",
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
