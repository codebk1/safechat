import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/chats/cubits/chats/chats_cubit.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/contacts/models/contact.dart';

class CreateChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool _keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final Orientation _orientation = MediaQuery.of(context).orientation;

    return BlocConsumer<ChatsCubit, ChatsState>(
      listener: (context, state) {
        // if (state.status.isSuccess) {
        //  Navigator.of(context).pop();

        // ScaffoldMessenger.of(context)
        //   ..hideCurrentSnackBar()
        //   ..showSnackBar(
        //     SnackBar(
        //       duration: Duration(seconds: 1),
        //       content: Row(
        //         children: <Widget>[
        //           Icon(
        //             Icons.check_circle,
        //             color: Colors.white,
        //           ),
        //           SizedBox(
        //             width: 10.0,
        //           ),
        //           Text('Wysłano zaproszenie.'),
        //         ],
        //       ),
        //     ),
        //   );
        // }

        // if (state.status.isFailure) {
        //   ScaffoldMessenger.of(context)
        //     ..hideCurrentSnackBar()
        //     ..showSnackBar(
        //       SnackBar(
        //         action: SnackBarAction(
        //           onPressed: () =>
        //               ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        //           label: 'Zamknij',
        //         ),
        //         content: Row(
        //           children: <Widget>[
        //             Icon(
        //               Icons.error,
        //               color: Colors.white,
        //             ),
        //             SizedBox(
        //               width: 10.0,
        //             ),
        //             Text(state.status.error),
        //           ],
        //         ),
        //       ),
        //     );
        // }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(
              color: Colors.grey.shade800, //change your color here
            ),
          ),
          body: Column(
            children: [
              Row(),
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
                              Expanded(
                                child: RefreshIndicator(
                                  onRefresh: () => context
                                      .read<ContactsCubit>()
                                      .getContacts(),
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
                                                  return CheckboxListTile(
                                                    value: false,
                                                    onChanged: (selected) {},
                                                    secondary: Stack(
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
                                                          backgroundColor:
                                                              Colors.grey
                                                                  .shade300,
                                                        ),
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
                                                    title: Text(
                                                      '${state.contact.firstName} ${state.contact.lastName}',
                                                    ),
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
        );
      },
    );
  }
}
