import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
// import 'package:mapbox_gl/mapbox_gl.dart';
// ignore: unused_import
import 'package:qr_flutter/qr_flutter.dart';
// ignore: unused_import
import 'package:tomas_driver/configs/config.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/helpers/utils.dart';
import 'package:tomas_driver/localization/app_translations.dart';
import 'package:tomas_driver/screens/viewmap/view_map.dart';
import 'package:tomas_driver/widgets/map_fullscreen.dart';
import 'package:tomas_driver/widgets/custom_text.dart';

class CardBooking extends StatefulWidget {
  final String bookingCode,
      bookingId,
      differenceAB,
      pointA,
      pointB,
      addressA,
      addressB,
      type,
      status,
      stepTrip,
      destinationName,
      destinationAddress;

  final double latDestination, lngDestination;

  final DateTime dateA, dateB, timeA, timeB;

  final List pickupPoint;

  // final LatLng coordinatesA, coordinatesB;

  CardBooking(
      {this.bookingCode,
      this.bookingId,
      this.timeA,
      this.timeB,
      this.differenceAB,
      this.pointA,
      this.pointB,
      this.addressA,
      this.addressB,
      this.type,
      this.dateA,
      this.dateB,
      this.status,
      this.stepTrip,
      this.destinationName,
      this.destinationAddress,
      this.pickupPoint,
      this.latDestination,
      this.lngDestination});

  @override
  _CardBookingState createState() => _CardBookingState();
}

class _CardBookingState extends State<CardBooking> {
  List pickupPoint = [];

  setRoute() async {
    return Container();
  }

