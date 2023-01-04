import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/localization/app_translations.dart';
import 'package:tomas_driver/widgets/custom_text.dart';
import 'package:url_launcher/url_launcher.dart';

class CardContact extends StatelessWidget {
  final String title, icon, value, url;

  CardContact({this.title, this.icon, this.value, this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                blurRadius: 12,
                spreadRadius: 0,
                offset: Offset(0, 4),
                color: ColorsCustom.black.withOpacity(0.08))
          ]),
      child: TextButton(
        style: TextButton.styleFrom(),
        onPressed: () async {
          if (url == 'email') {
            var result = await OpenMailApp.openMailApp();

            // If no mail apps found, show error
            if (!result.didOpen && !result.canOpen) {
              showDialog(
                context: context,
                builder: (context) {
                  return CupertinoAlertDialog(
                    title: Text(
                        "${AppTranslations.of(context).text("open_mail_app")}"),
                    content: Text(
                        "${AppTranslations.of(context).text("no_mail_app")}"),
                    actions: <Widget>[
                      TextButton(
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        child: Text(
                          "OK",
                          style: TextStyle(
                            color: ColorsCustom.blueSystem,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  );
                },
              );

              // iOS: if multiple mail apps found, show dialog to select.
              // There is no native intent/default app system in iOS so
              // you have to do it yourself.
            } else if (!result.didOpen && result.canOpen) {
              showDialog(
                context: context,
                builder: (_) {
                  return MailAppPickerDialog(
                    mailApps: result.options,
                  );
                },
              );
            }
          } else {
            await canLaunch(url)
                ? await launch(url)
                : throw 'Could not launch $url';
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              "$title",
              fontWeight: FontWeight.w300,
              fontSize: 12,
              color: ColorsCustom.black,
              height: 2.1,
            ),
            SizedBox(height: 10),
            Row(
              children: [
                SvgPicture.asset(
                  'assets/images/$icon.svg',
                ),
                SizedBox(width: 10),
                Expanded(
                    child: Flexible(
                  child: CustomText(
                    "$value",
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: ColorsCustom.black,
                  ),
                ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
