import 'package:flutter/material.dart';

class ImageScannerAnimation extends AnimatedWidget {
  final bool stopped;
  final double width;

  ImageScannerAnimation(this.stopped, this.width,
      {Key key, Animation<double> animation})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final Animation<double> animation = listenable;
    final scorePosition = (animation.value * screenSize.height / 1.5) - 50;

    Color color1 = Color(0x5575C1D4);
    Color color2 = Color(0x0075C1D4);

    if (animation.status == AnimationStatus.reverse) {
      color1 = Color(0x0075C1D4);
      color2 = Color(0x5575C1D4);
    }

    return new Positioned(
        bottom: scorePosition,
        left: 0.0,
        child: new Opacity(
            opacity: 1.0,
            child: Container(
              height: 60.0,
              width: width,
              decoration: new BoxDecoration(
                  gradient: new LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.1, 0.9],
                colors: [color1, color2],
              )),
            )));
  }
}
