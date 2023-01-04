import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tomas_driver/configs/config.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/localization/app_translations.dart';
// import 'package:tomas_driver/helpers/utils.dart';
import 'package:tomas_driver/redux/app_state.dart';
import 'package:tomas_driver/redux/modules/user_state.dart';
// import 'package:tomas_driver/screens/profile/widget/ajk_request_time.dart';
import 'package:tomas_driver/screens/profile/widget/profile_menu.dart';
import 'package:tomas_driver/screens/webview/webview.dart';
import 'package:tomas_driver/widgets/custom_text.dart';
import './profile_view_model.dart';

class ProfileView extends ProfileViewModel {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StoreConnector<AppState, UserState>(
          converter: (store) => store.state.userState,
          builder: (context, state) {
            return Stack(
              children: [
                SafeArea(
                  child: Container(
                    margin: EdgeInsets.only(top: 20, left: 16, right: 16),
                    width: double.infinity,
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 16, bottom: 0),
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: state.userDetail['photo'] != null
                                      ? Image.network(
                                          "$BASE_API/files/${state.userDetail['photo']}")
                                      : SvgPicture.asset(
                                          "assets/images/placeholder_user.svg")),
                            ),
                            Flexible(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        "${state.userDetail.containsKey('name') ? state.userDetail['name'] : "-"}",
                                        fontWeight: FontWeight.w600,
                                        color: ColorsCustom.black,
                                        fontSize: 20,
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          CustomText(
                                            "${state.userDetail.containsKey('phone_number') ? state.userDetail['phone_number'] : "-"}",
                                            color: ColorsCustom.black,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                          ),
                                          state.userDetail.containsKey(
                                                      'vaccinated') &&
                                                  state.userDetail[
                                                          'vaccinated'] !=
                                                      null &&
                                                  state.userDetail['vaccinated']
                                              ? Expanded(
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 1,
                                                        height: 14,
                                                        decoration:
                                                            BoxDecoration(
                                                                color:
                                                                    ColorsCustom
                                                                        .border),
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 12),
                                                      ),
                                                      CustomText(
                                                        "${AppTranslations.of(context).text("vaccinated")}",
                                                        color:
                                                            ColorsCustom.black,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 14,
                                                      ),
                                                      SizedBox(width: 6),
                                                      SvgPicture.asset(
                                                        'assets/images/vaccinated-icon.svg',
                                                        width: 14,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : SizedBox(),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          RichText(
                                            text: new TextSpan(
                                              text: 'Driver ID  ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 14,
                                                  color: ColorsCustom.black,
                                                  fontFamily: 'Poppins'),
                                            ),
                                          ),
                                          Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color:
                                                    ColorsCustom.primaryVeryLow,
                                              ),
                                              padding: EdgeInsets.only(
                                                  top: 3,
                                                  bottom: 4,
                                                  right: 10,
                                                  left: 10),
                                              child: RichText(
                                                text: TextSpan(
                                                  text:
                                                      '${state.userDetail.containsKey('driver_code') ? state.userDetail['driver_code'] : "-"}',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 14,
                                                      color: Color(0xFF45ABC7),
                                                      fontFamily: 'Poppins'),
                                                ),
                                              ))
                                        ],
                                      ),
                                    ],
                                  )),
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 28),
                        ProfileMenu(
                          divider: true,
                          icon: 'call_outline.svg',
                          text: AppTranslations.of(context)
                              .text("profile_contact"),
                          onPress: () =>
                              Navigator.pushNamed(context, '/ContactUs'),
                        ),
                        ProfileMenu(
                          divider: true,
                          icon: 'help.svg',
                          text: AppTranslations.of(context).text("profile_faq"),
                          onPress: () => Navigator.pushNamed(context, '/Faq'),
                        ),
                        ProfileMenu(
                          divider: true,
                          icon: 'language.svg',
                          text: AppTranslations.of(context)
                              .text("profile_language"),
                          onPress: () =>
                              Navigator.pushNamed(context, '/Language'),
                        ),
                        ProfileMenu(
                          divider: true,
                          icon: 'privacy_policy.svg',
                          text:
                              "${AppTranslations.of(context).text("privacy_policy")}",
                          onPress: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => Webview(
                                        link: "https://tomas-admin.toyota.co.id/privacy-policy",
                                        title:
                                            "${AppTranslations.of(context).text("privacy_policy")}",
                                      ))),
                        ),
                        ProfileMenu(
                          divider: true,
                          icon: 'logout.svg',
                          text: AppTranslations.of(context)
                              .text("profile_logout"),
                          onPress: onDialogLogout,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                    bottom: 15,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: CustomText(
                        "${AppTranslations.of(context).text("profile_version")} $version",
                        color: ColorsCustom.black,
                        fontSize: 12,
                      ),
                    ))
              ],
            );
          }),
    );
  }
}
