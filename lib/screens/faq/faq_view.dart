import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tomas_driver/configs/static_text.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/localization/app_translations.dart';
import 'package:tomas_driver/widgets/custom_text.dart';
import './faq_view_model.dart';
import 'widgets/list_faq.dart';

class FaqView extends FaqViewModel {
  @override
  Widget build(BuildContext context) {
    // Replace this with your build function
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          style: TextButton.styleFrom(),
          onPressed: () => Navigator.pop(context),
          child: SvgPicture.asset(
            'assets/images/back_icon.svg',
          ),
        ),
        // elevation: 3,
        centerTitle: true,
        title: CustomText(
          "FAQ",
          color: ColorsCustom.black,
        ),
      ),
      body: ListView.builder(
        itemCount: AppTranslations.of(context).currentLanguage == 'id'
            ? StaticText.faqId.length
            : StaticText.faqEn.length,
        itemBuilder: (ctx, i) {
          return AppTranslations.of(context).currentLanguage == 'id'
              ? ListFaq(
                  title: StaticText.faqId[i]['title'],
                  text: StaticText.faqId[i]['text'] ?? null,
                  content: StaticText.faqId[i]['content'] ?? null,
                )
              : ListFaq(
                  title: StaticText.faqEn[i]['title'],
                  text: StaticText.faqEn[i]['text'] ?? null,
                  content: StaticText.faqEn[i]['content'] ?? null,
                );
        },
      ),
    );
  }
}
