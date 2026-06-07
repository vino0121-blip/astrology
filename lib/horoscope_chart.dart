// lib/horoscope_chart.dart
//
// Full natal chart renderer. The painter intentionally favors a precise,
// instrument-like look over a cute fortune-telling style.

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'astro_core.dart';
import 'astro_display.dart';

class HoroscopeChart extends StatefulWidget {
  final NatalChart chart;
  final List<Aspect> highlightedAspects;
  final Body? selectedBody;
  final ValueChanged<Body>? onBodySelected;
  final ValueChanged<int>? onHouseSelected;
  final ValueChanged<bool>? onGestureActiveChanged;
  final bool showLabels;
  final double revealProgress;

  const HoroscopeChart({
    super.key,
    required this.chart,
    this.highlightedAspects = const [],
    this.selectedBody,
    this.onBodySelected,
    this.onHouseSelected,
    this.onGestureActiveChanged,
    this.showLabels = true,
    this.revealProgress = 1,
  });

  @override
  State<HoroscopeChart> createState() => _HoroscopeChartState();
}

class _HoroscopeChartState extends State<HoroscopeChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  double _scale = 1;
  double _scaleStart = 1;
  Offset _offset = Offset.zero;
  Offset _offsetStart = Offset.zero;
  Offset _focalStart = Offset.zero;
  int _pointerCount = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );
  }

  @override
  void didUpdateWidget(covariant HoroscopeChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedBody != null &&
        widget.selectedBody != oldWidget.selectedBody) {
      _pulseController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    widget.onGestureActiveChanged?.call(false);
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        _pointerCount++;
        widget.onGestureActiveChanged?.call(true);
      },
      onPointerUp: (_) => _releasePointer(),
      onPointerCancel: (_) => _releasePointer(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onDoubleTap: () => setState(() {
          _scale = 1;
          _offset = Offset.zero;
        }),
        onScaleStart: (details) {
          _scaleStart = _scale;
          _offsetStart = _offset;
          _focalStart = details.localFocalPoint;
        },
        onScaleUpdate: (details) {
          if (details.pointerCount >= 2) {
            final nextScale = (_scaleStart * details.scale).clamp(1.0, 2.8);
            final box = context.findRenderObject() as RenderBox?;
            if (box == null) return;
            final center = Offset(box.size.width / 2, box.size.height / 2);
            final basePoint =
                (_focalStart - center - _offsetStart) / _scaleStart;
            final nextOffset =
                details.localFocalPoint - center - basePoint * nextScale;
            setState(() {
              _scale = nextScale;
              _offset = _clampOffset(nextOffset, box.size, nextScale);
            });
            return;
          }
          if (_scale <= 1) return;
          final box = context.findRenderObject() as RenderBox?;
          if (box == null) return;
          setState(() {
            _offset = _clampOffset(
              _offset + details.focalPointDelta,
              box.size,
              _scale,
            );
          });
        },
        onTapUp: (details) {
          final box = context.findRenderObject() as RenderBox?;
          if (box == null) return;
          final local = _unscaledPoint(details.localPosition, box.size);
          final body = _nearestBody(local, box.size);
          if (body != null && widget.onBodySelected != null) {
            _pulseController.forward(from: 0);
            widget.onBodySelected!(body);
            return;
          }
          final house = _houseAt(local, box.size);
          if (house != null && widget.onHouseSelected != null) {
            widget.onHouseSelected!(house);
          }
        },
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, _) => CustomPaint(
            painter: HoroscopeChartPainter(
              chart: widget.chart,
              highlightedAspects: widget.highlightedAspects,
              selectedBody: widget.selectedBody,
              showLabels: widget.showLabels,
              revealProgress: widget.revealProgress,
              highlightPulse: _pulseController.value,
              viewScale: _scale,
              viewOffset: _offset,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }

  void _releasePointer() {
    _pointerCount = math.max(0, _pointerCount - 1);
    if (_pointerCount == 0) widget.onGestureActiveChanged?.call(false);
  }

  Offset _unscaledPoint(Offset point, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    return center + (point - center - _offset) / _scale;
  }

  Offset _clampOffset(Offset offset, Size size, double scale) {
    if (scale <= 1) return Offset.zero;
    final extra = math.min(size.width, size.height) * 0.36 * (scale - 1);
    return Offset(
      offset.dx.clamp(-extra, extra).toDouble(),
      offset.dy.clamp(-extra, extra).toDouble(),
    );
  }

  Body? _nearestBody(Offset point, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final chartR = math.min(size.width, size.height) * 0.405;
    final radius = chartR * 0.76;
    Body? best;
    var bestDistance = double.infinity;
    final entries = widget.chart.positions.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    final offsets = _labelOffsets(entries.map((e) => e.value).toList());
    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      final p = _pointForLongitude(center, radius + offsets[i], e.value);
      final d = (p - point).distance;
      if (d < bestDistance) {
        bestDistance = d;
        best = e.key;
      }
    }
    return bestDistance <= 48 ? best : null;
  }

  int? _houseAt(Offset point, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final chartR = math.min(size.width, size.height) * 0.405;
    final distance = (point - center).distance;
    if (distance < chartR * 0.36 || distance > chartR * 0.88) return null;
    final angle = math.atan2(point.dy - center.dy, point.dx - center.dx);
    final longitude = norm360(angle * 180 / math.pi + 90);
    for (var i = 0; i < widget.chart.cusps.length; i++) {
      if (norm360(longitude - widget.chart.cusps[i]) < 30) return i + 1;
    }
    return null;
  }
}

