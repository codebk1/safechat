import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/utils/utils.dart';
import 'package:safechat/common/common.dart';
import 'package:safechat/signup/signup.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final orientation = MediaQuery.of(context).orientation;
    final showHero = !keyboardOpen && orientation == Orientation.portrait;

    return BlocConsumer<SignupCubit, SignupState>(
      listenWhen: (prev, curr) => prev.formStatus != curr.formStatus,
      listener: (context, state) {
        if (state.formStatus.isSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              getSuccessSnackBar(
                context,
                successText: 'Pomyślnie zarejestrowano.',
              ),
            );

          Navigator.of(context).pushReplacementNamed('/login');
        }

        if (state.formStatus.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              getErrorSnackBar(
                context,
                errorText: state.formStatus.message!,
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
                overScroll.disallowIndicator();
                return true;
              },
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showHero) const HeroSection(),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 30.0,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Zarejestruj się.',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Utwórz konto i ciesz się bezpieczną komunikacją.',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                              const SizedBox(height: 25),
                              const Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: FirstNameInput(),
                                  ),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  Flexible(
                                    child: LastNameInput(),
                                  ),
                                ],
                              ),
                              ...const [
                                SizedBox(
                                  height: 15,
                                ),
                                EmailInput(),
                                SizedBox(
                                  height: 15,
                                ),
                                PasswordInput(),
                                SizedBox(
                                  height: 15,
                                ),
                                ConfirmPasswordInput(),
                              ]
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
                              PrimaryButton(
                                label: 'Zarejestruj',
                                onTap: context.read<SignupCubit>().submit,
                                isLoading: state.formStatus.isLoading,
                              ),
                              const LoginLink(),
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
