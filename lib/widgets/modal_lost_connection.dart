import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/localization/app_translations.dart';

import 'custom_text.dart';

class ModalNoInternet extends StatefulWidget {
  @override
  _ModalNoInternetState createState() => _ModalNoInternetState();
}

class _ModalNoInternetState extends State<ModalNoInternet> {
  Future<void> onRetry() async {
    try {
      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        Navigator.pop(context);
      }
    } on SocketException catch (_) {
      print("Not Connected");
    }
  }

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
                )),
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset("assets/images/lost_connection.svg"),
                SizedBox(height: 30),
                CustomText(
                  "Oops! Something went wrong",
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: ColorsCustom.black,
                  // textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                CustomText(
                  "Don’t worry, we are working on fixing the problem. Please try again later.",
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: ColorsCustom.black,
                  // textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                backgroundColor: ColorsCustom.primary,
                elevation: 1,
              ),
              onPressed: () => onRetry(),
              child: Text(
                AppTranslations.of(context).text("retry"),
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    fontFamily: 'Poppins'),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SvgPicture.asset(
                "assets/images/close.svg",
                width: 16,
                height: 16,
              ),
            ),
          )
        ],
      ),
    );
  }
}
