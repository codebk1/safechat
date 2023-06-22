import 'package:flutter/material.dart';

class ContactsListGroupHeader extends StatelessWidget {
  const ContactsListGroupHeader({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15.0,
        vertical: 5.0,
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}
