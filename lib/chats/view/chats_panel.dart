import 'package:flutter/material.dart';
import 'package:safechat/chats/cubits/chat/cubit/chat_cubit.dart';
import 'package:safechat/chats/cubits/chats/chats_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/contacts/models/contact.dart';

import 'package:safechat/home/view/panels/side_panels.dart';
import 'package:safechat/user/user.dart';

class MainPanel extends StatelessWidget {
  const MainPanel({
    Key? key,
    required GlobalKey<SidePanelsState> sidePanelsKey,
  })  : _sidePanelsKey = sidePanelsKey,
        super(key: key);

  final GlobalKey<SidePanelsState> _sidePanelsKey;

  @override
  Widget build(BuildContext context) {
    context.read<ChatsCubit>().getChats();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 15.0,
              left: 15.0,
              right: 15.0,
              bottom: 10.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    onPressed: () {
                      _sidePanelsKey.currentState!
                          .open(direction: Direction.left);
                    },
                    icon: const Icon(Icons.menu)),
                const Text(
                  'Czaty',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                IconButton(
                    onPressed: () {
                      _sidePanelsKey.currentState!
                          .open(direction: Direction.right);
                    },
                    icon: const Icon(Icons.people)),
              ],
            ),
          ),
          Divider(
            height: 1,
          ),
          BlocBuilder<ChatsCubit, ChatsState>(
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
                      child: RefreshIndicator(
                        onRefresh: () => context.read<ChatsCubit>().getChats(),
                        child: state.chats.length == 0
                            ? Center(
                                child: Text(
                                  'Brak konwersacji',
                                  style: Theme.of(context).textTheme.subtitle2,
                                ),
                              )
                            : ListView.builder(
                                itemCount: state.chats.length,
                                itemBuilder: (context, index) {
                                  final chatState = state.chats[index];

                                  final chatCubit = ChatCubit(
                                    id: chatState.id,
                                    participants: chatState.participants,
                                  );

                                  final contactCubit = ContactCubit(
                                    contact: chatState.participants[0].contact,
                                    currentState:
                                        chatState.participants[0].currentState,
                                  );

                                  return MultiBlocProvider(
                                    providers: [
                                      BlocProvider.value(
                                        value: chatCubit,
                                      ),
                                      BlocProvider.value(value: contactCubit),
                                    ],
                                    child: BlocBuilder<ChatCubit, ChatState>(
                                      builder: (context, state) {
                                        return ListTile(
                                          onTap: () {
                                            Navigator.of(context).pushNamed(
                                              '/chat',
                                              arguments: chatCubit,
                                            );
                                          },
                                          leading: BlocBuilder<ContactCubit,
                                              ContactState>(
                                            builder: (context, state) {
                                              return Stack(
                                                children: [
                                                  CircleAvatar(
                                                    child: state.contact
                                                                .avatar !=
                                                            null
                                                        ? ClipOval(
                                                            child: Image.file(
                                                                state.contact
                                                                    .avatar!),
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
                                                        color: state.contact
                                                                    .status ==
                                                                Status.ONLINE
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
                                              );
                                            },
                                          ),
                                          title: Text(
                                            '${state.participants[0].contact.firstName} ${state.participants[0].contact.lastName}',
                                          ),
                                          subtitle: Text('Co tam słychać? :)'),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                    );
            },
          ),
        ],
      ),
    );
  }
}
