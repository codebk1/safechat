import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/theme.dart';
import 'package:safechat/router.dart';
import 'package:safechat/user/user.dart';

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  final AppRouter _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(),
        ),
        RepositoryProvider<UserRepository>(
          create: (context) => UserRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => UserCubit(
              context.read<AuthRepository>(),
              context.read<UserRepository>(),
            )..authenticate(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SafeChat',
          theme: AppTheme.lightTheme,
          onGenerateRoute: _appRouter.onGenerateRoute,
        ),
      ),
    );
  }
}
