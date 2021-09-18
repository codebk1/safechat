import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/contacts/cubit/cubits.dart';

import 'package:safechat/user/user.dart';

class AddContactPage extends StatefulWidget {
  @override
  _AddContactPageState createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final bool _keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final Orientation _orientation = MediaQuery.of(context).orientation;

    return BlocConsumer<ContactsCubit, ContactsState>(
      listener: (context, state) {
        if (state.status.isSuccess) {
          Navigator.of(context).pop();

          // ScaffoldMessenger.of(context)
          //   ..hideCurrentSnackBar()
          //   ..showSnackBar(
          //     SnackBar(
          //       duration: Duration(seconds: 1),
          //       content: Row(
          //         children: <Widget>[
          //           Icon(
          //             Icons.check_circle,
          //             color: Colors.white,
          //           ),
          //           SizedBox(
          //             width: 10.0,
          //           ),
          //           Text('Wysłano zaproszenie.'),
          //         ],
          //       ),
          //     ),
          //   );
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
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _EmailTextFormField(),
                      SizedBox(
                        height: 15.0,
                      ),
                      Ink(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: BlocBuilder<ContactsCubit, ContactsState>(
                          builder: (context, state) {
                            return InkWell(
                              borderRadius: BorderRadius.circular(5.0),
                              onTap: () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<ContactsCubit>().addContact(
                                        context.read<UserCubit>().state.user,
                                      );
                                }
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
    return BlocBuilder<ContactsCubit, ContactsState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextFormField(
          onChanged: (value) =>
              context.read<ContactsCubit>().emailChanged(value),
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
