import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/localization/app_translations.dart';
// ignore: unused_import
import 'package:tomas_driver/providers/providers.dart';
import 'package:tomas_driver/redux/actions/ajk_action.dart';
// ignore: unused_import
import 'package:tomas_driver/redux/actions/user_action.dart';
import 'package:tomas_driver/redux/app_state.dart';
import 'package:tomas_driver/widgets/custom_text.dart';
import 'package:tomas_driver/widgets/custom_toast.dart';
import './detail_trip.dart';

import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';

abstract class DetailTripViewModel extends State<DetailTrip> {
  Store<AppState> store;
  ScrollController scrollController = ScrollController();
  String countdown = "00:00:00";
  NumberFormat timeFormat = new NumberFormat("00");

  // String statusButtonName = 'Start Trip xx';
  // String statusNameGlobal = "";

  bool onBottom = false;
  bool isWarningButton = false;

  bool isLoading = false;

  bool isOngoing = false;
  bool isTripAvailable = false;
  bool isStart = false;

  final databaseReference = FirebaseDatabase.instance.reference();

  void createData(double lat, double lng) async {
    var tripOrderId =
        await store.state.ajkState.selectedMyTrip["trip_order_id"];
    databaseReference
        .child("live_location/${tripOrderId}")
        .set({'lat': lat, 'lng': lng});
  }

  void readData() async {
    var tripOrderId =
        await store.state.ajkState.selectedMyTrip["trip_order_id"];
    databaseReference
        .child("live_location/${tripOrderId}")
        .once()
        .then((snapshot) {
      if (snapshot != null) {
        setState(() {
          isTripAvailable = true;
        });
      }
    });
  }

  void updateData(double lat, double lng) async {
    var tripOrderId =
        await store.state.ajkState.selectedMyTrip["trip_order_id"];
    databaseReference
        .child("live_location/${tripOrderId}")
        .update({'lat': lat, 'lng': lng});
  }

  void deleteData() async {
    var tripOrderId =
        await store.state.ajkState.selectedMyTrip["trip_order_id"];
    databaseReference.child("live_location/$tripOrderId").remove();
  }

