import 'package:flutter/material.dart';
import 'package:tomas_driver/helpers/utils.dart';
import 'package:tomas_driver/providers/providers.dart';
import './password_reset.dart';

abstract class PasswordResetViewModel extends State<PasswordReset> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController retypePasswordController = TextEditingController();

  String errorRetype = "";
  String errorPassword = "";

  bool isLoading = false;

  void toggleLoading(bool status) {
    setState(() {
      isLoading = status;
    });
  }

  void setError({String type, String value}) {
    setState(() {
      if (type == 'retype') {
        errorRetype = value;
      } else if (type == 'password') {
        errorPassword = value;
      }
      isLoading = false;
    });
  }

  void clearError(String type) {
    setState(() {
      if (type == 'retype') {
        errorRetype = "";
      } else if (type == 'password') {
        errorPassword = "";
      }
    });
  }

  Future<void> onSave() async {
    if (passwordController.text.length <= 0) {
      setError(type: "password", value: "Please fill in your password");
    }
    if (retypePasswordController.text.length <= 0) {
      setError(type: "retype", value: "Please fill in your retype password");
    }
    if (retypePasswordController.text != passwordController.text) {
      setError(
          type: "retype",
          value: "Passwords are not the same, please check again.");
    }
    if (errorRetype == "" && errorPassword == "") {
      toggleLoading(true);
      try {
        dynamic res = await Providers.changePassword(
            driverId:
                passwordController.text.replaceAll(new RegExp(r"\s+"), ""),
            password: passwordController.text);
        if (res.data['message'] == 'SUCCESS') {
          Utils.showSuccessDialog(context,
              title: "Successful",
              desc: "Yeay! your password has been updated.",
              onClick: Navigator.pushNamedAndRemoveUntil(
                  context, '/Sign', (route) => false));
        }
      } catch (e) {
        print(e);
      }
    }
  }
}
