import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tomas_driver/configs/config.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/helpers/utils.dart';
import 'package:tomas_driver/localization/app_translations.dart';
import 'package:tomas_driver/providers/providers.dart';
import 'package:tomas_driver/redux/actions/ajk_action.dart';
import 'package:tomas_driver/redux/actions/general_action.dart';
import 'package:tomas_driver/redux/actions/user_action.dart';
import 'package:tomas_driver/redux/app_state.dart';
import 'package:tomas_driver/widgets/custom_text.dart';
import 'package:tomas_driver/widgets/error_page.dart';
import 'package:tomas_driver/widgets/modal_lost_connection.dart';
import './lifecycle_manager.dart';

abstract class LifecycleManagerViewModel extends State<LifecycleManager> {
  Store<AppState> store;
  final Connectivity _connectivity = Connectivity();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  bool permissionLocation = false;
  bool maintenance = false;
  bool noInternet = false;
  bool isLoading = false;

  void toggleIsLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  void toggleNoInternet(bool value) {
    setState(() {
      noInternet = value;
    });
  }

  void toggleMaintenance(bool value) {
    setState(() {
      maintenance = value;
    });
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        toggleNoInternet(false);
        break;
      case ConnectivityResult.mobile:
        toggleNoInternet(false);
        break;
      case ConnectivityResult.none:
        if (!noInternet) {
          Utils.onErrorConnection("modal_connection",
              navigatorKey: widget.navigatorKey);
          toggleNoInternet(true);
        }
        break;
      default:
        toggleNoInternet(false);
        break;
    }
  }

  Future<void> checkInternet() async {
    try {
      final result = await InternetAddress.lookup('www.google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // print('connected');
        toggleNoInternet(false);
      }
    } on SocketException catch (e) {
      print(e);
      if (!noInternet) {
        Utils.onErrorConnection("fullpage_connection",
            navigatorKey: widget.navigatorKey);
        toggleNoInternet(true);
      }
    } catch (e) {
      print(e);
    } finally {
      checkBE();
    }
  }

  Future<void> checkBE() async {
    try {
      final result = await InternetAddress.lookup(
          DEV ? 'tomas-api-dev.geekco.id' : "tomas-api.toyota.co.id");
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // print('connected');
        toggleMaintenance(false);
      }
    } on SocketException catch (e) {
      print(e);
      if (!maintenance && !noInternet) {
        Utils.onErrorConnection("fullpage_maintenance",
            navigatorKey: widget.navigatorKey);
        toggleMaintenance(true);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> getTripByDriverId(String startDate, String endDate) async {
    try {
      dynamic res = await Providers.getBookingByDriverId(
          startDate: startDate, endDate: endDate);
      if (res.data['message'] == 'SUCCESS') {
        await store.dispatch(SetMyTrip(myTrip: res.data['data']));
      }
    } catch (e) {
      print(e);
      // setError(type: "login", value: e);
    } finally {
      // toggleLoading(false);

    }
  }

  Future initNotification() async {
    if (Platform.isIOS) {
      _fcm.requestPermission(badge: true, sound: true);
    }

    // store = StoreProvider.of(context);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      // _fcm.configure(
      //   onMessage: (Map<String, dynamic> message) async {
      //     // print("onMessage: $message");
      //     try {
      //       print("2");

      //       prefs.setBool("new_notifications", true);
      //       print("3");
      //       showSimpleNotification(
      //           CustomText(
      //             message['notification']['title'],
      //             fontSize: 14,
      //             fontWeight: FontWeight.w500,
      //             color: ColorsCustom.black,
      //           ),
      //           subtitle: CustomText(
      //             message['notification']['body'],
      //             fontSize: 12,
      //             fontWeight: FontWeight.w400,
      //             color: ColorsCustom.black,
      //           ),
      //           trailing: IconButton(
      //               icon: Icon(
      //                 Icons.close,
      //                 color: ColorsCustom.black,
      //               ),
      //               onPressed: () {
      //                 OverlaySupportEntry.of(context).dismiss();
      //               }),
      //           background: Colors.white,
      //           elevation: 4,
      //           duration: Duration(seconds: 4));
      //       await getDataNotif();
      //       // await getNotifications();
      //       // await getBookingData();
      //       // await getUserDetail();
      //       // await getUserBalance();
      //       if (store.state.ajkState.selectedMyTrip.containsKey("booking_id")) {
      //         // await DetailTrip.of(context).onRefresh();
      //       }
      //     } catch (e) {
      //       print(e);
      //     } finally {
      //       toggleIsLoading(false);
      //     }
      //   },
      //   onBackgroundMessage: myBackgroundMessageHandler,
      //   onLaunch: (Map<String, dynamic> message) async {
      //     // print("onLaunch: $message");
      //     prefs.setBool("new_notifications", true);
      //     await getDataNotif();
      //     // onHandlePage(
      //     //     message: message, navigatorKey: navigatorKey, store: store);
      //     // _navigateToItemDetail(message);
      //   },
      //   onResume: (Map<String, dynamic> message) async {
      //     // print("onResume: $message");
      //     prefs.setBool("new_notifications", true);
      //     await getDataNotif();
      //     // onHandlePage(
      //     //     message: message, navigatorKey: navigatorKey, store: store);
      //     // _navigateToItemDetail(message);
      //   },
      // );
    } catch (e) {
      print(e);
    }
  }

  static Future<void> myBackgroundMessageHandler(
      Map<String, dynamic> message) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setBool("new_notifications", true);
    if (message.containsKey('data')) {
      // Handle data message
      // final dynamic data = message['data'];
    }

    if (message.containsKey('notification')) {
      // Handle notification message
      // final dynamic notification = message['notification'];
    }

    // Or do other work.
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result = ConnectivityResult.none;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> getUserDetail() async {
    try {
      dynamic res = await Providers.getUserDetail();
      // print(res.data['data']);
      store.dispatch(SetUserDetail(userDetail: res.data['data']));
    } catch (e) {
      print(e);
    }
  }

  Future<void> getResolveDate() async {
    try {
      dynamic res = await Providers.getResolveDate();
      if (res.data['code'] == 'SUCCESS') {
        store.dispatch(SetResolveDate(resolveDate: res.data['data']));
        getTripByDriverId(
            DateTime.parse(store.state.ajkState.resolveDate['start_date'])
                .millisecondsSinceEpoch
                .toString(),
            DateTime.parse(store.state.ajkState.resolveDate['end_date'])
                .millisecondsSinceEpoch
                .toString());
      }
    } catch (e) {
      print(e);
    }
  }

  // Future<void> getNotification() async {
  //   try {
  //     dynamic res = await Providers.getNotifByUserId(limit: 10, offset: 0);

  //     store.dispatch(SetNotifications(
  //         notifications: res.data['data'],
  //         limitNotif: store.state.generalState.limitNotif + 10));
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  Future<void> getDataNotif() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("jwtToken");
    if (jwtToken != null) {
      getUserDetail();
      getResolveDate();
      getNotifications();
    }
  }

  Future<void> initData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("jwtToken");
    if (jwtToken != null) {
      getUserDetail();
      getResolveDate();
      getNotifications();
    }
  }

  Future<void> initPeriodic() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("jwtToken");

    if (!maintenance) {
      checkBE();
    }

    if (jwtToken != null && !noInternet && !maintenance) {
      getUserDetail();
    }
  }

  Future<void> getNotifications() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      dynamic res = await Providers.getNotifByUserId(
          limit: store.state.generalState.limitNotif, offset: 0);
      // if (!store.state.generalState.disableNavbar) {
      List _temp = res.data['data']
          .where((e) => e['is_active'].toString() == 'true')
          .toList();
      List _tempRead = res.data['data']
          .where((e) => e['is_read'].toString() == 'false')
          .toList();

      if (_temp.length <= 0) {
        prefs.setBool("new_notifications", false);
      }

      if (_tempRead.length > 0) {
        prefs.setBool("new_notifications", true);
      } else {
        prefs.setBool("new_notifications", false);
      }
      store.dispatch(SetNotifications(notifications: _temp));
      // }

      // if (res.data['data'].length >
      //     store.state.generalState.notifications.length) {
      //   prefs.setBool("new_notifications", true);
      // } else {
      //   prefs.setBool("new_notifications", false);
      // }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    initConnectivity();
    checkInternet();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    Timer.periodic(Duration(seconds: 5), (_) {
      checkInternet();
      initPeriodic();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      store = StoreProvider.of<AppState>(context);
      initNotification();
      initData();
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
