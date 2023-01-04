import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tomas_driver/configs/config.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/helpers/utils.dart';
import 'package:tomas_driver/localization/app_translations.dart';
import 'package:tomas_driver/providers/providers.dart';
import 'package:tomas_driver/redux/actions/ajk_action.dart';
import 'package:tomas_driver/redux/actions/general_action.dart';
import 'package:tomas_driver/redux/app_state.dart';
import 'package:tomas_driver/widgets/custom_button.dart';
import 'package:tomas_driver/widgets/custom_text.dart';

// import 'custom_toast.dart';

class CardTrips extends StatefulWidget {
  final String id,
      title,
      type,
      pointA,
      pointB,
      differenceAB,
      status,
      stepTrip,
      destinationName;
  final DateTime dateA, dateB, timeA, timeB;
  final bool home;
  final Map data;
  final List pickupPoint, tripHistories;
  final parentFunction;

  CardTrips(
      {this.title,
      this.type,
      this.destinationName,
      this.pointA,
      this.pointB,
      this.dateA,
      this.dateB,
      this.home: false,
      this.id,
      this.data,
      this.differenceAB,
      this.timeA,
      this.timeB,
      this.status,
      this.stepTrip,
      this.pickupPoint,
      this.tripHistories,
      this.parentFunction});

  @override
  _CardTripsState createState() => _CardTripsState();
}

class _CardTripsState extends State<CardTrips> {
  Store<AppState> store;
  // List sortedPickupPoint = [];

  bool isLoading = false;

  void toggleIsLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  Color getColorTypeText() {
    if (widget.data['status'] == 'ASSIGNED') {
      return ColorsCustom.primaryGreenHigh;
    } else if (widget.data['status'] == 'ONGOING') {
      return ColorsCustom.primaryGreenHigh;
    } else if (widget.data['status'] == 'COMPLETED') {
      return ColorsCustom.generalText;
    } else {
      return ColorsCustom.disable;
    }
  }

  Color getColorTypeBackground() {
    if (widget.data['status'] == 'ASSIGNED') {
      return ColorsCustom.primaryGreenVeryLow;
    } else if (widget.data['status'] == 'ONGOING') {
      return ColorsCustom.primaryGreenVeryLow;
    } else if (widget.data['status'] == 'COMPLETED') {
      return ColorsCustom.border.withOpacity(0.64);
    } else {
      return ColorsCustom.border;
    }
  }

  Future<void> getTripdByTripId() async {
    try {
      dynamic res = await Providers.getTripByTripId(tripId: widget.id);
      print("res.data");
      print(res.data);
      store.dispatch(SetSelectedMyTrip(selectedMyTrip: res.data['data']));
    } catch (e) {
      print(e);
    }
  }

  Future<void> onMoveDetailPage() async {
    await getTripdByTripId();
    Navigator.pushNamed(context, "/DetailTrip").then((value) =>
        widget.parentFunction != null ? widget.parentFunction() : {});
  }

