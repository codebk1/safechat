import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/utils/utils.dart';
import 'package:safechat/profile/profile.dart';

class NewPasswordInput extends StatelessWidget {
  const NewPasswordInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return TextFormField(
          onChanged: (value) =>
              context.read<ProfileCubit>().newPasswordChanged(value),
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Nowe hasło',
            errorText:
                state.formStatus.isSubmiting ? state.newPassword.error : null,
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (String? value) {
            return state.newPassword.error;
          },
        );
      },
    );
  }
}
