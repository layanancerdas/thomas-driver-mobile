import 'package:flutter/material.dart';
import 'package:tomas_driver/screens/password_reset/password_reset.dart';

class Deeplinks {
  static void parseRoute(
      Uri uri, GlobalKey<NavigatorState> navigatorKey, bool isLogin) {
// 1
    if (uri.pathSegments.isEmpty) {
      !isLogin
          ? navigatorKey.currentState.pushReplacementNamed('/Sign')
          : navigatorKey.currentState.pushReplacementNamed('/Home');
      return;
    }

// 2
    // Handle navapp://deeplinks/details/#
    final path = uri.pathSegments[0];
// 4
    switch (path) {
      case 'password_reset':
        navigatorKey.currentState.pushReplacement(MaterialPageRoute(
            builder: (_) => PasswordReset(
                  driverId: uri.pathSegments[1],
                  token: uri.pathSegments[2],
                )));
        break;
    }
  }
}
