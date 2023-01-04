import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/localization/app_translations.dart';
import 'package:tomas_driver/redux/app_state.dart';
import 'package:tomas_driver/redux/modules/ajk_state.dart';
import 'package:tomas_driver/redux/modules/user_state.dart';
import 'package:tomas_driver/widgets/custom_text.dart';

class BusDetails extends StatelessWidget {

  final bool isLoading;

  BusDetails({this.isLoading: false});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AjkState>(
        converter: (store) => store.state.ajkState,
        builder: (context, state) {
          return Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        offset: Offset(0, 0),
                        spreadRadius: 1,
                        blurRadius: 4,
                        color: ColorsCustom.black.withOpacity(0.15))
                  ]),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            'assets/images/school_bus.svg',
                            height: 24,
                            width: 24,
                          ),
                          SizedBox(width: 16),
                          CustomText(
                            AppTranslations.of(context).text("detail_bus"),
                            color: ColorsCustom.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14),
                    isLoading
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomText(
                                  "Coming Soon",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                  color: ColorsCustom.black,
                                ),
                                SvgPicture.asset(
                                  'assets/images/hour_glass.svg',
                                  height: 24,
                                  width: 24,
                                ),
                              ],
                            ),
                          )
                        : Column(children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        state.selectedMyTrip['bus_type']['name'],
                                        color: ColorsCustom.generalText,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      CustomText(
                                        "${state.selectedMyTrip['bus_type']['seats']} ${AppTranslations.of(context).text("detail_seat")}",
                                        color: ColorsCustom.generalText,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        "${state.selectedMyTrip['bus']['brand']}",
                                        color: ColorsCustom.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      CustomText(
                                        "${state.selectedMyTrip['bus']['license_plate']}",
                                        color: ColorsCustom.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ])
                  ]));
        });
  }
}
