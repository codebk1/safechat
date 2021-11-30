import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/chats/cubits/chats/chats_cubit.dart';

import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/home/view/panels/panels.dart';
import 'package:safechat/router.dart';
import 'package:safechat/user/cubit/user_cubit.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final GlobalKey<SidePanelsState> _sidePanelsKey =
      GlobalKey<SidePanelsState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatsCubit, ChatsState>(
      listener: (context, state) {
        if (state.nextChat != null) {
          final currentUser = context.read<UserCubit>().state.user;

          context.read<ChatsCubit>().emit(state.copyWith(nextChat: null));

          Navigator.of(context).pushNamed(
            '/chat',
            arguments: ChatPageArguments(
              state.nextChat!,
              List.of(state.nextChat!.participants)
                ..removeWhere(
                  (p) => p.id == currentUser.id,
                ),
            ),
          );
        }
      },
      child: AnnotatedRegion(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.grey.shade300,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: SafeArea(
          child: SidePanels(
            key: _sidePanelsKey,
            leftPanel: const LeftPanel(),
            rightPanel: const ContactsPanel(),
            mainPanel: MainPanel(sidePanelsKey: _sidePanelsKey),
          ),
        ),
      ),
    );
  }
}
