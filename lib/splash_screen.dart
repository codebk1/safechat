import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/logo.svg',
            allowDrawingOutsideViewBox: true,
            width: 180,
          ),
          SizedBox(
            height: 35.0,
          ),
          CircularProgressIndicator(
            color: Colors.blue.shade800,
            strokeWidth: 2.0,
          ),
        ],
      ),
    );
  }
}
