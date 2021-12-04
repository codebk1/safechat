import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/profile/cubit/profile_cubit.dart';

import 'package:safechat/utils/utils.dart';
import 'package:safechat/user/user.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.formStatus.isSuccess) {
          Navigator.of(context).pop();
        }

        if (state.formStatus.isFailure) {
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
                    const Icon(
                      Icons.error,
                      color: Colors.white,
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Text(state.formStatus.message!),
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
            title: Text(
              'Edytuj dane konta',
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
                      children: [
                        Column(
                          children: [
                            _FirstNameTextFormField(),
                            const SizedBox(
                              height: 15.0,
                            ),
                            _LastNameTextFormField(),
                            const SizedBox(
                              height: 15.0,
                            ),
                            Ink(
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: BlocBuilder<ProfileCubit, ProfileState>(
                                builder: (context, state) {
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(5.0),
                                    onTap: () {
                                      //if (_formKey.currentState!.validate()) {
                                      context
                                          .read<ProfileCubit>()
                                          .editProfileSubmit();
                                      //}
                                    },
                                    child: SizedBox(
                                      height: 60.0,
                                      child: Center(
                                        child: state.formStatus.isLoading
                                            ? const CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.0,
                                              )
                                            : Text(
                                                'Zapisz',
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
                      ],
                    ),
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

class _FirstNameTextFormField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (previous, current) => previous.firstName != current.firstName,
      builder: (context, state) {
        return TextFormField(
          initialValue: context.read<UserCubit>().state.user.firstName,
          onChanged: (value) =>
              context.read<ProfileCubit>().firstNameChanged(value),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: const InputDecoration(
            labelText: 'Imię',
          ),
          validator: (String? value) {
            if (value!.isEmpty) {
              return 'Imię jest wymagane.';
            }
          },
        );
      },
    );
  }
}

class _LastNameTextFormField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (previous, current) => previous.lastName != current.lastName,
      builder: (context, state) {
        return TextFormField(
          initialValue: context.read<UserCubit>().state.user.lastName,
          onChanged: (value) =>
              context.read<ProfileCubit>().lastNameChanged(value),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: const InputDecoration(
            labelText: 'Naziwsko',
          ),
          validator: (String? value) {
            if (value!.isEmpty) {
              return 'Nazwisko jest wymagane.';
            }
          },
        );
      },
    );
  }
}
