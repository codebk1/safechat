import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/contacts/contacts.dart';

class ContactListTile extends StatelessWidget {
  const ContactListTile({
    Key? key,
    required this.contact,
  }) : super(key: key);

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onLongPress: () {
        context.read<ContactsCubit>().toggleActionsMenu(contact.id);
      },
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            child: contact.avatar != null
                ? ClipOval(
                    child: Image.file(
                      contact.avatar!,
                    ),
                  )
                : Icon(
                    Icons.person,
                    color: Colors.grey.shade50,
                  ),
          ),
          if (!contact.currentState.isInviting &&
              !contact.currentState.isPending)
            Positioned(
              right: 0,
              bottom: 0,
              child: StatusIndicator(
                isOnline: contact.isOnline,
                status: contact.status,
              ),
            ),
        ],
      ),
      title: contact.currentState.isPending
          ? Text(contact.email)
          : Text('${contact.firstName} ${contact.lastName}'),
      trailing: ContactActions(
        contact: contact,
      ),
    );
  }
}
