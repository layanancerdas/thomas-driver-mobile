import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/localization/app_translations.dart';
import 'package:tomas_driver/providers/providers.dart';
import 'package:tomas_driver/redux/actions/ajk_action.dart';
import 'package:tomas_driver/redux/app_state.dart';
import 'package:tomas_driver/redux/modules/ajk_state.dart';
import 'package:tomas_driver/widgets/qr_scan.dart';

import 'custom_text.dart';

class PassengerBody2 extends StatefulWidget {
  final String tripGroupId, tripId;
  final bool isCompleted;

  PassengerBody2({this.isCompleted: false, this.tripGroupId, this.tripId});
  @override
  _PassengerBody2State createState() => _PassengerBody2State();
}

class _PassengerBody2State extends State<PassengerBody2> {
  bool isScanned = false;

  @override
  Widget build(BuildContext context) {
    var store = StoreProvider.of<AppState>(context);
    Future<void> getBookByTripId(String tripId) async {
      try {
        dynamic res = await Providers.getBookingByTripId(tripId: tripId);
        if (res.data['code'] == 'SUCCESS') {
          print('refresh');
          store.dispatch(SetSelectedBooking(selectedBooking: res.data['data']));
        }
      } catch (e) {
        print(e);
      }
    }

    Future<void> checkInTrip(String bookingId) async {
      print('masuk');
      try {
        dynamic res = await Providers.confirmAttendance(bookingId: bookingId);
        print(res.data);
        if (res.data['code'] == 'SUCCESS') {
          print('berhasil checkin');
          getBookByTripId(widget.tripId);
        }
      } catch (e) {
        print(e);
      }
    }

    final screenSize = MediaQuery.of(context).size;
    return StoreConnector<AppState, AjkState>(
        converter: (store) => store.state.ajkState,
        builder: (context, state) {
          return Container(
            height: screenSize.height,
            // color: Colors.black.withOpacity(0.20),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    // height: screenSize.height / 1.5,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: screenSize.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 20, left: 30),
                                child: CustomText(
                                  "${AppTranslations.of(context).text("detail_pass")} [${state.selectedBooking.length}]",
                                  color: ColorsCustom.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 20),
                              Container(
                                height: screenSize.height / 2,
                                child: Container(
                                  width: screenSize.width,
                                  child: Column(
                                    children: [
                                      // generateListPassenger(
                                      //     name: 'Test',
                                      //     divisionName: 'Internship',
                                      //     checkIn: false),
                                      ListView.builder(
                                        physics: ScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: state.selectedBooking.length,
                                        padding: EdgeInsets.only(bottom: 100),
                                        itemBuilder: (context, index) {
                                          return generateListPassenger(
                                              name: state.selectedBooking[index]
                                                  ['user']['name'],
                                              divisionName:
                                                  state.selectedBooking[index]
                                                          ['user']['division']
                                                      ['division_name'],
                                              checkIn:
                                                  state.selectedBooking[index]
                                                      ['attended'],
                                              tripId: widget.tripId,
                                              onCheckIn: () {
                                                print('object');
                                                checkInTrip(
                                                    state.selectedBooking[index]
                                                        ["booking_id"]);
                                              });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                widget.isCompleted
                    ? SizedBox(
                        height: double.infinity,
                        width: double.infinity,
                      )
                    : Positioned(
                        bottom: 32,
                        left: 20,
                        right: 20,
                        child: ElevatedButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              backgroundColor: ColorsCustom.primary,
                              elevation: 0,
                            ),
                            onPressed: () {
                              getBookByTripId(widget.tripId);
                            },
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(
                                Icons.refresh,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                'Refresh',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    fontFamily: 'Poppins'),
                              ),
                            ])),
                      ),
              ],
            ),
          );
        });
  }

  Widget generateListPassenger(
      {String name,
      String divisionName,
      bool checkIn,
      String tripId,
      Function onCheckIn}) {
    var store = StoreProvider.of<AppState>(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16, top: 10),
                  child: Row(
                    children: [
                      CustomText(
                        "$name",
                        color: ColorsCustom.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      //generate
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 16, bottom: 5),
                  child: CustomText(
                    "$divisionName",
                    color: ColorsCustom.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            checkIn
                ? Container(
                    margin: EdgeInsets.only(right: 16),
                    child: Icon(
                      Icons.check_circle,
                      size: 30,
                      color: ColorsCustom.green,
                    ),
                  )
                : store.state.ajkState.selectedMyTrip['status'] == 'ASSIGNED'
                    ? SizedBox()
                    : Container(
                        margin: EdgeInsets.only(right: 16),
                        child: ElevatedButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            backgroundColor: ColorsCustom.primary,
                            elevation: 0,
                          ),
                          onPressed: () {
                            onCheckIn();
                          },
                          child: Text(
                            'Check In',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                fontFamily: 'Poppins'),
                          ),
                        ),
                      ),
          ],
        ),
        SizedBox(height: 5),
        Divider(color: Colors.grey, height: 1),
        SizedBox(height: 5),
      ],
    );
  }

  Widget generateVaccinated(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 8),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: ColorsCustom.primaryGreenVeryLow,
          borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            AppTranslations.of(context).text("vaccinated"),
            color: ColorsCustom.primaryGreenHigh,
            fontSize: 8,
            fontWeight: FontWeight.w400,
          ),
          SizedBox(width: 4),
          SvgPicture.asset(
            'assets/images/vaccinated-icon.svg',
            width: 12,
          )
        ],
      ),
    );
  }
}
