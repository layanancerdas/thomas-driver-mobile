import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:tomas_driver/configs/config.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';

import 'custom_text.dart';

const randomMarkerNum = 100;

class MapFullscreen extends StatefulWidget {
  final LatLng coordinates;
  final String city, address;

  MapFullscreen({this.coordinates, this.city, this.address});

  @override
  _MapFullscreenState createState() => _MapFullscreenState();
}

class _MapFullscreenState extends State<MapFullscreen> {
  final Random _rnd = new Random();

  MapboxMapController _mapController;
  List<Marker> _markers = [];
  List<_MarkerState> _markerStates = [];

  void _addMarkerStates(_MarkerState markerState) {
    _markerStates.add(markerState);
  }

  void _onMapCreated(MapboxMapController controller) {
    setState(() {
      _mapController = controller;
    });
    controller.addListener(() {
      if (controller.isCameraMoving) {
        _updateMarkerPosition();
      }
    });
    _mapController.toScreenLocationBatch([widget.coordinates]).then((value) {
      var point = Point<double>(value[0].x, value[0].y);
      _addMarker(point, widget.coordinates);
    });
  }

  // void moveNewCamera() {
  //   _mapController.animateCamera(
  //     CameraUpdate.newCameraPosition(
  //       CameraPosition(
  //         bearing: 0.0,
  //         target: widget.coordinates,
  //         tilt: 0.0,
  //         zoom: 16.0,
  //       ),
  //     ),
  //   );
  // }

  void _onStyleLoadedCallback() {
    print('onStyleLoadedCallback');
  }

  // void _onMapLongClickCallback(Point<double> point, LatLng coordinates) {
  //   _addMarker(point, coordinates);
  // }

  void _onCameraIdleCallback() {
    _updateMarkerPosition();
  }

  void _updateMarkerPosition() {
    final coordinates = <LatLng>[];

    for (final markerState in _markerStates) {
      coordinates.add(markerState.getCoordinate());
    }

    _mapController.toScreenLocationBatch(coordinates).then((points) {
      _markerStates.asMap().forEach((i, value) {
        _markerStates[i].updatePosition(points[i]);
      });
    });
  }

  void _addMarker(Point<double> point, LatLng coordinates) {
    setState(() {
      _markers.add(Marker(_rnd.nextInt(100000).toString(), coordinates, point,
          _addMarkerStates, widget.city, widget.address));
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     Future.delayed(Duration(seconds: 1), () => moveNewCamera());
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Stack(children: [
        MapboxMap(
          accessToken: ACCESS_TOKEN,
          trackCameraPosition: true,
          onMapCreated: _onMapCreated,
          // onMapLongClick: _onMapLongClickCallback,
          onCameraIdle: _onCameraIdleCallback,
          onStyleLoadedCallback: _onStyleLoadedCallback,

          initialCameraPosition: CameraPosition(
              bearing: 0.0, target: widget.coordinates, tilt: 0.0, zoom: 16.2),
        ),
        IgnorePointer(
            ignoring: true,
            child: Stack(
              children: _markers,
            )),
        Positioned(
            top: 10,
            right: 20,
            child: SafeArea(
              child: ElevatedButton(
                style: TextButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  backgroundColor: ColorsCustom.primary,
                ),
                onPressed: () => Navigator.pop(context),
                child: CustomText("Close"),
              ),
            ))
      ]),
    );
  }

  // ignore: unused_element
  void _measurePerformance() {
    final trial = 10;
    final batches = [500, 1000, 1500, 2000, 2500, 3000];
    var results = Map<int, List<double>>();
    for (final batch in batches) {
      results[batch] = [0.0, 0.0];
    }

    _mapController.toScreenLocation(LatLng(0, 0));
    Stopwatch sw = Stopwatch();

    for (final batch in batches) {
      //
      // primitive
      //
      for (var i = 0; i < trial; i++) {
        sw.start();
        var list = <Future<Point<num>>>[];
        for (var j = 0; j < batch; j++) {
          var p = _mapController
              .toScreenLocation(LatLng(j.toDouble() % 80, j.toDouble() % 300));
          list.add(p);
        }
        Future.wait(list);
        sw.stop();
        results[batch][0] += sw.elapsedMilliseconds;
        sw.reset();
      }

      //
      // batch
      //
      for (var i = 0; i < trial; i++) {
        sw.start();
        var param = <LatLng>[];
        for (var j = 0; j < batch; j++) {
          param.add(LatLng(j.toDouble() % 80, j.toDouble() % 300));
        }
        Future.wait([_mapController.toScreenLocationBatch(param)]);
        sw.stop();
        results[batch][1] += sw.elapsedMilliseconds;
        sw.reset();
      }
    }
  }
}

class Marker extends StatefulWidget {
  final Point _initialPosition;
  final LatLng _coordinate;
  final void Function(_MarkerState) _addMarkerState;
  final String _city, _address;

  Marker(
    String key,
    this._coordinate,
    this._initialPosition,
    this._addMarkerState,
    this._city,
    this._address,
  ) : super(key: Key(key));

  @override
  State<StatefulWidget> createState() {
    final state = _MarkerState(_initialPosition, _city, _address);
    _addMarkerState(state);
    return state;
  }
}

class _MarkerState extends State with TickerProviderStateMixin {
  final _iconSize = 220.0;

  Point _position;
  String _city, _address;

  // AnimationController _controller;
  // Animation<double> _animation;

  _MarkerState(this._position, this._city, this._address);

  @override
  void initState() {
    super.initState();
    // _controller = AnimationController(
    //   duration: const Duration(seconds: 2),
    //   vsync: this,
    // )..repeat(reverse: true);
    // _animation = CurvedAnimation(
    //   parent: _controller,
    //   curve: Curves.elasticOut,
    // );
  }

  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var ratio = 1.0;

    //web does not support Platform._operatingSystem
    // if (!kIsWeb) {
    // iOS returns logical pixel while Android returns screen pixel
    ratio = Platform.isIOS ? 1.0 : MediaQuery.of(context).devicePixelRatio;
    // }

    return Positioned(
      left: _position.x / ratio - _iconSize / 2,
      top: _position.y / ratio - _iconSize / 2,
      child: Column(
        children: [
          Stack(
            children: [
              Image.asset(
                "assets/images/tooltip.png",
                width: 220,
                fit: BoxFit.cover,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      "${_city.length > 22 ? _city.substring(0, 21) + "..." : _city}",
                      color: ColorsCustom.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    SizedBox(height: 5),
                    CustomText(
                      "${_address.length > 26 ? _address.substring(0, 25) + "..." : _address}",
                      color: ColorsCustom.black,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SvgPicture.asset(
            'assets/images/marker.svg',
            height: 25,
          ),
        ],
      ),
    );
  }

  void updatePosition(Point<num> point) {
    setState(() {
      _position = point;
    });
  }

  LatLng getCoordinate() {
    return (widget as Marker)._coordinate;
  }
}
