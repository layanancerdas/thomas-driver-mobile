
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tomas_driver/helpers/colors_custom.dart';
import 'package:tomas_driver/widgets/custom_text.dart';

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