  Future<void> onWarningButtonClicked() async {
    setState(() {
      isWarningButton = true;
    });

    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        isWarningButton = false;
      });
    });
  }

  _getCurrentLocation() async {
    Position _currentPosition = await Geolocator.getCurrentPosition();

    // setState(() {
    //   _currentPosition = _geolocator;
    // })

    readData();

    if (isTripAvailable) {
      updateData(_currentPosition.latitude, _currentPosition.longitude);
    } else {
      createData(_currentPosition.latitude, _currentPosition.longitude);
    }
  }

  void toggleLoading(bool status) {
    setState(() {
      isLoading = status;
    });
  }

  void getCountdown() {
    if (store.state.ajkState.selectedMyTrip.containsKey('created_date')) {
      DateTime getExpiredTime = DateTime.fromMillisecondsSinceEpoch(
              int.parse(store.state.ajkState.selectedMyTrip['created_date']))
          .add(Duration(days: 1));

      setState(() {
        countdown =
            "${timeFormat.format(getExpiredTime.difference(DateTime.now()).inHours % 24)}:${timeFormat.format(getExpiredTime.difference(DateTime.now()).inMinutes % 60)}:${timeFormat.format(getExpiredTime.difference(DateTime.now()).inSeconds % 60)}";
      });
    }
  }

  void onPaymentInstructionsClick() {
    Navigator.pushNamed(context, '/Payment');
  }

  void toggleStatusNameGlobal(String value) {
    store.dispatch(SetStatusSelectedTrip(statusSelectedTrip: value));
  }

  void toggleButtonNameGlobal(String value) {
    store.dispatch(SetButtonSelectedTrip(buttonSelectedTrip: value));
  }

  void toggleSetLastHistorySelectedTrip(Map value) {
    store.dispatch(SetLastHistoryTransation(lastHistorySelectedTrip: value));
  }

  Future<void> statusHandler() async {
    if (store == null) {
      return;
    }
    toggleLoading(true);

    try {
      await buttonNameHandler();
      if (store.state.ajkState.selectedMyTrip['status'] == 'ASSIGNED') {
        toggleStatusNameGlobal(
            AppTranslations.of(context).currentLanguage == 'en'
                ? 'Assigned'
                : 'Ditugaskan');
      } else if (store.state.ajkState.selectedMyTrip['status'] == 'COMPLETED') {
        toggleStatusNameGlobal(
            AppTranslations.of(context).currentLanguage == 'en'
                ? 'Completed'
                : 'Selesai');
      } else {
        List _sortingTripHistory =
            store.state.ajkState.selectedMyTrip['trip_histories'];

        _sortingTripHistory
            .sort((a, b) => a['created_date'].compareTo(b['created_date']));

        Map lastTripHistories =
            _sortingTripHistory[_sortingTripHistory.length - 1];

        List _pickupPoint = store.state.ajkState.selectedMyTrip['trip']
            ['trip_group']['route']['pickup_points'];

        toggleSetLastHistorySelectedTrip(lastTripHistories);

        // if (_sortingTripHistory.length <= 0) {
        //   toggleButtonNameGlobal(
        //       "${AppTranslations.of(context).currentLanguage == 'en' ? 'Start Trip' : 'Mulai Trip'}");
        // }

        if (lastTripHistories['pickup_point_id'] != null) {
          Map _filterPickupPoint = _pickupPoint.firstWhere((element) =>
              element['pickup_point_id'] ==
              lastTripHistories['pickup_point_id']);

          if (lastTripHistories.containsValue('HEADING') ||
              lastTripHistories.containsValue('HEADING_TO_DESTINATION')) {
            toggleStatusNameGlobal(
                "${AppTranslations.of(context).currentLanguage == 'en' ? 'Heading to' : 'Menuju'} ${_filterPickupPoint['name']}");
          } else {
            toggleStatusNameGlobal(
                "${AppTranslations.of(context).currentLanguage == 'en' ? 'Arrived at' : 'Sampai di'} ${_filterPickupPoint['name']}");
          }
        } else {
          if (lastTripHistories.containsValue('HEADING') ||
              lastTripHistories.containsValue('HEADING_TO_DESTINATION')) {
            toggleStatusNameGlobal(
                "${AppTranslations.of(context).currentLanguage == 'en' ? 'Heading to' : 'Menuju'} ${store.state.ajkState.selectedMyTrip['trip']['trip_group']['route']['destination_name']}");
          } else {
            toggleStatusNameGlobal(
                "${AppTranslations.of(context).currentLanguage == 'en' ? 'Arrived at' : 'Sampai di'} ${store.state.ajkState.selectedMyTrip['trip']['trip_group']['route']['destination_name']}");
          }
        }
      }

      if (store.state.ajkState.statusSelectedTrip ==
          "${AppTranslations.of(context).currentLanguage == 'en' ? 'Arrived at' : 'Sampai di'} ${store.state.ajkState.selectedMyTrip['trip']['trip_group']['route']['destination_name']}") {
        setState(() {
          isOngoing = false;
        });
      } else {
        setState(() {
          isOngoing = true;
        });
      }
    } catch (e) {
      print(e);
    } finally {
      toggleLoading(false);
    }
  }

  String checkVia(String value) {
    String _name;

    if (value.contains("(Via")) {
      int startIndex = value.indexOf("(Via");
      int endIndex = value.indexOf(")", startIndex + 4);
      // String gotData = value.substring(startIndex + 4, endIndex);
      _name = value.replaceRange(startIndex, endIndex + 1, "");
    } else {
      _name = value;
    }

    return _name;
  }

  Future<void> buttonNameHandler() async {
    try {
      String tripType = store.state.ajkState.selectedMyTrip['trip']['type'];
      String destinationName = store.state.ajkState.selectedMyTrip['trip']
          ['trip_group']['route']['destination_name'];
      List _sortingTripHistory =
          store.state.ajkState.selectedMyTrip['trip_histories'];

      List _pickupPoint = store.state.ajkState.selectedMyTrip['trip']
          ['trip_group']['route']['pickup_points'];

      _pickupPoint.sort((a, b) => a['priority'].compareTo(b['priority']));

      if (_sortingTripHistory.length <= 0) {
        toggleButtonNameGlobal(
            "${AppTranslations.of(context).currentLanguage == 'en' ? 'Start Trip' : 'Mulai Trip'}");
      } else {
        _sortingTripHistory
            .sort((a, b) => a['created_date'].compareTo(b['created_date']));

        Map lastTripHistories =
            _sortingTripHistory[_sortingTripHistory.length - 1];
        Map lastHistoryPickupPoint;

        if (lastTripHistories['pickup_point_id'] != null) {
          lastHistoryPickupPoint = _pickupPoint.firstWhere((element) =>
              element['pickup_point_id'] ==
              lastTripHistories['pickup_point_id']);
        }

        if (lastTripHistories['type'] == 'HEADING') {
          toggleButtonNameGlobal(
              "${AppTranslations.of(context).currentLanguage == 'en' ? 'Arrived at' : 'Sampai di'} ${checkVia(lastHistoryPickupPoint != null ? lastHistoryPickupPoint['name'] : destinationName)}");
        } else if (lastTripHistories['type'] == 'HEADING_TO_DESTINATION') {
          if (tripType == 'DEPARTURE') {
            toggleButtonNameGlobal(
                "${AppTranslations.of(context).currentLanguage == 'en' ? 'Arrived at' : 'Sampai di'} ${checkVia(destinationName)}");
          } else {
            toggleButtonNameGlobal(
                "${AppTranslations.of(context).currentLanguage == 'en' ? 'Arrived at' : 'Sampai di'} ${checkVia(lastHistoryPickupPoint != null ? lastHistoryPickupPoint['name'] : destinationName)}");
          }
        } else {
          if (tripType == 'DEPARTURE') {
            int lastHistoryIndex = _pickupPoint.indexWhere((element) =>
                element['pickup_point_id'] ==
                lastTripHistories['pickup_point_id']);

            if (lastHistoryIndex < _pickupPoint.length - 1) {
              toggleButtonNameGlobal(
                  "${AppTranslations.of(context).currentLanguage == 'en' ? 'Heading to' : 'Menuju'} ${checkVia(_pickupPoint[lastHistoryIndex + 1]['name'])}");
            } else {
              toggleButtonNameGlobal(
                  "${AppTranslations.of(context).currentLanguage == 'en' ? 'Heading to' : 'Menuju'} ${checkVia(destinationName)}");
            }
          } else {
            _pickupPoint.sort((b, a) => a['priority'].compareTo(b['priority']));

            if (lastTripHistories['pickup_point_id'] == null) {
              toggleButtonNameGlobal(
                  "${AppTranslations.of(context).currentLanguage == 'en' ? 'Heading to' : 'Menuju'} ${checkVia(_pickupPoint[0]['name'])}");
            } else {
              int lastHistoryIndex = _pickupPoint.indexWhere((element) =>
                  element['pickup_point_id'] ==
                  lastTripHistories['pickup_point_id']);
              if (lastHistoryIndex < _pickupPoint.length - 1) {
                toggleButtonNameGlobal(
                    "${AppTranslations.of(context).currentLanguage == 'en' ? 'Heading to' : 'Menuju'} ${checkVia(_pickupPoint[lastHistoryIndex + 1]['name'])}");
              } else {
                toggleButtonNameGlobal(
                    "${AppTranslations.of(context).currentLanguage == 'en' ? 'Heading to' : 'Menuju'} ${checkVia(_pickupPoint[_pickupPoint.length - 1]['name'])}");
              }
            }
          }
        }
      }
    } catch (e) {
      print(e);
    } finally {
      toggleLoading(false);
    }
  }

  void onConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: CustomText(
            'Confirmation',
            color: ColorsCustom.black,
          ),
          content: CustomText(
            'Are you sure you want cancel this booking?',
            color: ColorsCustom.generalText,
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                // onCancelBooking();
              },
              child: CustomText(
                'Yes',
                color: ColorsCustom.black,
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => Navigator.pop(context),
              child: CustomText('No',
                  color: ColorsCustom.black, fontWeight: FontWeight.w600),
            ),
          ],
        );
      },
    );
  }

  void onCopy() {
    Clipboard.setData(ClipboardData(text: "AJKT021"));
    showDialog(
        context: context,
        barrierColor: Colors.white24,
        builder: (BuildContext context) {
          return CustomToast(
            image: "success_icon_white.svg",
            title: "Booking ID Copied",
            color: ColorsCustom.primaryGreen,
            duration: Duration(seconds: 1),
          );
        });
  }

  Future<void> onCancel() async {
    showDialog(
        context: context,
        barrierColor: Colors.white24,
        builder: (BuildContext context) {
          return CustomToast(
            image: "success_icon_white.svg",
            title: "Booking Cancelled Successfully",
            color: ColorsCustom.primaryGreen,
            duration: Duration(seconds: 3),
          );
        });
  }

  Future<void> getTripdByTripId(String tripId) async {
    try {
      dynamic res = await Providers.getTripByTripId(tripId: tripId);
      store.dispatch(SetSelectedMyTrip(selectedMyTrip: res.data['data']));
      statusHandler();
      getPassanger(
          store.state.ajkState.selectedMyTrip["trip"]['trip_group_id']);
    } catch (e) {
      print(e);
    }
  }

  Future<void> getPassanger(String tripGroupId) async {
    try {
      dynamic res = await Providers.getPassengers(tripGroupId: tripGroupId);
      store.dispatch(SetSelectedPassanger(selectedPassanger: res.data['data']));
    } catch (e) {
      print(e);
    }
  }

  Future<void> initMyActivities() async {
    await getAssignedTrip();
    await getOngoingTrip();
    await getCompletedTrip();
  }

  Future<void> getAssignedTrip() async {
    try {
      dynamic res = await Providers.getTripByStatus(
          limit: 10, offset: 0, status: "ASSIGNED");
      if (res.data['message'] == 'SUCCESS') {
        List _sortingData = res.data['data'];
        _sortingData.sort((a, b) =>
            a['trip']['departure_time'].compareTo(b['trip']['departure_time']));

        store.dispatch(SetAssignedTrip(assignedTrip: _sortingData));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> getOngoingTrip() async {
    try {
      dynamic res = await Providers.getTripByStatus(
          limit: 10, offset: 0, status: "ONGOING");
      if (res.data['message'] == 'SUCCESS') {
        List _sortingData = res.data['data'];
        _sortingData.sort((a, b) =>
            a['trip']['departure_time'].compareTo(b['trip']['departure_time']));

        store.dispatch(SetOngoingTrip(ongoingTrip: _sortingData));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> getCompletedTrip() async {
    try {
      dynamic res = await Providers.getTripByStatus(
          limit: 10, offset: 0, status: "COMPLETED");
      if (res.data['message'] == 'SUCCESS') {
        List _sortingData = res.data['data'];
        _sortingData.sort((a, b) =>
            a['trip']['departure_time'].compareTo(b['trip']['departure_time']));

        store.dispatch(SetCompletedTrip(completedTrip: _sortingData));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> onChangeStatusClick() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool dontShow = prefs.getBool('dont_show_again') ?? false;

    if (!dontShow &&
        (store.state.ajkState.buttonSelectedTrip == 'Mulai Trip' ||
            store.state.ajkState.buttonSelectedTrip == 'Start Trip')) {
      showCupertinoDialog<void>(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text("${AppTranslations.of(context).text('attention')}"),
          content:
              Text("${AppTranslations.of(context).text('desc_attention')}"),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () async {
                Navigator.pop(context);
                await prefs.setBool('dont_show_again', false);
                await manageTrip();
              },
            ),
            CupertinoDialogAction(
              child: Text("${AppTranslations.of(context).text('dont_show')}"),
              onPressed: () async {
                Navigator.pop(context);
                await prefs.setBool('dont_show_again', true);
                await manageTrip();
              },
            )
          ],
        ),
      );
    } else {
      await manageTrip();
    }
  }

  Future<void> manageTrip() async {
    if (isLoading) {
      return;
    }
    try {
      //  [HEADING, ARRIVED, ARRIVED_AT_DESTINATION, HEADING_TO_DESTINATION]
      String tripOrderId = store.state.ajkState.selectedMyTrip['trip_order_id'];
      String tripType = store.state.ajkState.selectedMyTrip['trip']['type'];
      String _pickupPoint;
      String _method;

      List _sortingTripHistory =
          store.state.ajkState.selectedMyTrip['trip_histories'];

      List _tripPickupPoint = store.state.ajkState.selectedMyTrip['trip']
          ['trip_group']['route']['pickup_points'];

      print("pickupPoint_detail");
      print(_tripPickupPoint);

      _tripPickupPoint.sort((a, b) => a['priority'].compareTo(b['priority']));

      if (_sortingTripHistory.length <= 0) {
        _method = "HEADING";
        if (tripType == 'DEPARTURE') {
          _pickupPoint = _tripPickupPoint[0]['pickup_point_id'];
        }
      } else {
        _sortingTripHistory
            .sort((a, b) => a['created_date'].compareTo(b['created_date']));

        Map lastTripHistories =
            _sortingTripHistory[_sortingTripHistory.length - 1];

        if (lastTripHistories['type'] == 'HEADING') {
          _method = "ARRIVED";
          _pickupPoint = lastTripHistories['pickup_point_id'];
        } else if (lastTripHistories['type'] == 'HEADING_TO_DESTINATION') {
          if (tripType == 'DEPARTURE') {
            _method = "ARRIVED_AT_DESTINATION";
            _pickupPoint = null;
          } else {
            _method = "ARRIVED_AT_DESTINATION";
            _pickupPoint = lastTripHistories['pickup_point_id'];
          }
        } else {
          if (tripType == 'DEPARTURE') {
            int lastHistoryIndex = _tripPickupPoint.indexWhere((element) =>
                element['pickup_point_id'] ==
                lastTripHistories['pickup_point_id']);

            if (lastHistoryIndex < _tripPickupPoint.length - 1) {
              _method = "HEADING";
              _pickupPoint =
                  _tripPickupPoint[lastHistoryIndex + 1]['pickup_point_id'];
            } else {
              _method = "HEADING_TO_DESTINATION";
              _pickupPoint = null;
            }
          } else {
            _tripPickupPoint
                .sort((b, a) => a['priority'].compareTo(b['priority']));

            if (lastTripHistories['pickup_point_id'] == null) {
              _method = "HEADING";
              _pickupPoint = _tripPickupPoint[0]['pickup_point_id'];
            } else {
              int lastHistoryIndex = _tripPickupPoint.indexWhere((element) =>
                  element['pickup_point_id'] ==
                  lastTripHistories['pickup_point_id']);
              if (lastHistoryIndex + 1 < _tripPickupPoint.length - 1) {
                _method = "HEADING";
                _pickupPoint =
                    _tripPickupPoint[lastHistoryIndex + 1]['pickup_point_id'];
              } else {
                _method = "HEADING_TO_DESTINATION";
                _pickupPoint = _tripPickupPoint[_tripPickupPoint.length - 1]
                    ['pickup_point_id'];
              }
            }
          }
        }
      }

      toggleLoading(true);
      try {
        // dynamic res = await Providers.manageTrip(
        //     tripId: "314e28d0-eded-11eb-ac0a-c18ea3fccad7",
        //     pickupPointId: "6d22c690-d259-11eb-94bc-c3fc446052a0",
        //     type: "ARRIVED"
        // );
        dynamic res = await Providers.manageTrip(
            tripOrderId: tripOrderId,
            pickupPointId: _pickupPoint,
            type: _method);

        print(res.data);

        if (_method == "HEADING" || _method == "ARRIVED") {
          setState(() {
            isOngoing = true;
          });
        }

        if (_method == "ARRIVED_AT_DESTINATION") {
          getTripdByTripId(tripOrderId);
          initMyActivities();
          setState(() {
            isOngoing = false;
          });
          deleteData();
        }
        // if (res.data['message'] == 'SUCCESS') {
        //   SharedPreferences prefs = await SharedPreferences.getInstance();
        //   await prefs.setString('jwtToken', res.data['data']['token']);
        //   await prefs.setString('driverId', res.data['data']['driver_id']);

        //   Navigator.push(context, MaterialPageRoute(builder: (_) => Home()));
        // } else {
        //   if (res.data['message'].contains("phone_number")) {
        //     setError(type: "phoneNumber", value: "Invalid phone number");
        //   } else if (res.data['message'].contains("user")) {
        //     setError(
        //         type: "phoneNumber",
        //         value: "Your phone number is not registered");
        //   }
        // }
      } catch (e) {
        print(e);
        // setError(type: "login", value: e);
      } finally {
        // toggleLoading(false);
        toggleLoading(false);
        getTripdByTripId(tripOrderId);
        initMyActivities();
      }
    } catch (e) {
      print(e);
    } finally {
      toggleLoading(false);
    }
  }

  Color getColorTypeText(String status) {
    if (status == 'ASSIGNED') {
      return ColorsCustom.primaryGreenHigh;
    } else if (status == 'ONGOING') {
      return ColorsCustom.primaryGreenHigh;
    } else if (status == 'COMPLETED') {
      return ColorsCustom.generalText;
    } else {
      return ColorsCustom.disable;
    }
  }

  void scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      setState(() {
        onBottom = true;
      });
    } else {
      setState(() {
        onBottom = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        // getCountdown();
      }
    });

    Timer.periodic(Duration(seconds: 5), (timer) {
      if (isOngoing) {
        _getCurrentLocation();
      }
    });

    scrollController.addListener(() => scrollListener());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      store = StoreProvider.of<AppState>(context);
      statusHandler();
      getTripdByTripId(store.state.ajkState.selectedMyTrip['trip_order_id']);
      // getCountdown();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
