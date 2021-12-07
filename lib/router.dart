import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/splash_screen.dart';
import 'package:safechat/login/login.dart';
import 'package:safechat/signup/signup.dart';
import 'package:safechat/home/home.dart';
import 'package:safechat/user/user.dart';
import 'package:safechat/profile/profile.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/chats/chats.dart';

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
          pageBuilder: (context, __, ___) => BlocProvider(
            create: (_) => SignupCubit(
              context.read<AuthRepository>(),
            ),
            child: const SignupPage(),
          ),
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
              context.read<UserRepository>(),
            ),
            child: const ProfilePage(),
          ),
        );
      case '/profile/edit':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => BlocProvider(
            create: (context) => ProfileCubit(
              context.read<UserCubit>(),
              context.read<UserRepository>(),
            )..initForm(),
            child: const EditProfilePage(),
          ),
        );
      case '/password/edit':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => BlocProvider(
            create: (context) => ProfileCubit(
              context.read<UserCubit>(),
              context.read<UserRepository>(),
            )..initForm(),
            child: const EditPasswordPage(),
          ),
        );
      case '/chat':
        final chat = routeSettings.arguments as Chat;
        return PageRouteBuilder(
          pageBuilder: (context, __, ___) => MultiBlocProvider(
            providers: [
              BlocProvider.value(
                value: _chatsCubit
                  ..readChat(
                    chat,
                    context.read<UserCubit>().state.user.id,
                  )
                  ..openChat(chat.id),
              ),
            ],
            child: ChatPage(
              chatId: chat.id,
            ),
          ),
        );
      case '/chat/info':
        final chat = routeSettings.arguments as Chat;
        return PageRouteBuilder(
          pageBuilder: (context, __, ___) => BlocProvider.value(
            value: _chatsCubit,
            child: ChatInfoPage(chatId: chat.id),
          ),
        );
      case '/chat/edit/name':
        final chatId = routeSettings.arguments as String;
        return PageRouteBuilder(
          pageBuilder: (context, __, ___) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: _chatsCubit),
            ],
            child: EditChatNamePage(chatId: chatId),
          ),
        );
      case '/chat/edit/avatar':
        final chatId = routeSettings.arguments as String;
        return PageRouteBuilder(
          pageBuilder: (context, __, ___) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: _chatsCubit),
            ],
            child: EditChatAvatarPage(chatId: chatId),
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
