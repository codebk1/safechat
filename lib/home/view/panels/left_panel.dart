import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/contacts/contacts.dart';
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
                                child: StatusIndicator(
                                  isOnline: true,
                                  status: state.status,
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
                    onTap: () {
                      SystemChrome.setEnabledSystemUIMode(
                        SystemUiMode.immersive,
                      );
                      showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(
                                10.0,
                              ),
                            ),
                          ),
                          builder: (BuildContext _) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Text(
                                    'Ustaw status',
                                    style:
                                        Theme.of(context).textTheme.headline5,
                                  ),
                                ),
                                for (Status value in Status.values)
                                  StatusListTile(status: value),
                              ],
                            );
                          }).whenComplete(
                        () => SystemChrome.setEnabledSystemUIMode(
                          SystemUiMode.edgeToEdge,
                        ),
                      );
                    },
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
                  // ListTile(
                  //   title: const Text(
                  //     "Ustawienia",
                  //     style: TextStyle(fontSize: 16),
                  //   ),
                  //   leading: const Icon(Icons.settings),
                  //   onTap: () {},
                  // ),
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

class StatusListTile extends StatelessWidget {
  const StatusListTile({
    Key? key,
    required this.status,
  }) : super(key: key);

  final Status status;

  String _getTitleText() {
    switch (status) {
      case Status.visible:
        return 'Dostępny';
      case Status.idle:
        return 'Zaraz wracam';
      case Status.busy:
        return 'Nie przeszkadzać';
      case Status.invisible:
        return 'Niewidoczny';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        return ListTile(
          onTap: () {
            context.read<UserCubit>().updateStatus(status);
            Navigator.of(context).pop();
          },
          leading: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: StatusIndicator(
              isOnline: true,
              status: status,
            ),
          ),
          title: Text(
            _getTitleText(),
          ),
          trailing: state.user.status == status
              ? const Icon(
                  Icons.check,
                )
              : null,
        );
      },
    );
  }
}
