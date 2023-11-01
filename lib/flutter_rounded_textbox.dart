library flutter_rounded_textbox;

import 'dart:math';
import 'dart:ui';

import 'package:flutter/widgets.dart';

/// Draws text in a box with rounded corners, each line having an individual
/// box and the concave corners of the boxes being rounded.
class RoundedTextbox extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double radius;
  final double padding;
  final Color backgroundColor;

  const RoundedTextbox({
    Key? key,
    required this.text,
    required this.style,
    required this.backgroundColor,
    this.radius = 10,
    this.padding = 5.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter:
          _RoundedTextboxPainter(text, style, radius, padding, backgroundColor),
    );
  }
}

class _RoundedTextboxPainter extends CustomPainter {
  final String text;
  final TextStyle textStyle;
  final double radius;
  final double padding;
  final Color background;
  _RoundedTextboxPainter(
      this.text, this.textStyle, this.radius, this.padding, this.background);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || text.isEmpty) return;

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout(maxWidth: size.width - padding * 2);
    final metrics = textPainter.computeLineMetrics();
    final scaling = textStyle.height ?? 1.0;

    final paint = Paint()
      ..color = background
      ..style = PaintingStyle.fill;
    final path = Path();

    for (var i = 0; i < metrics.length; i++) {
      final line = metrics.elementAt(i);
      final above = metrics.getOrNull(i - 1);
      final below = metrics.getOrNull(i + 1);

      final aboveDifference = (above?.width ?? 0) - line.width;
      final belowDifference = (below?.width ?? 0) - line.width;

      final topRadiusOut = (aboveDifference > 0) ? min(radius, aboveDifference / 3) : 0.0;
      final bottomRadiusOut = (belowDifference > 0) ? min(radius, belowDifference / 3) : 0.0;
      final topRadiusIn = (aboveDifference < 0) ? min(radius, -aboveDifference / 3) : 0.0;
      final bottomRadiusIn = (belowDifference < 0) ? min(radius, -belowDifference / 3) : 0.0;

      final top = (above?.baseline ?? 0) + (above?.descent ?? 0) * scaling + padding;
      final bottom = line.baseline + line.descent * scaling + padding;
      final left = (size.width - line.width) / 2 - padding;
      final right = (size.width + line.width) / 2 + padding;

      final halfHeight = (bottom - top) / 2;
      final positiveRectTop = RRect.fromLTRBAndCorners(
        left - topRadiusOut,
        top,
        right + topRadiusOut,
        top + halfHeight,
        topLeft: Radius.elliptical(topRadiusIn, radius),
        topRight: Radius.elliptical(topRadiusIn, radius),
      );

      final positiveRectBottom = RRect.fromLTRBAndCorners(
        left - bottomRadiusOut,
        bottom - halfHeight,
        right + bottomRadiusOut,
        bottom,
        bottomLeft: Radius.elliptical(bottomRadiusIn, radius),
        bottomRight: Radius.elliptical(bottomRadiusIn, radius),
      );

      final negativeRectLeft = RRect.fromLTRBAndCorners(
        left - radius,
        top,
        left,
        bottom,
        topRight: Radius.elliptical(topRadiusOut, radius),
        bottomRight: Radius.elliptical(bottomRadiusOut, radius),
      );

      final negativeRectRight = RRect.fromLTRBAndCorners(
        right,
        top,
        right + radius,
        bottom,
        topLeft: Radius.elliptical(topRadiusOut, radius),
        bottomLeft: Radius.elliptical(bottomRadiusOut, radius),
      );

      var tempPath = Path()
        ..addRRect(positiveRectTop)
        ..addRRect(positiveRectBottom);

      final negative = Path()
        ..addRRect(negativeRectLeft)
        ..addRRect(negativeRectRight);

      tempPath = Path.combine(PathOperation.difference, tempPath, negative);

      path.addPath(tempPath, Offset.zero);
    }

    canvas.drawPath(path, paint);
    textPainter.paint(canvas, Offset(padding, padding));
  }

  @override
  bool shouldRepaint(_RoundedTextboxPainter oldDelegate) {
    return oldDelegate.text != text ||
        oldDelegate.textStyle != textStyle ||
        oldDelegate.radius != radius ||
        oldDelegate.padding != padding ||
        oldDelegate.background != background;
  }
}

extension _IterableHelpers<T> on Iterable<T> {
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return elementAt(index);
  }
}
