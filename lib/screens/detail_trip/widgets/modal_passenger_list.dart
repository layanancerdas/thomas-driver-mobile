import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/localization/app_translations.dart';
import 'package:tomas_driver/widgets/custom_text.dart';
import 'package:tomas_driver/screens/detail_trip/widgets/passenger_unscanned.dart';

class ModalPassengerList extends StatefulWidget {
  @override
  _ModalPassengerListState createState() => _ModalPassengerListState();
}

class _ModalPassengerListState extends State<ModalPassengerList> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
      color: Colors.white.withOpacity(0.20),
      child: Stack(
        children: [
          Container(
            height: screenSize.height,
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
                        padding: const EdgeInsets.only(top: 37, left: 30),
                        child: CustomText(
                          "Passenger List[8]",
                          color: ColorsCustom.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        width: screenSize.width,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              alignment: Alignment.center,
                              width: screenSize.width / 2,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: 2,
                                    color: Color(0xFF75C1D4),
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 12, bottom: 12),
                                child: CustomText(
                                  AppTranslations.of(context)
                                      .text("detail_pass"),
                                  color: ColorsCustom.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              width: screenSize.width / 2,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: 2,
                                    color: Color(0xFFE8E8E8),
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 12, bottom: 12),
                                child: CustomText(
                                  AppTranslations.of(context).text("scan_2"),
                                  color: ColorsCustom.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: screenSize.height / 3.3,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PassengerUnscanned(
                                name: "Venus Darmawan",
                                istd: "ISTD",
                                asal: "Bogor",
                              ),
                              PassengerUnscanned(
                                name: "Venus Darmawan",
                                istd: "ISTD",
                                asal: "Depok",
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 32,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsCustom.primary,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => () {},
              child: Text(
                "Scan Attendance",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white,
                    fontFamily: 'Poppins'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
