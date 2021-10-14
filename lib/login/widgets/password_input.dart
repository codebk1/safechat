import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/utils/utils.dart';
import 'package:safechat/login/login.dart';

class PasswordInput extends StatelessWidget {
  const PasswordInput({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        return TextFormField(
          onChanged: (value) {
            context.read<LoginCubit>().passwordChanged(value);
          },
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
