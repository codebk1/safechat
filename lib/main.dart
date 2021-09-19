import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/app/app_bloc_observer.dart';
import 'package:safechat/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = AppBlocObserver();
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
        statusBarColor: Colors.grey.shade300,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark),
  );

  // final storage = FlutterSecureStorage();
  // final apiService = ApiService();
  // final encryptionService = EncryptionService();

  // if (await storage.containsKey(key: 'publicKey'))
  //   await encryptionService.init();

  // final authRepository = AuthRepository(apiService.init(), encryptionService);

  runApp(App());
}
