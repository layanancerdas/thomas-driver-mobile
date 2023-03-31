import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/localization/app_translations.dart';

import 'custom_text.dart';

class ModalNoLocation extends StatefulWidget {
  final String mode;

  ModalNoLocation({this.mode: 'service'});

  @override
  _ModalNoLocationState createState() => _ModalNoLocationState();
}

class _ModalNoLocationState extends State<ModalNoLocation> {
  static const platform = const MethodChannel("com.tomasdriver.apps/location");
  Future<void> onEnableLocation() async {
    Navigator.pop(context);
    if (widget.mode == 'service') {
      await Geolocator.openLocationSettings();
    } else {
      if (Platform.isIOS) {
        await Geolocator.requestPermission();
      } else if (Platform.isAndroid) {
        var androidInfo = await DeviceInfoPlugin().androidInfo;
        var sdkInt = androidInfo.version.sdkInt;
        if (sdkInt >= 30) {
          try {
            platform.invokeMethod("locationRequest");
          } catch (e) {
            print(e);
          }
        } else {
          await Geolocator.requestPermission();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          )),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SvgPicture.asset(
                  "assets/images/close.svg",
                  width: 16,
                  height: 16,
                ),
              ),
            ),
          ),
          Expanded(
            child: SvgPicture.asset(
              "assets/images/enable_location.svg",
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(20, 28, 20, 16),
            child: CustomText(
              "${widget.mode == 'permission' ? AppTranslations.of(context).text("allow_location") : AppTranslations.of(context).text("enable_location")}",
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: ColorsCustom.black,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: CustomText(
              "${widget.mode == 'permission' ? AppTranslations.of(context).text("pop_up_alert") : AppTranslations.of(context).text("allow_location_desc")}",
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: ColorsCustom.black,
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(20, 0, 20, 30),
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                backgroundColor: ColorsCustom.primary,
                elevation: 1,
              ),
              onPressed: () => onEnableLocation(),
              child: Text(
                AppTranslations.of(context).currentLanguage == 'id'
                    ? "${widget.mode == 'permission' ? "Izinkan selalu" : "Aktifkan Lokasi"}"
                    : "${widget.mode == 'permission' ? "Allow all the time" : "Enable Location"}",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    fontFamily: 'Poppins'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
