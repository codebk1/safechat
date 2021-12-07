import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/utils/utils.dart';
import 'package:safechat/common/common.dart';
import 'package:safechat/profile/profile.dart';

class EditPasswordPage extends StatelessWidget {
  const EditPasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listenWhen: (prev, curr) => prev.formStatus != curr.formStatus,
      listener: (context, state) {
        if (state.formStatus.isSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(getSuccessSnackBar(
              context,
              successText: state.formStatus.message!,
            ));

          Navigator.of(context).pop();
        }

        if (state.formStatus.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(getErrorSnackBar(
              context,
              errorText: state.formStatus.message!,
            ));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(
              color: Colors.grey.shade800,
            ),
            title: Text(
              'Zmień hasło',
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
                            const CurrentPasswordInput(),
                            const SizedBox(
                              height: 15.0,
                            ),
                            const Divider(),
                            const SizedBox(
                              height: 15.0,
                            ),
                            Text(
                              'Zapamietaj nowe hasło, ponieważ bez niego Twoje dane zostaną bezpowrotnie utracone.',
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            const NewPasswordInput(),
                            const SizedBox(
                              height: 15.0,
                            ),
                            const ConfirmNewPasswordInput(),
                            const SizedBox(
                              height: 15.0,
                            ),
                            PrimaryButton(
                              label: 'Zapisz',
                              onTap: context
                                  .read<ProfileCubit>()
                                  .editPasswordSubmit,
                              isLoading: state.formStatus.isLoading,
                            )
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
