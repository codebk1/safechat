import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/theme.dart';
import 'package:safechat/router.dart';
import 'package:safechat/user/user.dart';
import 'package:safechat/utils/notification_service.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _appRouter = AppRouter();

  @override
  void dispose() {
    _appRouter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => AuthRepository(),
        ),
        RepositoryProvider(
          create: (context) => UserRepository(),
        ),
        RepositoryProvider(
          create: (context) => NotificationService()..init(),
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
