import 'package:flutter/material.dart';

import 'package:safechat/home/view/panels/panels.dart';

class HomePage extends StatelessWidget {
  final GlobalKey<SidePanelsState> _sidePanelsKey =
      GlobalKey<SidePanelsState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SidePanels(
        key: _sidePanelsKey,
        leftPanel: LeftPanel(),
        rightPanel: RightPanel(),
        mainPanel: MainPanel(sidePanelsKey: _sidePanelsKey),
      ),
    );
  }
}
