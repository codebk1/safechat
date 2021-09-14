import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';
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
          BlocBuilder<AttachmentCubit, AttachmentState>(
            builder: (context, state) {
              return state.downloading
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Transform.scale(
                          scale: 0.6,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 1,
                          ),
                        ),
                      ),
                    )
                  : IconButton(
                      onPressed: () async {
                        final file = await context
                            .read<AttachmentCubit>()
                            .downloadAttachment(
                              attachment.name,
                              context.read<ChatCubit>().state,
                            );

                        if (file.existsSync()) {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                action: SnackBarAction(
                                  onPressed: () => OpenFile.open(
                                    file.path,
                                  ),
                                  label: 'Wyświetl',
                                ),
                                content: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.error,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Text('Pobrano załącznik'),
                                  ],
                                ),
                              ),
                            );
                        }
                      },
                      icon: Icon(Icons.download),
                    );
            },
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
              return attachment.type == AttachmentType.PHOTO
                  ? Photo(photo: snapshot.data)
                  : Video(video: snapshot.data);
            } else {
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              );
            }
          }),
    );
  }
}

class Photo extends StatelessWidget {
  const Photo({
    Key? key,
    required this.photo,
  }) : super(key: key);

  final File photo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.file(
        photo,
        frameBuilder: (BuildContext context, Widget child, int? frame,
            bool wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) {
            return child;
          }
          return Container(
            child: AnimatedOpacity(
              child: child,
              opacity: frame == null ? 0 : 1,
              duration: const Duration(seconds: 1),
              curve: Curves.easeOut,
            ),
          );
        },
      ),
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
        child: ValueListenableBuilder(
          valueListenable: _controller,
          builder: (context, VideoPlayerValue value, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: Stack(children: [
                    VideoPlayer(_controller),
                    !_controller.value.isPlaying
                        ? Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.play_circle,
                              color: Colors.white,
                              size: 55,
                            ),
                          )
                        : SizedBox.shrink(),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    '${formatDuration(_controller.value.position)} / ${formatDuration(_controller.value.duration)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

// chewie: https://github.com/brianegan/chewie/blob/master/lib/src/helpers/utils.dart
String formatDuration(Duration position) {
  final ms = position.inMilliseconds;

  int seconds = ms ~/ 1000;
  final int hours = seconds ~/ 3600;
  seconds = seconds % 3600;
  final minutes = seconds ~/ 60;
  seconds = seconds % 60;

  final hoursString = hours >= 10
      ? '$hours'
      : hours == 0
          ? '00'
          : '0$hours';

  final minutesString = minutes >= 10
      ? '$minutes'
      : minutes == 0
          ? '00'
          : '0$minutes';

  final secondsString = seconds >= 10
      ? '$seconds'
      : seconds == 0
          ? '00'
          : '0$seconds';

  final formattedTime =
      '${hoursString == '00' ? '' : '$hoursString:'}$minutesString:$secondsString';

  return formattedTime;
}