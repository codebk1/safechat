import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/router.dart';
import 'package:safechat/chats/chats.dart';

class VideosMessage extends StatelessWidget {
  const VideosMessage({
    Key? key,
    required this.chat,
    required this.videos,
    required this.borderRadius,
  }) : super(key: key);

  final Chat chat;
  final List<Attachment> videos;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AttachmentsCubit(),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: min(videos.length, 3),
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: videos.length,
            itemBuilder: (BuildContext context, index) {
              return FutureBuilder(
                  future: context
                      .read<AttachmentsCubit>()
                      .getAttachment(chat, videos[index]),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.inState(ConnectionState.done).hasData) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/chat/media',
                            arguments: MediaPageArguments(
                              chat,
                              videos[index],
                            ),
                          );
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              snapshot.data!,
                              fit: BoxFit.cover,
                              frameBuilder: (
                                BuildContext context,
                                Widget child,
                                int? frame,
                                bool wasSynchronouslyLoaded,
                              ) {
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
                            const DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.black26,
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.play_circle,
                                color: Colors.white,
                                size: 60 / min(videos.length, 3) + 5,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }
                  });
            }),
      ),
    );
  }
}
