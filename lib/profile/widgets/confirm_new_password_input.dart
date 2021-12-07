import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/utils/utils.dart';
import 'package:safechat/profile/profile.dart';

class ConfirmNewPasswordInput extends StatelessWidget {
  const ConfirmNewPasswordInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return TextFormField(
          onChanged: (value) =>
              context.read<ProfileCubit>().confirmNewPasswordChanged(value),
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Potwierdź nowe hasło',
            errorText: state.formStatus.isSubmiting
                ? state.confirmNewPassword.error
                : null,
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (String? value) {
            return state.confirmNewPassword.error;
          },
        );
      },
    );
  }
}
