import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/widgets/custom_text.dart';

class CustomDialog extends StatelessWidget {
  final String image, title, desc;
  final onClick;

  CustomDialog({this.image, this.title, this.desc, this.onClick});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
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
                  width: screenSize.width / 1.5,
                  padding: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: screenSize.width * 0.2,
                              child: SvgPicture.asset(
                                'assets/images/$image',
                              ),
                            ),
                            SizedBox(height: 20),
                            CustomText(
                              "$title",
                              textAlign: TextAlign.center,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: ColorsCustom.black,
                            ),
                            SizedBox(height: 20),
                            CustomText(
                              "$desc",
                              fontSize: 13,
                              textAlign: TextAlign.center,
                              fontWeight: FontWeight.w300,
                              color: ColorsCustom.black.withOpacity(0.9),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                      Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              border: Border(top: BorderSide(width: .2))),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(16),
                                      bottomRight: Radius.circular(16))),
                              padding: EdgeInsets.symmetric(vertical: 15),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: onClick,
                            child: CustomText(
                              "OK",
                              color: ColorsCustom.primary,
                              fontSize: 16,
                            ),
                          ))
                    ],
                  )),
            )
          ],
        ));
  }
}
