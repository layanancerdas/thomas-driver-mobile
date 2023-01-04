import 'package:flutter/material.dart';
import 'package:tomas_driver/widgets/custom_text.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final EdgeInsets padding, margin;
  final Color textColor, bgColor;
  final double fontSize, width;
  final BorderRadius borderRadius;
  final FontWeight fontWeight;
  final bool isLoading, flat;
  final onPressed;

  CustomButton(
      {this.text,
      this.textColor,
      this.bgColor,
      this.onPressed,
      this.width,
      this.padding,
      this.fontSize,
      this.fontWeight,
      this.borderRadius,
      this.isLoading: false,
      this.margin,
      this.flat: false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      width: width ?? null,
      child: flat
          ? TextButton(
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: borderRadius ?? BorderRadius.circular(16)),
                padding: padding,
              ),
              onPressed: onPressed,
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              new AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : CustomText(
                        "$text",
                        color: textColor,
                        fontSize: fontSize,
                        fontWeight: fontWeight,
                      ),
              ))
          : ElevatedButton(
              style: TextButton.styleFrom(
                backgroundColor: bgColor,
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: borderRadius ?? BorderRadius.circular(16)),
                padding: padding,
              ),
              onPressed: onPressed,
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              new AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : CustomText(
                        "$text",
                        color: textColor,
                        fontSize: fontSize,
                        fontWeight: fontWeight,
                      ),
              ),
            ),
    );
  }
}
