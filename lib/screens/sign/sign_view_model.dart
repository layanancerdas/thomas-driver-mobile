import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/helpers/push_notification_service.dart';
import 'package:tomas_driver/localization/app_translations.dart';
import 'package:tomas_driver/providers/providers.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:tomas_driver/providers/providers.dart';
import 'package:tomas_driver/screens/home/home.dart';
import 'package:tomas_driver/widgets/custom_toast.dart';
import './sign.dart';

abstract class SignViewModel extends State<Sign> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final PushNotificationService pushNotificationService =
      PushNotificationService();

  // String countryCode = "+62";
  String errorPassword = "";
  String errorPhoneNumber = "";
  String errorLogin = "";

  bool isLoading = false;

  void toggleLoading(bool status) {
    setState(() {
      isLoading = status;
    });
  }

  void setError({String type, String value}) {
    setState(() {
      if (type == 'phoneNumber') {
        errorPhoneNumber = value;
      } else if (type == 'password') {
        errorPassword = value;
      } else if (type == 'login') {
        errorLogin = value;
      }
      isLoading = false;
    });

    // showDialog(
    //   context: context,
    //   barrierColor: Colors.white24,
    //   builder: (BuildContext context) {
    //     return CustomToast(
    //       image: "warning.svg",
    //       title: value,
    //       color: ColorsCustom.danger,
    //       duration: Duration(seconds: 1),
    //     );
    //   });
  }

  void clearError(String type) {
    setState(() {
      if (type == 'phoneNumber') {
        errorPhoneNumber = "";
      } else if (type == 'password') {
        errorPassword = "";
      }
    });
  }

  void onForgotPassword() {
    showDialog(
        context: context,
        barrierColor: Colors.white24,
        builder: (BuildContext context) {
          return CustomToast(
            title: AppTranslations.of(context).currentLanguage == 'id'
                ? "Silakan hubungi admin Anda di 08118409615 atau klik di sini jika Anda ingin mereset kata sandi Anda."
                : "Please contact your admin at 08118409615 or click here if you want to reset your password.",
            color: ColorsCustom.primary,
            duration: Duration(seconds: 1),
            isForgotPassword: true,
          );
        });
  }

  Future<void> onLogin() async {
    if (phoneNumberController.text.length <= 0) {
      setError(
          type: "phoneNumber",
          value: AppTranslations.of(context).currentLanguage == 'id'
              ? "Mohon Isi Nomor Handphone Anda"
              : "Please fill in your phone number");
    }
   if (phoneNumberController.text.length < 7 ||
        !RegExp(r'^[0]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$').hasMatch(
            phoneNumberController.text.replaceAll(new RegExp(r"\s+"), ""))) {
      setError(
          type: "phoneNumber",
          value: AppTranslations.of(context).currentLanguage == 'id'
              ? "Nomor ponsel tidak valid"
              : "Invalid phone number");
    }
    if (passwordController.text.length <= 0) {
      setError(
          type: "password",
          value: AppTranslations.of(context).currentLanguage == 'en'
              ? "Please fill in your password"
              : "Mohon isi form kata sandi anda");
    }
    print("errorPhoneNumber");
    print(errorPhoneNumber);
    print("errorPassword");
    print(errorPassword);
    if (errorPhoneNumber == "" && errorPassword == "") {
      toggleLoading(true);
      try {
        dynamic res = await Providers.signIn(
            phoneNumber:
                phoneNumberController.text.replaceAll(new RegExp(r"\s+"), ""),
            password: passwordController.text);
        if (res.data['message'] == 'SUCCESS') {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwtToken', res.data['data']['token']);
          await prefs.setString('driverId', res.data['data']['driver_id']);

          await pushNotificationService.getFirebaseToken();

          // Navigator.push(context, MaterialPageRoute(builder: (_) => Home()));
          // showDialog(
          //     context: context,
          //     barrierColor: Colors.white24,
          //     builder: (BuildContext context) {
          //       return CustomToast(
          //         image: "success_icon_white.svg",
          //         title: "Login Success",
          //         color: ColorsCustom.green,
          //         duration: Duration(seconds: 1),
          //       );
          //     });

          Navigator.pushNamedAndRemoveUntil(
              context, '/Home', (Route<dynamic> route) => false);
        } else {
          print('${res.data['message']}');
          print(res.data['message']);
          if (res.data['message'].toString().toLowerCase().contains("phone number")) {
            setError(type: "phoneNumber", value: "Your phone number is not registered");
          } else
          if (res.data['message'].contains("user")) {
          setError(
              type: "phoneNumber",
              value: "Your phone number is not registered");
          } else
           if (res.data['message'].contains("password")) {
            setError(type: "password", value: "Your password is wrong");
          }
          // } else {
          //   setError(type: "login", value: res.data['message']);
          // }
        }
      } catch (e) {
        print(e);
        setError(type: "login", value: e);
      } finally {
        toggleLoading(false);
      }
    }
  }
}
