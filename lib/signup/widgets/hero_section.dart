import 'package:flutter/material.dart';

import 'package:safechat/common/common.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SizedBox(
          height: 25.0,
        ),
        Logo(
          size: 180,
        ),
        SizedBox(
          height: 40,
          child: VerticalDivider(
            thickness: 1,
          ),
        ),
        Divider(
          height: 0,
          thickness: 1,
        ),
      ],
    );
  }
}
