import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:tomas_driver/providers/providers.dart';
import 'package:tomas_driver/widgets/custom_dialog.dart';
// import 'package:tomas_driver/widgets/custom_text.dart';
import 'package:tomas_driver/widgets/error_page.dart';
import 'package:tomas_driver/widgets/modal_no_internet.dart';

// import 'colors_custom.dart';

class Utils {
  // static DateFormat formatterTime = DateFormat('HH:mm');
  // static DateFormat formatterDate = DateFormat('E, dd MMM');
  // static DateFormat formatterDateMonth = DateFormat('dd MMM');
  // static DateFormat formatterDateWithYear = DateFormat('E, dd MMM yyyy');
  // static DateFormat formatterDateLong = DateFormat('E, dd MMMM, HH:mm a');
  // static DateFormat formatterDateCompleted =
  //     DateFormat('E, dd MMMM yyyy, HH:mm a');
  // static DateFormat formatterDateFirst = DateFormat('MMM, dd yyyy');
  // static DateFormat formatterDateGeneral = DateFormat('dd MMM yyyy');
  // static DateFormat formatterDateVertical = DateFormat('E,\ndd MMM');
  static NumberFormat currencyFormat = new NumberFormat("#,##0", "en_US");

  static String inCaps(String value) =>
      '${value[0].toUpperCase()}${value.substring(1)}';
  static String allInCaps(String value) => value.toUpperCase();
  static String capitalizeFirstofEach(String value) => value
      .split(" ")
      .map((str) => str[0].toUpperCase() + str.substring(1))
      .join(" ");

  static void showSuccessDialog(BuildContext context,
      {String title, String desc, onClick}) {
    showDialog(
        context: context,
        builder: (_) => CustomDialog(
            image: "success_icon.svg",
            title: title,
            desc: desc,
            onClick: () => onClick ?? Navigator.pop(context)));
  }

  static onErrorConnection(type, {GlobalKey<NavigatorState> navigatorKey}) {
    if (type == 'modal_connection') {
      showModalBottomSheet(
          context: navigatorKey.currentContext,
          builder: (BuildContext context) {
            return ModalNoInternet();
          });
    } else if (type == 'fullpage_connection') {
      navigatorKey.currentState.push(MaterialPageRoute(
          builder: (_) => ErrorPage(mode: "connection"),
          fullscreenDialog: true));
    } else if (type == 'fullpage_maintenance') {
      navigatorKey.currentState.push(MaterialPageRoute(
          builder: (_) => ErrorPage(mode: "maintenance"),
          fullscreenDialog: true));
    }
  }
}
