import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/router.dart';
import 'package:safechat/chats/chats.dart';

class PhotoMessage extends StatelessWidget {
  const PhotoMessage({
    Key? key,
    required this.chat,
    required this.photos,
    required this.borderRadius,
  }) : super(key: key);

  final Chat chat;
  final List<Attachment> photos;
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
              crossAxisCount: min(photos.length, 3),
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: photos.length,
            itemBuilder: (BuildContext context, index) {
              return FutureBuilder(
                  key: Key(photos[index].name),
                  future: context
                      .read<AttachmentsCubit>()
                      .getAttachment(chat, photos[index]),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.inState(ConnectionState.done).hasData) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/chat/media',
                            arguments: MediaPageArguments(
                              chat,
                              photos[index],
                            ),
                          );
                        },
                        child: Image.file(
                          snapshot.data!,
                          fit: BoxFit.cover,
                          frameBuilder: (BuildContext context, Widget child,
                              int? frame, bool wasSynchronouslyLoaded) {
                            if (wasSynchronouslyLoaded) {
                              return child;
                            }
                            return AnimatedOpacity(
                              opacity: frame == null ? 0 : 1,
                              duration: const Duration(seconds: 1),
                              curve: Curves.easeOut,
                              child: child,
                            );
                          },
                          cacheWidth: 500,
                          filterQuality: FilterQuality.medium,
                        ),
                      );
                    } else {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                        ),
                      );
                    }
                  });
            }),
      ),
    );
  }
}
