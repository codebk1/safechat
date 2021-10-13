import 'package:flutter/material.dart';

class SignupLink extends StatelessWidget {
  const SignupLink({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Nie masz konta?',
          style: Theme.of(context).textTheme.subtitle2,
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/signup');
          },
          child: const Text(
            'Zarejestruj się',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
