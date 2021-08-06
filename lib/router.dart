import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:safechat/splash_screen.dart';
import 'package:safechat/login/login.dart';
import 'package:safechat/signup/signup.dart';
import 'package:safechat/home/home.dart';

class AppRouter {
  Route? onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case '/':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => SplashScreen(),
        );
      case '/login':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => LoginPage(),
        );
      case '/signup':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => SignupPage(),
        );
      case '/home':
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => HomePage(),
        );
      default:
        return null;
    }
  }
}