class HoroscopeChartPainter extends CustomPainter {
  final NatalChart chart;
  final List<Aspect> highlightedAspects;
  final Body? selectedBody;
  final bool showLabels;
  final double revealProgress;
  final double highlightPulse;
  final double viewScale;
  final Offset viewOffset;

  HoroscopeChartPainter({
    required this.chart,
    this.highlightedAspects = const [],
    this.selectedBody,
    this.showLabels = true,
    this.revealProgress = 1,
    this.highlightPulse = 0,
    this.viewScale = 1,
    this.viewOffset = Offset.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2) + viewOffset;
    final r = math.min(size.width, size.height) * 0.405 * viewScale;
    final outerR = r;
    final zodiacInnerR = r * 0.86;
    final degreeR = r * 0.81;
    final houseR = r * 0.67;
    final planetR = r * 0.76;
    final aspectGuideR = r * 0.49;
    final aspectR = r * 0.42;
    final houseNumberR = (aspectGuideR + aspectR) / 2;

    final progress = revealProgress.clamp(0.0, 1.0);
    _drawBackground(canvas, size, center, r);
    _drawFaded(
      canvas,
      size,
      _fade(progress, 0.02, 0.16),
      () => _drawOuterGlow(canvas, center, outerR),
    );
    _drawFaded(
      canvas,
      size,
      _fade(progress, 0.08, 0.24),
      () => _drawRings(
        canvas,
        center,
        outerR,
        zodiacInnerR,
        degreeR,
        houseR,
        aspectGuideR,
        aspectR,
      ),
    );
    _drawFaded(
      canvas,
      size,
      _fade(progress, 0.18, 0.36),
      () => _drawZodiacBand(canvas, center, outerR, zodiacInnerR),
    );
    _drawFaded(
      canvas,
      size,
      _fade(progress, 0.32, 0.50),
      () => _drawDegreeTicks(canvas, center, zodiacInnerR, degreeR),
    );
    _drawFaded(
      canvas,
      size,
      _fade(progress, 0.44, 0.62),
      () => _drawHouses(canvas, center, aspectR, zodiacInnerR, houseNumberR),
    );
    _drawFaded(
      canvas,
      size,
      _fade(progress, 0.52, 0.74),
      () => _drawAngles(canvas, center, houseR, outerR),
    );
    _drawFaded(
      canvas,
      size,
      _fade(progress, 0.70, 0.90),
      () => _drawAspects(canvas, center, aspectR),
    );
    _drawFaded(
      canvas,
      size,
      _fade(progress, 0.58, 0.82),
      () => _drawBodies(canvas, center, planetR),
    );
  }

