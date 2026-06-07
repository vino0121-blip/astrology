// lib/chart_reveal_screen.dart
//
// A short "chart generation ritual" shown right after the user saves birth
// data. It turns a plain form submit into the moment the natal chart appears.

import 'package:flutter/material.dart';

import 'astro_core.dart';
import 'astro_display.dart';
import 'horoscope_chart.dart';

class ChartRevealScreen extends StatefulWidget {
  final NatalChart chart;
  final void Function(BuildContext context) onDone;

  const ChartRevealScreen({
    super.key,
    required this.chart,
    required this.onDone,
  });

  @override
  State<ChartRevealScreen> createState() => _ChartRevealScreenState();
}

class _ChartRevealScreenState extends State<ChartRevealScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    );
    _progress = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hero = _tightestAspect(widget.chart);
    final highlight = hero == null ? const <Aspect>[] : [hero];
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _progress,
          builder: (context, _) {
            final p = _progress.value;
            return Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _RevealHeader(progress: p),
                  const SizedBox(height: 18),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF080A0D),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF26303A)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: HoroscopeChart(
                        chart: widget.chart,
                        highlightedAspects: highlight,
                        revealProgress: p,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _RevealStatus(
                    progress: p,
                    aspect: hero,
                    chart: widget.chart,
                  ),
                  const SizedBox(height: 16),
                  AnimatedOpacity(
                    opacity: p >= 0.98 ? 1 : 0,
                    duration: const Duration(milliseconds: 260),
                    child: FilledButton(
                      onPressed: p >= 0.98 ? () => widget.onDone(context) : null,
                      child: const Text('星図を見る'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RevealHeader extends StatelessWidget {
  final double progress;
  const _RevealHeader({required this.progress});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NATAL CHART',
          style: TextStyle(
            color: scheme.primary,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'あなたが生まれた瞬間の星図を描画しています。',
          style: TextStyle(
            fontSize: 20,
            height: 1.35,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 3,
            backgroundColor: scheme.onSurface.withValues(alpha: 0.09),
            valueColor: AlwaysStoppedAnimation(scheme.primary),
          ),
        ),
      ],
    );
  }
}

class _RevealStatus extends StatelessWidget {
  final double progress;
  final Aspect? aspect;
  final NatalChart chart;
  const _RevealStatus({
    required this.progress,
    required this.aspect,
    required this.chart,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 15),
      decoration: BoxDecoration(
        color: const Color(0xFF10141A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF26303A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _stageLabel(progress),
            style: TextStyle(
              color: scheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _stageMessage(progress, aspect, chart),
            style: const TextStyle(
              fontSize: 15,
              height: 1.55,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

String _stageLabel(double p) {
  if (p < 0.18) return '01 / BIRTH DATA';
  if (p < 0.36) return '02 / ZODIAC RING';
  if (p < 0.54) return '03 / HOUSES';
  if (p < 0.74) return '04 / PLANETS';
  if (p < 0.96) return '05 / ASPECTS';
  return 'COMPLETE';
}

String _stageMessage(double p, Aspect? aspect, NatalChart chart) {
  if (p < 0.18) return '出生日時と場所を固定。ここからあなた専用の座標に変換します。';
  if (p < 0.36) return '12星座のリングを展開中。まずは宇宙の目盛りを引いています。';
  if (p < 0.54) return 'ASCとMC、ハウスを配置中。人生の舞台設定が見えてきます。';
  if (p < 0.74) return '太陽、月、水星、金星、火星、木星、土星を配置中。';
  if (p < 0.96) {
    if (aspect == null) return '天体同士の関係を接続中。目立つ衝突は少なめです。';
    return '${aspectShort(aspect)} を検出。ここ、あとでちゃんと見ます。';
  }
  final asc = '${signName(chart.angles.ascendant)} ${degreeInSign(chart.angles.ascendant).toStringAsFixed(1)}°';
  return '完成。ASCは $asc。あなたの星図、逃げ道なく出ました。';
}

Aspect? _tightestAspect(NatalChart chart) {
  if (chart.aspects.isEmpty) return null;
  final aspects = [...chart.aspects]..sort((a, b) => a.orb.compareTo(b.orb));
  return aspects.first;
}
