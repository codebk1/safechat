import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/utils/utils.dart';
import 'package:safechat/common/common.dart';
import 'package:safechat/user/user.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/chats/chats.dart';

class CreateChatPage extends StatelessWidget {
  const CreateChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatsCubit, ChatsState>(
      listenWhen: (prev, curr) => prev.formStatus != curr.formStatus,
      listener: (context, state) {
        if (state.formStatus.isSuccess) {
          Navigator.of(context).pushNamed(
            '/chat',
            arguments: state.chats.first,
          );

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              getSuccessSnackBar(
                context,
                successText: state.formStatus.message!,
              ),
            );
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
        return WillPopScope(
          onWillPop: () {
            context.read<ChatsCubit>().resetSelectedContacts();

            return Future.value(true);
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(
                color: Colors.grey.shade800,
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
                      if (state.selectedContacts.isEmpty)
                        const Text('Wybierz znajomych:'),
                      ...state.selectedContacts.map(
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
                                              'Brak kontaktów',
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
                                                value: state.selectedContacts
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
                                if (state.selectedContacts.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: PrimaryButton(
                                      label: 'Utwórz czat',
                                      onTap: () async {
                                        final chat = await context
                                            .read<ChatsCubit>()
                                            .createChat(
                                                ChatType.group,
                                                context
                                                    .read<UserCubit>()
                                                    .state
                                                    .user,
                                                state.selectedContacts);

                                        Navigator.of(context).popAndPushNamed(
                                          '/chat',
                                          arguments: chat,
                                        );
                                      },
                                      isLoading: state.formStatus.isLoading,
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
