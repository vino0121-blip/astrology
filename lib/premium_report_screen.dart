import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ai_diagnosis_service.dart';
import 'aspect_mark.dart';
import 'astro_core.dart';
import 'astro_narration.dart' show DailyReading, DailyReadingItem;
import 'astro_service.dart';
import 'daily_ai_diagnosis_screen.dart';
import 'main.dart'
    show aiDiagnosisServiceProvider, astroServiceProvider, isPaidProvider;
import 'paywall_screen.dart';

class PremiumReportScreen extends ConsumerStatefulWidget {
  const PremiumReportScreen({super.key});

  @override
  ConsumerState<PremiumReportScreen> createState() =>
      _PremiumReportScreenState();
}

class _PremiumReportScreenState extends ConsumerState<PremiumReportScreen> {
  late DateTime _month;
  late DateTime _minMonth;
  late DateTime _maxMonth;
  Future<_MonthlyReport?>? _reportFuture;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
    _minMonth = DateTime(now.year - 1, now.month, 1);
    _maxMonth = DateTime(now.year + 3, now.month, 1);
    _refresh();
  }

  void _refresh() {
    _reportFuture = _buildMonthlyReport(
      ref.read(astroServiceProvider),
      ref.read(aiDiagnosisServiceProvider),
      _month,
    );
  }

  void _moveMonth(int delta) {
    final next = DateTime(_month.year, _month.month + delta, 1);
    if (_monthBefore(next, _minMonth) || _monthAfter(next, _maxMonth)) return;
    setState(() {
      _month = next;
      _refresh();
    });
  }

  Future<void> _openPaywall() async {
    await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const PaywallScreen()));
    ref.invalidate(isPaidProvider);
    if (mounted) setState(_refresh);
  }

  @override
  Widget build(BuildContext context) {
    final paid = ref.watch(isPaidProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('月間AI診断'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: '前の月',
            onPressed:
                _monthBefore(_month, _minMonth) || _sameMonth(_month, _minMonth)
                ? null
                : () => _moveMonth(-1),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: '次の月',
            onPressed:
                _monthAfter(_month, _maxMonth) || _sameMonth(_month, _maxMonth)
                ? null
                : () => _moveMonth(1),
          ),
        ],
      ),
      body: SafeArea(
        child: paid.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _GateView(onTap: _openPaywall),
          data: (isPaid) {
            if (!isPaid) return _GateView(onTap: _openPaywall);
            return FutureBuilder<_MonthlyReport?>(
              future: _reportFuture,
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
                      child: Text('出生情報を登録すると、月間AI診断を作成できます。'),
                    ),
                  );
                }
                return _ReportView(report: report);
              },
            );
          },
        ),
      ),
    );
  }
}

class _GateView extends StatelessWidget {
  final VoidCallback onTap;
  const _GateView({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
      children: [
        Icon(Icons.auto_awesome, size: 42, color: scheme.primary),
        const SizedBox(height: 18),
        const Text(
          '月間AI診断はプレミアム機能です',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(
          '1か月の流れ、注意日、伸ばすテーマをまとめて確認できます。',
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
      ],
    );
  }
}

class _ReportView extends StatelessWidget {
  final _MonthlyReport report;
  const _ReportView({required this.report});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        _MonthHeader(report: report),
        const SizedBox(height: 12),
        _ScoreOverview(report: report),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DailyAiDiagnosisScreen()),
            ),
            icon: const Icon(Icons.auto_awesome, size: 17),
            label: const Text('今日の詳しいAI診断'),
          ),
        ),
        const SizedBox(height: 12),
        _AiDiagnosisCard(report: report),
        const SizedBox(height: 12),
        _SectionTitle(
          icon: Icons.timeline_outlined,
          title: '月の流れ',
          subtitle: '週ごとのリズム',
        ),
        const SizedBox(height: 8),
        for (final week in report.weeks) ...[
          _WeekRow(week: week),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 12),
        _SectionTitle(
          icon: Icons.flag_outlined,
          title: '重要日',
          subtitle: '良い日と慎重にいきたい日',
        ),
        const SizedBox(height: 8),
        for (final day in report.highlightDays) ...[
          _HighlightDayRow(day: day),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 12),
        _SectionTitle(
          icon: Icons.grid_view_outlined,
          title: 'カテゴリ別レポート',
          subtitle: '今月の使いどころ',
        ),
        const SizedBox(height: 8),
        for (final item in report.categories) ...[
          _CategoryReportRow(item: item),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 12),
        Text(
          '診断は出生図と月内トランジットをもとに生成しています。',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.5,
            color: scheme.onSurface.withValues(alpha: 0.45),
          ),
        ),
      ],
    );
  }
}

