import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/router.dart';
import 'package:safechat/home/view/panels/panels.dart';
import 'package:safechat/user/user.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/chats/chats.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final GlobalKey<SidePanelsState> _sidePanelsKey =
      GlobalKey<SidePanelsState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatsCubit, ChatsState>(
      listener: (context, state) {
        if (state.nextChat != null) {
          context.read<ChatsCubit>().emit(state.copyWith(nextChat: null));

          Navigator.of(context).pushNamed(
            '/chat',
            arguments: state.nextChat!,
          );
        }
      },
      child: SafeArea(
        child: SidePanels(
          key: _sidePanelsKey,
          leftPanel: const LeftPanel(),
          rightPanel: const ContactsPanel(),
          mainPanel: MainPanel(sidePanelsKey: _sidePanelsKey),
        ),
      ),
    );
  }
}
