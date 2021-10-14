import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/common/common.dart';
import 'package:safechat/user/user.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserCubit, UserState>(
      listener: (context, state) {
        if (state.authState == AuthState.authenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            (route) => false,
          );
        }

        if (state.authState == AuthState.unauthenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      },
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Logo(
              size: 180,
            ),
            const SizedBox(
              height: 35.0,
            ),
            CircularProgressIndicator(
              color: Colors.blue.shade800,
              strokeWidth: 2.0,
            ),
          ],
        ),
      ),
    );
  }
}
