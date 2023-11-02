library flutter_rounded_textbox;

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
  final TextAlign textAlign;
  final TextDirection textDirection;
  final List<InlineSpan>? children;

  const RoundedTextbox({
    Key? key,
    required this.text,
    required this.style,
    required this.backgroundColor,
    this.radius = 10,
    this.padding = 5.0,
    this.textAlign = TextAlign.center,
    this.textDirection = TextDirection.ltr,
    this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RoundedTextboxPainter(
        text,
        style,
        radius,
        padding,
        backgroundColor,
        textAlign,
        textDirection,
        children,
      ),
    );
  }
}

class _RoundedTextboxPainter extends CustomPainter {
  final String text;
  final TextStyle textStyle;
  final double radius;
  final double padding;
  final Color background;
  final TextAlign align;
  final TextDirection direction;
  final List<InlineSpan>? children;

  _RoundedTextboxPainter(
    this.text,
    this.textStyle,
    this.radius,
    this.padding,
    this.background,
    this.align,
    this.direction,
    this.children,
  );

  Radius _diffRadius(double a, double b) {
    final difference = a - b;
    return Radius.elliptical((difference / 2).clamp(-radius, radius), radius);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || text.isEmpty) return;

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle, children: children),
      textDirection: direction,
      textAlign: align,
    );
    textPainter.layout(maxWidth: size.width - padding * 2);
    final metrics = textPainter.computeLineMetrics();
    final scaling = textStyle.height ?? 1.0;

    final paint = Paint()
      ..color = background
      ..style = PaintingStyle.fill;
    final path = Path();

    final rrects = List<RRect>.filled(metrics.length, RRect.zero);
    for (var i = 0; i < metrics.length; i++) {
      final line = metrics.elementAt(i);
      final above = metrics.getOrNull(i - 1);
      final below = metrics.getOrNull(i + 1);

      final top = (above?.baseline ?? 0) + (above?.descent ?? 0) * scaling;
      final bottom = line.baseline + line.descent * scaling;
      final left = line.left - padding;
      final right = line.left + line.width + padding;
      final rect = Rect.fromLTRB(left, top, right, bottom);

      rrects[i] = RRect.fromRectAndCorners(
        rect,
        topLeft: _diffRadius(line.left, above.leftOrDefault),
        topRight: _diffRadius(above.rightOrDefault, line.right),
        bottomLeft: _diffRadius(line.left, below.leftOrDefault),
        bottomRight: _diffRadius(below.rightOrDefault, line.right),
      );
    }

    path.moveTo(rrects.first.left + radius, rrects.first.top);

    for (var i in rrects) {
      path.lineTo(i.right + i.trRadiusX, i.top);
      path.arcToPoint(
        Offset(i.right, i.top + radius),
        radius: i.trRadius,
        clockwise: i.trRadiusX < 0,
      );

      path.lineTo(i.right, i.bottom - radius);
      path.arcToPoint(
        Offset(i.right + i.brRadiusX, i.bottom),
        radius: i.brRadius,
        clockwise: i.brRadiusX < 0,
      );
    }

    for (var i in rrects.reversed) {
      path.lineTo(i.left - i.blRadiusX, i.bottom);
      path.arcToPoint(
        Offset(i.left, i.bottom - radius),
        radius: i.blRadius,
        clockwise: i.blRadiusX < 0,
      );

      path.lineTo(i.left, i.top + radius);
      path.arcToPoint(
        Offset(i.left - i.tlRadiusX, i.top),
        radius: i.tlRadius,
        clockwise: i.tlRadiusX < 0,
      );
    }

    final paddingOffset = Offset(padding, 0);
    canvas.drawPath(path.shift(paddingOffset), paint);
    textPainter.paint(canvas, paddingOffset);
  }

  @override
  bool shouldRepaint(_RoundedTextboxPainter oldDelegate) {
    return oldDelegate.text != text ||
        oldDelegate.textStyle != textStyle ||
        oldDelegate.radius != radius ||
        oldDelegate.padding != padding ||
        oldDelegate.background != background ||
        oldDelegate.align != align ||
        oldDelegate.direction != direction;
  }
}

extension _LineMetricsHelpers on LineMetrics {
  double get right => left + width;
}

extension _NullableLineMetricsHelpers on LineMetrics? {
  double get rightOrDefault => this?.right ?? 0;
  double get leftOrDefault => this?.left ?? double.infinity;
}

extension _IterableHelpers<T> on Iterable<T> {
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return elementAt(index);
  }
}
