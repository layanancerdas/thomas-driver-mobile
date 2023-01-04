import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:redux/redux.dart';
import 'package:tomas_driver/configs/config.dart';
import 'package:tomas_driver/providers/providers.dart';
import 'package:tomas_driver/redux/actions/ajk_action.dart';
import 'package:tomas_driver/redux/app_state.dart';
import 'package:tomas_driver/screens/live_tracking/widgets/dialog_qr.dart';
import 'package:tomas_driver/screens/viewmap/view_map.dart';

abstract class ViewMapViewModel extends State<ViewMap> {
  Store<AppState> store;
  var _streamDB;

  double duration = 0;
  String status;
  String subStatus;
  String etaTime;

  void onViewETicket() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogQr();
        });
  }

  Future<void> getBookingByGroupId() async {
    try {
      dynamic res = await Providers.getTripByTripId(
          tripId: store.state.ajkState.selectedMyTrip['trip']['trip_order_id']);
      if (res.data['code'] == 'SUCCESS') {
        store.dispatch(SetSelectedMyTrip(selectedMyTrip: res.data['data']));

        setState(() {
          isStart = true;
        });
        if (res.data['data']['status'] == 'COMPLETED') {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print(e);
    } finally {
      // getStatusText();
    }
  }

  // Future<void> getETATime({Map origin, Map destination}) async {
  //   try {
  //     dynamic res =
  //         await Providers.getETATime(origin: origin, destination: destination);
  //         print('=====================================================================');
  //         print(res);
  //     setState(() {
  //       etaTime = res.data['rows'][0]['element'][0]['duration']['text'];
  //     });
  //   } catch (e) {
  //     print(e);
  //   } finally {
  //     getStatusText();
  //   }
  // }

  void getStatusText() {
    setState(() {
      // print(store.state.ajkState.selectedMyTrip['status']);

      if (store.state.ajkState.selectedMyTrip['booking_note'] != null) {
        if (store.state.ajkState.selectedMyTrip['booking_note'] ==
            'DRIVER_ON_THE_WAY') {
          status = 'Driver On The Way';
        } else if (store.state.ajkState.selectedMyTrip['booking_note'] ==
            'DRIVER_HAS_ARRIVED') {
          status = "Driver Has Arrived";
        } else if (store.state.ajkState.selectedMyTrip['booking_note'] ==
            'ON_BOARD') {
          status = "On Board";
        }
      } else {
        status = "Loading...";
      }
    });
  }

  void getSubStatusText() {
    setState(() {
      // print(store.state.ajkState.selectedMyTrip['status']);

      if (store.state.ajkState.selectedMyTrip['booking_note'] != null) {
        if (store.state.ajkState.selectedMyTrip['booking_note'] ==
            'DRIVER_ON_THE_WAY') {
          subStatus = 'Your driver is coming';
        } else if (store.state.ajkState.selectedMyTrip['booking_note'] ==
            'DRIVER_HAS_ARRIVED') {
          subStatus = "Your driver has arrived";
        } else if (store.state.ajkState.selectedMyTrip['booking_note'] ==
            'ON_BOARD') {
          subStatus = "On board";
        }
      } else {
        subStatus = "Loading...";
      }
    });
  }

  Completer<GoogleMapController> _controller = Completer();
  // GoogleMapController controller;
  Map<MarkerId, Marker> markers = {};
  Map<CircleId, Circle> circles = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Map latlng;

  bool isStart = false;

  final CameraPosition initialLocation = CameraPosition(
    target: LatLng(-6.1753871, 106.829641),
    zoom: 12,
  );

  Future<Uint8List> getMarker(String url) async {
    ByteData byteData = await DefaultAssetBundle.of(context).load(url);
    return byteData.buffer.asUint8List();
  }

  // void updateMarkerAndCircleBus(Map newLocalData, Uint8List imageData) {
  //   LatLng latlng = LatLng(newLocalData['lat'], newLocalData['lng']);
  //   MarkerId markerId = MarkerId('home');
  //   Marker marker = Marker(
  //       markerId: markerId,
  //       position: latlng,
  //       rotation: 0,
  //       draggable: false,
  //       zIndex: 2,
  //       flat: true,
  //       anchor: Offset(0.5, 0.5),
  //       icon: BitmapDescriptor.fromBytes(imageData));
  //   CircleId circleId = CircleId("car");
  //   Circle circle = Circle(
  //       circleId: circleId,
  //       radius: 20,
  //       zIndex: 1,
  //       strokeColor: Colors.blue,
  //       strokeWidth: 1,
  //       center: latlng,
  //       fillColor: Colors.blue.withAlpha(70));
  //   setState(() {
  //     markers[markerId] = marker;
  //     circles[circleId] = circle;
  //   });
  // }

  // // void getCurrentLocation(Map newData) async {
  // //   try {
  // //     Uint8List imageData = await getMarker("assets/images/bus.png");

  // //     updateMarkerAndCircleBus(newData, imageData);
  // //     if (controller != null) {
  // //       controller.animateCamera(CameraUpdate.newCameraPosition(
  // //           new CameraPosition(
  // //               target: LatLng(newData['lat'], newData['lng']), zoom: 12.00)));
  // //       updateMarkerAndCircleBus(newData, imageData);

  // //       List _tempPickupPoints = store.state.ajkState.selectedMyTrip['trip']
  // //           ['trip_group']['route']['pickup_points'] as List;

  // //       if (_tempPickupPoints.length > 1) {
  // //         generateMultiplePolylines(newData);
  // //       } else {
  // //         generateSinglePolyline(newData);
  // //       }
  // //     }
  // //   } on PlatformException catch (e) {
  // //     if (e.code == 'PERMISSION_DENIED') {
  // //       debugPrint("Permission Denied");
  // //     }
  // //   }
  // // }

  // // void getRouteMap(Map newData) async {
  // //   List _tempPickupPoints = store.state.ajkState.selectedMyTrip['trip']['trip_group']['route']['pickup_points'] as List;
  // //   if (_tempPickupPoints.length > 1) {
  // //     generateMultiplePolylines(newData);
  // //   } else {
  // //     generateSinglePolyline(newData);
  // //   }
  // // }

  // Future<void> getUserLocation() async {
  //   print('========== GET CURRENT LOCATION ==========');
  //   Uint8List iconUser = await getMarker("assets/images/bus.png");
  //   Position position = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.best);
  //   print(position);

  //   addMarker(
  //       position: LatLng(position.latitude, position.longitude),
  //       id: "pickupPointBus",
  //       descriptor: BitmapDescriptor.fromBytes(iconUser),
  //       anchor: Offset(0.5, 0.5));

  //   Map mapData = {
  //     'lat':position.latitude,
  //     'lng':position.longitude
  //   };
  //   generateSinglePolyline(mapData);

  // }

  // Future<void> generateMarker() async {
  //   Uint8List iconDestination =
  //       await getMarker("assets/images/pin_destination.png");
  //   Uint8List iconPickupPoint =
  //       await getMarker("assets/images/pin_pickup_point.png");

  //   LatLng destination = LatLng(
  //         store.state.ajkState.selectedMyTrip['trip']['trip_group']['route']
  //             ['destination_latitude'],
  //         store.state.ajkState.selectedMyTrip['trip']['trip_group']['route']
  //             ['destination_longitude']);

  //     addMarker(
  //         position: destination,
  //         id: "destination",
  //         descriptor: BitmapDescriptor.fromBytes(iconDestination),
  //         anchor: Offset(0.5, 0.5));

  //     List _tempPickupPoints = store.state.ajkState.selectedMyTrip['trip']
  //         ['trip_group']['route']['pickup_points'] as List;

  //     int i = 0;
  //     for (Map element in _tempPickupPoints) {
  //       print('ASUUUUUUUUUUUPPPPPPPPPP');
  //       print(element['latitude']);
  //       print(element['longitude']);
  //       LatLng pickupPointElement =
  //           LatLng(element['latitude'], element['longitude']);
  //       addMarker(
  //           position: pickupPointElement,
  //           id: "pickupPoint${i}",
  //           descriptor: BitmapDescriptor.fromBytes(iconPickupPoint),
  //           anchor: Offset(0.5, 0.5));
  //       i++;
  //     }
  // }

  // void generateSinglePolyline(Map newData) {
  //   // if (status == 'Driver On The Way') {
  //   //   List _tempPickupPoints = store.state.ajkState.selectedMyTrip['trip']
  //   //       ['trip_group']['route']['pickup_points'] as List;
  //   //   Map pick = {
  //   //     "lat": _tempPickupPoints[0]['latitude'],
  //   //     "lng": _tempPickupPoints[0]['longitude']
  //   //   };
  //   //   getPolyline(newData, pick, "otw");
  //   //   // getETATime(origin: newData, destination: pick);
  //   // } else if (status == 'On Board') {
  //   //   // destination
  //   //   Map destination = {
  //   //     'lat': store.state.ajkState.selectedMyTrip['trip']['trip_group']
  //   //         ['route']['destination_latitude'],
  //   //     'lng': store.state.ajkState.selectedMyTrip['trip']['trip_group']
  //   //         ['route']['destination_longitude']
  //   //   };
  //   //   getPolyline(newData, destination, "single");
  //   //   // getETATime(origin: newData, destination: destination);
  //   // }
  //   Map destination = {
  //     'lat': widget.lat,
  //     'lng': widget.lng
  //   };
  //   List<PolylineWayPoint> _wayPoint = new List<PolylineWayPoint>();
  //   getPolyline(newData, destination, "single", _wayPoint);
  // }

  // void generateMultiplePolylines() {

  //   Map destination = {
  //       'lat': store.state.ajkState.selectedMyTrip['trip']['trip_group']
  //           ['route']['destination_latitude'],
  //       'lng': store.state.ajkState.selectedMyTrip['trip']['trip_group']
  //           ['route']['destination_longitude']
  //     };

  //     List _tempPickupPoints = store.state.ajkState.selectedMyTrip['trip']
  //         ['trip_group']['route']['pickup_points'] as List;

  //     Map newData = {
  //       "lat": _tempPickupPoints[0]['latitude'],
  //       "lng": _tempPickupPoints[0]['longitude']
  //     };

  //     List<PolylineWayPoint> _wayPoint = new List<PolylineWayPoint>();

  //     for (Map element in _tempPickupPoints) {
  //       _wayPoint.add(PolylineWayPoint(
  //           location: "${element['address']} ${element['name']}",
  //           stopOver: true));
  //     }

  //     getPolyline(newData, destination, "1", _wayPoint);
  //     // getETATime(origin: newData, destination: destination);
  // }

  addMarker(
      {LatLng position,
      String id,
      BitmapDescriptor descriptor,
      Offset anchor}) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(
        markerId: markerId,
        icon: descriptor,
        position: position,
        flat: true,
        anchor: anchor);
    setState(() {
      markers[markerId] = marker;
    });
  }

  // addPolyLine(String _id) {
  //   PolylineId polyId = PolylineId("$_id");
  //   Polyline polyline = Polyline(
  //       polylineId: polyId,
  //       color: Color(0xFF5BB1C8),
  //       width: 6,
  //       points: polylineCoordinates);

  //   setState(() {
  //     polylines[polyId] = polyline;
  //   });
  // }

  // getPolyline(Map origin, Map destination, String id,
  //     [List<PolylineWayPoint> waypoint]) async {
  //   PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //       GOOGLE_API_KEY,
  //       PointLatLng(origin['lat'], origin['lng']),
  //       PointLatLng(destination['lat'], destination['lng']),
  //       travelMode: TravelMode.driving,
  //       optimizeWaypoints: true,
  //       wayPoints: waypoint ?? []);
  //   print("try polylines");
  //   if (result.points.isNotEmpty) {
  //     print("polylines");
  //     polylineCoordinates.clear();
  //     result.points.forEach((PointLatLng point) {
  //       polylineCoordinates.add(LatLng(point.latitude, point.longitude));
  //     });
  //   }
  //   addPolyLine(id);
  // }

  Future<void> generateLocation() async {
    Uint8List iconLocation =
        await getMarker("assets/images/pin_destination.png");

    addMarker(
        position: LatLng(widget.lat, widget.lng),
        id: "destination",
        descriptor: BitmapDescriptor.fromBytes(iconLocation),
        anchor: Offset(0.5, 0.5));

    final GoogleMapController controller = await _controller.future;
    controller.moveCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(widget.lat, widget.lng), zoom: 10)));
  }

  @override
  void initState() {
    super.initState();
    generateLocation();
    // initialize();
    // Timer.periodic(Duration(seconds: 5), (timer) {
    //   getUserLocation();
    // });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      store = StoreProvider.of<AppState>(context);
      // getBookingByGroupId();
      // getStatusText();
      // getSubStatusText();
      // generateMarker();
      // generateMultiplePolylines();
      // getCurrentLocation(latlng);
    });
  }

  @override
  void dispose() {
    _streamDB?.cancel();
    super.dispose();
  }
}
