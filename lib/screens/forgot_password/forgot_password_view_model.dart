import 'package:flutter/material.dart';
import 'package:tomas_driver/helpers/utils.dart';
import 'package:tomas_driver/providers/providers.dart';
import './forgot_password.dart';

abstract class ForgotPasswordViewModel extends State<ForgotPassword> {
  TextEditingController phoneNumberController = TextEditingController();

  String errorPhoneNumber = "";

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
      }
      isLoading = false;
    });
  }

  void clearError(String type) {
    setState(() {
      if (type == 'phoneNumber') {
        errorPhoneNumber = "";
      }
    });
  }

  Future<void> onSubmit() async {
    toggleLoading(true);
    try {
      dynamic res = await Providers.forgotPassword(
          phoneNumber:
              phoneNumberController.text.replaceAll(new RegExp(r"\s+"), ""));

      if (res.data['code'] == 'SUCCESS') {
        toggleLoading(false);

        Utils.showSuccessDialog(context,
            title: "Whatsapp Link Sent",
            desc:
                "We sent a Whatsapp message to ${phoneNumberController.text} with a link to get back into your account.");
      }
    } catch (e) {
      print(e.toString());
    } finally {
      toggleLoading(false);
    }
  }
}
