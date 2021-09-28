import 'dart:io';

class NotificationData {
  const NotificationData({
    required this.id,
    required this.title,
    required this.body,
    this.image,
  });

  final String id;
  final String title;
  final String body;
  final File? image;
}
