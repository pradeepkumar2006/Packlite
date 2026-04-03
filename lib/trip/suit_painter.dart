import 'package:flutter/material.dart';

class SuitcaseBorderPainter extends CustomPainter {
  final double progress;
  SuitcaseBorderPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(48),
      ));

    final pathMetrics = path.computeMetrics().toList();
    if (pathMetrics.isNotEmpty) {
      final extractPath = pathMetrics.first.extractPath(0, pathMetrics.first.length * progress);
      canvas.drawPath(extractPath, paint);
    }
  }

  @override
  bool shouldRepaint(SuitcaseBorderPainter oldDelegate) => oldDelegate.progress != progress;
}
