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

      final topRadius = (aboveDifference / 3.5).clamp(-radius, radius);
      final bottomRadius = (belowDifference / 3.5).clamp(-radius, radius);

      final top =
          (above?.baseline ?? 0) + (above?.descent ?? 0) * scaling + padding;
      final bottom = line.baseline + line.descent * scaling + padding;
      final left = (size.width - line.width) / 2 - padding;
      final right = (size.width + line.width) / 2 + padding;

      path.moveTo(left + topRadius, top);

      path.lineTo(right + topRadius, top);
      path.arcToPoint(
        Offset(right, top + radius),
        radius: Radius.elliptical(topRadius, radius),
        clockwise: topRadius < 0,
      );

      path.lineTo(right, bottom - radius);
      path.arcToPoint(
        Offset(right + bottomRadius, bottom),
        radius: Radius.elliptical(bottomRadius, radius),
        clockwise: bottomRadius < 0,
      );

      path.lineTo(left - bottomRadius, bottom);
      path.arcToPoint(
        Offset(left, bottom - radius),
        radius: Radius.elliptical(bottomRadius, radius),
        clockwise: bottomRadius < 0,
      );

      path.lineTo(left, top + radius);
      path.arcToPoint(
        Offset(left - topRadius, top),
        radius: Radius.elliptical(topRadius, radius),
        clockwise: topRadius < 0,
      );
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
