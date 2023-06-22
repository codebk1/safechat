import 'dart:io';

import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';

class VideoThumbnail extends StatefulWidget {
  const VideoThumbnail({
    Key? key,
    required this.video,
  }) : super(key: key);

  final File video;

  @override
  VideoThumbnailState createState() => VideoThumbnailState();
}

class VideoThumbnailState extends State<VideoThumbnail> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.video)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(children: [
        VideoPlayer(_controller),
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            margin: const EdgeInsets.all(5.0),
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.black54,
            ),
            child: Text(
              '${_controller.value.duration.inSeconds}s',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ]),
    );
  }
}