  Future<void> onClick() async {
    await getTripdByTripId();
    int totalHistory = widget.data['trip_histories'].length;
    if (totalHistory > 0) {
      return onMoveDetailPage();
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool dontShow = prefs.getBool('dont_show_again') ?? false;

    if (!dontShow &&
        (makeStatusButton() == 'Mulai Trip' ||
            makeStatusButton() == 'Start Trip')) {
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
                await prefs.setBool('dont_show_again', false);
                await manageTrip(false);
              },
            ),
            // Container(
            //   height: 1,
            //   width: double.infinity,
            //   color: ColorsCustom.disable.withOpacity(0.5),
            // ),
            CupertinoDialogAction(
              child: Text("${AppTranslations.of(context).text('dont_show')}"),
              onPressed: () async {
                await prefs.setBool('dont_show_again', true);
                await manageTrip(false);
              },
            )
          ],
        ),
      );
    } else {
      await manageTrip(true);
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

  Future<void> manageTrip(bool noPop) async {
    print("utu");
    if (store.state.generalState.isLoading) {
      return;
    }

    store.dispatch(SetIsLoading(isLoading: true));
    String tripOrderId = widget.id;
    String tripType = widget.data['trip']['type'];
    String _pickupPoint;
    String _method;

    List _sortingTripHistory = widget.data['trip_histories'];

    List pickupPoint =
        widget.data['trip']['trip_group']['route']['pickup_points'];

    pickupPoint.sort((a, b) => a['priority'].compareTo(b['priority']));

    if (_sortingTripHistory.length <= 0) {
      _method = "HEADING";
      if (tripType == 'DEPARTURE') {
        _pickupPoint = pickupPoint[0]['pickup_point_id'];
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
          int lastHistoryIndex = pickupPoint.indexWhere((element) =>
              element['pickup_point_id'] ==
              lastTripHistories['pickup_point_id']);

          if (lastHistoryIndex < pickupPoint.length - 1) {
            _method = "HEADING";
            _pickupPoint = pickupPoint[lastHistoryIndex + 1]['pickup_point_id'];
          } else {
            _method = "HEADING_TO_DESTINATION";
            _pickupPoint = null;
          }
        } else {
          pickupPoint.sort((b, a) => a['priority'].compareTo(b['priority']));

          if (lastTripHistories['pickup_point_id'] == null) {
            _method = "HEADING";
            _pickupPoint = pickupPoint[0]['pickup_point_id'];
          } else {
            int lastHistoryIndex = pickupPoint.indexWhere((element) =>
                element['pickup_point_id'] ==
                lastTripHistories['pickup_point_id']);
            if (lastHistoryIndex < pickupPoint.length - 1) {
              _method = "HEADING";
              _pickupPoint =
                  pickupPoint[lastHistoryIndex + 1]['pickup_point_id'];
            } else {
              _method = "HEADING_AT_DESTINATION";
              _pickupPoint =
                  pickupPoint[pickupPoint.length - 1]['pickup_point_id'];
            }
          }
        }
      }
    }

    try {
      // dynamic res = await Providers.manageTrip(
      //     tripId: "314e28d0-eded-11eb-ac0a-c18ea3fccad7",
      //     pickupPointId: "6d22c690-d259-11eb-94bc-c3fc446052a0",
      //     type: "ARRIVED"
      // );
      dynamic res = await Providers.manageTrip(
          tripOrderId: tripOrderId, pickupPointId: _pickupPoint, type: _method);

      print("res.data bro");
      print(res.data);

      // if (vType == "HEADING" || vType == "ARRIVED") {
      //   setState(() {
      //     isOngoing = true;
      //   });
      // }

      // if (vType == "ARRIVED_AT_DESTINATION") {
      //   setState(() {
      //     isOngoing = false;
      //   });
      //   deleteData();
      // }
      if (res.data['message'] == 'SUCCESS') {
        await getTripdByTripId();
        if (noPop) {
          store.dispatch(SetIsLoading(isLoading: false));
          initMyActivities();
          widget.parentFunction != null ? widget.parentFunction() : print("");
          Navigator.pushNamed(context, '/LiveTracking');
        } else {
          store.dispatch(SetIsLoading(isLoading: false));
          initMyActivities();
          widget.parentFunction != null ? widget.parentFunction() : print("");
          Navigator.popAndPushNamed(context, '/LiveTracking');
        }
      }
      //  else {
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
      // store.dispatch(SetIsLoading(isLoading: true));

      // toggleLoading(false);
      // toggleLoading(false);
    }
  }

  // Future<void> sortPickupPoint() async {
  //   List _sortedPickupPoint = widget.pickupPoint;
  //   _sortedPickupPoint.sort((a, b) => a['priority'].compareTo(b['priority']));

  //   setState(() {
  //     sortedPickupPoint = _sortedPickupPoint;
  //   });

  //   toggleIsLoading(false);
  // }

  String makeStatusButton() {
    int totalHistory = widget.tripHistories.length;
    String statusButtonName = "";

    if (totalHistory == 0) {
      statusButtonName = AppTranslations.of(context).currentLanguage == 'en'
          ? 'Start Trip'
          : 'Mulai Trip';
    } else {
      statusButtonName = AppTranslations.of(context).currentLanguage == 'en'
          ? 'Trip Detail'
          : 'Detail Trip';
    }

    return statusButtonName;
  }

  String makeStatus() {
    try {
      if (widget.status == 'ASSIGNED') {
        return AppTranslations.of(context).currentLanguage == 'en'
            ? 'Assigned'
            : 'Ditugaskan';
      } else if (widget.status == 'COMPLETED') {
        return AppTranslations.of(context).currentLanguage == 'en'
            ? 'Completed'
            : 'Selesai';
      } else {
        List _sortingTripHistory = widget.tripHistories;
        _sortingTripHistory
            .sort((a, b) => a['created_date'].compareTo(b['created_date']));

        Map lastTripHistories =
            _sortingTripHistory[_sortingTripHistory.length - 1];

        List pickupPoint =
            widget.data['trip']['trip_group']['route']['pickup_points'];

        if (lastTripHistories['pickup_point_id'] != null) {
          Map _filterPickupPoint = pickupPoint.firstWhere((element) =>
              element['pickup_point_id'] ==
              lastTripHistories['pickup_point_id']);

          if (lastTripHistories.containsValue('HEADING') ||
              lastTripHistories.containsValue('HEADING_TO_DESTINATION')) {
            return "${AppTranslations.of(context).currentLanguage == 'en' ? 'Heading to' : 'Menuju'} ${_filterPickupPoint['name']}";
          } else {
            return "${AppTranslations.of(context).currentLanguage == 'en' ? 'Arrived at' : 'Sampai di'} ${_filterPickupPoint['name']}";
          }
        } else {
          if (lastTripHistories.containsValue('HEADING') ||
              lastTripHistories.containsValue('HEADING_TO_DESTINATION')) {
            return "${AppTranslations.of(context).currentLanguage == 'en' ? 'Heading to' : 'Menuju '} ${widget.destinationName}";
          } else {
            return "${AppTranslations.of(context).currentLanguage == 'en' ? 'Arrived at' : 'Sampai di'} ${widget.destinationName}";
          }
        }
      }
    } catch (e) {
      print(e);
      return "";
    }
  }

  String elipsisString(String vString) {
    if (vString.length > 15) return vString.substring(0, 13) + "...";
    return vString;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      store = StoreProvider.of<AppState>(context);
      // sortPickupPoint();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width - 32,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: widget.data['status'] == 'ONGOING'
              ? Border.all(color: ColorsCustom.primaryGreen)
              : null,
          boxShadow: [
            BoxShadow(
                blurRadius: 24, offset: Offset(0, 4), color: Colors.black12)
          ]),
      child: TextButton(
        style: TextButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          // highlightColor: ColorsCustom.black.withOpacity(0.01),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        onPressed: () => onMoveDetailPage(),
        // onPressed: () {},

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/images/school_bus.svg',
                        height: 23,
                        width: 23,
                      ),
                      SizedBox(width: 16),
                      CustomText(
                        // "${widget.title}",
                        AppTranslations.of(context).text("card_driving_ajk"),
                        color: ColorsCustom.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ],
                  ),
                ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: screenSize.width / 2.5,
                  ),
                  padding:
                      EdgeInsets.only(top: 5, bottom: 5, right: 12, left: 12),
                  decoration: BoxDecoration(
                      color: getColorTypeBackground(),
                      borderRadius: BorderRadius.circular(8)),
                  child: CustomText(
                    "${makeStatus()}",
                    // "Arrived at Sunter Park View Super duper",
                    color: getColorTypeText(),
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    overflow: true,
                  ),
                ),
              ],
            ),
            Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      "${DateFormat('HH:mm', AppTranslations.of(context).currentLanguage).format(widget.dateA)}",
                      color: ColorsCustom.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 7.3, right: 8.0, bottom: 3, top: 6),
                          child: SvgPicture.asset(
                            "assets/images/Location_source.svg",
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 10.4, right: 8.0),
                          child: SvgPicture.asset(
                            "assets/images/location_road.svg",
                            height: 37,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 7.2, right: 8.0),
                          child: SvgPicture.asset(
                            "assets/images/location_destination.svg",
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: CustomText(
                                  isLoading
                                      ? ""
                                      : elipsisString(widget.type != "DEPARTURE"
                                          ? widget.destinationName
                                          : widget.pickupPoint[widget.home
                                              ? widget.pickupPoint.length - 1
                                              : 0]['name']),
                                  color: ColorsCustom.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                )),
                            CustomText(
                              "${DateFormat('E, dd MMM yyyy', AppTranslations.of(context).currentLanguage).format(widget.dateA)}",
                              color: ColorsCustom.black,
                              fontWeight: FontWeight.w500,
                              // height: 2.4,
                              fontSize: 12,
                            ),
                          ],
                        ),
                        int.parse(widget.stepTrip) > 0
                            ? Padding(
                                padding: EdgeInsets.only(left: 8, top: 5),
                                child: CustomText(
                                  "${widget.stepTrip} ${AppTranslations.of(context).text("card_more_stop")}",
                                  color: ColorsCustom.black,
                                  fontWeight: FontWeight.w300,
                                  fontSize: 11,
                                ),
                              )
                            : SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: CustomText(
                                  elipsisString(widget.type != "DEPARTURE"
                                      ? widget.pickupPoint[widget.home
                                          ? widget.pickupPoint.length - 1
                                          : 0]['name']
                                      : widget.destinationName),
                                  color: ColorsCustom.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                )),
                            widget.data['status'] == 'COMPLETED'
                                ? SizedBox()
                                : Container(
                                    width: 120,
                                    height: 32,
                                    child: CustomButton(
                                      bgColor: MANAGE_TRIP_BY_TIME
                                          ? (makeStatusButton() == 'Trip Detail' ||
                                                      makeStatusButton() ==
                                                          'Detail Trip') ||
                                                  (DateTime.now().isAfter(
                                                          DateTime.fromMillisecondsSinceEpoch(widget.data['trip']['departure_time'])
                                                              .subtract(Duration(
                                                                  hours: 3))) &&
                                                      DateTime.now().isBefore(
                                                          DateTime.fromMillisecondsSinceEpoch(
                                                                  widget.data['trip']
                                                                      ['departure_time'])
                                                              .add(Duration(days: 1))))
                                              ? Color(0xFF75C1D4)
                                              : Color(0xFF828282)
                                          : Color(0xFF75C1D4),
                                      margin: EdgeInsets.zero,
                                      borderRadius: BorderRadius.circular(16),
                                      // padding: EdgeInsets.symmetric(
                                      //     vertical: 16, horizontal: 2),
                                      text: makeStatusButton(),
                                      textColor: Colors.white,
                                      onPressed: makeStatusButton() ==
                                                  'Trip Details' ||
                                              makeStatusButton() ==
                                                  'Detail Trip'
                                          ? () async {
                                              await getTripdByTripId();
                                              Navigator.pushNamed(
                                                      context, '/DetailTrip')
                                                  .then((value) => widget
                                                              .parentFunction !=
                                                          null
                                                      ? widget.parentFunction()
                                                      : {});
                                            }
                                          : MANAGE_TRIP_BY_TIME
                                              ? DateTime.now().isAfter(
                                                          DateTime.fromMillisecondsSinceEpoch(widget.data['trip']['departure_time'])
                                                              .subtract(Duration(
                                                                  hours: 3))) &&
                                                      DateTime.now().isBefore(
                                                          DateTime.fromMillisecondsSinceEpoch(
                                                                  widget.data['trip']
                                                                      ['departure_time'])
                                                              .add(Duration(days: 1)))
                                                  ? () => onClick()
                                                  : () => {
                                                        showDialog(
                                                            context: context,
                                                            barrierColor:
                                                                Colors.white24,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return 
                                                              Text('dsa');
                                                              // CustomToast(
                                                              //   title: AppTranslations.of(
                                                              //           context)
                                                              //       .text(
                                                              //           "error_start_trip")
                                                              //   // .OutlinedButton(style: OutlinedButton.styleFrom(),(
                                                              //   //     "\n",
                                                              //   //     " ")
                                                              //   ,
                                                              //   width: screenSize
                                                              //           .width /
                                                              //       1.5,
                                                              //   color: ColorsCustom
                                                              //       .primaryOrange,
                                                              //   duration:
                                                              //       Duration(
                                                              //           seconds:
                                                              //               2),
                                                              // );
                                                            })
                                                      }
                                              : () => onClick(),
                                    ))
                          ],
                        ),
                      ],
                    ))
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
