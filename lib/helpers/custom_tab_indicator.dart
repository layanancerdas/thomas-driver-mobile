import 'package:flutter/material.dart';

class CustomTabIndicator extends Decoration {
  final BoxPainter _painter;

  CustomTabIndicator(
      {@required Color color,
      @required double radius,
      @required double width,
      @required double height})
      : _painter = _CirclePainter(color, radius, width, height);

  @override
  BoxPainter createBoxPainter([onChanged]) => _painter;
}

class _CirclePainter extends BoxPainter {
  final Paint _paint;
  final double radius, width, height;

  _CirclePainter(Color color, this.radius, this.width, this.height)
      : _paint = Paint()
          ..color = color
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Offset circleOffset =
        offset + Offset(cfg.size.width / 2, cfg.size.height);
    // canvas.drawCircle(circleOffset, radius, _paint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: circleOffset, width: width, height: height),
            Radius.circular(radius)),
        _paint);
  }
}
