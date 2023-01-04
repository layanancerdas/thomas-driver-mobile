import 'package:flutter/material.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/widgets/custom_text.dart';

class ButtonDate extends StatelessWidget {
  final int selectedId;
  final Map data;
  final onPress;

  ButtonDate({this.data, this.onPress, this.selectedId});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
          color:
              data['id'] == selectedId ? ColorsCustom.primaryLow : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 2),
                blurRadius: 8,
                spreadRadius: 0,
                color: ColorsCustom.black.withOpacity(0.12))
          ]),
      child: TextButton(
        style: TextButton.styleFrom(
          //  highlightColor: ColorsCustom.black.withOpacity(0.08),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 5),
        ),
        onPressed: () => onPress(data['id']),
        child: Column(
          children: [
            CustomText(
              "${data['date']}",
              color: ColorsCustom.primaryHigh,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            CustomText(
              "${data['day']}",
              color: ColorsCustom.primaryHigh,
              fontWeight: FontWeight.w400,
              fontSize: 11,
            ),
          ],
        ),
      ),
    );
  }
}
