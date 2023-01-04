import 'package:flutter/material.dart';
import 'package:tomas_driver/screens/contact_us/contact_us.dart';
import 'package:tomas_driver/screens/detail_trip/detail_trip.dart';
import 'package:tomas_driver/screens/faq/faq.dart';
import 'package:tomas_driver/screens/forgot_password/forgot_password.dart';
import 'package:tomas_driver/screens/home/home.dart';
import 'package:tomas_driver/screens/language/language.dart';
import 'package:tomas_driver/screens/my_activities/my_activities.dart';
import 'package:tomas_driver/screens/password_reset/password_reset.dart';
import 'package:tomas_driver/screens/profile/profile.dart';
import 'package:tomas_driver/screens/sign/sign.dart';
import 'package:tomas_driver/screens/notifications/notifications.dart';
import 'package:tomas_driver/screens/live_tracking/live_tracking.dart';
import 'package:tomas_driver/screens/viewmap/view_map.dart';
import 'package:tomas_driver/widgets/qr_scan.dart';
import 'screens/faq/faq.dart';
import 'screens/language/language.dart';

final Map<String, WidgetBuilder> routes = {
  '/Sign': (BuildContext context) => Sign(),
  '/ForgotPassword': (BuildContext context) => ForgotPassword(),
  '/PasswordReset': (BuildContext context) => PasswordReset(),
  '/Profile': (BuildContext context) => Profile(),
  '/ContactUs': (BuildContext context) => ContactUs(),
  '/Notifications': (BuildContext context) => Notifications(),
  '/MyActivities': (BuildContext context) => MyActivities(),
  "/DetailTrip": (BuildContext context) => DetailTrip(),
  "/Faq": (BuildContext context) => Faq(),
  "/Language": (BuildContext context) => Language(),
  "/LiveTracking": (BuildContext context) => LiveTracking(),
  "/ViewMap": (BuildContext context) => ViewMap(),
  '/Home': (BuildContext context) => Home(),
};