  void _drawBackground(Canvas canvas, Size size, Offset center, double r) {
    final rect = Offset.zero & size;
    final bg = Paint()
      ..shader = ui.Gradient.radial(center, r * 1.35, const [
        Color(0xFF121821),
        Color(0xFF06080C),
      ]);
    canvas.drawRect(rect, bg);
    canvas.drawCircle(
      center,
      r * 1.02,
      Paint()
        ..shader = ui.Gradient.radial(center, r, [
          const Color(0xFF9BE7D4).withValues(alpha: 0.05),
          Colors.transparent,
        ]),
    );
  }

  void _drawFaded(Canvas canvas, Size size, double opacity, VoidCallback draw) {
    if (opacity <= 0) return;
    canvas.saveLayer(
      Offset.zero & size,
      Paint()
        ..color = Color.fromARGB(
          (opacity.clamp(0.0, 1.0) * 255).round(),
          255,
          255,
          255,
        ),
    );
    draw();
    canvas.restore();
  }

  double _fade(double progress, double start, double end) {
    if (progress <= start) return 0;
    if (progress >= end) return 1;
    final t = ((progress - start) / (end - start)).clamp(0.0, 1.0);
    return t * t * (3 - 2 * t);
  }

  void _drawRings(
    Canvas canvas,
    Offset center,
    double outerR,
    double zodiacInnerR,
    double degreeR,
    double houseR,
    double aspectGuideR,
    double aspectR,
  ) {
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFFECEFF4).withValues(alpha: 0.34);
    final neon = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = const Color(0xFF9BE7D4).withValues(alpha: 0.35);
    final fine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..color = const Color(0xFFECEFF4).withValues(alpha: 0.15);
    canvas.drawCircle(center, outerR, ring);
    canvas.drawCircle(center, zodiacInnerR, neon);
    canvas.drawCircle(center, degreeR, fine);
    canvas.drawCircle(center, houseR, fine);
    canvas.drawCircle(center, aspectGuideR, fine);
    canvas.drawCircle(center, aspectR, fine);
    canvas.drawCircle(center, aspectR * 0.32, fine);
  }

  void _drawOuterGlow(Canvas canvas, Offset center, double r) {
    canvas.drawCircle(
      center,
      r * 1.01,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..color = const Color(0xFF9BE7D4).withValues(alpha: 0.035),
    );
  }

  void _drawDegreeTicks(
    Canvas canvas,
    Offset center,
    double outerR,
    double innerR,
  ) {
    final tick = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.55
      ..color = const Color(0xFFECEFF4).withValues(alpha: 0.30);
    final major = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = const Color(0xFF9BE7D4).withValues(alpha: 0.55);
    for (var i = 0; i < 360; i++) {
      final a = _angleForLongitude(i.toDouble());
      final isMajor = i % 30 == 0;
      final isMedium = i % 10 == 0;
      final len = isMajor
          ? 0.055
          : isMedium
          ? 0.038
          : 0.020;
      final p1 =
          center + Offset(math.cos(a), math.sin(a)) * (outerR - outerR * len);
      final p2 = center + Offset(math.cos(a), math.sin(a)) * outerR;
      canvas.drawLine(p1, p2, isMajor ? major : tick);
    }
  }

  void _drawZodiacBand(
    Canvas canvas,
    Offset center,
    double outerR,
    double innerR,
  ) {
    final sector = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFFECEFF4).withValues(alpha: 0.24);
    for (var i = 0; i < 12; i++) {
      final lon = i * 30.0;
      final a = _angleForLongitude(lon);
      final p1 = center + Offset(math.cos(a), math.sin(a)) * innerR;
      final p2 = center + Offset(math.cos(a), math.sin(a)) * outerR;
      canvas.drawLine(p1, p2, sector);
      _drawText(
        canvas,
        signGlyphs[i],
        center +
            Offset(
                  math.cos(_angleForLongitude(lon + 15)),
                  math.sin(_angleForLongitude(lon + 15)),
                ) *
                ((outerR + innerR) / 2),
        21,
        _signColor(i),
        align: TextAlign.center,
        weight: FontWeight.w800,
        fontFamily: astroSymbolFontFamily,
        fontFamilyFallback: astroSymbolFontFamilyFallback,
      );
    }
  }

  void _drawHouses(
    Canvas canvas,
    Offset center,
    double lineInnerR,
    double outerR,
    double numberR,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.85
      ..color = const Color(0xFFECEFF4).withValues(alpha: 0.26);
    for (var i = 0; i < chart.cusps.length; i++) {
      final a = _angleForLongitude(chart.cusps[i]);
      final p1 = center + Offset(math.cos(a), math.sin(a)) * lineInnerR;
      final p2 = center + Offset(math.cos(a), math.sin(a)) * outerR;
      canvas.drawLine(p1, p2, paint);
      final labelAngle = _angleForLongitude(chart.cusps[i] + 15);
      _drawText(
        canvas,
        '${i + 1}',
        center + Offset(math.cos(labelAngle), math.sin(labelAngle)) * numberR,
        12,
        const Color(0xFFECEFF4).withValues(alpha: 0.82),
        align: TextAlign.center,
      );
    }
  }

  void _drawAspects(Canvas canvas, Offset center, double aspectR) {
    final highlighted = {for (final a in highlightedAspects) _aspectKey(a)};
    for (final a in chart.aspects) {
      final p1 = _pointForLongitude(center, aspectR, chart.positions[a.a]!);
      final p2 = _pointForLongitude(center, aspectR, chart.positions[a.b]!);
      final hot = highlighted.contains(_aspectKey(a));
      final tense = isTenseAspect(a.type);
      final major = _isMajorAspect(a.type);
      final base = tense ? const Color(0xFFFF6E73) : const Color(0xFF5D9BFF);
      final color = hot
          ? const Color(0xFF9BE7D4)
          : base.withValues(alpha: major ? 0.46 : 0.24);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = hot ? 2.2 : (major ? 0.85 : 0.55)
        ..color = color;
      if (hot) {
        final glow = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFF9BE7D4).withValues(alpha: 0.13);
        canvas.drawLine(p1, p2, glow);
      }
      canvas.drawLine(p1, p2, paint);
    }
  }

  void _drawAngles(Canvas canvas, Offset center, double innerR, double outerR) {
    _drawAngleMarker(
      canvas,
      center,
      innerR,
      outerR,
      chart.angles.ascendant,
      'Asc',
      const Color(0xFF9BE7D4),
    );
    _drawAngleMarker(
      canvas,
      center,
      innerR,
      outerR,
      chart.angles.midheaven,
      'MC',
      const Color(0xFFB7C2FF),
    );
  }

  void _drawAngleMarker(
    Canvas canvas,
    Offset center,
    double innerR,
    double outerR,
    double lon,
    String label,
    Color c,
  ) {
    final a = _angleForLongitude(lon);
    final p1 = center + Offset(math.cos(a), math.sin(a)) * (innerR * 0.73);
    final p2 = center + Offset(math.cos(a), math.sin(a)) * outerR;
    final paint = Paint()
      ..color = c.withValues(alpha: 0.86)
      ..strokeWidth = 1.5;
    canvas.drawLine(p1, p2, paint);
    _drawText(
      canvas,
      label,
      center + Offset(math.cos(a), math.sin(a)) * (outerR * 1.07),
      10,
      c,
      align: TextAlign.center,
      weight: FontWeight.w900,
    );
  }

  void _drawBodies(Canvas canvas, Offset center, double r) {
    final entries = chart.positions.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    final offsets = _labelOffsets(entries.map((e) => e.value).toList());
    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      final selected = selectedBody == e.key;
      final highlighted = highlightedAspects.any(
        (a) => a.a == e.key || a.b == e.key,
      );
      final p = _pointForLongitude(center, r + offsets[i], e.value);
      final color = selected
          ? const Color(0xFF9BE7D4)
          : highlighted
          ? const Color(0xFFFFD36E)
          : const Color(0xFFECEFF4);
      if (highlighted || selected) {
        if (selected && highlightPulse > 0) {
          final t = Curves.easeOutCubic.transform(highlightPulse);
          canvas.drawCircle(
            p,
            18 + 22 * t,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.2 * (1 - t)
              ..color = color.withValues(alpha: 0.72 * (1 - t)),
          );
          canvas.drawCircle(
            p,
            10 + 14 * t,
            Paint()..color = color.withValues(alpha: 0.12 * (1 - t)),
          );
        }
        canvas.drawCircle(
          p,
          selected ? 21 : 17,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = selected ? 1.4 : 1
            ..color = color.withValues(alpha: selected ? 0.72 : 0.44),
        );
      }
      canvas.drawCircle(p, 2.4, Paint()..color = color.withValues(alpha: 0.88));
      if (showLabels) {
        _drawPlanetLabel(
          canvas,
          p,
          e.key,
          e.value,
          color,
          selected || highlighted,
        );
      }
    }
  }

  void _drawPlanetLabel(
    Canvas canvas,
    Offset center,
    Body body,
    double longitude,
    Color color,
    bool active,
  ) {
    final degree = degreeInSign(longitude).floor().toString().padLeft(2, '0');
    final min = ((degreeInSign(longitude) % 1) * 60).round().toString().padLeft(
      2,
      '0',
    );
    final painter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: bodyMark(body),
            style: TextStyle(
              color: color,
              fontSize: active ? 18 : 16,
              fontWeight: FontWeight.w900,
              fontFamily: astroSymbolFontFamily,
              fontFamilyFallback: astroSymbolFontFamilyFallback,
              height: 1,
            ),
          ),
          TextSpan(
            text: ' $degree°$min',
            style: TextStyle(
              color: color.withValues(alpha: 0.82),
              fontSize: 9,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 72);
    final rect = Rect.fromCenter(
      center: center,
      width: painter.width + 8,
      height: painter.height + 6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()
        ..color = const Color(
          0xFF06080C,
        ).withValues(alpha: active ? 0.78 : 0.58),
    );
    painter.paint(canvas, rect.topLeft + const Offset(4, 3));
  }

  @override
  bool shouldRepaint(covariant HoroscopeChartPainter oldDelegate) =>
      oldDelegate.chart != chart ||
      oldDelegate.selectedBody != selectedBody ||
      oldDelegate.highlightedAspects != highlightedAspects ||
      oldDelegate.showLabels != showLabels ||
      oldDelegate.revealProgress != revealProgress ||
      oldDelegate.highlightPulse != highlightPulse ||
      oldDelegate.viewScale != viewScale ||
      oldDelegate.viewOffset != viewOffset;
}

