import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/utils/utils.dart';
import 'package:safechat/common/common.dart';
import 'package:safechat/contacts/contacts.dart';

class AddContactPage extends StatelessWidget {
  const AddContactPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final Orientation orientation = MediaQuery.of(context).orientation;

    return BlocConsumer<ContactsCubit, ContactsState>(
      listenWhen: (prev, curr) => prev.formStatus != curr.formStatus,
      listener: (context, state) {
        if (state.formStatus.isSuccess) {
          Navigator.of(context).pop();
        }

        if (state.formStatus.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              getErrorSnackBar(
                context,
                errorText: state.formStatus.message!,
              ),
            );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(
              color: Colors.grey.shade800,
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  if (!keyboardOpen && orientation == Orientation.portrait)
                    Icon(
                      Icons.person_add_alt_1,
                      size: 150.0,
                      color: Colors.grey.shade100,
                    ),
                  Text(
                    'Dodaj nowy kontakt',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(
                    height: 15.0,
                  ),
                  Text(
                    'Podaj adres email kontaktu, a następnie wyślij zaproszenie.',
                    style: Theme.of(context).textTheme.titleSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20.0,
                  ),
                  Column(
                    children: [
                      const EmailInput(),
                      const SizedBox(
                        height: 15.0,
                      ),
                      PrimaryButton(
                        label: 'Wyślij zaproszenie',
                        onTap: () => context.read<ContactsCubit>().addContact(),
                        isLoading: state.formStatus.isLoading,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
