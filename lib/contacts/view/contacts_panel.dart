import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/contacts/models/contact.dart';
import 'package:safechat/user/cubit/user_cubit.dart';
import 'package:safechat/user/models/user.dart';

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
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/contacts/add');
                    },
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
                                          final contactState =
                                              state.contacts[index];

                                          return BlocProvider(
                                            create: (context) => ContactCubit(
                                              contact: contactState.contact,
                                              currentState:
                                                  contactState.currentState,
                                            ),
                                            child: BlocBuilder<ContactCubit,
                                                ContactState>(
                                              builder: (context, state) {
                                                return ListTile(
                                                  onLongPress: () {
                                                    context
                                                        .read<ContactCubit>()
                                                        .emit(state.copyWith(
                                                            currentState:
                                                                CurrentState
                                                                    .DELETING));
                                                  },
                                                  leading: Stack(
                                                    children: [
                                                      CircleAvatar(
                                                        child: state.contact
                                                                    .avatar !=
                                                                null
                                                            ? ClipOval(
                                                                child: Image
                                                                    .file(state
                                                                        .contact
                                                                        .avatar!),
                                                              )
                                                            : Icon(
                                                                Icons.person,
                                                                color: Colors
                                                                    .grey
                                                                    .shade50,
                                                              ),
                                                        backgroundColor: Colors
                                                            .grey.shade300,
                                                      ),
                                                      if (state.currentState !=
                                                              CurrentState
                                                                  .NEW &&
                                                          state.currentState !=
                                                              CurrentState
                                                                  .PENDING)
                                                        Positioned(
                                                          right: 0,
                                                          bottom: 0,
                                                          child: Container(
                                                            height: 14,
                                                            width: 14,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: state.contact
                                                                          .status ==
                                                                      Status
                                                                          .ONLINE
                                                                  ? Colors.green
                                                                  : Colors.grey,
                                                              shape: BoxShape
                                                                  .circle,
                                                              border:
                                                                  Border.all(
                                                                width: 2,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  title: state.currentState ==
                                                          CurrentState.PENDING
                                                      ? Text(
                                                          '${state.contact.email}',
                                                        )
                                                      : Text(
                                                          '${state.contact.firstName} ${state.contact.lastName}',
                                                        ),
                                                  trailing: _ContactActions(),
                                                );
                                              },
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
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactCubit, ContactState>(builder: (context, state) {
      switch (state.currentState) {
        case CurrentState.NEW:
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  context.read<ContactCubit>().acceptInvitation();
                },
                icon: Icon(
                  Icons.check_circle,
                  color: Colors.green.shade800,
                ),
              ),
              IconButton(
                onPressed: () {
                  context.read<ContactsCubit>().cancelInvitation(
                        state.contact.id,
                      );
                },
                icon: Icon(
                  Icons.cancel,
                ),
              ),
            ],
          );

        case CurrentState.PENDING:
          return IconButton(
            onPressed: () {
              context.read<ContactsCubit>().cancelInvitation(
                    state.contact.id,
                  );
            },
            icon: Icon(Icons.cancel),
          );

        case CurrentState.ACCEPTED:
          return IconButton(
            onPressed: () {
              context.read<ContactCubit>().createChat();
            },
            icon: Icon(
              Icons.chat,
            ),
          );

        case CurrentState.REJECTED:
          return IconButton(
            onPressed: () {},
            icon: Icon(Icons.done),
          );

        case CurrentState.DELETING:
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
                onPressed: () {
                  context.read<ContactCubit>().emit(state.copyWith(
                        currentState: CurrentState.ACCEPTED,
                      ));
                },
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
