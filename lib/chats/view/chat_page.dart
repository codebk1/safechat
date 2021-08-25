import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/chats/cubits/chat/cubit/chat_cubit.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/contacts/models/contact.dart';
import 'package:safechat/user/user.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({Key? key, required this.chatCubit}) : super(key: key);

  final ChatCubit chatCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: chatCubit,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.info),
            ),
          ],
          backgroundColor: Colors.white,
          titleSpacing: 0,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.grey.shade800, //change your color here
          ),
          title: BlocProvider(
            create: (context) => ContactCubit(
              contact: chatCubit.state.participants[0].contact,
              currentState: chatCubit.state.participants[0].currentState,
            ),
            child: BlocBuilder<ContactCubit, ContactState>(
              builder: (context, state) {
                return Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          child: Icon(
                            Icons.person,
                            color: Colors.grey.shade50,
                          ),
                          backgroundColor: Colors.grey.shade300,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            height: 14,
                            width: 14,
                            decoration: BoxDecoration(
                              color: state.contact.status == Status.ONLINE
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
                    SizedBox(
                      width: 15.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${state.contact.firstName} ${state.contact.lastName}',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        Text(
                          'Aktywny 5min temu',
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              FocusManager.instance.primaryFocus!.unfocus();
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: 1 == 0
                      ? Center(
                          child: Text(
                            'Brak wiadomości',
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                        )
                      : BlocBuilder<ChatCubit, ChatState>(
                          builder: (context, state) {
                            return ListView.builder(
                                itemCount: state.messages.length,
                                itemBuilder: (
                                  BuildContext context,
                                  int index,
                                ) {
                                  return MessageBubble(
                                    isSender: state.messages[index].sender ==
                                        context.read<UserCubit>().state.user.id,
                                    message: state.messages[index].data,
                                  );
                                });
                          },
                        ),
                ),
              ),
              ChatInputField()
            ],
          ),
        ),
      ),
    );
  }
}

class ChatInputField extends StatelessWidget {
  const ChatInputField({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 10.0,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.photo_library,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(width: 15.0),
          Expanded(
            child: TextFormField(
              onChanged: (value) =>
                  context.read<ChatCubit>().messageChanged(value),
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: "Napisz wiadomość...",
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ChatCubit>().sendMessage();
            },
            child: Icon(Icons.send_outlined, color: Colors.white),
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.all(10),
              primary: Colors.blue.shade800,
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    Key? key,
    required this.message,
    required this.isSender,
  }) : super(key: key);

  final String message;
  final bool isSender;

  @override
  Widget build(BuildContext context) {
    // Widget messageContaint(ChatMessage message) {
    //   switch (message.messageType) {
    //     case ChatMessageType.text:
    //       return TextMessage(message: message);
    //     case ChatMessageType.audio:
    //       return AudioMessage(message: message);
    //     case ChatMessageType.video:
    //       return VideoMessage();
    //     default:
    //       return SizedBox();
    //   }
    // }

    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Row(
        mainAxisAlignment:
            isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSender) ...[
            CircleAvatar(
              radius: 14.0,
              child: Icon(
                Icons.person,
                color: Colors.grey.shade50,
              ),
              backgroundColor: Colors.grey.shade300,
            ),
            SizedBox(width: 10.0),
          ],
          TextMessage(message: message, isSender: isSender),
          if (isSender) ...[
            SizedBox(width: 2.0),
            Icon(
              Icons.check_circle,
              size: 15,
              color: Colors.blue.shade800,
            )
          ],
        ],
      ),
    );
  }
}

class TextMessage extends StatelessWidget {
  const TextMessage({
    Key? key,
    this.message,
    required this.isSender,
  }) : super(key: key);

  final String? message;
  final bool isSender;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade800.withOpacity(isSender ? 1 : 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        message!,
        style: TextStyle(
          color: isSender ? Colors.white : Colors.grey.shade800,
        ),
      ),
    );
  }
}
