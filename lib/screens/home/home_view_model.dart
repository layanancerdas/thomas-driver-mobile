import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:geocoding/geocoding.dart';
// import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tomas_driver/localization/app_translations.dart';
import 'package:tomas_driver/redux/actions/ajk_action.dart';
import 'package:tomas_driver/redux/actions/user_action.dart';
import 'package:tomas_driver/redux/app_state.dart';
// import 'package:location_permissions/location_permissions.dart';
import 'package:tomas_driver/screens/my_activities/my_activities.dart';
import 'package:tomas_driver/widgets/modal_no_location.dart';
import './home.dart';
import 'package:tomas_driver/screens/profile/profile.dart';
import 'package:tomas_driver/screens/notifications/notifications.dart';
import 'package:tomas_driver/providers/providers.dart';
import 'package:intl/intl.dart';

abstract class HomeViewModel extends State<Home> {
  Store<AppState> store;
  StreamSubscription<Position> positionStream;
  DateTime now = new DateTime.now();
  bool isLoadingTrip = false;
  bool isHaveNewNotif = false;

  List<Map> children = [
    {
      "name": "home_menu_home",
    },
    {
      "name": "home_menu_activity",
      "page": MyActivities(index: 0),
    },
    {
      "name": "home_menu_notification",
      "page": Notifications(),
    },
    {
      "name": "home_menu_account",
      "page": Profile(),
    },
  ];

  int currentIndex = 0;

  List<Placemark> placemark = List();
  List tripPerDay = [];

  bool isLoading = false;

  String fotoProfile = "";
  String userName = "";

  String month1 = "";
  String month2 = "";
  String vYear = "";

