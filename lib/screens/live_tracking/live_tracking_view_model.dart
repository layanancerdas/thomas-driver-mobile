import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:redux/redux.dart';
import 'package:tomas_driver/configs/config.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/localization/app_translations.dart';
import 'package:tomas_driver/providers/providers.dart';
import 'package:tomas_driver/redux/actions/ajk_action.dart';
import 'package:tomas_driver/redux/app_state.dart';
import 'package:tomas_driver/redux/modules/ajk_state.dart';
import 'package:tomas_driver/screens/live_tracking/widgets/dialog_qr.dart';
import 'package:tomas_driver/widgets/custom_text.dart';
import 'package:tomas_driver/widgets/passanger_body2.dart';
import 'package:tomas_driver/widgets/passengers_body.dart';
import 'package:tomas_driver/widgets/qr_scan.dart';
import './live_tracking.dart';

abstract class LiveTrackingViewModel extends State<LiveTracking> {
  Store<AppState> store;
  var _streamDB;

  double duration = 0;
  // String status;
  // String subStatus;
  String etaTime = "";

  String statusButtonName = "";
  String statusGlobalName = "";

  bool isLoading = false;

  PersistentBottomSheetController _controller; // <------ Instance variable
  bool isScanned = false;
  List content1 = [];
  List content2 = [];

  void makeData() {}

  void changeIsScanned(bool value) {
    setState(() {
      isScanned = value;
    });
  }

  void toggleLoading(bool status) {
    setState(() {
      isLoading = status;
    });
  }

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

  Future<void> getETATime({Map origin, Map destination}) async {
    try {
      dynamic res =
          await Providers.getETATime(origin: origin, destination: destination);
      setState(() {
        etaTime = res.data['rows'][0]['elements'][0]['duration']['text'];
      });
    } catch (e) {
      print(e);
    } finally {
      // getStatusText();
    }
  }

  GoogleMapController controller;
  Map<MarkerId, Marker> markers = {};
  Map<CircleId, Circle> circles = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Map latlng;
  final databaseReference = FirebaseDatabase.instance.reference();

  bool isStart = false;
  bool isTripAvailable = false;
  Timer timer;
  @override
  void initState() {
    super.initState();
    // initialize();
    timer = Timer.periodic(Duration(seconds: 5), (_) {
      if (mounted) {
        getUserLocation();
      }

      if (isStart) {
        //getUserLocation();
      }
      // _getCurrentLocation();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      store = StoreProvider.of<AppState>(context);
      getBookingByGroupId();
      // getStatusText();
      // getSubStatusText();
      statusHandler();

      // getTripdByTripId();
      // getCurrentLocation(latlng);
    });
  }

  @override
  void dispose() {
    timer.cancel();
    _streamDB?.cancel();
    super.dispose();
  }

