import 'package:flutter/material.dart';

class ChatBubble extends CustomPainter {
  final LinearGradient gradient;
  final double borderRadius;
  final double nipSide;
  final Color bubbleColor;
  final bool isMe;

  ChatBubble(this.borderRadius, this.nipSide, this.isMe,
      {this.gradient, this.bubbleColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    if (gradient != null) {
      paint
        ..shader =
            gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..style = PaintingStyle.fill;
    } else {
      paint
        ..color = bubbleColor
        ..style = PaintingStyle.fill;
    }

    Path path = Path();
    if (isMe) {
      path.moveTo(size.width, size.height);
      path.lineTo((size.width - nipSide), size.height);
      path.lineTo(borderRadius, size.height);
      path.quadraticBezierTo(0, size.height, 0, (size.height - borderRadius));
      path.lineTo(0, borderRadius);
      path.quadraticBezierTo(0, 0, borderRadius, 0);
      path.lineTo((size.width - (nipSide + borderRadius)), 0);
      path.quadraticBezierTo(
          (size.width - nipSide), 0, (size.width - nipSide), borderRadius);
      path.lineTo((size.width - nipSide), (size.height - nipSide));
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(nipSide, size.height);
      path.lineTo((size.width - borderRadius), size.height);
      path.quadraticBezierTo(
          size.width, size.height, size.width, (size.height - borderRadius));
      path.lineTo(size.width, borderRadius);
      path.quadraticBezierTo(size.width, 0, (size.width - borderRadius), 0);
      path.lineTo((nipSide + borderRadius), 0);
      path.quadraticBezierTo(nipSide, 0, nipSide, borderRadius);
      path.lineTo(nipSide, (size.height - nipSide));
      path.lineTo(0, size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
