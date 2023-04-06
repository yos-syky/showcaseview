import 'package:flutter/material.dart';

class OverlayPainter extends CustomPainter {
  OverlayPainter({
    required this.rect,
    required this.shadow,
    required this.gradient,
    required this.radius,
  });

  final Rect rect;
  final BoxShadow shadow;
  final Gradient gradient;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());
    // this was to just draw a color as shadow.
    canvas.drawColor(shadow.color, BlendMode.dstATop);
    // canvas.drawRect(
    //   Rect.fromPoints(Offset.zero, Offset(size.width, size.height)),
    //   Paint()
    //     ..shader = gradient.createShader(
    //         Rect.fromPoints(Offset.zero, Offset(size.width, size.height)))
    //     ..blendMode = BlendMode.dstATop,
    // );
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)),
        shadow.toPaint()..blendMode = BlendMode.clear);
    canvas.restore();
  }

  @override
  bool shouldRepaint(OverlayPainter oldDelegate) => oldDelegate.rect != rect;
}
