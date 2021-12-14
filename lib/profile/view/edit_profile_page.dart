import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/utils/utils.dart';
import 'package:safechat/common/common.dart';
import 'package:safechat/profile/profile.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({Key? key}) : super(key: key);

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
              'Edytuj dane konta',
              style: TextStyle(
                color: Colors.grey.shade800,
              ),
            ),
          ),
          body: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overScroll) {
              overScroll.disallowIndicator();
              return true;
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Column(
                      children: [
                        const EditFirstNameInput(),
                        const SizedBox(
                          height: 15.0,
                        ),
                        const EditLastNameInput(),
                        const SizedBox(
                          height: 15.0,
                        ),
                        PrimaryButton(
                          label: 'Zapisz',
                          onTap: context.read<ProfileCubit>().editProfileSubmit,
                          isLoading: state.formStatus.isLoading,
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
