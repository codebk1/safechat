import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/utils/utils.dart';
import 'package:safechat/chats/chats.dart';

class NameInput extends StatelessWidget {
  const NameInput({
    Key? key,
    required this.initialValue,
  }) : super(key: key);

  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatsCubit, ChatsState>(
      builder: (context, state) {
        return TextFormField(
          onChanged: (value) => context.read<ChatsCubit>().nameChanged(value),
          initialValue: initialValue,
          decoration: InputDecoration(
            labelText: 'Nazwa konwersacji',
            errorText: state.formStatus.isSubmiting ? state.name.error : null,
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (String? value) {
            return state.name.error;
          },
        );
      },
    );
  }
}
