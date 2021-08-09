import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/theme.dart';
import 'package:safechat/router.dart';
import 'package:safechat/splash_screen.dart';
import 'package:safechat/auth/auth.dart';
import 'package:safechat/login/login.dart';
import 'package:safechat/home/home.dart';
import 'package:safechat/utils/encryption_service.dart';

class App extends StatelessWidget {
  App({
    Key? key,
    required AuthRepository authRepository,
    required EncryptionService encryptionService,
  })  : _authRepository = authRepository,
        _encryptionService = encryptionService,
        super(key: key);

  final AuthRepository _authRepository;
  final EncryptionService _encryptionService;
  final AppRouter _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => _authRepository,
        ),
        RepositoryProvider<EncryptionService>(
          create: (context) => _encryptionService,
        ),
      ],
      child: BlocProvider<AuthCubit>(
        create: (context) => AuthCubit(context.read<AuthRepository>())..init(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SafeChat',
          theme: AppTheme.lightTheme,
          onGenerateRoute: _appRouter.onGenerateRoute,
          home: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state.status == AuthStatus.authenticated) {
                return HomePage();
              }

              if (state.status == AuthStatus.unauthenticated) {
                return LoginPage();
              }

              return SplashScreen();
            },
          ),
        ),
      ),
    );
  }
}
