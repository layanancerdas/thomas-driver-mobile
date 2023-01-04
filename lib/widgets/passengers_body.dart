import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/localization/app_translations.dart';
import 'package:tomas_driver/redux/app_state.dart';
import 'package:tomas_driver/redux/modules/ajk_state.dart';
import 'package:tomas_driver/widgets/qr_scan.dart';

import 'custom_text.dart';

class PassengerBody extends StatefulWidget {
  final String tripGroupId;
  final bool isCompleted;

  PassengerBody({this.isCompleted: false, this.tripGroupId});
  @override
  _PassengerBodyState createState() => _PassengerBodyState();
}

class _PassengerBodyState extends State<PassengerBody> {
  bool isScanned = false;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return StoreConnector<AppState, AjkState>(
        converter: (store) => store.state.ajkState,
        builder: (context, state) {
          return Container(
            height: screenSize.height,
            // color: Colors.black.withOpacity(0.20),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    // height: screenSize.height / 1.5,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: screenSize.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 20, left: 30),
                                child: CustomText(
                                  "${AppTranslations.of(context).text("detail_pass")} [${state.selectedPassanger.length}]",
                                  color: ColorsCustom.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 20),
                              Container(
                                width: screenSize.width,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          isScanned = false;
                                        });
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        width: screenSize.width / 2,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              width: 2,
                                              color: isScanned
                                                  ? Color(0xFFE8E8E8)
                                                  : Color(0xFF75C1D4),
                                            ),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 12, bottom: 12),
                                          child: CustomText(
                                            AppTranslations.of(context)
                                                .text("scan_1"),
                                            color: ColorsCustom.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          isScanned = true;
                                        });
                                      },
                                      child: Container(
                                        alignment: Alignment.center,
                                        width: screenSize.width / 2,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              width: 2,
                                              color: isScanned
                                                  ? Color(0xFF75C1D4)
                                                  : Color(0xFFE8E8E8),
                                            ),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 12, bottom: 12),
                                          child: CustomText(
                                            AppTranslations.of(context)
                                                .text("scan_2"),
                                            color: ColorsCustom.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              (isScanned &&
                                          state.selectedPassanger.every(
                                              (element) => !element
                                                  .containsKey("attended"))) ||
                                      (!isScanned &&
                                          state.selectedPassanger.every(
                                              (element) => element
                                                  .containsKey("attended")))
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        SizedBox(height: 80),
                                        SvgPicture.asset(
                                            "assets/images/empty_passengers.svg"),
                                        SizedBox(height: 20),
                                        CustomText(
                                          state.selectedPassanger.every(
                                                  (element) => !element
                                                      .containsKey("attended"))
                                              ? AppTranslations.of(context)
                                                  .text("empty_passenger")
                                              : AppTranslations.of(context)
                                                  .text("completed_passenger"),
                                          fontWeight: FontWeight.w300,
                                          fontSize: 14,
                                          color: ColorsCustom.black,
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 120),
                                      ],
                                    )
                                  : Container(
                                      height: screenSize.height / 2,
                                      child: Container(
                                        width: screenSize.width,
                                        child: ListView.builder(
                                          physics: ScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount:
                                              state.selectedPassanger.length,
                                          padding: EdgeInsets.only(bottom: 100),
                                          itemBuilder: (context, index) {
                                            if (isScanned) {
                                              if (state.selectedPassanger[index]
                                                  .containsKey("attended")) {
                                                return generateListPassenger(
                                                    i: index,
                                                    name:
                                                        state.selectedPassanger[
                                                            index]['name'],
                                                    divisionName:
                                                        state.selectedPassanger[index]
                                                                ['division']
                                                            ['division_name'],
                                                    vaccinated: state
                                                            .selectedPassanger[
                                                                index]
                                                            .containsKey(
                                                                'vaccinated') &&
                                                        state.selectedPassanger[index]
                                                            ['vaccinated']);
                                              } else {
                                                return SizedBox();
                                              }
                                            } else {
                                              if (!state
                                                  .selectedPassanger[index]
                                                  .containsKey("attended")) {
                                                return generateListPassenger(
                                                    i: index,
                                                    name:
                                                        state.selectedPassanger[
                                                            index]['name'],
                                                    divisionName:
                                                        state.selectedPassanger[index]
                                                                ['division']
                                                            ['division_name'],
                                                    vaccinated: state
                                                            .selectedPassanger[
                                                                index]
                                                            .containsKey(
                                                                'vaccinated') &&
                                                        state.selectedPassanger[index]
                                                            ['vaccinated']);
                                              } else {
                                                return SizedBox();
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                widget.isCompleted
                    ? SizedBox(
                        height: double.infinity,
                        width: double.infinity,
                      )
                    : Positioned(
                        bottom: 32,
                        left: 20,
                        right: 20,
                        child: ElevatedButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              backgroundColor: ColorsCustom.primary,
                              elevation: 0,
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          QRScan(widget.tripGroupId)));
                              // .then((value) => {
                              //       // widget.detailFunction
                              //     });
                            },
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              SvgPicture.asset("assets/images/scan_icon.svg"),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                AppTranslations.of(context).text("detail_scan"),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    fontFamily: 'Poppins'),
                              ),
                            ])),
                      ),
              ],
            ),
          );
        });
  }

  Widget generateListPassenger(
      {String name, bool vaccinated, String divisionName, int i}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16, top: 10),
                  child: Row(
                    children: [
                      CustomText(
                        "$name",
                        color: ColorsCustom.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      //generate

                      vaccinated ? generateVaccinated(context) : SizedBox()
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 16, bottom: 5),
                  child: CustomText(
                    "$divisionName",
                    color: ColorsCustom.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            // Column(
            //   crossAxisAlignment:
            //       CrossAxisAlignment
            //           .start,
            //   children: [
            //     Padding(
            //       padding:
            //           EdgeInsets.only(
            //               left: 16,
            //               right: 16,
            //               top: 10),
            //       child: CustomText(
            //         "${isScanned ? content1[index]['pickup_point']['name'] : content2[index]['pickup_point']['name']}",
            //         color: ColorsCustom
            //             .black,
            //         fontSize: 14,
            //         fontWeight:
            //             FontWeight.w500,
            //       ),
            //     ),
            //     Padding(
            //       padding:
            //           EdgeInsets.only(
            //               left: 16,
            //               bottom: 5,
            //               right: 16),
            //       child: CustomText(
            //         "${isScanned ? content1[index]['status'] : content2[index]['status']}",
            //         color: ColorsCustom
            //             .black,
            //         fontSize: 12,
            //         fontWeight:
            //             FontWeight.w400,
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
        SizedBox(height: 5),
        Divider(color: Colors.grey, height: 1),
        SizedBox(height: 5),
      ],
    );
  }

  Widget generateVaccinated(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 8),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: ColorsCustom.primaryGreenVeryLow,
          borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            AppTranslations.of(context).text("vaccinated"),
            color: ColorsCustom.primaryGreenHigh,
            fontSize: 8,
            fontWeight: FontWeight.w400,
          ),
          SizedBox(width: 4),
          SvgPicture.asset(
            'assets/images/vaccinated-icon.svg',
            width: 12,
          )
        ],
      ),
    );
  }
}
