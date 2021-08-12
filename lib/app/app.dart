import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:safechat/theme.dart';
import 'package:safechat/router.dart';
import 'package:safechat/auth/auth.dart';
import 'package:safechat/utils/utils.dart';

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  final AppRouter _appRouter = AppRouter();

  // final storage = FlutterSecureStorage();
  // final apiService = ApiService();
  // final encryptionService = EncryptionService();

  // if (await storage.containsKey(key: 'publicKey'))
  //   await encryptionService.init();

  //final authRepository = AuthRepository(apiService.init(), encryptionService);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiService>(
          create: (context) => ApiService(),
        ),
        RepositoryProvider<EncryptionService>(
          create: (context) => EncryptionService()..init(),
        ),
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(context.read<ApiService>().init(),
              context.read<EncryptionService>()),
        ),
      ],
      child: BlocProvider<AuthCubit>(
        create: (context) => AuthCubit(context.read<AuthRepository>())..init(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SafeChat',
          theme: AppTheme.lightTheme,
          onGenerateRoute: _appRouter.onGenerateRoute,
          // home: BlocBuilder<AuthCubit, AuthState>(
          //   builder: (context, state) {
          //     if (state.status == AuthStatus.authenticated) {
          //       return HomePage();
          //     }

          //     if (state.status == AuthStatus.unauthenticated) {
          //       return LoginPage();
          //     }

          //     return SplashScreen();
          //   },
          // ),
        ),
      ),
    );
  }
}
