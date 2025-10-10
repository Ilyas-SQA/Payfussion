import 'package:flutter/material.dart';

/// A custom painter for drawing a dotted horizontal line.
class DottedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dotLength;
  final double spaceLength;

  /// Creates a [DottedLinePainter].
  ///
  /// [color] The color of the dots.
  /// [strokeWidth] The thickness of the dots.
  /// [dotLength] The length of each individual dot.
  /// [spaceLength] The length of the space between dots.
  const DottedLinePainter({
    this.color = Colors.black,
    this.strokeWidth = 1.0,
    this.dotLength = 4.0,
    this.spaceLength = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round; // Use round caps for a softer look

    double currentX = 0;
    final double segmentLength = dotLength + spaceLength;
    final int numberOfSegments = (size.width / segmentLength).floor();
    final double remainingWidth =
        size.width - (numberOfSegments * segmentLength);

    currentX = remainingWidth / 2;

    for (int i = 0; i < numberOfSegments; i++) {
      // Draw a dot
      canvas.drawLine(
        Offset(currentX, size.height / 2),
        Offset(currentX + dotLength, size.height / 2),
        paint,
      );
      // Move to the next starting point
      currentX += segmentLength;
    }

    // Draw any partial last dot if remainingWidth allows for it
    if (currentX < size.width && (size.width - currentX) > 0) {
      canvas.drawLine(
        Offset(currentX, size.height / 2),
        Offset(currentX + (size.width - currentX), size.height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! DottedLinePainter ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dotLength != dotLength ||
        oldDelegate.spaceLength != spaceLength;
  }
}

/// DottedLine widget that uses the DottedLinePainter
class DottedLine extends StatelessWidget {
  final double indent;
  final double endIndent;
  final Color color;
  final double thickness;
  final double dotLength; // Length of each dot
  final double space; // Space between dots

  const DottedLine({
    super.key,
    required this.indent,
    required this.endIndent,
    required this.color,
    required this.thickness,
    this.dotLength = 10, // Default dot length
    this.space = 5, // Default space between dots
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DottedLinePainter(
        color: color,
        strokeWidth: thickness,
        dotLength: dotLength,
        spaceLength: space,
      ),
      child: SizedBox(
        height: thickness, // Set the height based on stroke thickness
        width: double.infinity, // Take the full width
      ),
    );
  }
}
