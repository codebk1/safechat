import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/utils/utils.dart';
import 'package:safechat/profile/profile.dart';

class EditFirstNameInput extends StatelessWidget {
  const EditFirstNameInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return TextFormField(
          initialValue: state.firstName.value,
          onChanged: (value) =>
              context.read<ProfileCubit>().firstNameChanged(value),
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
