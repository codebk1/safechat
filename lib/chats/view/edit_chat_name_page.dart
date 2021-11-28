import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

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
      listener: (context, state) {
        if (state.formStatus.isSuccess) {
          Navigator.of(context).pop();
        }

        if (state.formStatus.isFailure) {
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
                    Text(state.formStatus.error!),
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
              'Edytuj nazwe czatu',
              style: TextStyle(
                color: Colors.grey.shade800,
              ),
            ),
          ),
          body: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overScroll) {
              overScroll.disallowGlow();
              return true;
            },
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
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
                            Ink(
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: BlocBuilder<ChatsCubit, ChatsState>(
                                builder: (context, state) {
                                  return InkWell(
                                    borderRadius: BorderRadius.circular(5.0),
                                    onTap: () {
                                      context
                                          .read<ChatsCubit>()
                                          .editChatNameSubmit(chatId);
                                    },
                                    child: SizedBox(
                                      height: 60.0,
                                      child: Center(
                                        child: state.formStatus.isLoading
                                            ? const CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.0,
                                              )
                                            : Text(
                                                'Zapisz',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline6!
                                                    .copyWith(
                                                      color: Colors.white,
                                                    ),
                                              ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
