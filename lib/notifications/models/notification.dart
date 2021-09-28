import 'dart:io';

class Notification {
  const Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.image,
  });

  final String id;
  final String title;
  final String body;
  final File image;
}
