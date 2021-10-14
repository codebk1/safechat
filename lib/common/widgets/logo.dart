import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

class Logo extends StatelessWidget {
  const Logo({
    Key? key,
    required this.size,
  }) : super(key: key);

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/logo.svg',
      allowDrawingOutsideViewBox: true,
      width: size,
    );
  }
}