  Future<void> sortPickupPoint() async {
    List _pickupPoint = widget.pickupPoint;

    _pickupPoint.sort((a, b) => widget.type == 'DEPARTURE'
        ? a['priority'].compareTo(b['priority'])
        : b['priority'].compareTo(a['priority']));

    setState(() {
      pickupPoint = _pickupPoint;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      sortPickupPoint();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  offset: Offset(0, 4),
                  spreadRadius: 0,
                  blurRadius: 14,
                  color: ColorsCustom.black.withOpacity(0.12)),
            ]),
        child: Column(children: [
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: CustomText(
                    AppTranslations.of(context).text("detail_route"),
                    color: ColorsCustom.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: CustomText(
                      "${DateFormat('E, dd MMM yyyy', AppTranslations.of(context).currentLanguage).format(widget.dateA)}",
                      color: ColorsCustom.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomText(
                          "${DateFormat('HH:mm', AppTranslations.of(context).currentLanguage).format(widget.dateA)}",
                          fontWeight: FontWeight.w500,
                          color: ColorsCustom.black,
                          fontSize: 14,
                        ),
                        SizedBox(height: 4),
                      ],
                    ),
                    // Column(
                    //     mainAxisAlignment: MainAxisAlignment.start,
                    //     mainAxisSize: MainAxisSize.min,
                    //     children: [
                    //       // for (int i = 0; i < pickupPoint.length + 1; i++)

                    //     ]),
                    // Column(
                    //   mainAxisAlignment: MainAxisAlignment.start,
                    //   mainAxisSize: MainAxisSize.min,
                    //   children: [
                    //     Container(
                    //       margin: EdgeInsets.only(left: 15, right: 15, top: 5),
                    //       width: 8,
                    //       height: 8,
                    //       decoration: BoxDecoration(
                    //           border: Border.all(
                    //               width: 2, color: ColorsCustom.black),
                    //           borderRadius: BorderRadius.circular(10)),
                    //     ),
                    //     SizedBox(height: 5),
                    //     Container(
                    //       margin: EdgeInsets.symmetric(horizontal: 10),
                    //       height: 82,
                    //       child: SvgPicture.asset(
                    //           "assets/images/dotted-very-long-black.svg"),
                    //     ),
                    //     SizedBox(height: 5),
                    //     Container(
                    //       margin: EdgeInsets.symmetric(horizontal: 13),
                    //       child: Icon(
                    //         Icons.location_on,
                    //         size: 15,
                    //         color: ColorsCustom.black,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    widget.type == "DEPARTURE"
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (int i = 0; i < pickupPoint.length; i++)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 17, right: 15, top: 6),
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: 2,
                                                  color: ColorsCustom.black),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                        ),
                                        SizedBox(height: 5),
                                        Container(
                                          margin: EdgeInsets.only(left: 2),
                                          height: 82,
                                          child: SvgPicture.asset(
                                              "assets/images/dotted-very-long-black.svg"),
                                        ),
                                        SizedBox(height: 2),
                                      ],
                                    ),
                                    Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 250,
                                            child: CustomText(
                                              pickupPoint[i]['name'],
                                              fontWeight: FontWeight.w500,
                                              color: ColorsCustom.black,
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Container(
                                            width: 250,
                                            child: CustomText(
                                              pickupPoint[i]['address'],
                                              fontWeight: FontWeight.w400,
                                              color: ColorsCustom.black,
                                              fontSize: 12,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          GestureDetector(
                                            onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        MapFullscreen(
                                                          address:
                                                              pickupPoint[i]
                                                                  ['address'],
                                                          city: pickupPoint[i]
                                                              ['name'],
                                                          coordinates: LatLng(
                                                              pickupPoint[i]
                                                                  ['latitude'],
                                                              pickupPoint[i][
                                                                  'longitude']),
                                                        ),
                                                    fullscreenDialog: true)),
                                            child: CustomText(
                                              AppTranslations.of(context)
                                                  .text("detail_view"),
                                              fontWeight: FontWeight.w400,
                                              color: ColorsCustom.primary,
                                              fontSize: 12,
                                            ),
                                          ),
                                          SizedBox(height: 30),
                                        ]),
                                  ],
                                ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        margin:
                                            EdgeInsets.only(left: 14, top: 2),
                                        child: Icon(
                                          Icons.location_on,
                                          size: 15,
                                          color: ColorsCustom.black,
                                        ),
                                      ),
                                      SizedBox(height: 5)
                                    ],
                                  ),
                                  SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 250,
                                        child: CustomText(
                                          "${widget.destinationName}",
                                          fontWeight: FontWeight.w500,
                                          color: ColorsCustom.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Container(
                                        width: 250,
                                        child: CustomText(
                                          "${widget.destinationAddress}",
                                          fontWeight: FontWeight.w400,
                                          color: ColorsCustom.black,
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      GestureDetector(
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) => MapFullscreen(
                                                    address: widget
                                                        .destinationAddress,
                                                    city:
                                                        widget.destinationName,
                                                    coordinates: LatLng(
                                                        widget.latDestination,
                                                        widget.lngDestination)),
                                                fullscreenDialog: true)),
                                        child: CustomText(
                                          AppTranslations.of(context)
                                              .text("detail_view"),
                                          fontWeight: FontWeight.w400,
                                          color: ColorsCustom.primary,
                                          fontSize: 12,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: 17, right: 15, top: 6),
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 2,
                                                color: ColorsCustom.black),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                      SizedBox(height: 5),
                                      Container(
                                        margin: EdgeInsets.only(left: 2),
                                        height: 82,
                                        child: SvgPicture.asset(
                                            "assets/images/dotted-very-long-black.svg"),
                                      ),
                                      SizedBox(height: 2)
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 250,
                                        child: CustomText(
                                          "${widget.destinationName}",
                                          fontWeight: FontWeight.w500,
                                          color: ColorsCustom.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Container(
                                        width: 250,
                                        child: CustomText(
                                          "${widget.destinationAddress}",
                                          fontWeight: FontWeight.w400,
                                          color: ColorsCustom.black,
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      GestureDetector(
                                        onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) => MapFullscreen(
                                                    address: widget
                                                        .destinationAddress,
                                                    city:
                                                        widget.destinationName,
                                                    coordinates: LatLng(
                                                        widget.latDestination,
                                                        widget.lngDestination)),
                                                fullscreenDialog: true)),
                                        child: CustomText(
                                          AppTranslations.of(context)
                                              .text("detail_view"),
                                          fontWeight: FontWeight.w400,
                                          color: ColorsCustom.primary,
                                          fontSize: 12,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              // SizedBox(height: 30),
                              for (int i = 0; i < pickupPoint.length; i++)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    i != pickupPoint.length - 1
                                        ? Column(
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(
                                                    left: 17,
                                                    right: 15,
                                                    top: 5),
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 2,
                                                        color:
                                                            ColorsCustom.black),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                              ),
                                              SizedBox(height: 5),
                                              Container(
                                                margin:
                                                    EdgeInsets.only(left: 2),
                                                height: 82,
                                                child: SvgPicture.asset(
                                                    "assets/images/dotted-very-long-black.svg"),
                                              ),
                                              SizedBox(height: 5),
                                            ],
                                          )
                                        : Column(
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(
                                                    left: 14,
                                                    top: 2,
                                                    right: 10),
                                                child: Icon(
                                                  Icons.location_on,
                                                  size: 15,
                                                  color: ColorsCustom.black,
                                                ),
                                              ),
                                              SizedBox(height: 5)
                                            ],
                                          ),
                                    Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 250,
                                            child: CustomText(
                                              pickupPoint[i]['name'],
                                              fontWeight: FontWeight.w500,
                                              color: ColorsCustom.black,
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Container(
                                            width: 250,
                                            child: CustomText(
                                              pickupPoint[i]['address'],
                                              fontWeight: FontWeight.w400,
                                              color: ColorsCustom.black,
                                              fontSize: 12,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          GestureDetector(
                                            onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) => MapFullscreen(
                                                        address: pickupPoint[i]
                                                            ['address'],
                                                        city: pickupPoint[i]
                                                            ['name'],
                                                        coordinates: LatLng(
                                                            pickupPoint[i]
                                                                ['latitude'],
                                                            pickupPoint[i]
                                                                ['longitude'])),
                                                    fullscreenDialog: true)),
                                            child: CustomText(
                                              AppTranslations.of(context)
                                                  .text("detail_view"),
                                              fontWeight: FontWeight.w400,
                                              color: ColorsCustom.primary,
                                              fontSize: 12,
                                            ),
                                          ),
                                          // SizedBox(height: 30),
                                        ]),
                                  ],
                                )
                            ],
                          ),
                    // Column(
                    //   mainAxisAlignment: MainAxisAlignment.start,
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   mainAxisSize: MainAxisSize.min,
                    //   children: [
                    //     CustomText(
                    //       "$pointA",
                    //       fontWeight: FontWeight.w500,
                    //       color: ColorsCustom.black,
                    //       fontSize: 14,
                    //     ),
                    //     SizedBox(height: 5),
                    //     CustomText(
                    //       "$addressA",
                    //       fontWeight: FontWeight.w400,
                    //       color: ColorsCustom.black,
                    //       fontSize: 12,
                    //     ),
                    //     SizedBox(height: 5),
                    //     GestureDetector(
                    //       // onTap: () => Navigator.push(
                    //       //     context,
                    //       //     MaterialPageRoute(
                    //       //         builder: (_) => MapFullscreen(
                    //       //               coordinates: coordinatesA,
                    //       //               city:
                    //       //                   "${Utils.capitalizeFirstofEach(pointA)}",
                    //       //               address:
                    //       //                   "${Utils.capitalizeFirstofEach(addressA)}",
                    //       //             ),
                    //       //         fullscreenDialog: true)),
                    //       child: CustomText(
                    //         "View on Map",
                    //         fontWeight: FontWeight.w400,
                    //         color: ColorsCustom.primary,
                    //         fontSize: 12,
                    //       ),
                    //     ),
                    //     SizedBox(height: 35),
                    //     CustomText(
                    //       "$pointB",
                    //       fontWeight: FontWeight.w500,
                    //       color: ColorsCustom.black,
                    //       fontSize: 14,
                    //     ),
                    //     SizedBox(height: 5),
                    //     CustomText(
                    //       "$addressB",
                    //       fontWeight: FontWeight.w400,
                    //       color: ColorsCustom.black,
                    //       fontSize: 12,
                    //     ),
                    //     SizedBox(height: 5),
                    //     GestureDetector(
                    //       // onTap: () => Navigator.push(
                    //       //     context,
                    //       //     MaterialPageRoute(
                    //       //         builder: (_) => MapFullscreen(
                    //       //               coordinates: coordinatesB,
                    //       //               city:
                    //       //                   "${Utils.capitalizeFirstofEach(pointB)}",
                    //       //               address:
                    //       //                   "${Utils.capitalizeFirstofEach(addressB)}",
                    //       //             ),
                    //       //         fullscreenDialog: true)),
                    //       child: CustomText(
                    //         "View on Map",
                    //         fontWeight: FontWeight.w400,
                    //         color: ColorsCustom.primary,
                    //         fontSize: 12,
                    //       ),
                    //     )
                    //   ],
                    // )
                  ],
                ),
              ],
            ),
          )
        ]));
  }
}
