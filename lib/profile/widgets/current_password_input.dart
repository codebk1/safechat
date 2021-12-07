import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/utils/utils.dart';
import 'package:safechat/profile/profile.dart';

class CurrentPasswordInput extends StatelessWidget {
  const CurrentPasswordInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return TextFormField(
          onChanged: (value) =>
              context.read<ProfileCubit>().currentPasswordChanged(value),
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Aktualne hasło',
            errorText: state.formStatus.isSubmiting
                ? state.currentPassword.error
                : null,
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (String? value) {
            return state.currentPassword.error;
          },
        );
      },
    );
  }
}
