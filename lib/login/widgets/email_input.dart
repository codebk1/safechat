import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/utils/utils.dart';
import 'package:safechat/login/login.dart';

class EmailInput extends StatelessWidget {
  const EmailInput({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        return TextFormField(
          onChanged: (value) => context.read<LoginCubit>().emailChanged(value),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            errorText: state.formStatus.isSubmiting ? state.email.error : null,
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (String? value) {
            return state.email.error;
          },
        );
      },
    );
  }
}
