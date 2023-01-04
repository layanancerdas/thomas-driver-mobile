import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/localization/app_translations.dart';
import 'package:tomas_driver/widgets/custom_text.dart';
// import 'package:tomas_driver/widgets/modal_detail_balance.dart';
import './profile.dart';

abstract class ProfileViewModel extends State<Profile> {
  String version = "1.0.0";
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.clear();
    Navigator.pushNamedAndRemoveUntil(context, '/Sign', (route) => false);
  }

  Future<bool> onDialogLogout() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: CustomText(
            AppTranslations.of(context).text("profile_confirmation"),
            color: ColorsCustom.black,
          ),
          content: CustomText(
            AppTranslations.of(context).text("profile_confirmation_message"),
            color: ColorsCustom.generalText,
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                logout();
              },
              child: CustomText(
                AppTranslations.of(context).text("profile_yes"),
                color: ColorsCustom.blueSystem,
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => Navigator.pop(context),
              child: CustomText(
                AppTranslations.of(context).text("profile_no"),
                color: ColorsCustom.blueSystem,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
    return false;
  }

  Future<void> getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      version = packageInfo.version;
    });
  }

  void onPersonalInformationClick() {
    Navigator.pushNamed(context, "/ProfileEdit");
  }

  void onDetailBalance() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return null; //ModalDetailBalance();
        });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // store = StoreProvider.of<AppState>(context);
      getVersion();
    });
  }
}
