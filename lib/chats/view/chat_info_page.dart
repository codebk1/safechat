import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/contacts/contacts.dart';

class ChatInfoPage extends StatelessWidget {
  const ChatInfoPage({Key? key, required this.chatId}) : super(key: key);

  final String chatId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.grey.shade800, //change your color here
        ),
        // title: Text(
        //   'Informacje',
        //   style: TextStyle(
        //     color: Colors.grey.shade800,
        //   ),
        // ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed(
                '/chat/edit/name',
                arguments: chatId,
              );
            },
            leading: const Icon(
              Icons.edit,
            ),
            title: const Text(
              'Nazwa',
            ),
          ),
          ListTile(
            onTap: () {},
            leading: const Icon(Icons.add_photo_alternate),
            title: const Text(
              'Avatar',
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              'Członkowie:',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          BlocBuilder<ContactsCubit, ContactsState>(
            builder: (context, state) {
              return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView.builder(
                          itemCount: state.contacts.length,
                          itemBuilder: (
                            BuildContext context,
                            int index,
                          ) {
                            var contact = state.contacts[index];
                            return ListTile(
                              leading: Stack(
                                children: [
                                  CircleAvatar(
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
                                    backgroundColor: Colors.grey.shade300,
                                  ),
                                  if (contact.currentState !=
                                          CurrentState.inviting &&
                                      contact.currentState !=
                                          CurrentState.pending)
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        height: 14,
                                        width: 14,
                                        decoration: BoxDecoration(
                                          color: contact.status == Status.online
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
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
