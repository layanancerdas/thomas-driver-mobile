import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading/indicator/ball_spin_fade_loader_indicator.dart';
import 'package:loading/loading.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/localization/app_translations.dart';
import 'package:tomas_driver/widgets/custom_button.dart';
import 'package:tomas_driver/widgets/custom_text.dart';
import 'package:tomas_driver/widgets/error_form_text.dart';
import 'package:tomas_driver/widgets/form_text.dart';
import './sign_view_model.dart';

class SignView extends SignViewModel {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: SvgPicture.asset(
              'assets/images/logo_header.svg',
              height: 40,
            ),
          ),
          body: Stack(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: 5,
                          top: screenSize.width * 0.04,
                          bottom: screenSize.width * 0.04),
                      child: CustomText(
                        "Welcome",
                        color: ColorsCustom.black,
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    errorPhoneNumber != "" &&
                            phoneNumberController.text.length <= 0
                        ? ErrorForm(error: errorPhoneNumber)
                        : SizedBox(height: 33),
                    FormText(
                      controller: phoneNumberController,
                      hint:
                          "${AppTranslations.of(context).text("phone_number")} (e.g. 08123456789)",
                      phone: true,
                      keyboard: TextInputType.phone,
                      onChange: clearError,
                      errorMessage: phoneNumberController.text.length > 0
                          ? errorPhoneNumber
                          : "",
                      idError: "phoneNumber",
                    ),
                    errorPassword != "" && passwordController.text.length <= 0
                        ? ErrorForm(error: errorPassword)
                        : SizedBox(height: 33),
                    FormText(
                      controller: passwordController,
                      hint: "${AppTranslations.of(context).text("password")}",
                      keyboard: TextInputType.text,
                      obscureText: true,
                      onChange: clearError,
                      errorMessage: passwordController.text.length > 0
                          ? errorPassword
                          : "",
                      idError: "password",
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            onForgotPassword();
                            // if (widget.mode == 'ldap') {
                            //   const _url =
                            //       'https://hrportal.dev.toyota.co.id/Login';
                            //   await canLaunch(_url)
                            //       ? await launch(_url)
                            //       : throw 'Could not launch $_url';
                            // } else {
                            // Navigator.pushNamed(context, '/ForgotPassword');
                            // }
                          },
                          child: CustomText(
                            "${AppTranslations.of(context).text("forgot_password")}?",
                            color: ColorsCustom.primary,
                            fontSize: 12,
                          ),
                        )
                      ],
                    ),
                    // errorLogin != ""
                    //     ? ErrorForm(error: errorLogin)
                    //     : SizedBox(height: 20),
                  ],
                ),
              ),
              Positioned(
                bottom: MediaQuery.of(context).viewInsets.bottom == 0 ? 30 : 10,
                left: 0,
                right: 0,
                child: CustomButton(
                  text: "${AppTranslations.of(context).text("log_in")}",
                  textColor: Colors.white,
                  bgColor: ColorsCustom.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  onPressed: () => onLogin(),
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
            ],
          ),
        ));
  }
}
