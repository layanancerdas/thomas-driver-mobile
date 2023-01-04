import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final double letterSpacing, fontSize, height;
  final FontWeight fontWeight;
  final Color color;
  final TextAlign textAlign;
  final String text;
  final bool overflow;

  CustomText(this.text,
      {this.fontSize,
      this.color: Colors.white,
      this.fontWeight,
      this.letterSpacing,
      this.textAlign,
      this.height,
      this.overflow: false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      overflow: overflow ? TextOverflow.ellipsis : null,
      style: TextStyle(
          color: color,
          height: height,
          fontFamily: 'Poppins',
          fontSize: fontSize,
          fontWeight: fontWeight,
          letterSpacing: letterSpacing),
    );
  }
}
