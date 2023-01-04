import 'package:flutter/material.dart';
import 'view_map_view.dart';

class ViewMap extends StatefulWidget {

  final double lat;
  final double lng;
  final String title;

  ViewMap({
    this.lat,
    this.lng,
    this.title
  });
  
  @override
  ViewMapView createState() => new ViewMapView();
}
  
