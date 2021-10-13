import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/login/login.dart';
import 'package:safechat/utils/utils.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final _orientation = MediaQuery.of(context).orientation;
    final _showHero = !_keyboardOpen && _orientation == Orientation.portrait;

    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state.formStatus.isSuccess) {
          Navigator.of(context).pushReplacementNamed('/home');
        }

        if (state.formStatus.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                action: SnackBarAction(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
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
                    Text(
                      state.formStatus.error!,
                    ),
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
                        if (_showHero) const HeroSection(),
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
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Zaloguj się.',
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Twoje wiadomości są zawsze bezpieczne.',
                                  style: Theme.of(context).textTheme.subtitle2,
                                ),
                              ),
                              const SizedBox(
                                height: 25,
                              ),
                              const EmailTextFormField(),
                              const SizedBox(
                                height: 15,
                              ),
                              const PasswordTextFormField(),
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
                            children: const [
                              PrimaryButton(),
                              SignupLink(),
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
