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
          style: Theme.of(context).textTheme.titleSmall,
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/signup');
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
