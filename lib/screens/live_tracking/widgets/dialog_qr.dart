import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tomas_driver/configs/config.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/redux/app_state.dart';
import 'package:tomas_driver/redux/modules/ajk_state.dart';
import 'package:tomas_driver/widgets/custom_text.dart';
import 'package:tomas_driver/localization/app_translations.dart';

class DialogQr extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return StoreConnector<AppState, AjkState>(
        converter: (store) => store.state.ajkState,
        builder: (context, state) {
          return Material(
              type: MaterialType.transparency,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(0, 4),
                                  spreadRadius: 0,
                                  blurRadius: 14,
                                  color: ColorsCustom.black.withOpacity(0.12)),
                            ]),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          QrImage(
                            data:
                                "${BASE_API + "/ajk/booking/confirm_attendance?booking_id="}${state.selectedMyTrip['booking_id']}",
                            version: QrVersions.auto,
                            size: screenSize.width / 1.2,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomText(
                                "${AppTranslations.of(context).text("booking_code")}",
                                color: ColorsCustom.generalText,
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                              ),
                              CustomText(
                                "${state.selectedMyTrip['booking_code']}",
                                color: ColorsCustom.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                        ])),
                  ),
                  Positioned(
                    bottom: screenSize.width / 3.5,
                    left: screenSize.width / 2 - 25,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                                offset: Offset(0, 4),
                                spreadRadius: 0,
                                blurRadius: 14,
                                color: ColorsCustom.black.withOpacity(0.12)),
                          ]),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Icon(
                          Icons.close,
                          color: ColorsCustom.primary,
                          size: 24,
                        ),
                      ),
                    ),
                  )
                ],
              ));
        });
  }
}
