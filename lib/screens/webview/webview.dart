import 'package:flutter/material.dart';
import './webview_view.dart';

class Webview extends StatefulWidget {
  final String link, title;

  Webview({this.link, this.title});

  @override
  WebviewView createState() => new WebviewView();
}
