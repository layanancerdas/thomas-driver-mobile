import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

import 'custom_text.dart';

class CustomToast extends StatefulWidget {
  final String image, title;
  final double width;
  final Color color;
  final bool isForgotPassword;
  final Duration duration;

  CustomToast(
      {this.image,
      this.title,
      this.color,
      this.duration,
      this.isForgotPassword: false,
      this.width});
  @override
  _CustomToastState createState() => _CustomToastState();
}

class _CustomToastState extends State<CustomToast> {
  Future<void> onClickHere() async {
    await canLaunch("https://wa.me/6282332878777")
        ? await launch("https://wa.me/6282332878777")
        : throw 'Could not launch https://wa.me/6282332878777';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.isForgotPassword) {
        Future.delayed(widget.duration, () => Navigator.pop(context));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Material(
        type: MaterialType.transparency,
        child: Stack(children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width:
                  widget.width != null ? widget.width : screenSize.width / 1.8,
              padding: !widget.isForgotPassword
                  ? EdgeInsets.symmetric(vertical: 24, horizontal: 16)
                  : EdgeInsets.fromLTRB(16, 24, 16, 10),
              decoration: BoxDecoration(
                  color: widget.color ?? ColorsCustom.primaryGreen,
                  boxShadow: [
                    BoxShadow(
                        offset: Offset(0, 8),
                        spreadRadius: 0,
                        blurRadius: 12,
                        color: ColorsCustom.black.withOpacity(0.2))
                  ],
                  borderRadius: BorderRadius.circular(16)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                widget.image != null
                    ? SvgPicture.asset(
                        'assets/images/${widget.image}',
                      )
                    : SizedBox(),
                widget.image != null ? SizedBox(height: 16) : SizedBox(),
                CustomText(
                  "${widget.title}",
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  textAlign: TextAlign.center,
                ),
                !widget.isForgotPassword ? SizedBox() : SizedBox(height: 10),
                widget.isForgotPassword
                    ? CustomButton(
                        onPressed: onClickHere,
                        text: "Contact Us",
                        margin: EdgeInsets.zero,
                        bgColor: Colors.white,
                        textColor: ColorsCustom.primary,
                      )
                    : Container()
              ]),
            ),
          )
        ]));
  }
}