  void toggleLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
    getTripByDriverId(
        DateTime(now.year, now.month, now.day)
            .millisecondsSinceEpoch
            .toString(),
        DateTime(now.year, now.month, now.day + 1)
            .subtract(Duration(seconds: 1))
            .millisecondsSinceEpoch
            .toString());
    if (index == 0) {
      checkFirstTrip();
    }
  }

  void toggleNewNotif(bool value) {
    // print(value);
    setState(() {
      isHaveNewNotif = value;
    });
  }

  // Future<void> getCurrentLocation() async {
  //   try {
  //     Position position = await Geolocator.getCurrentPosition(
  //         desiredAccuracy: LocationAccuracy.best);
  //     List<Placemark> _placemark =
  //         await placemarkFromCoordinates(position.latitude, position.longitude);

  //     setState(() {
  //       placemark = _placemark;
  //     });
  //   } catch (e) {
  //     print(e);
  //   } finally {
  //     toggleLoading(false);
  //   }
  // }

  // void locationListener(Position position) {}

  Future listenForPermissionStatus() async {
    try {
      LocationPermission permission;

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        await showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return ModalNoLocation(
                mode: 'permission',
              );
            });
      }
    } catch (e) {
      print(e);
    } finally {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        await showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return ModalNoLocation();
            });
      }
    }
  }

  List monthArray = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  List monthArrayId = [
    "Januari",
    "Februari",
    "Maret",
    "April",
    "Mei",
    "Juni",
    "Juli",
    "Agustus",
    "September",
    "Oktober",
    "November",
    "Desember"
  ];

  Future<void> checkFirstTrip() async {
    // print('-------------------------- Check First Trip ---------------------------------');
    var nowDate = DateTime.now();
    var isStopped = false;
    for (int i = 0; i < 7; i++) {
      if (DateFormat('EEEE', "en_US").format(nowDate.add(Duration(days: i))) !=
              "Sunday" &&
          DateFormat('EEEE', "en_US").format(nowDate.add(Duration(days: i))) !=
              "Saturday") {
        // date.add({
        //     'id': date.length,
        //     'date': nowDate.add(Duration(days: i)).day,
        //     'day': DateFormat.E().format(nowDate.add(Duration(days: i))),
        //     'days': DateFormat.EEEE().format(nowDate.add(Duration(days: i))),
        //     'month': DateFormat.MMMM().format(nowDate.add(Duration(days: i))),
        //     'year': nowDate.add(Duration(days: i)).year,
        //     'isToday': isToday
        // });

        var newMA = AppTranslations.of(context).currentLanguage == 'id'
            ? monthArrayId
            : monthArray;

        var vDate = nowDate.add(Duration(days: i)).day.toString().length == 1
            ? "0${nowDate.add(Duration(days: i)).day}"
            : "${nowDate.add(Duration(days: i)).day}";
        var vMonth = newMA.indexOf(
                DateFormat.MMMM().format(nowDate.add(Duration(days: i)))) +
            1;
        var finalVMonth =
            vMonth.toString().length == 1 ? "0$vMonth" : "$vMonth";

        var stringDate =
            "${nowDate.add(Duration(days: i)).year}-$finalVMonth-$vDate";
        // print(stringDate);
        // print(DateTime.parse(stringDate+" 00:00:00.000").millisecondsSinceEpoch.toString());

        if ((i == 0 || i == 1 || i == 2) && month1 == "") {
          // print(AppTranslations.of(context).text("${monthTranslate[vMonth-1]['value']}"));
          setState(() {
            month1 =
                DateFormat.MMMM(AppTranslations.of(context).currentLanguage)
                        .format(nowDate.add(Duration(days: i))) +
                    (nowDate.add(Duration(days: i + 5)).month !=
                            nowDate.add(Duration(days: i)).month
                        ? (" - " +
                            DateFormat.MMMM(
                                    AppTranslations.of(context).currentLanguage)
                                .format(nowDate.add(Duration(days: 5))))
                        : "");
          });
        } else {}
        if (mounted) {
          setState(() {
            vYear = nowDate.add(Duration(days: i)).year.toString();
          });
        }

        if (!isStopped) {
          getTripByDriverId(
              DateTime.parse(stringDate + " 00:00:00.000")
                  .millisecondsSinceEpoch
                  .toString(),
              DateTime.parse(stringDate + " 23:59:59.000")
                  .millisecondsSinceEpoch
                  .toString());
        }
        isStopped = true;
      }
    }
  }

  Future<void> getTripByDriverId(String startDate, String endDate) async {
    setState(() {
      isLoadingTrip = true;
    });

    try {
      dynamic res = await Providers.getBookingByDriverId(
          startDate: startDate, endDate: endDate);
      if (res.data['message'] == 'SUCCESS') {
        print('berhasil');
        List _data = res.data['data'];

        _data.sort((a, b) => b['status'].compareTo(a['status']));

        // await store.dispatch(SetMyTrip(myTrip: ));
        setState(() {
          tripPerDay = _data;
          isLoadingTrip = false;
        });
      }
    } catch (e) {
      print(e);
      // setError(type: "login", value: e);
    }
  }

  Future<void> getProfile() async {
    try {
      dynamic res = await Providers.getUserDetail(
          // startDate: startDate,
          // endDate: endDate
          //1628208000000
          );
      if (res.data['message'] == 'SUCCESS') {
        store.dispatch(SetUserDetail(userDetail: res.data['data']));

        setState(() {
          fotoProfile = res.data['data']['photo'];
          userName = res.data['data']['name'];
        });
        // SharedPreferences prefs = await SharedPreferences.getInstance();
        // await prefs.setString('jwtToken', res.data['data']['token']);
        // await prefs.setString('driverId', res.data['data']['driver_id']);

        // Navigator.push(context, MaterialPageRoute(builder: (_) => Home()));
      } else {
        // if (res.data['message'].contains("phone_number")) {
        //   setError(type: "phoneNumber", value: "Invalid phone number");
        // } else if (res.data['message'].contains("user")) {
        //   setError(
        //       type: "phoneNumber",
        //       value: "Your phone number is not registered");
        // }
      }
    } catch (e) {
      print(e);
      // setError(type: "login", value: e);
    } finally {
      // toggleLoading(false);
    }
  }

  Future<void> checkNotif() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // print("new_notifications");
    // print(prefs.getBool('new_notifications'));
    if (prefs.getBool('new_notifications') != null) {
      toggleNewNotif(prefs.getBool('new_notifications'));
    }
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
        // getTripByDriverId(
        //     DateTime.parse(store.state.ajkState.resolveDate['start_date'])
        //         .millisecondsSinceEpoch
        //         .toString(),
        //     DateTime.parse(store.state.ajkState.resolveDate['end_date'])
        //         .millisecondsSinceEpoch
        //         .toString());
        getTripByDriverId(
            DateTime(now.year, now.month, now.day)
                .millisecondsSinceEpoch
                .toString(),
            DateTime(now.year, now.month, now.day + 1)
                .subtract(Duration(seconds: 1))
                .millisecondsSinceEpoch
                .toString());
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> initData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jwtToken = prefs.getString("jwtToken");
    if (jwtToken != null) {
      getUserDetail();
      getResolveDate();
    }
  }

  @override
  void initState() {
    super.initState();
    currentIndex = widget.index;
    getProfile();
    initData();
    print('init');
    getTripByDriverId(
        DateTime(now.year, now.month, now.day)
            .millisecondsSinceEpoch
            .toString(),
        DateTime(now.year, now.month, now.day + 1)
            .subtract(Duration(seconds: 1))
            .millisecondsSinceEpoch
            .toString());

    Timer.periodic(Duration(seconds: 5), (_) {
      checkNotif();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      store = StoreProvider.of<AppState>(context);
      // checkFirstTrip();
      checkNotif();

      Future.delayed(Duration(milliseconds: 5), () {
        listenForPermissionStatus();
        checkFirstTrip();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (positionStream != null) {
      positionStream.cancel();
      positionStream = null;
    }
  }
}
