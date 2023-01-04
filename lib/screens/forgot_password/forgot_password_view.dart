import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading/indicator/ball_spin_fade_loader_indicator.dart';
import 'package:loading/loading.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/widgets/custom_button.dart';
import 'package:tomas_driver/widgets/custom_text.dart';
import 'package:tomas_driver/widgets/error_form_text.dart';
import 'package:tomas_driver/widgets/form_text.dart';
import './forgot_password_view_model.dart';

class ForgotPasswordView extends ForgotPasswordViewModel {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          leading: TextButton(
            style: TextButton.styleFrom(),
            onPressed: () => Navigator.pop(context),
            child: SvgPicture.asset(
              'assets/images/back_icon.svg',
            ),
          ),
          centerTitle: true,
          title: SvgPicture.asset(
            'assets/images/logo_header.svg',
            height: 40,
          ),
        ),
        body: Stack(children: [
          Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: 5,
                          top: screenSize.width * 0.08,
                          bottom: screenSize.width * 0.04),
                      child: CustomText(
                        "Forgot Password?",
                        color: ColorsCustom.black,
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 5, right: 5, bottom: 0),
                      child: CustomText(
                        "Enter your phone number and WhatsApp message with the reset link will be sent to you.",
                        color: ColorsCustom.black,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    errorPhoneNumber != "" &&
                            phoneNumberController.text.length <= 0
                        ? ErrorForm(error: errorPhoneNumber)
                        : SizedBox(height: 35),
                    FormText(
                      controller: phoneNumberController,
                      hint: "Phone Number (e.g. 08123456789)",
                      phone: true,
                      keyboard: TextInputType.phone,
                      onChange: clearError,
                      errorMessage: phoneNumberController.text.length > 0
                          ? errorPhoneNumber
                          : "",
                      idError: "phoneNumber",
                    ),
                  ])),
          Positioned(
            bottom: MediaQuery.of(context).viewInsets.bottom == 0 ? 30 : 10,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  CustomButton(
                    text: "Submit",
                    textColor: Colors.white,
                    bgColor: ColorsCustom.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    onPressed: () => onSubmit(),
                  ),
                  MediaQuery.of(context).viewInsets.bottom == 0
                      ? CustomButton(
                          text: "Back to Login",
                          textColor: ColorsCustom.black,
                          fontWeight: FontWeight.w600,
                          flat: true,
                          fontSize: 16,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          onPressed: () => Navigator.pop(context),
                        )
                      : SizedBox(),
                ],
              ),
            ),
          ),
          isLoading
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.white70,
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: Loading(
                      color: ColorsCustom.primary,
                      indicator: BallSpinFadeLoaderIndicator(),
                    ),
                  ),
                )
              : SizedBox()
        ]),
      ),
    );
  }
}
