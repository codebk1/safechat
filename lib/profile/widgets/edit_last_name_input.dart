import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/utils/utils.dart';
import 'package:safechat/profile/profile.dart';

class EditLastNameInput extends StatelessWidget {
  const EditLastNameInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return TextFormField(
          initialValue: state.lastName.value,
          onChanged: (value) =>
              context.read<ProfileCubit>().lastNameChanged(value),
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
