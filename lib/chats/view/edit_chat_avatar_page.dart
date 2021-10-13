import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/chats/cubits/chats/chats_cubit.dart';
import 'package:safechat/utils/form_helper.dart';

class EditChatAvatarPage extends StatelessWidget {
  const EditChatAvatarPage({
    Key? key,
    required this.chatId,
  }) : super(key: key);

  final String chatId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatsCubit, ChatsState>(
      listener: (context, state) {
        if (state.form.isSuccess) {
          Navigator.of(context).pop();
        }

        if (state.form.isFailure) {
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
                    Text(state.form.error!),
                  ],
                ),
              ),
            );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(
              color: Colors.grey.shade800, //change your color here
            ),
            title: Text(
              'Edytuj avatar czatu',
              style: TextStyle(
                color: Colors.grey.shade800,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 35.0,
              horizontal: 15.0,
            ),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => context.read<ChatsCubit>().setAvatar(chatId),
                    child: Stack(
                      children: [
                        BlocBuilder<ChatsCubit, ChatsState>(
                          builder: (context, state) {
                            final chat = state.chats.firstWhere(
                              (chat) => chat.id == chatId,
                            );

                            return CircleAvatar(
                              radius: 55.0,
                              backgroundColor: Colors.grey.shade200,
                              child: state.loadingAvatar
                                  ? CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.grey.shade900,
                                    )
                                  : chat.avatar != null
                                      ? ClipOval(
                                          child: Image.file(
                                            chat.avatar!,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.person,
                                          size: 45.0,
                                          color: Colors.white,
                                        ),
                            );
                          },
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 35.0,
                            height: 35.0,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade800,
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 2,
                                color: Colors.white,
                              ),
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        context.read<ChatsCubit>().removeAvatar(chatId),
                    child: Text(
                      'Usuń avatar',
                      style: TextStyle(
                        color: Colors.grey.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
