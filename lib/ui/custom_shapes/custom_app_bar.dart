import 'package:flutter/material.dart';

class CustomToolBar extends CustomPainter {
  final LinearGradient gradient;
  final double arcRadius;

  CustomToolBar(this.gradient, this.arcRadius);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Paint paint = Paint()
    //   ..color = Colors.red
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = 8.0;

    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, arcRadius);
    path.quadraticBezierTo(0, 0, arcRadius, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, (size.height - (arcRadius * 2)));
    path.quadraticBezierTo(size.width, (size.height - (arcRadius)),
        (size.width - arcRadius), (size.height - (arcRadius)));
    path.lineTo(arcRadius, (size.height - (arcRadius)));
    path.quadraticBezierTo(0, (size.height - (arcRadius)), 0, size.height);

    // path.quadraticBezierTo(0, 0, size.width, 0);
    // path.lineTo(0, 0);
    // path.lineTo(0, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
