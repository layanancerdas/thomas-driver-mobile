import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/localization/app_translations.dart';
import 'package:tomas_driver/widgets/custom_text.dart';
import './language_view_model.dart';

class LanguageView extends LanguageViewModel {
  @override
  Widget build(BuildContext context) {
    // Replace this with your build function
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: TextButton(
            style: TextButton.styleFrom(),
            onPressed: () => Navigator.pop(context),
            child: SvgPicture.asset(
              'assets/images/back_icon.svg',
            ),
          ),
          // elevation: 3,
          title: CustomText(
            "${AppTranslations.of(context).text("choose_language")}",
            color: ColorsCustom.black,
          ),
          actions: [
            TextButton(
                style: TextButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                ),
                onPressed: () => onSave(),
                child: CustomText(
                  AppTranslations.of(context).text("language_save"),
                  color: ColorsCustom.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ))
          ],
        ),
        body: ListView.builder(
          itemCount: languages.length,
          itemBuilder: (context, index) {
            return buttonLanguage(
                context: context, data: languages[index], index: index);
          },
        ));
  }

  Widget buttonLanguage({BuildContext context, Map data, int index}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: ColorsCustom.softGrey, width: 1))),
      child: TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 24),
          ),
          onPressed: () => toggleSelectedLanguage(index),
          child: Row(
            children: [
              Expanded(
                child: CustomText(
                  "${data['name']}",
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: ColorsCustom.black,
                  // textAlign: TextAlign.center,
                ),
              ),
              Container(
                height: 24,
                width: 24,
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        width: 1,
                        color: index == selectedLanguage
                            ? ColorsCustom.primary
                            : ColorsCustom.softGrey)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: index == selectedLanguage
                        ? ColorsCustom.primary
                        : Colors.white,
                  ),
                ),
              )
            ],
          )),
    );
  }
}
