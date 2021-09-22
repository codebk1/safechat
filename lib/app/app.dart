import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safechat/chats/cubits/chats/chats_cubit.dart';

import 'package:safechat/theme.dart';
import 'package:safechat/router.dart';
import 'package:safechat/user/user.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _appRouter = AppRouter();

  final _authRepository = AuthRepository();
  final _userRepository = UserRepository();

  @override
  void dispose() {
    _appRouter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => _authRepository,
        ),
        RepositoryProvider<UserRepository>(
          create: (context) => _userRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => UserCubit(
              _authRepository,
              _userRepository,
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
