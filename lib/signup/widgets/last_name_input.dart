import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/signup/signup.dart';
import 'package:safechat/utils/utils.dart';

class LastNameInput extends StatelessWidget {
  const LastNameInput({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupCubit, SignupState>(
      builder: (context, state) {
        return TextFormField(
          onChanged: (value) =>
              context.read<SignupCubit>().lastNameChanged(value),
          decoration: InputDecoration(
            labelText: 'Nazwisko',
            errorText:
                state.formStatus.isSubmiting ? state.lastName.error : null,
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (String? value) {
            return state.lastName.error;
          },
        );
      },
    );
  }
}
