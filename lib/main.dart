import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:safechat/app/app_bloc_observer.dart';
import 'package:safechat/utils/utils.dart';
import 'package:safechat/auth/auth.dart';
import 'package:safechat/app/app.dart';

void main() async {
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

  ApiService _apiService = new ApiService();
  final authRepository = AuthRepository(_apiService.init());

  runApp(App(authRepository: authRepository));
}
