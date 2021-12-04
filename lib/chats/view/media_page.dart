import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:open_file/open_file.dart';

import 'package:safechat/chats/chats.dart';

class MediaPage extends StatelessWidget {
  const MediaPage({
    Key? key,
    required this.chat,
  }) : super(key: key);

  final Chat chat;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttachmentsCubit, AttachmentsState>(
      builder: (context, state) {
        return AnnotatedRegion(
          value: const SystemUiOverlayStyle().copyWith(
            systemNavigationBarColor: Colors.black,
            systemNavigationBarIconBrightness: Brightness.light,
          ),
          child: Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              systemOverlayStyle: const SystemUiOverlayStyle().copyWith(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
              ),
              actions: [
                if (state.downloadedAttachment != null)
                  IconButton(
                    onPressed: () async {
                      if (state.downloadedAttachment!.existsSync()) {
                        final attachment = await File(
                          '/storage/emulated/0/Download/${state.downloadedAttachment!.uri.pathSegments.last}.jpg',
                        ).writeAsBytes(
                          state.downloadedAttachment!.readAsBytesSync(),
                        );

                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              action: SnackBarAction(
                                onPressed: () => OpenFile.open(
                                  attachment.path,
                                ),
                                label: 'Wyświetl',
                              ),
                              content: Row(
                                children: const <Widget>[
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
                    icon: const Icon(Icons.download),
                  ),
              ],
              backgroundColor: Colors.black,
              titleSpacing: 0,
              elevation: 0,
              iconTheme: const IconThemeData(
                color: Colors.white,
              ),
            ),
            body: FutureBuilder(
                future: context.read<AttachmentsCubit>().getAttachment(
                      chat,
                      state.attachments.first,
                      thumbnail: false,
                    ),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    return state.attachments.first.type == AttachmentType.photo
                        ? Photo(photo: snapshot.data)
                        : Video(video: snapshot.data);
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    );
                  }
                }),
          ),
        );
      },
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
          return AnimatedOpacity(
            child: child,
            opacity: frame == null ? 0 : 1,
            duration: const Duration(seconds: 1),
            curve: Curves.easeOut,
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
                        ? const Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.play_circle,
                              color: Colors.white,
                              size: 55,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    '${_formatDuration(_controller.value.position)} / ${_formatDuration(_controller.value.duration)}',
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
String _formatDuration(Duration position) {
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
