import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:latlong/latlong.dart';
import 'package:loading/indicator/ball_spin_fade_loader_indicator.dart';
import 'package:loading/loading.dart';
import 'package:mapbox_search/mapbox_search.dart' as mapboxSearch;
import 'package:tomas_driver/configs/config.dart';

import 'custom_map_page.dart';
import 'custom_nomatim_service.dart';

class CustomMapBoxLocationPicker extends StatefulWidget {
  CustomMapBoxLocationPicker({
    @required this.apiKey,
    this.onSelected,
    this.onChangeMarker,
    // this.onSearch,
    this.searchHint = 'Search',
    this.language = 'en',
    this.location,
    this.limit = 5,
    this.country,
    this.context,
    this.height,
    this.popOnSelect = false,
    this.awaitingForLocation = "Awaiting for you current location",
    this.customMarkerIcon,
    // this.customMapLayer,
    this.initLocation,
    this.showCurrent = false,
  });

  //
  // final TileLayerOptions customMapLayer;

  //
  final Widget customMarkerIcon;

  /// API Key of the MapBox.
  final String apiKey;

  final String country;

  /// Height of whole search widget
  final double height;

  final String language;

  /// Limits the no of predections it shows
  final int limit;

  /// The point around which you wish to retrieve place information.
  final Location location;
  final Location initLocation;

  /// Language used for the autocompletion.
  ///
  /// Check the full list of [supported languages](https://docs.mapbox.com/api/search/#language-coverage) for the MapBox API

  ///Limits the search to the given country
  ///
  /// Check the full list of [supported countries](https://docs.mapbox.com/api/search/) for the MapBox API

  /// True if there is different search screen and you want to pop screen on select
  final bool popOnSelect;

  final bool showCurrent;

  ///Search Hint Localization
  final String searchHint;

  /// Waiting For Location Hint text
  final String awaitingForLocation;

  @override
  _CustomMapBoxLocationPickerState createState() =>
      _CustomMapBoxLocationPickerState();

  ///To get the height of the page
  final BuildContext context;

  /// The callback that is called when one Place is selected by the user.
  final void Function(MapBoxPlace place) onSelected;

  final void Function(Map place) onChangeMarker;

  /// The callback that is called when the user taps on the search icon.
  // final void Function(MapBoxPlaces place) onSearch;
}

class _CustomMapBoxLocationPickerState extends State<CustomMapBoxLocationPicker>
    with SingleTickerProviderStateMixin {
  var reverseGeoCoding;

  List _addresses = List();
  AnimationController _animationController;
  // SearchContainer height.

  Position _currentPosition;
  double _lat;
  double _lng;
  // MapController _mapController = MapController();

  // List<Marker> _markers;

  bool isLoading = true;
  bool firstLoadShowCurrent = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    getCurrentLocation();

    // _markers = [
    /*
      --- manage marker
    // */
    //   Marker(
    //     width: 50.0,
    //     height: 50.0,
    //     point: new LatLng(0.0, 0.0),
    //     builder: (ctx) => new Container(
    //         child: widget.customMarkerIcon == null
    //             ? Icon(
    //                 Icons.location_on,
    //                 size: 50.0,
    //               )
    //             : widget.customMarkerIcon),
    //   )
    // ];

    Timer.periodic(Duration(milliseconds: 200), (_) => getShowCurrent());

    super.initState();
  }

  getShowCurrent() {
    setState(() {
      if (widget.showCurrent && !firstLoadShowCurrent) {
        firstLoadShowCurrent = true;

        Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
            .then((Position position) async {
          setState(() {
            _lat = position.latitude;
            _lng = position.longitude;
          });

          await _animationController.animateTo(0.5);
          // _mapController.move(
          //     LatLng(position.latitude, position.longitude), 15);

          _animationController.reverse();
        }).catchError((e) {
          print(e);
        });
      } else {
        firstLoadShowCurrent = false;
      }
    });
  }

  getCurrentLocation() {
    /*
    --- Função responsável por receber a localização atual do usuário
  */
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        _getCurrentLocationMarker();
        // _getCurrentLocationDesc();
        getLocationWithLatLng("init");
      });
    }).catchError((e) {
      print(e);
    });
  }

  _getCurrentLocationMarker() {
    /*
    --- Função responsável por atualizar o marcador para a localização atual do usuário
  */
    setState(() async {
      _lat = widget.initLocation != null
          ? widget.initLocation.lat
          : _currentPosition.latitude;
      _lng = widget.initLocation != null
          ? widget.initLocation.lng
          : _currentPosition.longitude;

      isLoading = false;
    });
  }

  void moveMarker(MapBoxPlace prediction) {
    setState(() {
      _lat = prediction.geometry.coordinates.elementAt(1);
      _lng = prediction.geometry.coordinates.elementAt(0);

      // _markers[0] = Marker(
      //   width: 50.0,
      //   height: 50.0,
      //   point: LatLng(_lat, _lng),
      //   builder: (ctx) => new Container(
      //       child: widget.customMarkerIcon == null
      //           ? Icon(
      //               Icons.location_on,
      //               size: 50.0,
      //             )
      //           : widget.customMarkerIcon),
      // );
    });
  }

  Future<void> getLocationWithLatLng(String mode) async {
    dynamic res =
        await CustomNominatimService().getAddressLatLng("$_lat $_lng");
    setState(() {
      _addresses = res;
    });

    var geoCodingService = mapboxSearch.ReverseGeoCoding(
      apiKey: ACCESS_TOKEN,
      country: "ID",
      limit: 1,
    );

    var addresses = await geoCodingService.getAddress(mapboxSearch.Location(
      lat: mode == 'change' ? _lat : widget.initLocation.lat,
      lng: mode == 'change' ? _lng : widget.initLocation.lng,
    ));
    widget.onChangeMarker({..._addresses[0], "name": addresses[0]});
  }

  // void onTapMarker(MapPosition position, bool hasGesture) {
  //   if (hasGesture &&
  //       _lat != position.center.latitude &&
  //       _lng != position.center.longitude) {
  //     setState(() {
  //       _lat = position.center.latitude;
  //       _lng = position.center.longitude;

  //       getLocationWithLatLng('change');
  //     });
  //   }
  // }

  // Widget mapContext(BuildContext context) {
  //   /*
  //   --- Widget responsável pela representação cartográfica da região, assim como seu ponto no espaço. 
  // */
  //   while (isLoading) {
  //     return new Center(
  //       child: Loading(
  //         indicator: BallSpinFadeLoaderIndicator(),
  //       ),
  //     );
  //   }

  //   return new CustomMapPage(
  //       lat: _lat,
  //       lng: _lng,
  //       mapController: _mapController,
  //       onChanged: onTapMarker,
  //       // markers: _markers,
  //       apiKey: widget.apiKey,
  //       customMapLayer: widget.customMapLayer);
  // }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: <Widget>[
            Container(width: double.infinity, height: double.infinity),
            // mapContext(context),
            isLoading
                ? SizedBox()
                : Positioned(
                    top: (screenSize.height / 4 * 1.5) - 50,
                    left: (screenSize.width / 2) - 25,
                    child: Container(
                      width: 50,
                      height: 50,
                      child: widget.customMarkerIcon,
                    ),
                  )
          ],
        ));
  }
}
