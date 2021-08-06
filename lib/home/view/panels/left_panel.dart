import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/auth/auth.dart';

class LeftPanel extends StatelessWidget {
  const LeftPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(right: 15.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(10.0),
          ),
          color: Colors.white,
        ),
        child: Column(
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
                  BlocSelector<AuthCubit, AuthState, User>(
                    selector: (state) {
                      return state.user;
                    },
                    builder: (context, state) {
                      return Flex(
                        direction: Axis.horizontal,
                        children: [
                          CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          SizedBox(width: 15.0),
                          Text('${state.firstName} ${state.lastName}')
                        ],
                      );
                    },
                  ),
                  IconButton(
                    onPressed: () => context.read<AuthCubit>().unauthenticate(),
                    icon: Icon(Icons.logout),
                  ),
                ],
              ),
            ),
            Divider(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        "Status",
                        style: TextStyle(fontSize: 16),
                      ),
                      leading: Icon(Icons.online_prediction_sharp),
                    ),
                    ListTile(
                      title: Text(
                        "Ustawienia",
                        style: TextStyle(fontSize: 16),
                      ),
                      leading: Icon(Icons.settings),
                    ),
                    Expanded(
                      child: new Align(
                        alignment: Alignment.bottomCenter,
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.copyright_sharp,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 10.0),
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
            ),
          ],
        ));
  }
}
