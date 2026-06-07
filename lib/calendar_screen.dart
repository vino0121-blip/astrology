// lib/calendar_screen.dart
//
// 月間カレンダー画面（広告枠あり）。
//   - 月グリッドで各日の overall score をドットで可視化
//   - 月ナビゲーション（◀ ▶）
//   - 日タップで下部に詳細パネル（ヘッドライン+スコアバー+主役アスペクト）
//   - 下部 AdMob 枠（プレースホルダ、本実装手順はファイル末尾のコメント参照）
//
// 計算コスト：月間 ~150ms（30日×~5ms）。月切替時のみ再計算、選択日のみ
// 詳細を都度計算。負荷的に問題ない範囲なのでメモリキャッシュは v1 では入れない。

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ad_banner.dart';
import 'ad_gate.dart';
import 'aspect_mark.dart';
import 'astro_core.dart' show Aspect;
import 'astro_display.dart'
    show astroSymbolFontFamily, astroSymbolFontFamilyFallback, bodyMark;
import 'astro_narration.dart' show DailyReading;
import 'main.dart' show astroServiceProvider;

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});
  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _focusedMonth; // 1日固定
  late int _selectedDay;
  Future<Map<int, double>>? _scoresFuture;
  Future<_DaySummary?>? _detailFuture;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);
    _selectedDay = now.day;
    _refreshScores();
    _refreshDetail();
  }

  void _refreshScores() {
    _scoresFuture = ref
        .read(astroServiceProvider)
        .computeMonthlyScores(_focusedMonth);
  }

  void _refreshDetail() {
    final svc = ref.read(astroServiceProvider);
    final date = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      _selectedDay,
    );
    _detailFuture = () async {
      final reading = await svc.getReadingForDate(date);
      final hero = await svc.getHeroAspectForDate(date);
      if (reading == null) return null;
      return _DaySummary(date: date, reading: reading, hero: hero);
    }();
  }

  void _goPrevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
      // 選択日をその月の同じ「日」に。月末を超えないよう clamp。
      final lastDay = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + 1,
        0,
      ).day;
      _selectedDay = _selectedDay.clamp(1, lastDay);
      _refreshScores();
      _refreshDetail();
    });
  }

  void _goNextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
      final lastDay = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + 1,
        0,
      ).day;
      _selectedDay = _selectedDay.clamp(1, lastDay);
      _refreshScores();
      _refreshDetail();
    });
  }

  void _selectDay(int day) {
    setState(() {
      _selectedDay = day;
      _refreshDetail();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('カレンダー')),
      body: SafeArea(
        child: Column(
          children: [
            _MonthHeader(
              month: _focusedMonth,
              onPrev: _goPrevMonth,
              onNext: _goNextMonth,
            ),
            const SizedBox(height: 8),
            const _WeekdayHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: FutureBuilder<Map<int, double>>(
                future: _scoresFuture,
                builder: (context, snap) {
                  final scores = snap.data ?? const <int, double>{};
                  return _MonthGrid(
                    month: _focusedMonth,
                    scores: scores,
                    selectedDay: _selectedDay,
                    onSelect: _selectDay,
                    loading: !snap.hasData,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: FutureBuilder<_DaySummary?>(
                  future: _detailFuture,
                  builder: (context, snap) {
                    if (!snap.hasData &&
                        snap.connectionState != ConnectionState.done) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final s = snap.data;
                    if (s == null) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Center(
                          child: Text(
                            '表示できません。出生情報をご確認ください。',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      );
                    }
                    return _DetailPanel(summary: s);
                  },
                ),
              ),
            ),
            const AdGate(child: AppBannerAd()),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 月ヘッダ
// ============================================================
class _MonthHeader extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  const _MonthHeader({
    required this.month,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: onPrev),
          Expanded(
            child: Center(
              child: Text(
                '${month.year} . ${month.month.toString().padLeft(2, "0")}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: onNext),
        ],
      ),
    );
  }
}

// ============================================================
// 曜日ヘッダ（日始まり）
// ============================================================
class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();
  @override
  Widget build(BuildContext context) {
    const labels = ['日', '月', '火', '水', '木', '金', '土'];
    final base = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.55);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Center(
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: i == 0
                        ? const Color(0xFFFF7B8A).withValues(alpha: 0.7)
                        : i == 6
                        ? const Color(0xFFB7C2FF).withValues(alpha: 0.85)
                        : base,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// 月グリッド
// ============================================================
class _MonthGrid extends StatelessWidget {
  final DateTime month;
  final Map<int, double> scores;
  final int selectedDay;
  final void Function(int day) onSelect;
  final bool loading;

  const _MonthGrid({
    required this.month,
    required this.scores,
    required this.selectedDay,
    required this.onSelect,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // weekday: Mon=1..Sun=7 → 日始まりに変換（Sun=0..Sat=6）
    final firstWeekday = month.weekday % 7;
    final totalCells = ((firstWeekday + daysInMonth + 6) ~/ 7) * 7;
    final rows = totalCells ~/ 7;
    final today = DateTime.now();
    final isCurrentMonth =
        today.year == month.year && today.month == month.month;

    return Column(
      children: [
        for (var r = 0; r < rows; r++)
          Row(
            children: [
              for (var c = 0; c < 7; c++)
                Expanded(
                  child: _buildCell(
                    context,
                    r * 7 + c,
                    firstWeekday,
                    daysInMonth,
                    today,
                    isCurrentMonth,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildCell(
    BuildContext context,
    int idx,
    int firstWeekday,
    int daysInMonth,
    DateTime today,
    bool isCurrentMonth,
  ) {
    final dayNum = idx - firstWeekday + 1;
    if (dayNum < 1 || dayNum > daysInMonth) {
      return const SizedBox(height: 50);
    }
    final score = scores[dayNum];
    final isToday = isCurrentMonth && today.day == dayNum;
    final isSelected = dayNum == selectedDay;
    return InkWell(
      onTap: () => onSelect(dayNum),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 50,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isToday
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)
                : isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.6)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$dayNum',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            _ScoreDot(score: score, loading: loading),
          ],
        ),
      ),
    );
  }
}

class _ScoreDot extends StatelessWidget {
  final double? score;
  final bool loading;
  const _ScoreDot({required this.score, required this.loading});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (loading) {
      return Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: scheme.onSurface.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
      );
    }
    if (score == null) {
      return const SizedBox(width: 6, height: 6);
    }
    // 0.65以上=調和ドット（mint）、0.35以下=緊張ドット（warm）、間=中立（淡）
    final s = score!;
    final Color color;
    final double alpha;
    if (s >= 0.65) {
      color = scheme.primary;
      alpha = 0.4 + ((s - 0.65) / 0.35).clamp(0, 1) * 0.55; // 0.4..0.95
    } else if (s <= 0.35) {
      color = scheme.error;
      alpha = 0.4 + ((0.35 - s) / 0.35).clamp(0, 1) * 0.55;
    } else {
      color = scheme.onSurface;
      alpha = 0.25;
    }
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color.withValues(alpha: alpha),
        shape: BoxShape.circle,
      ),
    );
  }
}

// ============================================================
// 選択日詳細パネル
// ============================================================
class _DaySummary {
  final DateTime date;
  final DailyReading reading;
  final Aspect? hero;
  _DaySummary({required this.date, required this.reading, this.hero});
}

class _DetailPanel extends StatelessWidget {
  final _DaySummary summary;
  const _DetailPanel({required this.summary});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final date = summary.date;
    const wd = ['月', '火', '水', '木', '金', '土', '日'];
    final weekday = wd[date.weekday - 1];
    final r = summary.reading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${date.month}月${date.day}日（$weekday）',
          style: TextStyle(
            fontSize: 12,
            color: scheme.onSurface.withValues(alpha: 0.6),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          r.overallHeadline,
          style: const TextStyle(
            fontSize: 15.5,
            height: 1.7,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        _ScoreBar(score: r.overallScore),
        if (summary.hero != null) ...[
          const SizedBox(height: 18),
          _HeroAspectRow(aspect: summary.hero!),
        ],
      ],
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final double score;
  const _ScoreBar({required this.score});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'バランス',
              style: TextStyle(
                fontSize: 11,
                color: scheme.onSurface.withValues(alpha: 0.55),
                letterSpacing: 0.4,
              ),
            ),
            const Spacer(),
            Text(
              '${(score * 100).round()} / 100',
              style: TextStyle(
                fontSize: 11,
                color: scheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score.clamp(0.0, 1.0),
            minHeight: 5,
            backgroundColor: scheme.onSurface.withValues(alpha: 0.08),
            valueColor: AlwaysStoppedAnimation(
              scheme.primary.withValues(alpha: 0.75),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroAspectRow extends StatelessWidget {
  final Aspect aspect;
  const _HeroAspectRow({required this.aspect});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          '主役',
          style: TextStyle(
            fontSize: 11,
            color: scheme.onSurface.withValues(alpha: 0.55),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          bodyMark(aspect.a),
          style: TextStyle(
            fontSize: 18,
            color: scheme.primary.withValues(alpha: 0.95),
            fontFamily: astroSymbolFontFamily,
            fontFamilyFallback: astroSymbolFontFamilyFallback,
          ),
        ),
        const SizedBox(width: 6),
        AspectMark(
          type: aspect.type,
          color: scheme.onSurface.withValues(alpha: 0.7),
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          bodyMark(aspect.b),
          style: TextStyle(
            fontSize: 18,
            color: scheme.secondary.withValues(alpha: 0.95),
            fontFamily: astroSymbolFontFamily,
            fontFamilyFallback: astroSymbolFontFamilyFallback,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'orb ${aspect.orb.toStringAsFixed(1)}°',
          style: TextStyle(
            fontSize: 11,
            color: scheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}
