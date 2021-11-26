import 'package:flutter/material.dart';

import 'package:collection/collection.dart';

import 'package:safechat/contacts/contacts.dart';

class ContactsList extends StatelessWidget {
  const ContactsList({
    Key? key,
    required this.contacts,
  }) : super(key: key);

  final List<Contact> contacts;

  @override
  Widget build(BuildContext context) {
    var groupedContacts = groupBy(contacts, (Contact c) {
      switch (c.currentState) {
        case CurrentState.inviting:
          return 'nowe';
        case CurrentState.pending:
          return 'oczekujące';
        case CurrentState.accepted:
          return c.isOnline ? 'online' : 'offline';
        default:
      }
    });

    List contactsListTiles = [];
    const sortedHeaders = ['nowe', 'oczekujące', 'online', 'offline'];

    groupedContacts.entries
        .sorted((a, b) =>
            sortedHeaders.indexOf(a.key!) - sortedHeaders.indexOf(b.key!))
        .forEach((item) {
      contactsListTiles.add(ContactsListGroupHeader(
        text: '${item.key!} - ${item.value.length}',
      ));

      for (var contact in item.value) {
        contactsListTiles.add(ContactListTile(
          contact: contact,
        ));
      }
    });

    return ListView.builder(
      itemCount: contactsListTiles.length,
      itemBuilder: (
        BuildContext context,
        int index,
      ) {
        return contactsListTiles[index];
      },
    );
  }
}
