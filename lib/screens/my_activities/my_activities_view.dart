import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tomas_driver/localization/app_translations.dart';
import 'package:tomas_driver/providers/providers.dart';
import 'package:tomas_driver/redux/app_state.dart';
import 'package:tomas_driver/redux/modules/ajk_state.dart';
import 'package:tomas_driver/widgets/card_trips.dart';
import 'package:tomas_driver/widgets/no_assignments.dart';
import './my_activities_view_model.dart';
import 'package:tomas_driver/widgets/custom_text.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/helpers/custom_tab_indicator.dart';

class MyActivitiesView extends MyActivitiesViewModel {
  @override
  Widget build(BuildContext context) {
    // Replace this with your build function
    return DefaultTabController(
        initialIndex: widget.index,
        length: 3,
        child: Scaffold(
            appBar: AppBar(
              centerTitle: false,
              title: CustomText(
                AppTranslations.of(context).text("home_menu_activity"),
                color: ColorsCustom.black,
                fontWeight: FontWeight.w500,
                fontSize: 24,
              ),
              bottom: TabBar(
                unselectedLabelColor: ColorsCustom.generalText,
                labelColor: ColorsCustom.primary,
                labelPadding: EdgeInsets.all(0),
                unselectedLabelStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: ColorsCustom.primary,
                    fontFamily: "Poppins"),
                labelStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorsCustom.primary,
                    fontFamily: "Poppins"),
                indicator: CustomTabIndicator(
                    color: ColorsCustom.primary,
                    radius: 10,
                    width: 16,
                    height: 3),
                tabs: [
                  Tab(
                      text: AppTranslations.of(context)
                          .text("my_activity_assigned")),
                  Tab(
                      text: AppTranslations.of(context)
                          .text("my_activity_ongoing")),
                  Tab(
                      text: AppTranslations.of(context)
                          .text("my_activity_completed")),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                asignedTripSection(context),
                ongGoingTripSection(context),
                completedTripSection(context)
              ],
            )));
  }

  Widget ongGoingTripSection(BuildContext context) {
    return StoreConnector<AppState, AjkState>(
        converter: (store) => store.state.ajkState,
        builder: (context, state) {
          return SmartRefresher(
            controller: refreshControllerOngoing,
            enablePullUp: state.ongoingTrip.length > 0 ?? false,
            enablePullDown: true,
            onLoading: onLoadingOnGoing,
            onRefresh: onRefreshOnGoing,
            header: ClassicHeader(),
            footer: ClassicFooter(
              loadStyle: LoadStyle.ShowWhenLoading,
            ),
            child: state.ongoingTrip.length == 0
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 50.0),
                      child: NoAssignments(AppTranslations.of(context)
                          .text("empty_state_ongoing_trip")),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.ongoingTrip.length,
                    padding: EdgeInsets.only(top: 20),
                    itemBuilder: (ctx, i) {
                      return CardTrips(
                        dateA: DateTime.fromMicrosecondsSinceEpoch(
                            state.ongoingTrip[i]['trip']['departure_time'] *
                                1000),
                        dateB: 'RETURN' == 'RETURN'
                            ? DateTime.now()
                            : DateTime.now().add(Duration(minutes: 20)).day,
                        timeB: 'RETURN' == 'RETURN'
                            ? DateTime.now()
                            : DateTime.now().add(Duration(minutes: 20)),
                        timeA: DateTime.fromMicrosecondsSinceEpoch(
                            state.ongoingTrip[i]['trip']['departure_time']),
                        title: 'Shift Siang',
                        pointA: 'Bandung',
                        pointB: 'Tasik',
                        type: state.ongoingTrip[i]['trip']['type'],
                        //data: ,
                        id: state.ongoingTrip[i]['trip_order_id'],
                        differenceAB: 'tes',
                        status: state.ongoingTrip[i]['status'],
                        stepTrip: (state
                                    .ongoingTrip[i]['trip']['trip_group']
                                        ['route']['pickup_points']
                                    .length -
                                1)
                            .toString(),
                        pickupPoint: state.ongoingTrip[i]['trip']['trip_group']
                            ['route']['pickup_points'],
                        destinationName: state.ongoingTrip[i]['trip']
                            ['trip_group']['route']['destination_name'],
                        tripHistories: state.ongoingTrip[i]['trip_histories'],
                        data: state.ongoingTrip[i],
                      );
                    }),
          );
        });
  }

  Widget asignedTripSection(BuildContext context) {
    return StoreConnector<AppState, AjkState>(
        converter: (store) => store.state.ajkState,
        builder: (context, state) {
          return SmartRefresher(
            controller: refreshControllerAssigned,
            enablePullUp: (state.assignedTrip.length > 0 &&
                    state.assignedTrip.length % 10 == 0) ??
                false,
            enablePullDown: true,
            onLoading: onLoadingAssigned,
            onRefresh: onRefreshAssigned,
            header: ClassicHeader(),
            footer: ClassicFooter(
              loadStyle: LoadStyle.ShowWhenLoading,
            ),
            child: state.assignedTrip.length == 0
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 50.0),
                      child: NoAssignments(
                          AppTranslations.of(context).text("empty_state_trip")),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.assignedTrip.length,
                    padding: EdgeInsets.only(top: 20),
                    itemBuilder: (ctx, i) {
                      return CardTrips(
                        dateA: DateTime.fromMicrosecondsSinceEpoch(
                            state.assignedTrip[i]['trip']['departure_time'] *
                                1000),
                        dateB: 'RETURN' == 'RETURN'
                            ? DateTime.now()
                            : DateTime.now().add(Duration(minutes: 20)).day,
                        timeB: 'RETURN' == 'RETURN'
                            ? DateTime.now()
                            : DateTime.now().add(Duration(minutes: 20)),
                        timeA: DateTime.fromMicrosecondsSinceEpoch(
                            state.assignedTrip[i]['trip']['departure_time']),
                        title: 'Shift Siang',
                        pointA: 'Bandung',
                        pointB: 'Tasik',
                        type: state.assignedTrip[i]['trip']['type'],
                        //data: ,
                        id: state.assignedTrip[i]['trip_order_id'],
                        differenceAB: 'tes',
                        status: state.assignedTrip[i]['status'],
                        stepTrip: (state
                                    .assignedTrip[i]['trip']['trip_group']
                                        ['route']['pickup_points']
                                    .length -
                                1)
                            .toString(),
                        pickupPoint: state.assignedTrip[i]['trip']['trip_group']
                            ['route']['pickup_points'],
                        destinationName: state.assignedTrip[i]['trip']
                            ['trip_group']['route']['destination_name'],
                        tripHistories: state.assignedTrip[i]['trip_histories'],
                        data: state.assignedTrip[i],
                      );
                    }),
          );
        });
  }

  Widget completedTripSection(BuildContext context) {
    return StoreConnector<AppState, AjkState>(
        converter: (store) => store.state.ajkState,
        builder: (context, state) {
          return SmartRefresher(
            controller: refreshControllerComplete,
            enablePullUp: (state.completedTrip.length > 0 &&
                    state.completedTrip.length % 10 == 0) ??
                false,
            enablePullDown: true,
            onLoading: onLoadingCompleted,
            onRefresh: onRefreshCompleted,
            header: ClassicHeader(),
            footer: ClassicFooter(
              loadStyle: LoadStyle.ShowWhenLoading,
            ),
            child: state.completedTrip.length == 0
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 50.0),
                      child: NoAssignments(AppTranslations.of(context)
                          .text("empty_state_completed_trip")),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.completedTrip.length,
                    padding: EdgeInsets.only(top: 20),
                    itemBuilder: (ctx, i) {
                      return CardTrips(
                          dateA: DateTime.fromMicrosecondsSinceEpoch(
                              state.completedTrip[i]['trip']['departure_time'] *
                                  1000),
                          dateB: 'RETURN' == 'RETURN'
                              ? DateTime.now()
                              : DateTime.now().add(Duration(minutes: 20)).day,
                          timeB: 'RETURN' == 'RETURN'
                              ? DateTime.now()
                              : DateTime.now().add(Duration(minutes: 20)),
                          timeA: DateTime.fromMicrosecondsSinceEpoch(
                              state.completedTrip[i]['trip']['departure_time']),
                          title: 'Shift Siang',
                          pointA: 'Bandung',
                          pointB: 'Tasik',
                          type: state.completedTrip[i]['trip']['type'],
                          //data: ,
                          id: state.completedTrip[i]['trip_order_id'],
                          differenceAB: 'tes',
                          status: state.completedTrip[i]['status'],
                          stepTrip:
                              (state.completedTrip[i]['trip']['trip_group']['route']['pickup_points'].length -
                                      1)
                                  .toString(),
                          pickupPoint: state.completedTrip[i]['trip']
                              ['trip_group']['route']['pickup_points'],
                          destinationName: state.completedTrip[i]['trip']
                              ['trip_group']['route']['destination_name'],
                          tripHistories: state.completedTrip[i]['trip_histories'],
                          data: state.completedTrip[i]);
                    }),
          );
        });
  }
}
