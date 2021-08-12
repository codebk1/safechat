import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/auth/cubit/auth_cubit.dart';

import 'package:safechat/friends/cubit/friends_cubit.dart';
import 'package:safechat/friends/repository/friends_repository.dart';
import 'package:safechat/utils/api_service.dart';

class AddFriendPage extends StatelessWidget {
  AddFriendPage({Key? key}) : super(key: key);

  final apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return AddFriendView();
  }
}

class AddFriendView extends StatefulWidget {
  @override
  _AddFriendViewState createState() => _AddFriendViewState();
}

class _AddFriendViewState extends State<AddFriendView> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final bool _keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final Orientation _orientation = MediaQuery.of(context).orientation;

    return BlocConsumer<FriendsCubit, FriendsState>(
      listener: (context, state) {
        if (state.status.isSuccess) {
          Navigator.of(context).pop();
        }

        if (state.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                action: SnackBarAction(
                  onPressed: () =>
                      ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                  label: 'Zamknij',
                ),
                content: Row(
                  children: <Widget>[
                    Icon(
                      Icons.error,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text(state.status.error),
                  ],
                ),
              ),
            );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            // title: Text(
            //   'Dodaj znajomego',
            //   style: TextStyle(color: Colors.grey.shade800),
            // ),
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(
              color: Colors.grey.shade800, //change your color here
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                if (!_keyboardOpen && _orientation == Orientation.portrait)
                  Icon(
                    Icons.person_add_alt_1,
                    size: 150.0,
                    color: Colors.grey.shade100,
                  ),
                Text(
                  'Dodaj swojego znajomego',
                  style: Theme.of(context).textTheme.headline5,
                ),
                SizedBox(
                  height: 15.0,
                ),
                Text(
                  'Podaj email i wyślij zaproszenie.',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                SizedBox(
                  height: 20.0,
                ),
                _EmailTextFormField(),
                SizedBox(
                  height: 15.0,
                ),
                Ink(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: BlocBuilder<FriendsCubit, FriendsState>(
                    builder: (context, state) {
                      return InkWell(
                        borderRadius: BorderRadius.circular(5.0),
                        onTap: () {
                          //if (_formKey.currentState!.validate()) {
                          context.read<FriendsCubit>().submit(
                                context.read<AuthCubit>().state.user,
                              );
                          //}
                        },
                        child: SizedBox(
                          height: 60.0,
                          child: Center(
                            child: state.status.isLoading
                                ? CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.0,
                                  )
                                : Text(
                                    'Wyślij zaproszenie',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6!
                                        .copyWith(
                                          color: Colors.white,
                                        ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmailTextFormField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendsCubit, FriendsState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextFormField(
          onChanged: (value) =>
              context.read<FriendsCubit>().emailChanged(value),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            labelText: 'Email',
          ),
          validator: (String? value) {
            if (value!.length == 0) {
              return 'Email jest wymagany.';
            }
          },
        );
      },
    );
  }
}