  final CameraPosition initialLocation = CameraPosition(
    target: LatLng(-6.1753871, 106.829641),
    zoom: 12,
  );

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
    databaseReference.child("live_location/${tripOrderId}").remove();
  }

  Future<Uint8List> getMarker(String url) async {
    ByteData byteData = await DefaultAssetBundle.of(context).load(url);
    return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircleBus(Map newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData['lat'], newLocalData['lng']);
    MarkerId markerId = MarkerId('home');
    Marker marker = Marker(
        markerId: markerId,
        position: latlng,
        rotation: 0,
        draggable: false,
        zIndex: 2,
        flat: true,
        anchor: Offset(0.5, 0.5),
        icon: BitmapDescriptor.fromBytes(imageData));
    CircleId circleId = CircleId("car");
    Circle circle = Circle(
        circleId: circleId,
        radius: 20,
        zIndex: 1,
        strokeColor: Colors.blue,
        strokeWidth: 1,
        center: latlng,
        fillColor: Colors.blue.withAlpha(70));
    setState(() {
      markers[markerId] = marker;
      circles[circleId] = circle;
    });
  }

  Future<void> getUserLocation({bool initLocation: false}) async {
    Uint8List iconUser = await getMarker("assets/images/bus.png");
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    if (initLocation) {
      controller.animateCamera(CameraUpdate.newCameraPosition(
          new CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 17.00)));
      generateMarker();
    }

    readData();

    if (isTripAvailable) {
      updateData(position.latitude, position.longitude);
    } else {
      createData(position.latitude, position.longitude);
    }

    addMarker(
        position: LatLng(position.latitude, position.longitude),
        id: "pickupPointBus",
        descriptor: BitmapDescriptor.fromBytes(iconUser),
        anchor: Offset(0.5, 0.5));

    Map newData = {'lat': position.latitude, 'lng': position.longitude};
    // getRouteMap(newData);
    generateMultiplePolylines(newData);
  }

  Future<void> generateMarker() async {
    int totalHistory =
        store.state.ajkState.selectedMyTrip['trip_histories'].length;
    if (store.state.ajkState.selectedMyTrip['status'] == 'ONGOING' &&
        totalHistory == 1) {
      Uint8List iconPickupPoint =
          await getMarker("assets/images/pin_pickup_point.png");
      LatLng pickupPointElement = LatLng(
          store.state.ajkState.selectedMyTrip['trip']['type'] == "RETURN"
              ? store.state.ajkState.selectedMyTrip['trip']['trip_group']
                  ['route']['destination_latitude']
              : store.state.ajkState.selectedMyTrip['trip']['trip_group']
                  ['route']['pickup_points'][0]['latitude'],
          store.state.ajkState.selectedMyTrip['trip']['type'] == "RETURN"
              ? store.state.ajkState.selectedMyTrip['trip']['trip_group']
                  ['route']['destination_longitude']
              : store.state.ajkState.selectedMyTrip['trip']['trip_group']
                  ['route']['pickup_points'][0]['longitude']);
      addMarker(
          position: pickupPointElement,
          id: store.state.ajkState.selectedMyTrip['trip']['trip_group']['route']
              ['pickup_points'][0]['pickup_point_id'],
          descriptor: BitmapDescriptor.fromBytes(iconPickupPoint),
          anchor: Offset(0.5, 0.5));
    } else {
      Uint8List iconDestination =
          await getMarker("assets/images/pin_destination.png");
      Uint8List iconPickupPoint =
          await getMarker("assets/images/pin_pickup_point.png");

      LatLng destination = LatLng(
          store.state.ajkState.selectedMyTrip['trip']['type'] != "RETURN"
              ? store.state.ajkState.selectedMyTrip['trip']['trip_group']
                  ['route']['destination_latitude']
              : store.state.ajkState.selectedMyTrip['trip']['trip_group']
                  ['route']['pickup_points'][0]['latitude'],
          store.state.ajkState.selectedMyTrip['trip']['type'] != "RETURN"
              ? store.state.ajkState.selectedMyTrip['trip']['trip_group']
                  ['route']['destination_longitude']
              : store.state.ajkState.selectedMyTrip['trip']['trip_group']
                  ['route']['pickup_points'][0]['longitude']);

      addMarker(
          position: destination,
          id: "destination",
          descriptor: BitmapDescriptor.fromBytes(iconDestination),
          anchor: Offset(0.5, 0.5));

      List _tripPickupPoints = List.from(store.state.ajkState
          .selectedMyTrip['trip']['trip_group']['route']['pickup_points']);

      if (store.state.ajkState.selectedMyTrip['trip']['type'] == 'RETURN') {
        await _tripPickupPoints.removeAt(0);
        _tripPickupPoints.insert(0, {
          "latitude": store.state.ajkState.selectedMyTrip['trip']['trip_group']
              ['route']['destination_latitude'],
          "longitude": store.state.ajkState.selectedMyTrip['trip']['trip_group']
              ['route']['destination_longitude']
        });
      }

      int i = 0;
      for (Map element in _tripPickupPoints) {
        LatLng pickupPointElement =
            LatLng(element['latitude'], element['longitude']);
        addMarker(
            position: pickupPointElement,
            id: "pickupPoint${i}",
            descriptor: BitmapDescriptor.fromBytes(iconPickupPoint),
            anchor: Offset(0.5, 0.5));
        i++;
      }
    }
  }

  // void generateSinglePolyline(Map newData) {
  //   int totalHistory =
  //       store.state.ajkState.selectedMyTrip['trip_histories'].length;
  //   if (status == 'ONGOING' && totalHistory == 1) {
  //     List _tempPickupPoints = store.state.ajkState.selectedMyTrip['trip']
  //         ['trip_group']['route']['pickup_points'] as List;
  //     Map pick = {
  //       "lat": _tempPickupPoints[0]['latitude'],
  //       "lng": _tempPickupPoints[0]['longitude']
  //     };
  //     getPolyline(newData, pick, "otw");
  //     getETATime(origin: newData, destination: pick);
  //   } else {
  //     // destination
  //     Map destination = {
  //       'lat': store.state.ajkState.selectedMyTrip['trip']['trip_group']
  //           ['route']['destination_latitude'],
  //       'lng': store.state.ajkState.selectedMyTrip['trip']['trip_group']
  //           ['route']['destination_longitude']
  //     };
  //     getPolyline(newData, destination, "single");
  //     getETATime(origin: newData, destination: destination);
  //   }
  // }

  void generateMultiplePolylines(Map newData) async {
    int totalHistory =
        store.state.ajkState.selectedMyTrip['trip_histories'].length;
    if (store.state.ajkState.selectedMyTrip['status'] == 'ONGOING' &&
        totalHistory == 1) {
      Map pick = {
        "lat": store.state.ajkState.selectedMyTrip['trip']['type'] == "RETURN"
            ? store.state.ajkState.selectedMyTrip['trip']['trip_group']['route']
                ['destination_latitude']
            : store.state.ajkState.selectedMyTrip['trip']['trip_group']['route']
                ['pickup_points'][0]['latitude'],
        "lng": store.state.ajkState.selectedMyTrip['trip']['type'] == "RETURN"
            ? store.state.ajkState.selectedMyTrip['trip']['trip_group']['route']
                ['destination_longitude']
            : store.state.ajkState.selectedMyTrip['trip']['trip_group']['route']
                ['pickup_points'][0]['longitude']
      };
      getPolyline(newData, pick, "otw");
      getETATime(origin: newData, destination: pick);
    } else {
      Map destination = {
        'lat': store.state.ajkState.selectedMyTrip['trip']['trip_group']
            ['route']['destination_latitude'],
        'lng': store.state.ajkState.selectedMyTrip['trip']['trip_group']
            ['route']['destination_longitude'],
        "address": store.state.ajkState.selectedMyTrip['trip']['trip_group']
            ['route']['destination_address'],
        "name": store.state.ajkState.selectedMyTrip['trip']['trip_group']
            ['route']['destination_name']
      };

      List _tempTripPickupPoints = List.from(store.state.ajkState
          .selectedMyTrip['trip']['trip_group']['route']['pickup_points']);

      Map returnDestination;
      // print(thenewData);

      if (store.state.ajkState.selectedMyTrip['trip']['type'] == 'RETURN') {
        _tempTripPickupPoints = _tempTripPickupPoints.reversed.toList();
        _tempTripPickupPoints.insert(0, destination);
        returnDestination = {
          "lat": _tempTripPickupPoints[_tempTripPickupPoints.length - 1]
              ['latitude'],
          "lng": _tempTripPickupPoints[_tempTripPickupPoints.length - 1]
              ['longitude']
        };
      }

      List<PolylineWayPoint> _wayPoint = new List<PolylineWayPoint>();

      for (Map element in _tempTripPickupPoints) {
        _wayPoint.add(PolylineWayPoint(
            location: "${element['address']} ${element['name']}",
            stopOver: true));
      }

      // print("newData");
      // print(thenewData);
      // print("destination");
      // print(destination);

      getPolyline(
          newData,
          store.state.ajkState.selectedMyTrip['trip']['type'] == 'RETURN'
              ? returnDestination
              : destination,
          "1",
          _wayPoint);
      getETATime(origin: newData, destination: destination);
    }
  }

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

  addPolyLine(String _id) {
    PolylineId polyId = PolylineId("$_id");
    Polyline polyline = Polyline(
        polylineId: polyId,
        color: Color(0xFF5BB1C8),
        width: 6,
        points: polylineCoordinates);
    setState(() {
      polylines[polyId] = polyline;
    });
  }

  getPolyline(Map origin, Map destination, String id,
      [List<PolylineWayPoint> waypoint]) async {
    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          GOOGLE_API_KEY,
          PointLatLng(origin['lat'], origin['lng']),
          PointLatLng(destination['lat'], destination['lng']),
          travelMode: TravelMode.driving,
          optimizeWaypoints: true,
          wayPoints: waypoint ?? []);
      if (result.points.isNotEmpty) {
        polylineCoordinates.clear();
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      }
      addPolyLine(id);
    } catch (e) {
      print(e.toString());
    }
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

        List listPickupPoint = store.state.ajkState.selectedMyTrip['trip']
            ['trip_group']['route']['pickup_points'];

        toggleSetLastHistorySelectedTrip(lastTripHistories);

        if (lastTripHistories['pickup_point_id'] != null) {
          Map _filterPickupPoint = listPickupPoint.firstWhere((element) =>
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
        if (tripType == 'DEPARTURE') {
          toggleButtonNameGlobal(
              "${AppTranslations.of(context).currentLanguage == 'en' ? 'Heading to' : 'Menuju'} ${checkVia(_pickupPoint[0]['name'])}");
        } else {
          toggleButtonNameGlobal(
              "${AppTranslations.of(context).currentLanguage == 'en' ? 'Heading to' : 'Menuju'} ${checkVia(destinationName)}");
        }
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
              if (lastHistoryIndex + 1 < _pickupPoint.length - 1) {
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

  Future<void> manageTrip() async {
    if (isLoading) {
      return;
    }
    try {
      String tripOrderId = store.state.ajkState.selectedMyTrip['trip_order_id'];
      String tripType = store.state.ajkState.selectedMyTrip['trip']['type'];
      String _pickupPoint;
      String _method;

      List _sortingTripHistory =
          store.state.ajkState.selectedMyTrip['trip_histories'];

      List _listPickupPoint = store.state.ajkState.selectedMyTrip['trip']
          ['trip_group']['route']['pickup_points'];

      _listPickupPoint.sort((a, b) => a['priority'].compareTo(b['priority']));

      if (_sortingTripHistory.length <= 0) {
        _method = "HEADING";
        if (tripType == 'DEPARTURE') {
          _pickupPoint = _listPickupPoint[0]['pickup_point_id'];
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
            int lastHistoryIndex = _listPickupPoint.indexWhere((element) =>
                element['pickup_point_id'] ==
                lastTripHistories['pickup_point_id']);

            if (lastHistoryIndex < _listPickupPoint.length - 1) {
              _method = "HEADING";
              _pickupPoint =
                  _listPickupPoint[lastHistoryIndex + 1]['pickup_point_id'];
            } else {
              _method = "HEADING_TO_DESTINATION";
              _pickupPoint = null;
            }
          } else {
            _listPickupPoint
                .sort((b, a) => a['priority'].compareTo(b['priority']));

            if (lastTripHistories['pickup_point_id'] == null) {
              _method = "HEADING";
              _pickupPoint = _listPickupPoint[0]['pickup_point_id'];
            } else {
              int lastHistoryIndex = _listPickupPoint.indexWhere((element) =>
                  element['pickup_point_id'] ==
                  lastTripHistories['pickup_point_id']);
              if (lastHistoryIndex < _listPickupPoint.length - 1) {
                _method = "HEADING";
                _pickupPoint =
                    _listPickupPoint[lastHistoryIndex + 1]['pickup_point_id'];
              } else {
                _method = "HEADING_TO_DESTINATION";
                _pickupPoint = _listPickupPoint[_listPickupPoint.length - 1]
                    ['pickup_point_id'];
              }
            }
          }
        }
      }

      toggleLoading(true);
      // dynamic res = await Providers.manageTrip(
      //     tripId: "314e28d0-eded-11eb-ac0a-c18ea3fccad7",
      //     pickupPointId: "6d22c690-d259-11eb-94bc-c3fc446052a0",
      //     type: "ARRIVED"
      // );
      dynamic res = await Providers.manageTrip(
          tripOrderId: tripOrderId, pickupPointId: _pickupPoint, type: _method);

      // if(vType == "HEADING" || vType == "ARRIVED"){
      //   setState((){
      //     isOngoing = true;
      //   });
      // }

      // if(vType == "ARRIVED_AT_DESTINATION"){
      //   setState((){
      //     isOngoing = false;
      //   });
      //   deleteData();
      // }
      initMyActivities();
      getTripdByTripId(tripOrderId);
      if (_method == "ARRIVED_AT_DESTINATION") {
        Navigator.pop(context);
      }
    } catch (e) {
      print(e);
      // setError(type: "login", value: e);
    } finally {
      // toggleLoading(false);
      toggleLoading(false);
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

  Future<void> getTripdByTripId(String tripId) async {
    try {
      dynamic res = await Providers.getTripByTripId(tripId: tripId);

      store.dispatch(SetSelectedMyTrip(selectedMyTrip: res.data['data']));
      statusHandler();
      getPassanger(res.data['data']['trip']['trip_group_id']);
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

  void showPassenger(context) {
    final screenSize = MediaQuery.of(context).size;
    print(store.state.ajkState.selectedMyTrip['trip']['status']);
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.black.withOpacity(0.20),
        isDismissible: true,
        isScrollControlled: true,
        builder: (context) {
          return PassengerBody2(
              isCompleted:
                  store.state.ajkState.selectedMyTrip['status'] == "COMPLETED",
              tripGroupId: store.state.ajkState.selectedMyTrip['trip']
                  ['trip_group_id'],
              tripId: store.state.ajkState.selectedMyTrip['trip_id']);
        });
    // showModalBottomSheet(
    //     context: context,
    //     backgroundColor: Colors.black.withOpacity(0.20),
    //     isDismissible: true,
    //     isScrollControlled: true,
    //     builder: (context) {
    //       return PassengerBody(
    //         tripGroupId: store.state.ajkState.selectedMyTrip['trip']
    //             ['trip_group_id'],
    //       );
    //     });
  }
}
