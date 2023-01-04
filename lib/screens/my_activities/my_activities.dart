import 'package:flutter/material.dart';
import './my_activities_view.dart';

class MyActivities extends StatefulWidget {
  final int index;

  MyActivities({this.index});

  @override
  MyActivitiesView createState() => new MyActivitiesView();
}
