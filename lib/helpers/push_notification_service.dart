import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tomas_driver/providers/providers.dart';
import 'package:tomas_driver/redux/app_state.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  // SharedPreferences prefs;
  // Store<AppState> store;

  Future getFirebaseToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _fcm.getToken().then((token) {
      if (prefs.getString("jwtToken") != null) {
        String language =
            prefs.getString('language') == 'id' ? "INDONESIA" : "ENGLISH";
        setSubscribe(token, language ?? "ENGLISH");
      }
    });
  }

  static Future<void> setSubscribe(
      String firebaseToken, String language) async {
    try {
      dynamic res = await Providers.subscribeNotification(
          firebaseToken: firebaseToken, language: language);
    } catch (e) {
      print(e);
    }
  }

  static Future<void> onHandlePage(
      {Map<String, dynamic> message,
      GlobalKey<NavigatorState> navigatorKey,
      Store<AppState> store}) async {
    Map data = await jsonDecode(message['data']);
    String typeNotif = data['type'];

    if (typeNotif.toLowerCase() == 'waiting_payment') {
      // navigatorKey.currentState.push(MaterialPageRoute(
      //     builder: (_) => Payment(
      //           goToFinish: true,
      //           // detail: true,
      //           mode: 'unfinish',
      //         )));
    } else if (typeNotif.toLowerCase() == 'reminder_upcoming_trip' ||
        typeNotif.toLowerCase() == 'order_canceled' ||
        typeNotif.toLowerCase() == 'driver_on_the_way' ||
        typeNotif.toLowerCase() == 'driver_has_arrived' ||
        typeNotif.toLowerCase() == 'arrived_at_destination' ||
        typeNotif.toLowerCase() == 'you_missed_trip') {
      // navigatorKey.currentState.pushNamed("/DetailTrip");
    } else if (typeNotif.toLowerCase() == 'payment_confirmed') {
      // navigatorKey.currentState.push(MaterialPageRoute(
      //     builder: (_) => Payment(
      //           mode: 'finish',
      //           fromDeeplink: true,
      //         )));
    } else if (typeNotif.toLowerCase() == 'reminder_for_feedback') {
      if (store.state.ajkState.selectedMyTrip['rating'] == null &&
          store.state.ajkState.selectedMyTrip['review'] == null) {
        // navigatorKey.currentState.push(MaterialPageRoute(
        //     builder: (_) => Review(
        //           dataNotif: data,
        //         ),
        //     fullscreenDialog: true));
      }
    } else if (typeNotif.toLowerCase() == 'request_ajk_accepted') {
      navigatorKey.currentState.pushNamed('/SearchAjkShuttle');
    }
  }
}
