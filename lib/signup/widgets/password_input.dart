import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/utils/utils.dart';
import 'package:safechat/signup/cubit/signup_cubit.dart';

class PasswordInput extends StatelessWidget {
  const PasswordInput({
    Key? key,
  }) : super(key: key);

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
