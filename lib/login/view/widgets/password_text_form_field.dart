import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/login/login.dart';
import 'package:safechat/utils/form_helper.dart';

class PasswordTextFormField extends StatelessWidget {
  const PasswordTextFormField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        return TextFormField(
          onChanged: (value) =>
              context.read<LoginCubit>().passwordChanged(value),
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Hasło',
            errorText: state.formStatus.isInvalid ? state.password.error : null,
          ),
        );
      },
    );
  }
}
