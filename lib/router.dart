import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/auth/auth.dart';
import 'package:safechat/friends/cubit/friends_cubit.dart';
import 'package:safechat/friends/repository/friends_repository.dart';

import 'package:safechat/splash_screen.dart';
import 'package:safechat/login/login.dart';
import 'package:safechat/signup/signup.dart';
import 'package:safechat/home/home.dart';
import 'package:safechat/friends/view/add_friend_page.dart';
import 'package:safechat/utils/api_service.dart';
import 'package:safechat/utils/encryption_service.dart';

class AppRouter {
  Route? onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case '/':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => SplashScreen(),
        );
      case '/login':
        return PageRouteBuilder(
          pageBuilder: (context, __, ___) => BlocProvider(
            create: (_) => LoginCubit(
                context.read<AuthCubit>(), context.read<AuthRepository>()),
            child: LoginPage(),
          ),
        );
      case '/signup':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => SignupPage(),
        );
      case '/home':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => RepositoryProvider(
            create: (context) => FriendsRepository(
              context.read<ApiService>().init(),
              context.read<EncryptionService>(),
            ),
            child: BlocProvider(
              create: (context) =>
                  FriendsCubit(context.read<FriendsRepository>()),
              child: HomePage(),
            ),
          ),
        );
      case '/add-friend':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => RepositoryProvider(
            create: (context) => FriendsRepository(
              context.read<ApiService>().init(),
              context.read<EncryptionService>(),
            ),
            child: BlocProvider(
              create: (context) =>
                  FriendsCubit(context.read<FriendsRepository>()),
              child: AddFriendPage(),
            ),
          ),
        );
      default:
        return null;
    }
  }
}