Offset _pointForLongitude(Offset center, double radius, double longitude) {
  final a = _angleForLongitude(longitude);
  return center + Offset(math.cos(a), math.sin(a)) * radius;
}

double _angleForLongitude(double longitude) {
  // Put Aries near the top and move clockwise to feel like an app chart,
  // while preserving stable relative positions.
  return (longitude - 90) * math.pi / 180.0;
}

String _aspectKey(Aspect a) => '${a.a.name}:${a.b.name}:${a.type.name}';

bool _isMajorAspect(AspectType type) {
  switch (type) {
    case AspectType.conjunction:
    case AspectType.sextile:
    case AspectType.square:
    case AspectType.trine:
    case AspectType.opposition:
      return true;
    case AspectType.semiSextile:
    case AspectType.semiSquare:
    case AspectType.quintile:
    case AspectType.sesquiquadrate:
    case AspectType.quincunx:
      return false;
  }
}

Color _signColor(int index) {
  return const Color(0xFFECEFF4).withValues(alpha: 0.78);
}

List<double> _labelOffsets(List<double> longitudes) {
  final offsets = List<double>.filled(longitudes.length, 0);
  for (var i = 1; i < longitudes.length; i++) {
    final prev = longitudes[i - 1];
    final current = longitudes[i];
    final near = separation(prev, current) < 8;
    if (near) {
      offsets[i] = offsets[i - 1] + 16;
    }
  }
  for (var i = 0; i < offsets.length; i++) {
    offsets[i] = offsets[i].clamp(0, 42).toDouble();
  }
  return offsets;
}

void _drawText(
  Canvas canvas,
  String text,
  Offset center,
  double size,
  Color color, {
  TextAlign align = TextAlign.left,
  FontWeight weight = FontWeight.w400,
  String? fontFamily,
  List<String>? fontFamilyFallback,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: weight,
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
        height: 1.1,
        letterSpacing: 0,
      ),
    ),
    textAlign: align,
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: 120);
  painter.paint(canvas, center - Offset(painter.width / 2, painter.height / 2));
}
