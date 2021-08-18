import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/contacts/contacts.dart';

class ContactsPanel extends StatelessWidget {
  const ContactsPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<ContactsCubit>().getContacts();

    return Container(
      margin: EdgeInsets.only(left: 15.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
        ),
        color: Colors.white,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 15.0,
                left: 15.0,
                right: 15.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Znajomi',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/contacts/add'),
                    icon: Icon(Icons.person_add),
                  ),
                ],
              ),
            ),
            Divider(),
            BlocBuilder<ContactsCubit, ContactsState>(
              builder: (context, state) {
                return state.listStatus == ListStatus.loading
                    ? Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: Colors.grey.shade300,
                        ),
                      )
                    : Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Padding(
                            //   padding:
                            //       const EdgeInsets.symmetric(horizontal: 15.0),
                            //   child: Text(
                            //     'online - 2',
                            //     style: Theme.of(context).textTheme.subtitle2,
                            //   ),
                            // ),
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: () =>
                                    context.read<ContactsCubit>().getContacts(),
                                child: state.contacts.length == 0
                                    ? Center(
                                        child: Text(
                                          'Brak znajomych',
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2,
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: state.contacts.length,
                                        itemBuilder: (
                                          BuildContext context,
                                          int index,
                                        ) {
                                          final contact = state.contacts[index];

                                          return ListTile(
                                            onLongPress: () {
                                              var newContacts =
                                                  state.contacts.toList();

                                              newContacts[index] = state
                                                  .contacts[index]
                                                  .copyWith(
                                                      state: ContactState
                                                          .DELETING);

                                              context
                                                  .read<ContactsCubit>()
                                                  .emit(state.copyWith(
                                                      contacts: newContacts));
                                            },
                                            leading: Stack(
                                              children: [
                                                CircleAvatar(
                                                  child: contact.avatar != null
                                                      ? ClipOval(
                                                          child: Image.file(
                                                              contact.avatar!),
                                                        )
                                                      : Icon(
                                                          Icons.person,
                                                          color: Colors
                                                              .grey.shade50,
                                                        ),
                                                  backgroundColor:
                                                      Colors.grey.shade300,
                                                ),
                                                if (contact.state !=
                                                        ContactState.NEW &&
                                                    contact.state !=
                                                        ContactState.PENDING)
                                                  Positioned(
                                                    right: 0,
                                                    bottom: 0,
                                                    child: Container(
                                                      height: 14,
                                                      width: 14,
                                                      decoration: BoxDecoration(
                                                        color: Colors.orange,
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          width: 2,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            title: contact.state ==
                                                    ContactState.PENDING
                                                ? Text(
                                                    '${contact.email}',
                                                  )
                                                : Text(
                                                    '${contact.firstName} ${contact.lastName}',
                                                  ),
                                            trailing: _ContactActions(
                                              contact: contact,
                                              state: contact.state,
                                            ),
                                          );
                                        }),
                              ),
                            ),
                          ],
                        ),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactActions extends StatelessWidget {
  const _ContactActions({
    Key? key,
    required this.contact,
    required this.state,
  }) : super(key: key);

  final Contact contact;
  final ContactState state;

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (_) {
      switch (state) {
        case ContactState.NEW:
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  context.read<ContactsCubit>().acceptInvitation(contact);
                },
                icon: Icon(
                  Icons.check_circle,
                  color: Colors.green.shade800,
                ),
              ),
              IconButton(
                onPressed: () {
                  context.read<ContactsCubit>().cancelInvitation(contact.id);
                },
                icon: Icon(
                  Icons.cancel,
                ),
              ),
            ],
          );

        case ContactState.PENDING:
          return IconButton(
            onPressed: () {
              context.read<ContactsCubit>().cancelInvitation(contact.id);
            },
            icon: Icon(Icons.cancel),
          );

        case ContactState.ACCEPTED:
          return IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.chat,
            ),
          );

        case ContactState.REJECTED:
          return IconButton(
            onPressed: () {},
            icon: Icon(Icons.done),
          );

        case ContactState.DELETING:
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.delete,
                  color: Colors.red.shade800,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.cancel,
                ),
              ),
            ],
          );
      }
    });
  }
}
