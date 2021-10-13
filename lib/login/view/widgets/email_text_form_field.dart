import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/login/cubit/login_cubit.dart';
import 'package:safechat/utils/utils.dart';

class EmailTextFormField extends StatelessWidget {
  const EmailTextFormField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) {
        return TextFormField(
          onChanged: (value) => context.read<LoginCubit>().emailChanged(value),
          decoration: InputDecoration(
            labelText: 'Email',
            errorText: state.formStatus.isInvalid ? state.email.error : null,
          ),
        );
      },
    );
  }
}
