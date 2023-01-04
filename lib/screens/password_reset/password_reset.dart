import 'package:flutter/material.dart';
import './password_reset_view.dart';

class PasswordReset extends StatefulWidget {
  final String driverId, token;

  PasswordReset({this.driverId, this.token});

  @override
  PasswordResetView createState() => new PasswordResetView();
}
