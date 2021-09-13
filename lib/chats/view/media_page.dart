import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/chats/cubits/attachment/attachment_cubit.dart';
import 'package:safechat/chats/cubits/chat/chat_cubit.dart';
import 'package:video_player/video_player.dart';

class MediaPage extends StatelessWidget {
  const MediaPage({
    Key? key,
    required this.attachment,
  }) : super(key: key);

  final AttachmentState attachment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.download),
          ),
        ],
        backgroundColor: Colors.black,
        titleSpacing: 0,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: FutureBuilder(
          future: context.read<ChatCubit>().getAttachment(
                attachment,
                thumbnail: false,
              ),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return Video(video: snapshot.data);
            } else {
              return CircularProgressIndicator();
            }
          }),
    );
  }
}

class Video extends StatefulWidget {
  const Video({
    Key? key,
    required this.video,
  }) : super(key: key);

  final File video;

  @override
  _VideoMessageThumbnailState createState() => _VideoMessageThumbnailState();
}

class _VideoMessageThumbnailState extends State<Video> {
  late VideoPlayerController _controller;
  var isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.video)..initialize();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _controller.value.isPlaying
          ? _controller.pause()
          : _controller.play(),
      child: Center(
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Stack(children: [
            VideoPlayer(_controller),
            ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, VideoPlayerValue value, child) {
                return !_controller.value.isPlaying
                    ? Align(
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.play_circle,
                          color: Colors.white,
                          size: 55,
                        ),
                      )
                    : SizedBox.shrink();
              },
            ),
          ]),
        ),
      ),
    );
  }
}
