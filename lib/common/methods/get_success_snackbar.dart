import 'package:flutter/material.dart';

SnackBar getSuccessSnackBar(
  BuildContext context, {
  required String successText,
}) {
  return SnackBar(
    duration: const Duration(
      seconds: 1,
    ),
    content: Row(
      children: [
        const Icon(
          Icons.check_circle,
          color: Colors.white,
        ),
        const SizedBox(
          width: 10.0,
        ),
        Text(
          successText,
        ),
      ],
    ),
  );
}
