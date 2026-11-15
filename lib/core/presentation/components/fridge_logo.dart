import 'package:flutter/material.dart';

/// Reusable FridgeWise Refrigerator Vector Logo.
/// Features a minimalist refrigerator outline with rounded corners,
/// clean light-mint/forest strokes, and an elegant small leaf detail on the refrigerator door.
class FridgeWiseLogo extends StatelessWidget {
  const FridgeWiseLogo({
    super.key,
    this.size = 54,
    this.strokeColor,
    this.leafAccentColor,
  });

  final double size;
  final Color? strokeColor;
  final Color? leafAccentColor;

  @override
  Widget build(BuildContext context) {
    final defaultStroke = strokeColor ?? const Color(0xFFDDF2E3);
    final defaultLeaf = leafAccentColor ?? const Color(0xFFDDF2E3);

    return SizedBox(
      width: size * (48 / 62),
      height: size,
      child: CustomPaint(
        painter: _FridgeLogoPainter(
          strokeColor: defaultStroke,
          leafColor: defaultLeaf,
        ),
      ),
    );
  }
}

class _FridgeLogoPainter extends CustomPainter {
  const _FridgeLogoPainter({
    required this.strokeColor,
    required this.leafColor,
  });

  final Color strokeColor;
  final Color leafColor;

  @override
  void paint(Canvas canvas, Size size) {
    // Base design bounds: 48 x 62
    final scale = size.height / 62.0;
    canvas.save();
    canvas.scale(scale);

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final thinStrokePaint = Paint()
      ..color = strokeColor.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final leafFillPaint = Paint()
      ..color = leafColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    // 1. Refrigerator Cabinet Outer Rounded Body
    const cabinetRect = Rect.fromLTWH(5, 4, 38, 54);
    final cabinetRRect = RRect.fromRectAndRadius(cabinetRect, const Radius.circular(8.5));
    canvas.drawRRect(cabinetRRect, strokePaint);

    // 2. Horizontal Divider separating Freezer (top) and Fridge (bottom)
    canvas.drawLine(const Offset(5, 20), const Offset(43, 20), thinStrokePaint);

    // 3. Handles on Left Side of Doors (matching reference)
    // Freezer door handle
    canvas.drawLine(const Offset(10, 9), const Offset(10, 15), strokePaint);
    // Main fridge door handle
    canvas.drawLine(const Offset(10, 26), const Offset(10, 38), strokePaint);

    // 4. Delicate Leaf Detail on Main Refrigerator Door (positioned on right side, tilted up-right)
    final leafPath = Path()
      ..moveTo(23, 44) // Stem base
      ..quadraticBezierTo(21, 34, 32, 29) // Upper curve to tip
      ..quadraticBezierTo(35, 38, 23, 44) // Lower curve back
      ..close();

    canvas.drawPath(leafPath, leafFillPaint);
    canvas.drawPath(leafPath, thinStrokePaint);

    // Leaf Center Vein
    final veinPath = Path()
      ..moveTo(23, 44)
      ..quadraticBezierTo(26, 37, 31, 31);
    canvas.drawPath(veinPath, thinStrokePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FridgeLogoPainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor || oldDelegate.leafColor != leafColor;
  }
}
