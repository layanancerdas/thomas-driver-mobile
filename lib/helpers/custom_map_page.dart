import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong/latlong.dart';

class CustomMapPage extends StatefulWidget {
  CustomMapPage(
      {Key key,
      @required this.lat,
      @required this.lng,
      // @required this.mapController,
      // @required this.markers,
      this.apiKey,
      // this.customMapLayer,
      // this.onChanged
      })
      : super(key: key);
  // final List<Marker> markers;
  final double lat;
  final double lng;
  // final MapController mapController;
  final String apiKey;
  // final TileLayerOptions customMapLayer;
  // final void Function(MapPosition position, bool hasGesture) onChanged;

  @override
  _CustomMapPageState createState() => _CustomMapPageState();
}

class _CustomMapPageState extends State<CustomMapPage> {
  Widget body(BuildContext context) {
    // return new FlutterMap(
    //   mapController: widget.mapController,
    //   options: MapOptions(
    //     center: LatLng(widget.lat, widget.lng),
    //     zoom: 15,
    //     maxZoom: 18,
    //     onPositionChanged: widget.onChanged,
    //   ),
    //   layers: [
    //     widget.customMapLayer,
    //   ],
    // );
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: body(context),
    );
  }
}