class _MonthHeader extends StatelessWidget {
  final _MonthlyReport report;
  const _MonthHeader({required this.report});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${report.month.year}年${report.month.month}月',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          report.monthTitle,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: scheme.onSurface.withValues(alpha: 0.72),
          ),
        ),
      ],
    );
  }
}

class _ScoreOverview extends StatelessWidget {
  final _MonthlyReport report;
  const _ScoreOverview({required this.report});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${(report.averageScore * 100).round()}',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '/ 100',
                  style: TextStyle(
                    fontSize: 14,
                    color: scheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
                const Spacer(),
                _ScoreBadge(label: report.scoreBand),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: report.averageScore,
                minHeight: 8,
                backgroundColor: scheme.onSurface.withValues(alpha: 0.1),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: '追い風',
                    value: '${report.best.date.day}日',
                    sub: '${(report.best.score * 100).round()}点',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniStat(
                    label: '調整日',
                    value: '${report.careful.date.day}日',
                    sub: '${(report.careful.score * 100).round()}点',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AiDiagnosisCard extends StatelessWidget {
  final _MonthlyReport report;
  const _AiDiagnosisCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, size: 20, color: scheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'AI総合診断',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 14),
            for (final block in report.aiBlocks) ...[
              Text(
                block.title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                block.body,
                style: const TextStyle(fontSize: 14.5, height: 1.75),
              ),
              if (block != report.aiBlocks.last) const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: scheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            subtitle,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _WeekRow extends StatelessWidget {
  final _WeekReport week;
  const _WeekRow({required this.week});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            SizedBox(
              width: 58,
              child: Text(
                '${week.startDay}-${week.endDay}日',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: week.averageScore,
                  minHeight: 7,
                  backgroundColor: scheme.onSurface.withValues(alpha: 0.1),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 42,
              child: Text(
                '${(week.averageScore * 100).round()}',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: _scoreColor(scheme, week.averageScore),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightDayRow extends StatelessWidget {
  final _DayReport day;
  const _HighlightDayRow({required this.day});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final aspect = day.heroAspect;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${day.date.month}/${day.date.day}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(width: 8),
                _ScoreBadge(label: day.score >= 0.5 ? '追い風' : '調整'),
                const Spacer(),
                Text(
                  '${(day.score * 100).round()}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: _scoreColor(scheme, day.score),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              day.reading.overallHeadline,
              style: const TextStyle(fontSize: 13.5, height: 1.6),
            ),
            if (aspect != null) ...[
              const SizedBox(height: 10),
              AspectNameMarkLabel(
                leading: _bodyName(aspect.a),
                trailing: _bodyName(aspect.b),
                type: aspect.type,
                color: scheme.onSurface.withValues(alpha: 0.75),
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryReportRow extends StatelessWidget {
  final _CategoryReport item;
  const _CategoryReportRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final aspect = item.aspect;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                if (aspect != null)
                  AspectNameMarkLabel(
                    leading: _bodyName(aspect.a),
                    trailing: _bodyName(aspect.b),
                    type: aspect.type,
                    color: scheme.onSurface.withValues(alpha: 0.65),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.body,
              style: const TextStyle(fontSize: 13.5, height: 1.65),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final String label;
  const _ScoreBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          color: scheme.primary,
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  const _MiniStat({
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: scheme.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: scheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          Text(
            sub,
            style: TextStyle(
              fontSize: 11.5,
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

Future<_MonthlyReport?> _buildMonthlyReport(
  AstroService svc,
  AiDiagnosisService aiService,
  DateTime month,
) async {
  final chart = await svc.resolveNatalChart();
  if (chart == null) return null;

  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  final days = <_DayReport>[];
  for (var day = 1; day <= daysInMonth; day++) {
    final date = DateTime(month.year, month.month, day, 12);
    final reading = await svc.getReadingForDate(date);
    if (reading == null) continue;
    final hero = await svc.getHeroAspectForDate(date);
    days.add(
      _DayReport(
        date: date,
        score: reading.overallScore,
        reading: reading,
        heroAspect: hero,
      ),
    );
  }
  if (days.isEmpty) return null;

  final average =
      days.map((d) => d.score).reduce((a, b) => a + b) / days.length;
  final best = days.reduce((a, b) => a.score >= b.score ? a : b);
  final careful = days.reduce((a, b) => a.score <= b.score ? a : b);
  final sortedHigh = [...days]..sort((a, b) => b.score.compareTo(a.score));
  final sortedLow = [...days]..sort((a, b) => a.score.compareTo(b.score));
  final highlight = <_DayReport>[];
  for (final d in [...sortedHigh.take(3), ...sortedLow.take(3)]) {
    if (!highlight.any((e) => _sameDay(e.date, d.date))) highlight.add(d);
  }
  highlight.sort((a, b) => a.date.compareTo(b.date));

  final base = _MonthlyReport(
    month: month,
    chart: chart,
    days: days,
    averageScore: average,
    best: best,
    careful: careful,
    highlightDays: highlight,
    weeks: _buildWeeks(days),
    categories: _buildCategories(days),
    fallbackAiBlocks: _buildAiBlocks(chart, days, average, best, careful),
  );
  final generated = await aiService.generateMonthly(base.toAiInput());
  return base.withGenerated(generated);
}

List<_WeekReport> _buildWeeks(List<_DayReport> days) {
  final out = <_WeekReport>[];
  for (var start = 1; start <= days.length; start += 7) {
    final end = math.min(start + 6, days.length);
    final slice = days.where((d) => d.date.day >= start && d.date.day <= end);
    final avg =
        slice.map((d) => d.score).reduce((a, b) => a + b) / slice.length;
    out.add(_WeekReport(startDay: start, endDay: end, averageScore: avg));
  }
  return out;
}

List<_CategoryReport> _buildCategories(List<_DayReport> days) {
  const categories = [
    ('全体運', '全体'),
    ('恋愛・対人', '恋愛・対人'),
    ('仕事', '仕事'),
    ('心の調子', '心の調子'),
  ];
  return [for (final c in categories) _categoryReport(c.$1, c.$2, days)];
}

_CategoryReport _categoryReport(
  String title,
  String key,
  List<_DayReport> days,
) {
  _DayReport selected = days.first;
  Aspect? aspect;
  for (final day in days) {
    final item = _findCategoryItem(day.reading, key);
    if (item?.usedAspects.isNotEmpty ?? false) {
      selected = day;
      aspect = item!.usedAspects.first;
      break;
    }
  }
  final score = selected.score;
  final tone = score >= 0.62
      ? '攻めていい流れです。'
      : score <= 0.38
      ? '急ぎすぎず整える月です。'
      : '安定重視で進めると良い月です。';
  final item = _findCategoryItem(selected.reading, key);
  final text = item?.text ?? selected.reading.overallHeadline;
  return _CategoryReport(
    title: title,
    body: '$tone $text',
    aspect: aspect ?? selected.heroAspect,
  );
}

DailyReadingItem? _findCategoryItem(DailyReading reading, String key) {
  for (final entry in reading.byCategory.entries) {
    if (entry.key.contains(key)) return entry.value;
  }
  return null;
}

List<_AiBlock> _buildAiBlocks(
  NatalChart chart,
  List<_DayReport> days,
  double average,
  _DayReport best,
  _DayReport careful,
) {
  final sun = signName(chart.positions[Body.sun] ?? 0);
  final moon = signName(chart.positions[Body.moon] ?? 0);
  final asc = signName(chart.angles.ascendant);
  final strongest = chart.aspects.isNotEmpty ? chart.aspects.first : null;
  final activeDays = days.where((d) => d.score >= 0.62).length;
  final carefulDays = days.where((d) => d.score <= 0.38).length;
  final rhythm = activeDays >= carefulDays
      ? '前に出る日が多く、試す・決める・広げる動きに向いています。'
      : '揺れを拾いやすい月なので、広げるより整える判断が効きます。';
  final strongestText = strongest == null
      ? '出生図の主要配置は穏やかに働いています。'
      : '出生図では${_bodyName(strongest.a)}と${_bodyName(strongest.b)}の結びつきが強く、判断の速さと慎重さのバランスがテーマです。';

  return [
    _AiBlock(
      title: '今月の核',
      body:
          '太陽は$sun、月は$moon、ASCは$asc。平均スコアは${(average * 100).round()}点で、$rhythm $strongestText',
    ),
    _AiBlock(
      title: '伸ばすこと',
      body:
          '${best.date.month}/${best.date.day}前後は追い風が入りやすいタイミングです。予定を入れる、提案する、少し先の目標を言葉にするなど、外へ出す行動が合います。',
    ),
    _AiBlock(
      title: '注意点',
      body:
          '${careful.date.month}/${careful.date.day}前後は反応が強く出やすい日です。無理に結論を急がず、睡眠・返信・お金の判断を一段だけ丁寧にすると崩れにくくなります。',
    ),
    const _AiBlock(
      title: '具体アクション',
      body:
          '月初に大きめの予定を3つまで絞り、週末に見直してください。迷った日は「今やること」と「今月中でいいこと」を分けるだけで、運の使い方がかなり安定します。',
    ),
  ];
}

Color _scoreColor(ColorScheme scheme, double score) {
  if (score >= 0.62) return scheme.primary;
  if (score <= 0.38) return scheme.error;
  return scheme.onSurface.withValues(alpha: 0.75);
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

bool _sameMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;

bool _monthBefore(DateTime a, DateTime b) =>
    a.year < b.year || (a.year == b.year && a.month < b.month);

bool _monthAfter(DateTime a, DateTime b) =>
    a.year > b.year || (a.year == b.year && a.month > b.month);

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

class _MonthlyReport {
  final DateTime month;
  final NatalChart chart;
  final List<_DayReport> days;
  final double averageScore;
  final _DayReport best;
  final _DayReport careful;
  final List<_DayReport> highlightDays;
  final List<_WeekReport> weeks;
  final List<_CategoryReport> categories;
  final List<_AiBlock> fallbackAiBlocks;
  final AiMonthlyDiagnosis? generated;

  const _MonthlyReport({
    required this.month,
    required this.chart,
    required this.days,
    required this.averageScore,
    required this.best,
    required this.careful,
    required this.highlightDays,
    required this.weeks,
    required this.categories,
    required this.fallbackAiBlocks,
    this.generated,
  });

  _MonthlyReport withGenerated(AiMonthlyDiagnosis? value) {
    return _MonthlyReport(
      month: month,
      chart: chart,
      days: days,
      averageScore: averageScore,
      best: best,
      careful: careful,
      highlightDays: highlightDays,
      weeks: weeks,
      categories: categories,
      fallbackAiBlocks: fallbackAiBlocks,
      generated: value,
    );
  }

  List<_AiBlock> get aiBlocks {
    final blocks = generated?.blocks;
    if (blocks == null) return fallbackAiBlocks;
    return blocks
        .map((block) => _AiBlock(title: block.title, body: block.body))
        .toList();
  }

  String get scoreBand {
    if (averageScore >= 0.65) return '追い風';
    if (averageScore <= 0.38) return '調整月';
    return '安定運';
  }

  String get monthTitle {
    final aiTitle = generated?.title;
    if (aiTitle != null) return aiTitle;
    if (averageScore >= 0.65) {
      return '流れを味方につけやすい月。温めていた予定を表に出すほど、手応えが戻ってきます。';
    }
    if (averageScore <= 0.38) {
      return '焦って押し切るより、整えるほど強くなる月。小さな違和感を早めに拾うのが鍵です。';
    }
    return '大きく崩れにくい月。日々の選択を丁寧に重ねるほど、後半の安定感が増します。';
  }

  AiMonthlyInput toAiInput() {
    return AiMonthlyInput(
      month:
          '${month.year.toString().padLeft(4, '0')}-'
          '${month.month.toString().padLeft(2, '0')}',
      averageScore: (averageScore * 100).round(),
      bestDay: best.date.day,
      bestScore: (best.score * 100).round(),
      carefulDay: careful.date.day,
      carefulScore: (careful.score * 100).round(),
      weeks: weeks
          .map(
            (week) => {
              'start_day': week.startDay,
              'end_day': week.endDay,
              'average_score': (week.averageScore * 100).round(),
            },
          )
          .toList(),
      highlights: highlightDays
          .map(
            (day) => {
              'day': day.date.day,
              'score': (day.score * 100).round(),
              'headline': day.reading.overallHeadline,
              'aspect': day.heroAspect == null
                  ? null
                  : {
                      'leading': _bodyName(day.heroAspect!.a),
                      'trailing': _bodyName(day.heroAspect!.b),
                      'type': day.heroAspect!.type.name,
                      'orb': day.heroAspect!.orb,
                    },
            },
          )
          .toList(),
    );
  }
}

class _DayReport {
  final DateTime date;
  final double score;
  final DailyReading reading;
  final Aspect? heroAspect;

  const _DayReport({
    required this.date,
    required this.score,
    required this.reading,
    required this.heroAspect,
  });
}

class _WeekReport {
  final int startDay;
  final int endDay;
  final double averageScore;

  const _WeekReport({
    required this.startDay,
    required this.endDay,
    required this.averageScore,
  });
}

class _CategoryReport {
  final String title;
  final String body;
  final Aspect? aspect;

  const _CategoryReport({
    required this.title,
    required this.body,
    required this.aspect,
  });
}

class _AiBlock {
  final String title;
  final String body;

  const _AiBlock({required this.title, required this.body});
}
