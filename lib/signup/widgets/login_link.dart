import 'package:flutter/material.dart';

class LoginLink extends StatelessWidget {
  const LoginLink({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Masz konto?',
          style: Theme.of(context).textTheme.subtitle2,
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/login',
              (Route<dynamic> route) => false,
            );
          },
          child: const Text(
            'Zaloguj się',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}
