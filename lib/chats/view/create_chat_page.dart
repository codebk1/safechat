import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/chats/cubits/chats/chats_cubit.dart';
import 'package:safechat/chats/models/chat.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/contacts/view/widgets/status_indicator.dart';
import 'package:safechat/user/user.dart';
import 'package:safechat/utils/utils.dart';

class CreateChatPage extends StatelessWidget {
  const CreateChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatsCubit, ChatsState>(
      listener: (context, state) {
        if (state.newChat.status.isSuccess) {
          // context.read<ChatsCubit>().emit(state.copyWith(
          //       newChat: state.newChat.copyWith(
          //         status: const FormStatus.init(),
          //       ),
          //     ));

          Navigator.of(context).pop();

          // ScaffoldMessenger.of(context)
          //   ..hideCurrentSnackBar()
          //   ..showSnackBar(
          //     SnackBar(
          //       duration: const Duration(seconds: 1),
          //       content: Row(
          //         children: const <Widget>[
          //           Icon(
          //             Icons.check_circle,
          //             color: Colors.white,
          //           ),
          //           SizedBox(
          //             width: 10.0,
          //           ),
          //           Text('Utworzono czat.'),
          //         ],
          //       ),
          //     ),
          //   );
        }

        if (state.newChat.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                action: SnackBarAction(
                  onPressed: () =>
                      ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                  label: 'Zamknij',
                ),
                content: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.error,
                      color: Colors.white,
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Text(state.newChat.status.error),
                  ],
                ),
              ),
            );
        }
      },
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () {
            print('POPOPOPO');
            context.read<ChatsCubit>().emit(state.copyWith(
                  newChat: state.newChat.copyWith(
                    selectedParticipants: [],
                    status: const FormStatus.init(),
                  ),
                ));

            return Future.value(true);
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(
                color: Colors.grey.shade800, //change your color here
              ),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: const BoxConstraints(minHeight: 40),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 5.0,
                  ),
                  child: Wrap(
                    runSpacing: 5.0,
                    spacing: 5.0,
                    children: [
                      if (state.newChat.selectedParticipants.isEmpty)
                        const Text('Wybierz znajomych:'),
                      ...state.newChat.selectedParticipants.map(
                        (p) => UnconstrainedBox(
                          child: Container(
                            padding: const EdgeInsets.only(
                              left: 10.0,
                              right: 5.0,
                              top: 5.0,
                              bottom: 5.0,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(15.0),
                              ),
                              color: Colors.blue.shade800,
                            ),
                            child: Flex(
                              direction: Axis.horizontal,
                              children: [
                                Text(
                                  p.firstName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 5.0),
                                InkWell(
                                  onTap: () {
                                    context
                                        .read<ChatsCubit>()
                                        .toggleParticipant(p);
                                  },
                                  child: const Icon(
                                    Icons.clear,
                                    size: 20.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                BlocBuilder<ContactsCubit, ContactsState>(
                  builder: (context, contactsState) {
                    final acceptedContacts = contactsState.acceptedContacts;

                    return contactsState.listStatus == ListStatus.loading
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                color: Colors.grey.shade300,
                              ),
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
                                    child: acceptedContacts.isEmpty
                                        ? Center(
                                            child: Text(
                                              'Brak znajomych',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle2,
                                            ),
                                          )
                                        : ListView.builder(
                                            itemCount: acceptedContacts.length,
                                            itemBuilder: (
                                              BuildContext context,
                                              int index,
                                            ) {
                                              final contact =
                                                  acceptedContacts[index];

                                              return CheckboxListTile(
                                                value: state.newChat
                                                    .selectedParticipants
                                                    .contains(contact),
                                                onChanged: (_) {
                                                  context
                                                      .read<ChatsCubit>()
                                                      .toggleParticipant(
                                                        contact,
                                                      );
                                                },
                                                secondary: Stack(
                                                  children: [
                                                    CircleAvatar(
                                                      child: contact.avatar !=
                                                              null
                                                          ? ClipOval(
                                                              child: Image.file(
                                                                contact.avatar!,
                                                              ),
                                                            )
                                                          : Icon(
                                                              Icons.person,
                                                              color: Colors
                                                                  .grey.shade50,
                                                            ),
                                                      backgroundColor:
                                                          Colors.grey.shade300,
                                                    ),
                                                    Positioned(
                                                      right: 0,
                                                      bottom: 0,
                                                      child: StatusIndicator(
                                                        isOnline:
                                                            contact.isOnline,
                                                        status: contact.status,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                title: Text(
                                                  '${contact.firstName} ${contact.lastName}',
                                                ),
                                              );
                                            }),
                                  ),
                                ),
                                if (state
                                    .newChat.selectedParticipants.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: InkWell(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        onTap: () {
                                          context.read<ChatsCubit>().createChat(
                                                ChatType.group,
                                                context
                                                    .read<UserCubit>()
                                                    .state
                                                    .user,
                                                state.newChat
                                                    .selectedParticipants,
                                              );
                                        },
                                        child: SizedBox(
                                          height: 60.0,
                                          child: Center(
                                            child: state
                                                    .newChat.status.isLoading
                                                ? Transform.scale(
                                                    scale: 0.6,
                                                    child:
                                                        const CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2.0,
                                                    ),
                                                  )
                                                : Text(
                                                    'Utwórz czat',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline6!
                                                        .copyWith(
                                                          color: Colors.white,
                                                        ),
                                                  ),
                                          ),
                                        ),
                                      ),
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
      },
    );
  }
}
