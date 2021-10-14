import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/utils/utils.dart';
import 'package:safechat/signup/signup.dart';

class FirstNameInput extends StatelessWidget {
  const FirstNameInput({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupCubit, SignupState>(
      builder: (context, state) {
        return TextFormField(
          onChanged: (value) =>
              context.read<SignupCubit>().firstNameChanged(value),
          decoration: InputDecoration(
            labelText: 'Imię',
            errorText:
                state.formStatus.isSubmiting ? state.firstName.error : null,
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (String? value) {
            return state.firstName.error;
          },
        );
      },
    );
  }
}
