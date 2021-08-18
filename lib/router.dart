import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/profile/cubit/profile_cubit.dart';
import 'package:safechat/profile/view/edit_profile_page.dart';

import 'package:safechat/user/user.dart';
import 'package:safechat/contacts/contacts.dart';
import 'package:safechat/profile/view/profile_page.dart';
import 'package:safechat/splash_screen.dart';
import 'package:safechat/login/login.dart';
import 'package:safechat/signup/signup.dart';
import 'package:safechat/home/home.dart';

class AppRouter {
  Route? onGenerateRoute(RouteSettings routeSettings) {
    final _contactsCubit = ContactsCubit();

    switch (routeSettings.name) {
      case '/':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => SplashScreen(),
        );
      case '/login':
        return PageRouteBuilder(
          pageBuilder: (context, __, ___) => BlocProvider(
            create: (_) => LoginCubit(
              context.read<UserCubit>(),
              context.read<AuthRepository>(),
            ),
            child: LoginPage(),
          ),
        );
      case '/signup':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => SignupPage(),
        );
      case '/home':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: _contactsCubit),
            ],
            child: HomePage(),
          ),
        );
      case '/contacts/add':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => BlocProvider.value(
            value: _contactsCubit,
            child: AddContactPage(),
          ),
        );
      case '/profile':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => BlocProvider(
            create: (context) => ProfileCubit(
              context.read<UserCubit>(),
            ),
            child: ProfilePage(),
          ),
        );
      case '/profile/edit':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => BlocProvider(
            create: (context) => ProfileCubit(
              context.read<UserCubit>(),
            )..initForm(),
            child: EditProfilePage(),
          ),
        );
      default:
        return null;
    }
  }
}
