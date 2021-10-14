import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/utils/utils.dart';
import 'package:safechat/signup/signup.dart';

class ConfirmPasswordInput extends StatelessWidget {
  const ConfirmPasswordInput({
    Key? key,
  }) : super(key: key);

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
