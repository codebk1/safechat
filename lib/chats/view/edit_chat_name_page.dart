import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/common/common.dart';

import 'package:safechat/utils/utils.dart';
import 'package:safechat/chats/chats.dart';

class EditChatNamePage extends StatelessWidget {
  const EditChatNamePage({
    Key? key,
    required this.chatId,
  }) : super(key: key);

  final String chatId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatsCubit, ChatsState>(
      listenWhen: (prev, curr) => prev.formStatus != curr.formStatus,
      listener: (context, state) {
        if (state.formStatus.isSuccess) {
          Navigator.of(context).pop();
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
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(
              color: Colors.grey.shade800, //change your color here
            ),
            title: Text(
              'Edytuj nazwe czatu',
              style: TextStyle(
                color: Colors.grey.shade800,
              ),
            ),
          ),
          body: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overScroll) {
              overScroll.disallowIndicator();
              return true;
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Column(
                      children: [
                        NameInput(
                          initialValue: state.chats
                              .firstWhere((c) => c.id == chatId)
                              .name,
                        ),
                        const SizedBox(
                          height: 15.0,
                        ),
                        PrimaryButton(
                          label: 'Zapisz',
                          onTap: () {
                            context
                                .read<ChatsCubit>()
                                .editChatNameSubmit(chatId);
                          },
                          isLoading: state.formStatus.isLoading,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
