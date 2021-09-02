import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'package:safechat/login/login.dart';

// class LoginPage extends StatelessWidget {
//   const LoginPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final AuthCubit _authCubit = BlocProvider.of<AuthCubit>(context);

//     return LoginView();
//   }
// }

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final bool _keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final Orientation _orientation = MediaQuery.of(context).orientation;

    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state.status.isSuccess) {
          Navigator.of(context).pushReplacementNamed('/home');
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (!_keyboardOpen &&
                              _orientation == Orientation.portrait)
                            Column(
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.reply),
                                    ),
                                  ],
                                ),
                                SvgPicture.asset(
                                  'assets/logo.svg',
                                  allowDrawingOutsideViewBox: true,
                                  width: 180,
                                ),
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const SizedBox(
                                      height: 125,
                                      child: VerticalDivider(
                                        thickness: 1,
                                      ),
                                    ),
                                    SvgPicture.asset(
                                      'assets/messages_animation.svg',
                                      allowDrawingOutsideViewBox: true,
                                      width: 200,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          const Divider(
                            height: 0,
                            thickness: 1,
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
                                        'Zaloguj się.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Twoje wiadomości są zawsze bezpieczne.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2,
                                      ),
                                    ),
                                    const SizedBox(height: 25),
                                    _EmailTextFormField(),
                                    const SizedBox(height: 15),
                                    _PasswordTextFormField(),
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
                                  child: BlocBuilder<LoginCubit, LoginState>(
                                    builder: (context, state) {
                                      return InkWell(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        onTap: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            context.read<LoginCubit>().submit();
                                          }
                                        },
                                        child: SizedBox(
                                          height: 60.0,
                                          child: Center(
                                            child: state.status.isLoading
                                                ? Transform.scale(
                                                    scale: 0.6,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2.0,
                                                    ),
                                                  )
                                                : Text(
                                                    'Zaloguj',
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
                                      'Nie masz konta?',
                                      style:
                                          Theme.of(context).textTheme.subtitle2,
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context)
                                          .pushReplacementNamed('/signup'),
                                      child: const Text(
                                        'Zarejestruj się',
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

class _EmailTextFormField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextFormField(
          onChanged: (value) => context.read<LoginCubit>().emailChanged(value),
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

class _PasswordTextFormField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextFormField(
          onChanged: (value) =>
              context.read<LoginCubit>().passwordChanged(value),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Hasło',
          ),
          validator: (String? value) {
            if (value!.length == 0) {
              return 'Hasło jest wymagane.';
            }
          },
        );
      },
    );
  }
}
