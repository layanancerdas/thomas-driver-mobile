import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading/indicator/ball_spin_fade_loader_indicator.dart';
import 'package:loading/loading.dart';
import 'package:tomas_driver/configs/config.dart';
import 'package:tomas_driver/localization/app_translations.dart';
import 'package:tomas_driver/redux/modules/ajk_state.dart';
// import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:tomas_driver/screens/detail_trip/widgets/bus_details.dart';
import 'package:tomas_driver/screens/detail_trip/widgets/passenger_list.dart';
import 'package:tomas_driver/screens/detail_trip/widgets/scan_attendace.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/helpers/utils.dart';
import 'package:tomas_driver/redux/app_state.dart';
import 'package:tomas_driver/redux/modules/user_state.dart';
import 'package:tomas_driver/screens/detail_trip/widgets/card_booking.dart';
// ignore: unused_import
import 'package:tomas_driver/widgets/custom_button.dart';
import 'package:tomas_driver/widgets/custom_text.dart';
import 'package:tomas_driver/widgets/custom_toast.dart';
import './detail_trip_view_model.dart';
import 'package:tomas_driver/screens/detail_trip/widgets/more_info.dart';

class DetailTripView extends DetailTripViewModel {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return StoreConnector<AppState, UserState>(
        converter: (store) => store.state.userState,
        builder: (context, state) {
          return StoreConnector<AppState, AjkState>(
              converter: (store) => store.state.ajkState,
              builder: (context, stateAjk) {
                return Scaffold(
                  appBar: AppBar(
                    leading: TextButton(
                      style: TextButton.styleFrom(),
                      onPressed: () => Navigator.pop(context),
                      child: SvgPicture.asset(
                        'assets/images/back_icon.svg',
                      ),
                    ),
                    // elevation: 3,
                    centerTitle: true,
                    title: CustomText(
                      // "${stateAjk.selectedMyTrip['trip']['trip_group']['trip_group_id']}",
                      AppTranslations.of(context).text("detail_trip"),
                      color: ColorsCustom.black,
                    ),
                  ),
                  body: stateAjk.selectedMyTrip.isEmpty
                      ? Container()
                      : Stack(
                          children: [
                            Container(
                              height: screenSize.height,
                              child: ListView(
                                padding: EdgeInsets.fromLTRB(16, 16, 16, 10),
                                controller: scrollController,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        "Status:",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300,
                                        height: 2.1,
                                        color: ColorsCustom.black,
                                      ),
                                      SizedBox(width: 100),
                                      Expanded(
                                        child: CustomText(
                                          //'asdasdsa',
                                          "${stateAjk.statusSelectedTrip}",
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          height: 2.1,
                                          overflow: true,
                                          textAlign: TextAlign.right,
                                          color: getColorTypeText(stateAjk
                                              .selectedMyTrip['status']),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 2),
                                  stateAjk.selectedMyTrip['status'] == "PENDING"
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                              CustomText(
                                                "Auto cancel in:",
                                                fontSize: 14,
                                                fontWeight: FontWeight.w300,
                                                height: 2.1,
                                                color: ColorsCustom.black,
                                              ),
                                              Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 3),
                                                  decoration: BoxDecoration(
                                                      color: ColorsCustom
                                                          .primaryOrange,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  child: CustomText(
                                                    "$countdown",
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                  )),
                                            ])
                                      : SizedBox(),
                                  CardBooking(
                                      bookingCode: 'tes',
                                      bookingId: stateAjk
                                          .selectedMyTrip['trip_order_id'],
                                      addressA: 'Jalan Surya Kencana No2',
                                      addressB: 'Jl. Yos Sudarso No.10',
                                      // coordinatesA: LatLng(-6.914744, 107.609811),
                                      // coordinatesB: LatLng(-7.319563, 108.202972),
                                      dateA: DateTime.fromMicrosecondsSinceEpoch(
                                          stateAjk.selectedMyTrip['trip']['departure_time'] *
                                              1000),
                                      timeA: DateTime.fromMicrosecondsSinceEpoch(
                                          stateAjk.selectedMyTrip['trip']['departure_time'] *
                                              1000),
                                      differenceAB: "1 h 30 m",
                                      pointA: "Tasik",
                                      pointB: "Bandung",
                                      type: stateAjk.selectedMyTrip['trip']
                                          ['type'],
                                      pickupPoint: stateAjk.selectedMyTrip['trip']['trip_group']
                                          ['route']['pickup_points'],
                                      destinationName: stateAjk.selectedMyTrip['trip']['trip_group']
                                          ['route']['destination_name'],
                                      destinationAddress: stateAjk.selectedMyTrip['trip']
                                          ['trip_group']['route']['destination_address'],
                                      latDestination: stateAjk.selectedMyTrip['trip']['trip_group']['route']['destination_latitude'],
                                      lngDestination: stateAjk.selectedMyTrip['trip']['trip_group']['route']['destination_longitude']),
                                  PassengerList(
                                      tripGroupId: stateAjk
                                          .selectedMyTrip['trip_group_id'],
                                      isCompleted:
                                          stateAjk.selectedMyTrip['status'] ==
                                              "COMPLETED"),
                                  stateAjk.selectedMyTrip['status'] ==
                                          "COMPLETED"
                                      ? Container()
                                      : ScanAttendance(
                                          tripOrderId: stateAjk
                                              .selectedMyTrip['trip_order_id'],
                                          detailFunction: getTripdByTripId),
                                  BusDetails(),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 10),
                                    child: CustomText(
                                      AppTranslations.of(context)
                                          .text("detail_more"),
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  MoreInfo(
                                    title: AppTranslations.of(context)
                                        .text("detail_important"),
                                    icon: "more_info",
                                    content: [
                                      AppTranslations.of(context)
                                                  .currentLanguage ==
                                              'en'
                                          ? "Please arrive at boarding point on schedule"
                                          : "Harap tiba di titik keberangkatan sesuai jadwal",
                                      AppTranslations.of(context)
                                                  .currentLanguage ==
                                              'en'
                                          ? "Please make sure you scan the e-ticket/QR code of all passengers who will board the shuttle"
                                          : "Harap pastikan Anda memindai e-tiket/kode QR semua penumpang yang akan menaiki kendaraan",
                                      AppTranslations.of(context)
                                                  .currentLanguage ==
                                              'en'
                                          ? "Please make sure the passengers who board the shuttle match those listed on the passenger attendance list"
                                          : "Harap pastikan penumpang yang naik kendaraan sesuai dengan yang tercantum pada daftar hadir penumpang",
                                      AppTranslations.of(context)
                                                  .currentLanguage ==
                                              'en'
                                          ? "All time shown are local times of each departure"
                                          : "Semua waktu yang ditampilkan adalah waktu setempat dari setiap keberangkatan"
                                    ],
                                  ),
                                  Container(
                                      margin:
                                          EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                                offset: Offset(0, 0),
                                                spreadRadius: 1,
                                                blurRadius: 4,
                                                color: ColorsCustom.black
                                                    .withOpacity(0.15))
                                          ]),
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          tapTargetSize:  MaterialTapTargetSize.shrinkWrap,
                                        
                                        // highlightColor: ColorsCustom.black
                                        //     .withOpacity(0.12),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 16),
                                        ),
                                        
                                        onPressed: () => Navigator.pushNamed(
                                            context, "/ContactUs"),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomText(
                                              "${AppTranslations.of(context).text("detail_need")}",
                                              color: ColorsCustom.black,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                            ),
                                            SvgPicture.asset(
                                              "assets/images/arrow_right.svg",
                                              height: 16,
                                              width: 16,
                                            ),
                                          ],
                                        ),
                                      )),
                                  stateAjk.selectedMyTrip['status'] != "ONGOING"
                                      ? Container()
                                      : Container(
                                          color: Colors.white,
                                          child: Center(
                                            child: TextButton(
                                              style: TextButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                side: BorderSide(
                                                    color: Color(0xFF75C1D4),
                                                    width: 1),
                                              ),
                                              // elevation: 0,
                                              backgroundColor: Colors.white,
                                              ),
                                              onPressed: () {
                                                // manageTrip();
                                                Navigator.pushNamed(
                                                    context, "/LiveTracking");
                                              },
                                              
                                              child: Container(
                                                height: 56,
                                                child: Center(
                                                  child: CustomText(
                                                    AppTranslations.of(context)
                                                        .text(
                                                            "detail_direction"),
                                                    color: Color(0xFF75C1D4),
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                  stateAjk.selectedMyTrip['status'] ==
                                          "COMPLETED"
                                      ? SizedBox(height: 15)
                                      : SizedBox(height: 105),
                                ],
                              ),
                            ),
                            // stateAjk.selectedMyTrip['status'] != "ONGOING"
                            //     ? Container()
                            //     : Positioned(
                            //         bottom: 0,
                            //         left: 0,
                            //         right: 0,
                            //         child:
                            //       ),
                            stateAjk.selectedMyTrip['status'] == "COMPLETED"
                                ? Container()
                                : Positioned(
                                    bottom: 0,
                                    right: 0,
                                    left: 0,
                                    child: Container(
                                      padding:
                                          EdgeInsets.fromLTRB(0, 10, 0, 16),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(16),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                                offset: Offset(4, 0),
                                                blurRadius: 12,
                                                spreadRadius: 0,
                                                color: Colors.black
                                                    .withOpacity(0.15))
                                          ]),
                                      child: Column(
                                        children: [
                                          Container(
                                            color: Colors.white,
                                            padding: EdgeInsets.all(10),
                                            child: Center(
                                              child: ElevatedButton(
                                                style: TextButton.styleFrom(
                                                   shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                elevation: 0,
                                                backgroundColor: MANAGE_TRIP_BY_TIME
                                                    ? DateTime.now().isAfter(DateTime.fromMillisecondsSinceEpoch(store
                                                                        .state
                                                                        .ajkState
                                                                        .selectedMyTrip['trip']
                                                                    [
                                                                    'departure_time'])
                                                                .subtract(Duration(
                                                                    hours:
                                                                        3))) &&
                                                            DateTime.now().isBefore(
                                                                DateTime.fromMillisecondsSinceEpoch(store.state.ajkState.selectedMyTrip['trip']['departure_time'])
                                                                    .add(Duration(days: 1)))
                                                        ? Color(0xFF75C1D4)
                                                        : Color(0xFF828282)
                                                    : Color(0xFF75C1D4)
                                                ),
                                                onPressed: MANAGE_TRIP_BY_TIME
                                                    ? DateTime.now().isAfter(DateTime.fromMillisecondsSinceEpoch(store
                                                                        .state
                                                                        .ajkState
                                                                        .selectedMyTrip['trip']
                                                                    [
                                                                    'departure_time'])
                                                                .subtract(Duration(
                                                                    hours:
                                                                        3))) &&
                                                            DateTime.now().isBefore(
                                                                DateTime.fromMillisecondsSinceEpoch(store.state.ajkState.selectedMyTrip['trip']['departure_time'])
                                                                    .add(Duration(days: 1)))
                                                        ? () => onChangeStatusClick()
                                                        : () {
                                                            onWarningButtonClicked();
                                                          }
                                                    : () => onChangeStatusClick(),
                                               
                                                child: Container(
                                                  height: 56,
                                                  child: isLoading
                                                      ? Center(
                                                          child: SizedBox(
                                                          width: 17,
                                                          height: 17,
                                                          child:
                                                              CircularProgressIndicator(
                                                            strokeWidth: 2.5,
                                                            valueColor:
                                                                new AlwaysStoppedAnimation<
                                                                        Color>(
                                                                    Colors
                                                                        .white),
                                                          ),
                                                        ))
                                                      : Center(
                                                          child: CustomText(
                                                            "${stateAjk.buttonSelectedTrip}",
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 15,
                                                            textAlign: TextAlign
                                                                .center,
                                                            overflow: true,
                                                          ),
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            isWarningButton
                                ? Positioned(
                                    bottom: 24,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 12),
                                        width: double.infinity,
                                        color: ColorsCustom.primaryOrange,
                                        alignment: Alignment.center,
                                        child: CustomText(
                                          AppTranslations.of(context)
                                              .text("error_start_trip"),
                                          fontSize: 14,
                                          color: Colors.white,
                                          textAlign: TextAlign.center,
                                        )),
                                  )
                                : SizedBox(),
                            isLoading
                                ? Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: Colors.white70,
                                    alignment: Alignment.center,
                                    child: SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: Loading(
                                        color: ColorsCustom.primary,
                                        indicator:
                                            BallSpinFadeLoaderIndicator(),
                                      ),
                                    ),
                                  )
                                : SizedBox()
                          ],
                        ),
                );
              });
        });
  }
}
