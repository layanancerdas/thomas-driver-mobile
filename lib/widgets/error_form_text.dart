import 'package:flutter/material.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';

class ErrorForm extends StatelessWidget {
  final String error;

  ErrorForm({this.error});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 5),
      child: Text(
        "$error",
        style: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 12,
            color: ColorsCustom.danger,
            fontFamily: 'Poppins'),
      ),
    );
  }
}
