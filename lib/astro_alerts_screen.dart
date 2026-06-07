import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ad_banner.dart';
import 'ad_gate.dart';
import 'aspect_mark.dart';
import 'astro_core.dart';
import 'astro_service.dart';
import 'main.dart' show astroServiceProvider, isPaidProvider;
import 'paywall_screen.dart';

class AstroAlertsScreen extends ConsumerStatefulWidget {
  const AstroAlertsScreen({super.key});

  @override
  ConsumerState<AstroAlertsScreen> createState() => _AstroAlertsScreenState();
}

class _AstroAlertsScreenState extends ConsumerState<AstroAlertsScreen> {
  Future<_AlertReport?>? _future;

  @override
  void initState() {
    super.initState();
    _future = _buildAlertReport(ref.read(astroServiceProvider));
  }

  Future<void> _openPaywall() async {
    await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const PaywallScreen()));
    ref.invalidate(isPaidProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('星模様アラート')),
      body: SafeArea(
        child: ref
            .watch(isPaidProvider)
            .when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => _AlertGate(onTap: _openPaywall),
              data: (isPaid) {
                if (!isPaid) return _AlertGate(onTap: _openPaywall);
                return FutureBuilder<_AlertReport?>(
                  future: _future,
                  builder: (context, snap) {
                    if (!snap.hasData &&
                        snap.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final report = snap.data;
                    if (report == null) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('出生情報を登録すると、あなたへの影響つきで星模様を確認できます。'),
                        ),
                      );
                    }
                    return _AlertList(report: report);
                  },
                );
              },
            ),
      ),
    );
  }
}

class _AlertGate extends StatelessWidget {
  final VoidCallback onTap;
  const _AlertGate({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 36, 20, 32),
      children: [
        Icon(Icons.notifications_none, size: 44, color: scheme.primary),
        const SizedBox(height: 18),
        const Text(
          '星模様アラートはプレミアム機能です',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        Text(
          '新月・満月・天体移動が、あなたのどのテーマに出やすいかを確認できます。',
          textAlign: TextAlign.center,
          style: TextStyle(
            height: 1.7,
            color: scheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 28),
        FilledButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.workspace_premium_outlined),
          label: const Text('プレミアムを見る'),
        ),
        const SizedBox(height: 18),
        const AdGate(child: AppBannerAd()),
      ],
    );
  }
}

