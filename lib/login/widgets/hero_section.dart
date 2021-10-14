import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:safechat/common/common.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 25.0,
        ),
        const Logo(
          size: 180.0,
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            const SizedBox(
              height: 125,
              child: VerticalDivider(
                thickness: 1,
              ),
            ),
            SvgPicture.asset(
              'assets/messages_animation.svg',
              allowDrawingOutsideViewBox: true,
              width: 200,
            ),
          ],
        ),
      ],
    );
  }
}
