import 'package:flutter/material.dart';

import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/home/view/panels/panels.dart';

class HomePage extends StatelessWidget {
  final GlobalKey<SidePanelsState> _sidePanelsKey =
      GlobalKey<SidePanelsState>();

  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SidePanels(
        key: _sidePanelsKey,
        leftPanel: const LeftPanel(),
        rightPanel: const ContactsPanel(),
        mainPanel: MainPanel(sidePanelsKey: _sidePanelsKey),
      ),
    );
  }
}
