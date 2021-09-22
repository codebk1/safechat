import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/chats/cubits/chats/chats_cubit.dart';
import 'package:safechat/chats/view/chat_page.dart';
import 'package:safechat/chats/view/create_chat_page.dart';
import 'package:safechat/chats/view/media_page.dart';
import 'package:safechat/profile/cubit/profile_cubit.dart';
import 'package:safechat/profile/view/edit_profile_page.dart';

import 'package:safechat/user/user.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/profile/view/profile_page.dart';
import 'package:safechat/splash_screen.dart';
import 'package:safechat/login/login.dart';
import 'package:safechat/signup/signup.dart';
import 'package:safechat/home/home.dart';

import 'chats/cubits/attachments/attachments_cubit.dart';
import 'chats/models/attachment.dart';
import 'chats/models/chat.dart';

class AppRouter {
  final _contactsCubit = ContactsCubit();
  final _chatsCubit = ChatsCubit();

  Route? onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case '/':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => const SplashScreen(),
        );
      case '/login':
        return PageRouteBuilder(
          pageBuilder: (context, __, ___) => BlocProvider(
            create: (_) => LoginCubit(
              context.read<UserCubit>(),
              context.read<AuthRepository>(),
            ),
            child: const LoginPage(),
          ),
        );
      case '/signup':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => const SignupPage(),
        );
      case '/home':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: _contactsCubit..getContacts()),
              BlocProvider.value(value: _chatsCubit..getChats()),
            ],
            child: HomePage(),
          ),
        );
      case '/contacts/add':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => BlocProvider.value(
            value: _contactsCubit,
            child: const AddContactPage(),
          ),
        );
      case '/profile':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => BlocProvider(
            create: (context) => ProfileCubit(
              context.read<UserCubit>(),
            ),
            child: const ProfilePage(),
          ),
        );
      case '/profile/edit':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => BlocProvider(
            create: (context) => ProfileCubit(
              context.read<UserCubit>(),
            )..initForm(),
            child: const EditProfilePage(),
          ),
        );
      case '/chat':
        final args = routeSettings.arguments as ChatPageArguments;
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => ContactsCubit(contacts: args.contacts),
              ),
              BlocProvider.value(value: _chatsCubit),
            ],
            child: ChatPage(
              chat: args.chat,
            ),
          ),
        );
      case '/chats/create':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: _contactsCubit),
              BlocProvider.value(value: _chatsCubit),
            ],
            child: const CreateChatPage(),
          ),
        );
      case '/chat/media':
        final args = routeSettings.arguments as MediaPageArguments;
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => AttachmentsCubit(
                  attachments: [args.attachment],
                ),
              ),
            ],
            child: MediaPage(chat: args.chat),
          ),
        );
      default:
        return null;
    }
  }

  void dispose() {
    _contactsCubit.close();
    _chatsCubit.close();
  }
}

class MediaPageArguments {
  MediaPageArguments(this.chat, this.attachment);

  final Chat chat;
  final Attachment attachment;
}

class ChatPageArguments {
  ChatPageArguments(this.chat, this.contacts);

  final Chat chat;
  final List<Contact> contacts;
}
