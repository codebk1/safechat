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
  }) : super(key: key);

  final Chat chat;
  final List<Attachment> photos;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AttachmentsCubit(),
      child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: min(photos.length, 3),
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
          ),
          itemCount: photos.length,
          itemBuilder: (BuildContext context, index) {
            return FutureBuilder(
                future: context
                    .read<AttachmentsCubit>()
                    .getAttachment(chat, photos[index]),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
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
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                        child: Image.file(
                          snapshot.data!,
                          fit: BoxFit.cover,
                          frameBuilder: (BuildContext context, Widget child,
                              int? frame, bool wasSynchronouslyLoaded) {
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
                          cacheWidth:
                              (MediaQuery.of(context).size.width).round(),
                          filterQuality: FilterQuality.medium,
                        ),
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
    );
  }
}
