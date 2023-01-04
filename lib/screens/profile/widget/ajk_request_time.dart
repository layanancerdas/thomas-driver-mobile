import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/helpers/utils.dart';
import 'package:tomas_driver/localization/app_translations.dart';
import 'package:tomas_driver/widgets/custom_text.dart';

class AjkRequestTime extends StatefulWidget {
  @override
  _AjkRequestTimeState createState() => _AjkRequestTimeState();
}

class _AjkRequestTimeState extends State<AjkRequestTime> {
  int permitTime = 0;

  Future<void> initPermitTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      permitTime = prefs.getInt('ajkPermitTime') ?? 0;
    });
  }

  @override
  void initState() {
    super.initState();
    initPermitTime();
  }

  @override
  Widget build(BuildContext context) {
    return permitTime > 0
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Card(
                elevation: 3,
                shadowColor: ColorsCustom.black.withOpacity(.35),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                "assets/images/hour_glass_red.svg",
                                width: 12.5,
                              ),
                              SizedBox(width: 12),
                              CustomText(
                                "AJK Request Processed",
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: ColorsCustom.black,
                              )
                            ],
                          ),
                          SizedBox(height: 3),
                          RichText(
                            text: new TextSpan(
                              text: 'Submission Time: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 12,
                                  color: ColorsCustom.black,
                                  fontFamily: 'Poppins'),
                              children: <TextSpan>[
                                new TextSpan(
                                    text:
                                        '${DateFormat('E, dd MMMM yyyy, HH:mm a', AppTranslations.of(context).currentLanguage).format(DateTime.fromMillisecondsSinceEpoch(permitTime))}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                    )),
                              ],
                            ),
                          )
                        ]))),
          )
        : SizedBox(height: 20);
  }
}
