import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/chats/cubits/create_chat/create_chat_cubit.dart';
import 'package:safechat/contacts/contacts.dart';

class CreateChatPage extends StatelessWidget {
  const CreateChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateChatCubit, CreateChatState>(
      listener: (context, state) {
        if (state.status.isSuccess) {
          Navigator.of(context).pop();

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                duration: const Duration(seconds: 1),
                content: Row(
                  children: const <Widget>[
                    Icon(
                      Icons.check_circle,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text('Utworzono czat.'),
                  ],
                ),
              ),
            );
        }

        if (state.status.isFailure) {
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
                    Text(state.status.error),
                  ],
                ),
              ),
            );
        }
      },
      builder: (context, createChatState) {
        return Scaffold(
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
                    if (createChatState.selectedParticipants.isEmpty)
                      const Text('Wybierz znajomych:'),
                    ...createChatState.selectedParticipants.map(
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
                                      .read<CreateChatCubit>()
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
                builder: (context, state) {
                  final acceptedContacts = state.acceptedContacts;

                  return state.listStatus == ListStatus.loading
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
                                              value: createChatState
                                                  .selectedParticipants
                                                  .contains(
                                                state,
                                              ),
                                              onChanged: (selected) {
                                                context
                                                    .read<CreateChatCubit>()
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
                                                    child: Container(
                                                      height: 14,
                                                      width: 14,
                                                      decoration: BoxDecoration(
                                                        color: contact.status ==
                                                                Status.online
                                                            ? Colors.green
                                                            : Colors.grey,
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
                                              title: Text(
                                                '${contact.firstName} ${contact.lastName}',
                                              ),
                                            );
                                          }),
                                ),
                              ),
                              if (createChatState
                                  .selectedParticipants.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(5.0),
                                      onTap: () {
                                        context
                                            .read<CreateChatCubit>()
                                            .createChat();
                                      },
                                      child: SizedBox(
                                        height: 60.0,
                                        child: Center(
                                          child: state.status.isLoading
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
        );
      },
    );
  }
}
