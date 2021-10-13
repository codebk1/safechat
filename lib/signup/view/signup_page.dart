import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'package:safechat/utils/utils.dart';
import 'package:safechat/signup/signup.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final _orientation = MediaQuery.of(context).orientation;
    final _showHero = !_keyboardOpen && _orientation == Orientation.portrait;

    return BlocConsumer<SignupCubit, SignupState>(
      buildWhen: (previous, current) => previous.email != current.email,
      listener: (context, state) {
        if (state.formStatus.isSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 1),
                content: Row(
                  children: const <Widget>[
                    Icon(
                      Icons.check_circle,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text('Pomyślnie zarejestrowano.'),
                  ],
                ),
              ),
            );

          Navigator.of(context).pushReplacementNamed('/login');
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
                    Text(state.formStatus.error!),
                  ],
                ),
              ),
            );
        }
      },
      builder: (context, state) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overScroll) {
                overScroll.disallowGlow();
                return true;
              },
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      children: [
                        if (_showHero)
                          Column(
                            children: [
                              const SizedBox(
                                height: 25.0,
                              ),
                              SvgPicture.asset(
                                'assets/logo.svg',
                                allowDrawingOutsideViewBox: true,
                                width: 180,
                              ),
                              const SizedBox(
                                height: 40,
                                child: VerticalDivider(
                                  thickness: 1,
                                ),
                              ),
                              const Divider(
                                height: 0,
                                thickness: 1,
                              ),
                            ],
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 30.0,
                          ),
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Zarejestruj się.',
                                      style:
                                          Theme.of(context).textTheme.headline5,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Utwórz konto i ciesz się bezpieczną komunikacją.',
                                      style:
                                          Theme.of(context).textTheme.subtitle2,
                                    ),
                                  ),
                                  const SizedBox(height: 25),
                                  Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            child: _FirstNameTextFormField(),
                                          ),
                                          const SizedBox(width: 15),
                                          Flexible(
                                            child: _LastNameTextFormField(),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 15),
                                      _EmailTextFormField(),
                                      const SizedBox(height: 15),
                                      _PasswordTextFormField(),
                                      const SizedBox(height: 15),
                                      _ConfirmPasswordTextFormField(),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 0,
                          thickness: 1,
                        ),
                        const Expanded(
                          child: SizedBox(
                            child: VerticalDivider(
                              thickness: 1,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Ink(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: BlocBuilder<SignupCubit, SignupState>(
                                  builder: (context, state) {
                                    return InkWell(
                                      borderRadius: BorderRadius.circular(5.0),
                                      onTap: () {
                                        context.read<SignupCubit>().submit();
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
                                                  'Zarejestruj',
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Masz konto?',
                                    style:
                                        Theme.of(context).textTheme.subtitle2,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pushNamedAndRemoveUntil(
                                        '/login',
                                        (Route<dynamic> route) => false,
                                      );
                                    },
                                    child: const Text(
                                      'Zaloguj się',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
    return BlocBuilder<SignupCubit, SignupState>(
      builder: (context, state) {
        return TextFormField(
          onChanged: (value) =>
              context.read<SignupCubit>().firstNameChanged(value),
          decoration: InputDecoration(
            labelText: 'Imię',
            errorText:
                state.formStatus.isSubmiting ? state.firstName.error : null,
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (String? value) {
            return state.firstName.error;
          },
        );
      },
    );
  }
}

class _LastNameTextFormField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupCubit, SignupState>(
      builder: (context, state) {
        return TextFormField(
          onChanged: (value) =>
              context.read<SignupCubit>().lastNameChanged(value),
          decoration: InputDecoration(
            labelText: 'Nazwisko',
            errorText:
                state.formStatus.isSubmiting ? state.lastName.error : null,
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (String? value) {
            return state.lastName.error;
          },
        );
      },
    );
  }
}

class _EmailTextFormField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupCubit, SignupState>(
      builder: (context, state) {
        return TextFormField(
          onChanged: (value) => context.read<SignupCubit>().emailChanged(value),
          decoration: InputDecoration(
            labelText: 'Email',
            errorText: state.formStatus.isSubmiting ? state.email.error : null,
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (String? value) {
            return state.email.error;
          },
        );
      },
    );
  }
}

class _PasswordTextFormField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupCubit, SignupState>(
      builder: (context, state) {
        return TextFormField(
          onChanged: (value) =>
              context.read<SignupCubit>().passwordChanged(value),
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Hasło',
            errorText:
                state.formStatus.isSubmiting ? state.password.error : null,
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (String? value) {
            return state.password.error;
          },
        );
      },
    );
  }
}

class _ConfirmPasswordTextFormField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupCubit, SignupState>(
      builder: (context, state) {
        return TextFormField(
          onChanged: (value) =>
              context.read<SignupCubit>().confirmPasswordChanged(value),
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Potwierdź hasło',
            errorText: state.formStatus.isSubmiting
                ? state.confirmPassword.error
                : null,
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (String? value) {
            return state.confirmPassword.error;
          },
        );
      },
    );
  }
}
