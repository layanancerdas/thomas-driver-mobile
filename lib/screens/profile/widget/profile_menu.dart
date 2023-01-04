import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/widgets/custom_text.dart';

class ProfileMenu extends StatelessWidget {
  final String text, icon;
  final bool divider;
  final onPress;

  ProfileMenu({this.divider: false, this.icon, this.text, this.onPress});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            ),
            onPressed: () => onPress(),
            child: Row(
              children: [
                SvgPicture.asset("assets/images/$icon", width: 20, height: 20),
                SizedBox(width: 16),
                CustomText(
                  "$text",
                  color: ColorsCustom.black,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                )
              ],
            )),
        divider
            ? Container(
                color: Color(0xFFE8E8E8),
                height: 1,
                width: double.infinity,
              )
            : SizedBox(),
      ],
    );
  }
}
