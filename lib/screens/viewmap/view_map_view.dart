import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/redux/app_state.dart';
import 'package:tomas_driver/redux/modules/ajk_state.dart';
import 'package:tomas_driver/widgets/custom_text.dart';
import 'view_map_view_model.dart';

class ViewMapView extends ViewMapViewModel {
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
          widget.title,
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
                        _controller = _controller;
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
                // Positioned(
                //     bottom: 30,
                //     left: 16,
                //     right: 16,
                //     child: Container(
                //       decoration: BoxDecoration(
                //           color: Colors.white,
                //           borderRadius: BorderRadius.circular(8),
                //           boxShadow: [
                //             BoxShadow(
                //                 blurRadius: 24,
                //                 offset: Offset(0, 4),
                //                 color: Colors.black12)
                //           ]),
                //       child: Column(
                //         children: [
                //           Padding(
                //             padding: EdgeInsets.symmetric(
                //                 vertical: 18, horizontal: 16),
                //             child: Row(
                //               children: [
                //                 // SizedBox(
                //                 //     height: 50,
                //                 //     width: 50,
                //                 //     child: state.selectedMyTrip['details']
                //                 //                 ['driver']['photo'] !=
                //                 //             null
                //                 //         ? CircleAvatar(
                //                 //             backgroundImage: NetworkImage(
                //                 //                 '${BASE_API + "/files/" + state.selectedMyTrip['details']['driver']['photo']}'),
                //                 //           )
                //                 //         : CircleAvatar(
                //                 //             backgroundImage: AssetImage(
                //                 //             'assets/images/placeholder_user.png',
                //                 //           ))),
                //                 SizedBox(width: 10),
                //                 Expanded(
                //                     child: Column(
                //                   children: [
                //                     Row(
                //                       mainAxisAlignment:
                //                           MainAxisAlignment.spaceBetween,
                //                       children: [
                //                         CustomText(
                //                           "Heading to",
                //                           color: ColorsCustom.generalText,
                //                           fontWeight: FontWeight.w400,
                //                           fontSize: 12,
                //                         ),
                //                       ],
                //                     ),
                //                     SizedBox(height: 4),
                //                     Row(
                //                       mainAxisAlignment:
                //                           MainAxisAlignment.spaceBetween,
                //                       children: [
                //                         // CustomText(
                //                         //   "${state.selectedMyTrip['details']['driver']['name'] ?? "-"}",
                //                         //   color: ColorsCustom.generalText,
                //                         //   fontWeight: FontWeight.w500,
                //                         //   fontSize: 14,
                //                         // ),
                //                         Row(
                //                           mainAxisSize: MainAxisSize.min,
                //                           children: [
                //                             CustomText(
                //                               "ETA ",
                //                               color: ColorsCustom.generalText,
                //                               fontWeight: FontWeight.w500,
                //                               fontSize: 14,
                //                             ),
                //                             CustomText(
                //                               "15 Menit",
                //                               color: ColorsCustom.generalText,
                //                               fontWeight: FontWeight.w600,
                //                               fontSize: 14,
                //                             ),
                //                           ],
                //                         ),
                //                         CustomText(
                //                           "View Passengers",
                //                           color: ColorsCustom.primary,
                //                           fontWeight: FontWeight.w500,
                //                           fontSize: 14,
                //                         ),
                //                       ],
                //                     ),
                //                   ],
                //                 ))
                //               ],
                //             ),
                //           ),
                //           Divider(color: Colors.grey, height: 1),
                //           Padding(
                //             padding: EdgeInsets.symmetric(
                //                 vertical: 18, horizontal: 16),
                //             child: ElevatedButton(style: TextButton.styleFrom(),
                //               onPressed: () {
                //                 // manageTrip();
                //               },
                //               shape: RoundedRectangleBorder(
                //                 borderRadius: BorderRadius.circular(30),
                //                 side:
                //                     BorderSide(color: Color(0xFF75C1D4), width: 1),
                //               ),
                //               elevation: 0,
                //               color: Color(0xFF75C1D4),
                //               child: Container(
                //                 height: 56,
                //                 child: Center(
                //                   child: CustomText(
                //                     "Arrived at",
                //                     color: Colors.white,
                //                     fontWeight: FontWeight.w600,
                //                     fontSize: 16,
                //                   ),
                //                 ),
                //               ),
                //             ),
                //           )
                //         ],
                //       ),
                //     ))
              ],
            );
          }),
    );
  }
}
