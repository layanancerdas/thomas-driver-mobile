// import 'dart:io';
// import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading/indicator/ball_spin_fade_loader_indicator.dart';
import 'package:loading/loading.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/localization/app_translations.dart';
import 'package:tomas_driver/redux/app_state.dart';
import 'package:tomas_driver/redux/modules/general_state.dart';
import 'package:tomas_driver/redux/modules/ajk_state.dart';
import 'package:tomas_driver/redux/modules/user_state.dart';
import 'package:tomas_driver/screens/home/widgets/list_day.dart';
import 'package:tomas_driver/screens/my_activities/my_activities.dart';
import 'package:tomas_driver/widgets/custom_text.dart';
// ignore: unused_import
import 'package:tomas_driver/widgets/no_assignments.dart';
import 'package:tomas_driver/widgets/card_trips.dart';
import './home_view_model.dart';
// import 'package:jiffy/jiffy.dart';
import 'package:tomas_driver/widgets/no_assignments.dart';
import 'package:tomas_driver/configs/config.dart';

class HomeView extends HomeViewModel {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark));
    return StoreConnector<AppState, GeneralState>(
        converter: (store) => store.state.generalState,
        builder: (context, state) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: widget.tab != null
                ? MyActivities(index: widget.tab)
                : children[currentIndex]['name'] == 'home_menu_home'
                    ? getScaffold(context)
                    : children[currentIndex]['page'],
            bottomNavigationBar: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: state.disableNavbar ? 0 : 90,
                child: new BottomNavigationBar(
                  onTap: onTabTapped,
                  currentIndex: currentIndex,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: ColorsCustom.black,
                  backgroundColor: Colors.white,
                  elevation: 10,
                  unselectedFontSize: 12,
                  selectedFontSize: 12,
                  showUnselectedLabels: true,
                  unselectedItemColor: ColorsCustom.disable,
                  items: [
                    BottomNavigationBarItem(
                      icon: currentIndex == 0
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: SvgPicture.asset(
                                  "assets/images/home_filled.svg"),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: SvgPicture.asset(
                                  "assets/images/home_outline.svg"),
                            ),
                      label:
                          '${AppTranslations.of(context).text("${children[0]['name']}")}',
                    ),
                    BottomNavigationBarItem(
                      icon: currentIndex == 1
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 7),
                              child: SvgPicture.asset(
                                  "assets/images/activities_filled.svg"),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 3),
                              child: SvgPicture.asset(
                                  "assets/images/activities_outline.svg"),
                            ),
                      label:
                          '${AppTranslations.of(context).text("${children[1]['name']}")}',
                    ),
                    BottomNavigationBarItem(
                      icon: currentIndex == 2
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: state.notifications
                                          .toString()
                                          .contains('is_read: false') ||
                                      !isHaveNewNotif
                                  ? SvgPicture.asset(
                                      "assets/images/notifications_filled.svg")
                                  : SvgPicture.asset(
                                      "assets/images/new_notification_filled.svg"),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: state.notifications
                                          .toString()
                                          .contains('is_read: false') ||
                                      !isHaveNewNotif
                                  ? SvgPicture.asset(
                                      "assets/images/notifications_outline.svg")
                                  : SvgPicture.asset(
                                      "assets/images/new_notification_outline.svg"),
                            ),
                      label:
                          '${AppTranslations.of(context).text("${children[2]['name']}")}',
                    ),
                    BottomNavigationBarItem(
                      icon: currentIndex == 3
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 7),
                              child: SvgPicture.asset(
                                  "assets/images/user_filled.svg"),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 7),
                              child: SvgPicture.asset(
                                  "assets/images/user_outline.svg"),
                            ),
                      label:
                          '${AppTranslations.of(context).text("${children[3]['name']}")}',
                    ),
                  ],
                )
                // : SizedBox(),
                ),
          );
        });
  }

  Widget getScaffold(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: StoreConnector<AppState, AppState>(
            converter: (store) => store.state,
            builder: (context, state) {
              return Stack(
                children: [
                  Container(
                    height: double.infinity,
                    width: double.infinity,
                    padding: EdgeInsets.only(top: 174),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: CustomText(
                            "$month1, $vYear",
                            color: ColorsCustom.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                        ListDay(getTripByDriverId: getTripByDriverId),
                        !isLoadingTrip
                            ? Expanded(
                                child: Container(
                                  width: double.infinity,
                                  child: tripPerDay.length <= 0
                                      ? SingleChildScrollView(
                                          child: NoAssignments(AppTranslations.of(context).text("empty_state_trip")))
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: tripPerDay.length,
                                          padding: EdgeInsets.only(top: 20),
                                          itemBuilder: (ctx, i) {
                                            return CardTrips(
                                              home: true,
                                              parentFunction: checkFirstTrip,
                                              dateA: DateTime
                                                  .fromMicrosecondsSinceEpoch(
                                                      tripPerDay[i]['trip'][
                                                              'departure_time'] *
                                                          1000),
                                              dateB: 'RETURN' == 'RETURN'
                                                  ? DateTime.now()
                                                  : DateTime.now()
                                                      .add(
                                                          Duration(minutes: 20))
                                                      .day,
                                              timeB: 'RETURN' == 'RETURN'
                                                  ? DateTime.now()
                                                  : DateTime.now().add(
                                                      Duration(minutes: 20)),
                                              timeA: DateTime
                                                  .fromMicrosecondsSinceEpoch(
                                                      tripPerDay[i]['trip']
                                                          ['departure_time']),
                                              title: 'Shift Siang',
                                              pointA: 'Bandung',
                                              pointB: 'Tasik',
                                              type: tripPerDay[i]['trip']
                                                  ['type'],
                                              //data: ,
                                              id: tripPerDay[i]
                                                  ['trip_order_id'],
                                              differenceAB: 'tes',
                                              status: tripPerDay[i]['status'],
                                              stepTrip: (tripPerDay[i]['trip'][
                                                                      'trip_group']
                                                                  ['route']
                                                              ['pickup_points']
                                                          .length -
                                                      1)
                                                  .toString(),
                                              pickupPoint: tripPerDay[i]['trip']
                                                      ['trip_group']['route']
                                                  ['pickup_points'],
                                              destinationName: tripPerDay[i]
                                                      ['trip']['trip_group']
                                                  ['route']['destination_name'],
                                              tripHistories: tripPerDay[i]
                                                  ['trip_histories'],
                                              data: tripPerDay[i],
                                            );
                                          }),
                                ),
                              )
                            : Container(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 200),
                                    SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: Loading(
                                        color: ColorsCustom.primary,
                                        indicator:
                                            BallSpinFadeLoaderIndicator(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(minHeight: 150),
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(16, 50, 16, 16),
                    decoration: BoxDecoration(
                      color: ColorsCustom.primary,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                            child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              "${AppTranslations.of(context).text("home_welcome")},",
                              //AppTranslations.of(context).currentLanguage,
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                            SizedBox(height: 4),
                            CustomText(
                              userName == "" || userName == null
                                  ? ""
                                  : userName,
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                            ),
                          ],
                        )),
                        Container(
                            margin: EdgeInsets.only(right: 16),
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(35),
                                color: ColorsCustom.disable),
                            child: fotoProfile != null || userName != ""
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(35),
                                    child: Image.network(
                                      "$BASE_API/files/$fotoProfile",
                                      fit: BoxFit.cover,
                                      height: 50,
                                      width: 50,
                                      // errorBuilder: (context, error,
                                      //         stackTrace) =>
                                      //     SvgPicture.asset(
                                      //         "assets/images/placeholder_user.svg"),
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(35),
                                    child: SvgPicture.asset(
                                      'assets/images/placeholder_user.svg',
                                      fit: BoxFit.cover,
                                      height: 50,
                                      width: 50,
                                    ))),
                        // Container(
                        //   margin: EdgeInsets.only(right: 16),
                        //   height: 48,
                        //   width: 48,
                        //   decoration: BoxDecoration(
                        //     shape: BoxShape.circle,
                        //     // borderRadius: BorderRadius.circular(30),
                        //     image: DecorationImage(
                        //       fit: BoxFit.contain,
                        //       image: fotoProfile == "" ? SvgPicture("assets/images/placeholder_user.svg") : NetworkImage(BASE_API +"/files/"+fotoProfile))
                        //     ),
                        //   ),
                      ],
                    ),
                  ),
                  isLoading || state.generalState.isLoading
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
                              indicator: BallSpinFadeLoaderIndicator(),
                            ),
                          ),
                        )
                      : SizedBox()
                ],
              );
            }));
  }
}