class _AlertList extends StatelessWidget {
  final _AlertReport report;
  const _AlertList({required this.report});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Text(
          '今後120日間の新月・満月・天体移動です。',
          style: TextStyle(
            fontSize: 13,
            height: 1.6,
            color: scheme.onSurface.withValues(alpha: 0.62),
          ),
        ),
        const SizedBox(height: 12),
        for (final event in report.events) ...[
          _EventCard(event: event),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  final _AstroEvent event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(event.icon, color: scheme.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  '${event.date.month}/${event.date.day}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              event.summary,
              style: const TextStyle(fontSize: 13.5, height: 1.6),
            ),
            const SizedBox(height: 10),
            Text(
              event.impact,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: scheme.onSurface.withValues(alpha: 0.72),
              ),
            ),
            if (event.aspect != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  AspectMark(
                    type: event.aspect!.type,
                    color: scheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_bodyName(event.aspect!.a)}と${_bodyName(event.aspect!.b)}に反応',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface.withValues(alpha: 0.62),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<_AlertReport?> _buildAlertReport(AstroService svc) async {
  final chart = await svc.resolveNatalChart();
  if (chart == null) return null;
  final start = DateTime.now();
  final startNoon = DateTime(start.year, start.month, start.day, 12);
  final events = <_AstroEvent>[
    ..._moonPhaseEvents(svc.ephemeris, chart, startNoon),
    ..._ingressEvents(svc.ephemeris, chart, startNoon),
  ]..sort((a, b) => a.date.compareTo(b.date));
  return _AlertReport(events: events.take(28).toList());
}

List<_AstroEvent> _moonPhaseEvents(
  EphemerisSource ephemeris,
  NatalChart chart,
  DateTime start,
) {
  final candidates = <_PhaseCandidate>[];
  for (var d = 0; d <= 120; d++) {
    final date = start.add(Duration(days: d));
    final jd = julianDayUtc(date.toUtc());
    final sun = ephemeris.eclipticLongitude(Body.sun, jd);
    final moon = ephemeris.eclipticLongitude(Body.moon, jd);
    final sep = separation(sun, moon);
    if (sep <= 12) {
      candidates.add(_PhaseCandidate(date, '新月', sep, moon));
    }
    if ((sep - 180).abs() <= 12) {
      candidates.add(_PhaseCandidate(date, '満月', (sep - 180).abs(), moon));
    }
  }

  final out = <_AstroEvent>[];
  var i = 0;
  while (i < candidates.length) {
    final kind = candidates[i].kind;
    var best = candidates[i];
    var j = i + 1;
    while (j < candidates.length &&
        candidates[j].kind == kind &&
        candidates[j].date.difference(candidates[j - 1].date).inDays <= 1) {
      if (candidates[j].distance < best.distance) best = candidates[j];
      j++;
    }
    final house = _houseForLongitude(chart, best.longitude);
    final aspect = _closestNatalAspect(Body.moon, best.longitude, chart);
    out.add(
      _AstroEvent(
        date: best.date,
        title: '${best.kind} ${signName(best.longitude)}',
        summary: best.kind == '新月'
            ? '新しい流れを仕込むタイミングです。予定や習慣を小さく始めるのに向きます。'
            : '見えてきた結果を受け取るタイミングです。続けるものと手放すものを分けやすい日です。',
        impact: 'あなたには第$houseハウスのテーマとして出やすいです。${_houseImpact(house)}',
        icon: best.kind == '新月'
            ? Icons.nightlight_round
            : Icons.brightness_2_outlined,
        aspect: aspect,
      ),
    );
    i = j;
  }
  return out;
}

List<_AstroEvent> _ingressEvents(
  EphemerisSource ephemeris,
  NatalChart chart,
  DateTime start,
) {
  const bodies = [
    Body.sun,
    Body.mercury,
    Body.venus,
    Body.mars,
    Body.jupiter,
    Body.saturn,
  ];
  final out = <_AstroEvent>[];
  for (final body in bodies) {
    var previousSign = _signAt(ephemeris, body, start);
    for (var d = 1; d <= 120; d++) {
      final date = start.add(Duration(days: d));
      final jd = julianDayUtc(date.toUtc());
      final lon = ephemeris.eclipticLongitude(body, jd);
      final currentSign = signIndex(lon);
      if (currentSign != previousSign) {
        final house = _houseForLongitude(chart, lon);
        final aspect = _closestNatalAspect(body, lon, chart);
        out.add(
          _AstroEvent(
            date: date,
            title: '${_bodyName(body)}が${signName(lon)}へ',
            summary: '${_bodyName(body)}のテーマが切り替わります。${_bodyTheme(body)}',
            impact: 'あなたには第$houseハウスのテーマとして出やすいです。${_houseImpact(house)}',
            icon: Icons.swap_calls,
            aspect: aspect,
          ),
        );
      }
      previousSign = currentSign;
    }
  }
  return out;
}

int _signAt(EphemerisSource ephemeris, Body body, DateTime date) {
  final jd = julianDayUtc(date.toUtc());
  return signIndex(ephemeris.eclipticLongitude(body, jd));
}

int _houseForLongitude(NatalChart chart, double longitude) {
  for (var i = 0; i < chart.cusps.length; i++) {
    if (norm360(longitude - chart.cusps[i]) < 30) return i + 1;
  }
  return 1;
}

Aspect? _closestNatalAspect(
  Body transitBody,
  double longitude,
  NatalChart chart,
) {
  Aspect? best;
  var bestDiff = double.infinity;
  for (final entry in chart.positions.entries) {
    for (final type in AspectType.values) {
      final diff = (separation(longitude, entry.value) - aspectAngle(type))
          .abs();
      final limit = aspectOrbLimit(type);
      if (diff <= limit && diff < bestDiff) {
        bestDiff = diff;
        best = Aspect(transitBody, entry.key, type, diff);
      }
    }
  }
  return best;
}

String _bodyTheme(Body body) {
  switch (body) {
    case Body.sun:
      return '自分の軸や目標の置き場所が変わりやすい時期です。';
    case Body.mercury:
      return '考え方、連絡、学びの流れが変わりやすい時期です。';
    case Body.venus:
      return '好きなもの、人との距離感、楽しみ方が変わりやすい時期です。';
    case Body.mars:
      return '行動力や勝負どころが切り替わりやすい時期です。';
    case Body.jupiter:
      return '広げたいこと、育てたいことの方向が見えやすい時期です。';
    case Body.saturn:
      return '責任や課題を置く場所が変わり、腰を据えるテーマが出ます。';
    default:
      return '日々の空気感が切り替わりやすい時期です。';
  }
}

String _houseImpact(int house) {
  switch (house) {
    case 1:
      return '自分の見せ方、第一印象、始め方に影響します。';
    case 2:
      return 'お金、持ち物、安心感の作り方に影響します。';
    case 3:
      return '会話、学び、身近な人とのやり取りに影響します。';
    case 4:
      return '家、家族、心の居場所に影響します。';
    case 5:
      return '恋、遊び、表現したいことに影響します。';
    case 6:
      return '仕事の習慣、体調管理、日々の役割に影響します。';
    case 7:
      return '対人関係、契約、パートナーシップに影響します。';
    case 8:
      return '深い関係、共有するもの、手放しに影響します。';
    case 9:
      return '学び、旅、専門性、信じるものに影響します。';
    case 10:
      return 'キャリア、目標、社会的な見られ方に影響します。';
    case 11:
      return '仲間、コミュニティ、未来計画に影響します。';
    case 12:
      return '休息、無意識、ひとりで整える時間に影響します。';
    default:
      return '日々の流れに影響します。';
  }
}

String _bodyName(Body body) {
  switch (body) {
    case Body.sun:
      return '太陽';
    case Body.moon:
      return '月';
    case Body.mercury:
      return '水星';
    case Body.venus:
      return '金星';
    case Body.mars:
      return '火星';
    case Body.jupiter:
      return '木星';
    case Body.saturn:
      return '土星';
    case Body.uranus:
      return '天王星';
    case Body.neptune:
      return '海王星';
    case Body.pluto:
      return '冥王星';
    case Body.earthBary:
      return '地球';
  }
}

class _AlertReport {
  final List<_AstroEvent> events;
  const _AlertReport({required this.events});
}

class _AstroEvent {
  final DateTime date;
  final String title;
  final String summary;
  final String impact;
  final IconData icon;
  final Aspect? aspect;

  const _AstroEvent({
    required this.date,
    required this.title,
    required this.summary,
    required this.impact,
    required this.icon,
    this.aspect,
  });
}

class _PhaseCandidate {
  final DateTime date;
  final String kind;
  final double distance;
  final double longitude;

  const _PhaseCandidate(this.date, this.kind, this.distance, this.longitude);
}
