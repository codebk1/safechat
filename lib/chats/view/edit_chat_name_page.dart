import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/chats/cubits/chats/chats_cubit.dart';

class EditChatNamePage extends StatefulWidget {
  const EditChatNamePage({
    Key? key,
    required this.chatId,
  }) : super(key: key);

  final String chatId;

  @override
  _EditChatNamePageState createState() => _EditChatNamePageState();
}

class _EditChatNamePageState extends State<EditChatNamePage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatsCubit, ChatsState>(
      listener: (context, state) {
        if (state.status.isSuccess) {
          Navigator.of(context).pop();
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
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _NameTextFormField(
                                initialValue: state.chats
                                    .firstWhere((c) => c.id == widget.chatId)
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
                                        if (_formKey.currentState!.validate()) {
                                          context
                                              .read<ChatsCubit>()
                                              .editChatNameSubmit(
                                                widget.chatId,
                                              );
                                        }
                                      },
                                      child: SizedBox(
                                        height: 60.0,
                                        child: Center(
                                          child: state.status.isLoading
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

class _NameTextFormField extends StatelessWidget {
  const _NameTextFormField({
    required this.initialValue,
  });

  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatsCubit, ChatsState>(
      builder: (context, state) {
        return TextFormField(
          initialValue: initialValue,
          onChanged: (value) => context.read<ChatsCubit>().nameChanged(value),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: const InputDecoration(
            labelText: 'Nazwa',
          ),
          validator: (String? value) {
            if (value!.isEmpty) {
              return 'Nazwa jest wymagane.';
            }
          },
        );
      },
    );
  }
}
