// lib/share_card_screen.dart
//
// Share-ready card preview and PNG export. This avoids adding a share package for
// now; the saved PNG can be shared from the device gallery/files.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'aspect_mark.dart';
import 'astro_core.dart';
import 'astro_display.dart';
import 'horoscope_chart.dart';

class ShareCardScreen extends StatefulWidget {
  final NatalChart chart;
  final RoastLevel roastLevel;
  final Aspect? heroAspect;
  final String message;
  final DateTime date;

  const ShareCardScreen({
    super.key,
    required this.chart,
    required this.roastLevel,
    required this.heroAspect,
    required this.message,
    required this.date,
  });

  @override
  State<ShareCardScreen> createState() => _ShareCardScreenState();
}

class _ShareCardScreenState extends State<ShareCardScreen> {
  static const _shareChannel = MethodChannel('astrology_app/share');
  final _boundaryKey = GlobalKey();
  bool _sharing = false;
  bool _saving = false;
  String? _savedPath;

  bool get _busy => _sharing || _saving;

  Future<File?> _writePng({required bool temporary}) async {
    final boundary =
        _boundaryKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) return null;
    final dir = temporary
        ? await getTemporaryDirectory()
        : await getApplicationDocumentsDirectory();
    final file = File(
      p.join(
        dir.path,
        'seijun-card-${DateTime.now().millisecondsSinceEpoch}.png',
      ),
    );
    await file.writeAsBytes(data.buffer.asUint8List());
    return file;
  }

  Future<void> _sharePng() async {
    setState(() => _sharing = true);
    try {
      final file = await _writePng(temporary: true);
      if (file == null) return;
      await _shareChannel.invokeMethod<void>('shareFile', {
        'path': file.path,
        'mimeType': 'image/png',
      });
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _savePng() async {
    setState(() {
      _saving = true;
      _savedPath = null;
    });
    try {
      final file = await _writePng(temporary: false);
      if (mounted && file != null) setState(() => _savedPath = file.path);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final highlight = widget.heroAspect == null
        ? const <Aspect>[]
        : [widget.heroAspect!];
    return Scaffold(
      appBar: AppBar(title: const Text('共有カード')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Center(
              child: RepaintBoundary(
                key: _boundaryKey,
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: _SocialCard(
                    chart: widget.chart,
                    highlight: highlight,
                    roastLevel: widget.roastLevel,
                    heroAspect: widget.heroAspect,
                    message: widget.message,
                    date: widget.date,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _busy ? null : _sharePng,
              icon: _sharing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.ios_share_outlined),
              label: Text(_sharing ? '準備中' : '共有'),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _busy ? null : _savePng,
                child: Text(_saving ? '保存中' : '画像を保存'),
              ),
            ),
            if (_savedPath != null) ...[
              const SizedBox(height: 10),
              Text(
                _savedPath!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.62),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SocialCard extends StatelessWidget {
  final NatalChart chart;
  final List<Aspect> highlight;
  final RoastLevel roastLevel;
  final Aspect? heroAspect;
  final String message;
  final DateTime date;

  const _SocialCard({
    required this.chart,
    required this.highlight,
    required this.roastLevel,
    required this.heroAspect,
    required this.message,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Color(0xFF080A0D)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'TODAY\'S TRANSIT',
                style: TextStyle(
                  color: Color(0xFFECEFF4),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
              const Spacer(),
              Text(
                roastLevel.badge,
                style: const TextStyle(
                  color: Color(0xFF9BE7D4),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: Color(0xFF8B96A3),
              fontSize: 12,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF26303A)),
                color: const Color(0xFF080A0D),
              ),
              clipBehavior: Clip.antiAlias,
              child: HoroscopeChart(
                chart: chart,
                highlightedAspects: highlight,
                showLabels: true,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF9BE7D4).withValues(alpha: 0.10),
                  border: Border.all(
                    color: const Color(0xFF9BE7D4).withValues(alpha: 0.44),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: heroAspect == null
                    ? const Text(
                        '—',
                        style: TextStyle(
                          color: Color(0xFF9BE7D4),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      )
                    : AspectMark(
                        type: heroAspect!.type,
                        color: const Color(0xFF9BE7D4),
                        size: 17,
                      ),
              ),
              const SizedBox(width: 10),
              if (heroAspect != null)
                Expanded(
                  child: _AspectNameSymbolLabel(
                    aspect: heroAspect!,
                    color: const Color(0xFF9BE7D4),
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFFECEFF4),
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.32,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            '星巡',
            style: TextStyle(
              color: Color(0xFF596571),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _AspectNameSymbolLabel extends StatelessWidget {
  final Aspect aspect;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;

  const _AspectNameSymbolLabel({
    required this.aspect,
    required this.color,
    required this.fontSize,
    required this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return AspectNameMarkLabel(
      leading: bodyLabel(aspect.a),
      trailing: bodyLabel(aspect.b),
      type: aspect.type,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }
}
