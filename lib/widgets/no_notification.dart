import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/localization/app_translations.dart';

import 'custom_text.dart';

class NoNotification extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 20),
        SvgPicture.asset("assets/images/no_notifications.svg"),
        CustomText(
          AppTranslations.of(context).text("empty_state_notification"),
          fontWeight: FontWeight.w300,
          fontSize: 14,
          color: ColorsCustom.black,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
