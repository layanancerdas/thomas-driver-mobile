import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading/indicator/ball_spin_fade_loader_indicator.dart';
import 'package:loading/loading.dart';
import 'package:tomas_driver/configs/config.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/localization/app_translations.dart';
import 'package:tomas_driver/redux/app_state.dart';
import 'package:tomas_driver/redux/modules/ajk_state.dart';
import 'package:tomas_driver/widgets/custom_text.dart';
import 'package:tomas_driver/widgets/custom_toast.dart';
import 'package:url_launcher/url_launcher.dart';
import './live_tracking_view_model.dart';

class LiveTrackingView extends LiveTrackingViewModel {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          style: TextButton.styleFrom(),
          onPressed: () => Navigator.pop(context),
          child: SvgPicture.asset(
            'assets/images/back_icon.svg',
          ),
        ),
        title: CustomText(
          AppTranslations.of(context).text("map_on"),
          // routeBuilt && !isNavigating ? "Clear Route" : "Build Route",
          color: ColorsCustom.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      body: StoreConnector<AppState, AjkState>(
          converter: (store) => store.state.ajkState,
          builder: (context, state) {
            return Stack(
              children: [
                Container(
                    height: double.infinity,
                    width: double.infinity,
                    // decoration: BoxDecoration(
                    //     image: DecorationImage(
                    //         image: AssetImage("assets/images/map-dummy.jpeg"),
                    //         fit: BoxFit.cover)),
                    child: GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: initialLocation,
                      markers: Set<Marker>.of(markers.values),
                      circles: Set<Circle>.of(circles.values),
                      polylines: Set<Polyline>.of(polylines.values),
                      myLocationButtonEnabled: false,
                      onMapCreated: (GoogleMapController _controller) {
                        controller = _controller;
                        getUserLocation(initLocation: true);
                      },
                    )
                    // )
                    // MyApp())
                    // Image.network(getStaticImageWithPolyline()))
                    // child: MapBoxNavigationView(
                    //     options: options,
                    //     onRouteEvent: onEmbeddedRouteEvent,
                    //     onCreated:
                    //         (MapBoxNavigationViewController _controller) async {
                    //       controller = _controller;
                    //       _controller.initialize();
                    //       onCreated();
                    //     }),
                    ),
                Positioned(
                    bottom: 30,
                    left: 16,
                    right: 16,
                    child: Container(
                      margin: EdgeInsets.only(top: 70),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 24,
                                offset: Offset(0, 4),
                                color: Colors.black12)
                          ]),
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                EdgeInsets.only(top: 16, left: 16, right: 16),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    //     CustomText(
                                    //       "${state.statusSelectedTrip}",
                                    //       color: ColorsCustom.generalText,
                                    //       fontWeight: FontWeight.w400,
                                    //       fontSize: 12,
                                    //     ),
                                    SizedBox(
                                        height: 50,
                                        width: 50,
                                        child: state.selectedMyTrip['driver']
                                                    ['photo'] !=
                                                null
                                            ? CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    '${BASE_API + "/files/" + state.selectedMyTrip['driver']['photo']}'),
                                              )
                                            : CircleAvatar(
                                                backgroundImage: AssetImage(
                                                'assets/images/placeholder_user.png',
                                              ))),
                                    SizedBox(width: 10),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          "${state.selectedMyTrip['driver']['name'] ?? "-"}",
                                          color: ColorsCustom.generalText,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                        CustomText(
                                          "${state.selectedMyTrip['bus']['license_plate'] ?? "-"}",
                                          color: ColorsCustom.generalText,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CustomText(
                                          "ETA ",
                                          color: ColorsCustom.generalText
                                              .withOpacity(0.5),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                        CustomText(
                                          "$etaTime",
                                          color: ColorsCustom.generalText,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ],
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(),
                                      onPressed: () {
                                        showPassenger(context);
                                      },
                                      child: CustomText(
                                        AppTranslations.of(context)
                                            .text("map_view"),
                                        color: ColorsCustom.primary,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Divider(color: Colors.grey, height: 1),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 18, horizontal: 16),
                            child: ElevatedButton(
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                                backgroundColor: MANAGE_TRIP_BY_TIME
                                    ? DateTime.now().isAfter(DateTime.fromMillisecondsSinceEpoch(store
                                                        .state
                                                        .ajkState
                                                        .selectedMyTrip['trip']
                                                    ['departure_time'])
                                                .subtract(
                                                    Duration(hours: 3))) &&
                                            DateTime.now().isBefore(
                                                DateTime.fromMillisecondsSinceEpoch(store
                                                            .state
                                                            .ajkState
                                                            .selectedMyTrip['trip']
                                                        ['departure_time'])
                                                    .add(Duration(days: 1)))
                                        ? Color(0xFF75C1D4)
                                        : Color(0xFF828282)
                                    : Color(0xFF75C1D4),
                              ),
                              onPressed: MANAGE_TRIP_BY_TIME
                                  ? DateTime.now().isAfter(DateTime.fromMillisecondsSinceEpoch(
                                                  store.state.ajkState
                                                          .selectedMyTrip['trip']
                                                      ['departure_time'])
                                              .subtract(Duration(hours: 3))) &&
                                          DateTime.now().isBefore(
                                              DateTime.fromMillisecondsSinceEpoch(
                                                      store.state.ajkState
                                                              .selectedMyTrip['trip']
                                                          ['departure_time'])
                                                  .add(Duration(days: 1)))
                                      ? () => manageTrip()
                                      : () => {
                                            showDialog(
                                                context: context,
                                                barrierColor: Colors.white24,
                                                builder:
                                                    (BuildContext context) {
                                                  return CustomToast(
                                                    title: AppTranslations.of(
                                                            context)
                                                        .text(
                                                            "error_start_trip"),
                                                    color: ColorsCustom.danger,
                                                    duration:
                                                        Duration(seconds: 2),
                                                  );
                                                })
                                          }
                                  : () => manageTrip(),
                              child: Container(
                                height: 56,
                                child: isLoading
                                    ? Center(
                                        child: SizedBox(
                                        width: 17,
                                        height: 17,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor:
                                              new AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      ))
                                    : Center(
                                        child: CustomText(
                                          "${state.buttonSelectedTrip}",
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          overflow: true,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                              ),
                            ),
                          )
                        ],
                      ),
                    )),
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
                            indicator: BallSpinFadeLoaderIndicator(),
                          ),
                        ),
                      )
                    : SizedBox()
              ],
            );
          }),
    );
  }
}
