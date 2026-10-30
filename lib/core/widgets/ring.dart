import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Anneau de progression (jauge circulaire). `value` entre 0 et 1.
class Ring extends StatelessWidget {
  const Ring({
    super.key,
    required this.value,
    required this.color,
    required this.track,
    required this.size,
    required this.strokeWidth,
    this.semanticLabel,
    this.child,
  });

  final double value;
  final Color color;
  final Color track;
  final double size;
  final double strokeWidth;
  final String? semanticLabel;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(
              value: value,
              color: color,
              track: track,
              strokeWidth: strokeWidth,
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.color,
    required this.track,
    required this.strokeWidth,
  });

  final double value;
  final Color color;
  final Color track;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, base..color = track);

    final v = value.clamp(0.0, 1.0);
    if (v > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * v,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value ||
      old.color != color ||
      old.track != track ||
      old.strokeWidth != strokeWidth;
}
