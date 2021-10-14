import 'package:flutter/material.dart';

SnackBar getErrorSnackBar(
  BuildContext context, {
  required String errorText,
}) {
  return SnackBar(
    action: SnackBarAction(
      onPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
      label: 'Zamknij',
      textColor: Colors.blue.shade800,
    ),
    content: Row(
      children: [
        const Icon(
          Icons.error,
          color: Colors.white,
        ),
        const SizedBox(
          width: 10.0,
        ),
        Text(
          errorText,
        ),
      ],
    ),
  );
}
