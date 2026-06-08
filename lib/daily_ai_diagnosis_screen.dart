import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ad_banner.dart';
import 'ad_gate.dart';
import 'ai_diagnosis_service.dart';
import 'aspect_mark.dart';
import 'astro_core.dart';
import 'astro_display.dart' show RoastLevel;
import 'astro_narration.dart' show DailyReading;
import 'astro_service.dart';
import 'main.dart'
    show aiDiagnosisServiceProvider, astroServiceProvider, isPaidProvider;
import 'paywall_screen.dart';

class DailyAiDiagnosisScreen extends ConsumerStatefulWidget {
  final RoastLevel? roastLevel;
  const DailyAiDiagnosisScreen({super.key, this.roastLevel});

  @override
  ConsumerState<DailyAiDiagnosisScreen> createState() =>
      _DailyAiDiagnosisScreenState();
}

class _DailyAiDiagnosisScreenState
    extends ConsumerState<DailyAiDiagnosisScreen> {
  Future<_DailyAiReport?>? _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _future = _buildDailyAiReport(
      ref.read(astroServiceProvider),
      ref.read(aiDiagnosisServiceProvider),
      overrideLevel: widget.roastLevel,
    );
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
      appBar: AppBar(title: const Text('今日のAI診断')),
      body: SafeArea(
        child: paid.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _DailyAiGate(onTap: _openPaywall),
          data: (isPaid) {
            if (!isPaid) return _DailyAiGate(onTap: _openPaywall);
            return FutureBuilder<_DailyAiReport?>(
              future: _future,
              builder: (context, snap) {
                if (!snap.hasData &&
                    snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return _DailyAiError(
                    message: snap.error.toString(),
                    onRetry: () => setState(_refresh),
                  );
                }
                final report = snap.data;
                if (report == null) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('出生情報を登録すると、今日のAI診断を作成できます。'),
                    ),
                  );
                }
                return _DailyAiView(report: report);
              },
            );
          },
        ),
      ),
    );
  }
}

class _DailyAiError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _DailyAiError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
      children: [
        Icon(Icons.error_outline, size: 42, color: scheme.error),
        const SizedBox(height: 16),
        const Text(
          'AI診断の準備中にエラーが出ました',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Text(
          '出生情報は登録されています。通信設定か診断データの生成で止まっているため、下の内容を確認してください。',
          textAlign: TextAlign.center,
          style: TextStyle(
            height: 1.7,
            color: scheme.onSurface.withValues(alpha: 0.72),
          ),
        ),
        const SizedBox(height: 16),
        SelectableText(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            height: 1.5,
            color: scheme.onSurface.withValues(alpha: 0.64),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('再試行'),
        ),
      ],
    );
  }
}

class _DailyAiGate extends StatelessWidget {
  final VoidCallback onTap;
  const _DailyAiGate({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 36, 20, 32),
      children: [
        Icon(Icons.auto_awesome, size: 44, color: scheme.primary),
        const SizedBox(height: 18),
        const Text(
          '今日のAI診断はプレミアム機能です',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        Text(
          '今日の星の出方、注意点、具体アクションまで詳しく確認できます。',
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

class _DailyAiView extends StatelessWidget {
  final _DailyAiReport report;
  const _DailyAiView({required this.report});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final aspect = report.heroAspect;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Text(
          '${report.date.year}年${report.date.month}月${report.date.day}日',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: scheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${(report.reading.overallScore * 100).round()}',
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w900,
                color: scheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '/ 100',
                style: TextStyle(
                  fontSize: 14,
                  color: scheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ),
            const Spacer(),
            _ScoreBadge(label: report.rankLabel),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              report.modeLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: scheme.primary,
              ),
            ),
            const Spacer(),
            _ScoreBadge(label: report.sourceLabel),
          ],
        ),
        const SizedBox(height: 14),
        if (aspect != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Expanded(
                    child: AspectNameMarkLabel(
                      leading: _bodyName(aspect.a),
                      trailing: _bodyName(aspect.b),
                      type: aspect.type,
                      color: scheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'orb ${aspect.orb.toStringAsFixed(1)}°',
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurface.withValues(alpha: 0.48),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 10),
        _DiagnosisBlock(title: '今日の位置づけ', body: report.positionText),
        const SizedBox(height: 10),
        _DiagnosisBlock(title: '星の出方', body: report.aspectText),
        const SizedBox(height: 10),
        _DiagnosisBlock(title: '具体アクション', body: report.actionText),
        const SizedBox(height: 18),
        _SectionTitle('今日の使い方'),
        const SizedBox(height: 8),
        _UsePlanBlock(lines: report.usePlan),
        const SizedBox(height: 12),
        _ChecklistBlock(items: report.checklist),
      ],
    );
  }
}

class _DiagnosisBlock extends StatelessWidget {
  final String title;
  final String body;
  const _DiagnosisBlock({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(body, style: const TextStyle(fontSize: 14.5, height: 1.7)),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
    );
  }
}

class _UsePlanBlock extends StatelessWidget {
  final List<_PlanLine> lines;
  const _UsePlanBlock({required this.lines});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < lines.length; i++) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      lines[i].label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: scheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      lines[i].body,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.55,
                        color: scheme.onSurface.withValues(alpha: 0.78),
                      ),
                    ),
                  ),
                ],
              ),
              if (i != lines.length - 1) const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChecklistBlock extends StatelessWidget {
  final List<String> items;
  const _ChecklistBlock({required this.items});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '今日のチェック',
              style: TextStyle(
                color: scheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            for (final item in items) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 17,
                    color: scheme.primary.withValues(alpha: 0.82),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.55,
                        color: scheme.onSurface.withValues(alpha: 0.78),
                      ),
                    ),
                  ),
                ],
              ),
              if (item != items.last) const SizedBox(height: 7),
            ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

Future<_DailyAiReport?> _buildDailyAiReport(
  AstroService svc,
  AiDiagnosisService aiService, {
  RoastLevel? overrideLevel,
}) async {
  try {
    final user = await svc.currentUser();
    if (user == null) return null;

    final today = DateTime.now();
    final reading = await svc.getReadingForDate(today);
    if (reading == null) {
      throw StateError(
        'Daily reading could not be generated for user ${user.id}.',
      );
    }
    final storedLevelName = await svc.getRoastLevel();
    final level =
        overrideLevel ??
        RoastLevel.values.firstWhere(
          (e) => e.name == storedLevelName,
          orElse: () => RoastLevel.mild,
        );
    final hero = await svc.getHeroAspectForDate(today);
    final monthScores = await svc.computeMonthlyScores(
      DateTime(today.year, today.month, 1),
    );
    final scoreValues = monthScores.values.toList();
    final rank = scoreValues.isEmpty
        ? 0.5
        : scoreValues.where((s) => s <= reading.overallScore).length /
              scoreValues.length;

    final base = _DailyAiReport(
      date: today,
      reading: reading,
      heroAspect: hero,
      rank: rank,
      roastLevel: level,
    );
    final generated = await aiService.generateDaily(base.toAiInput());
    return base.withGenerated(generated);
  } catch (error, stackTrace) {
    debugPrint('Daily AI diagnosis failed: $error');
    debugPrintStack(stackTrace: stackTrace);
    rethrow;
  }
}

String _dailyAspectAdvice(Aspect aspect) {
  if (isHarmoniousAspect(aspect.type)) {
    return '流れに乗りやすい配置なので、考えを形にする、連絡する、軽く試す行動と相性が良いです。';
  }
  if (isTenseAspect(aspect.type)) {
    return '反応が強く出やすい配置なので、即答や衝動買いを避け、少し間を置いて判断すると安定します。';
  }
  return '意識が一点に集まりやすい配置なので、今日いちばん大事な用事をひとつ決めると使いやすいです。';
}

String _dailyAction(double score) {
  if (score >= 0.62) {
    return '午前中に一番大事な連絡か判断を済ませてください。午後は人に見せる、共有する、予約するなど外向きの行動に向きます。';
  }
  if (score <= 0.38) {
    return '予定は詰め込みすぎず、確認作業を先に。返信は一呼吸置き、夜は睡眠や入浴など回復に寄せると明日に残りにくいです。';
  }
  return 'いつもの手順を崩さないのが正解です。小さなタスクを片づけ、迷う話はメモだけ残して明日以降に判断しても大丈夫です。';
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

class _DailyAiReport {
  final DateTime date;
  final DailyReading reading;
  final Aspect? heroAspect;
  final double rank;
  final RoastLevel roastLevel;
  final AiDailyDiagnosis? generated;

  const _DailyAiReport({
    required this.date,
    required this.reading,
    required this.heroAspect,
    required this.rank,
    required this.roastLevel,
    this.generated,
  });

  _DailyAiReport withGenerated(AiDailyDiagnosis? value) {
    return _DailyAiReport(
      date: date,
      reading: reading,
      heroAspect: heroAspect,
      rank: rank,
      roastLevel: roastLevel,
      generated: value,
    );
  }

  String get sourceLabel => generated == null ? '端末診断' : 'AI生成';

  String get modeLabel {
    switch (roastLevel) {
      case RoastLevel.mild:
        return 'やさしめ診断';
      case RoastLevel.sharp:
        return '鋭め診断';
      case RoastLevel.extraHot:
        return '直球診断';
    }
  }

  String get rankLabel {
    if (rank >= 0.75) return '今月上位';
    if (rank <= 0.25) return '慎重日';
    return '中庸';
  }

  String get positionText {
    final aiText = generated?.position;
    if (aiText != null) return aiText;
    final rankText = rank >= 0.75
        ? '今月の中でもかなり動きやすい日です。'
        : rank <= 0.25
        ? '今月の中では慎重に扱いたい日です。'
        : '今月の中では中庸で、整えながら進める日です。';
    final scoreText = reading.overallScore >= 0.62
        ? '外に出す、相談する、決める動きが追い風になりやすいです。'
        : reading.overallScore <= 0.38
        ? '勢いよりも確認と休息を優先すると、余計な消耗を避けられます。'
        : '大きく振れにくいので、日常のリズムを崩さず進めるのが合います。';
    return _byMode(
      mild: '$rankText $scoreText',
      sharp:
          '$rankText $scoreText ただし、流れが良い日ほど雑な判断も通したくなります。今日は「一番大事な一手」だけは外さないでください。',
      direct: '$rankText $scoreText 今日はぼんやり流すと普通に終わります。使うなら、先に一個決めて動く日です。',
    );
  }

  String get aspectText {
    final aiText = generated?.aspect;
    if (aiText != null) return aiText;
    final aspect = heroAspect;
    if (aspect == null) {
      return _byMode(
        mild: '今日は強く目立つ配置が少なめです。無理に特別な意味を探すより、淡々と整えるほど安定します。',
        sharp: '今日は強い配置が少なめです。だからこそ、星のせいにせず自分のリズムを整える日です。',
        direct: '今日は派手な星の言い訳は少なめ。やるか休むか、自分で決める日です。',
      );
    }
    final base =
        '${_bodyName(aspect.a)}と${_bodyName(aspect.b)}の動きが目立ちます。${_dailyAspectAdvice(aspect)}';
    return _byMode(
      mild: base,
      sharp: '$base 反応が出る場所はごまかさず、先に小さく対処すると楽です。',
      direct: '$base 見て見ぬふりすると、あとで面倒になります。今日のうちに一手だけ打って。',
    );
  }

  String get actionText {
    final aiText = generated?.action;
    if (aiText != null) return aiText;
    return _byMode(
      mild: _dailyAction(reading.overallScore),
      sharp: '${_dailyAction(reading.overallScore)} 迷うなら、重要度の低い予定から削ってください。',
      direct:
          '${_dailyAction(reading.overallScore)} 今日は「気分が乗ったら」待ちはなし。やることをひとつに絞って終わらせて。',
    );
  }

  List<_PlanLine> get usePlan {
    final aiPlan = generated?.timePlan;
    if (aiPlan != null) {
      return aiPlan.map((line) => _PlanLine(line.label, line.body)).toList();
    }
    if (reading.overallScore >= 0.62) {
      return [
        const _PlanLine('午前', '連絡、予約、相談など、人を動かす用事を先に置くと流れが作りやすいです。'),
        const _PlanLine('午後', '一度外に出したものを整える時間。見直し、共有、軽い修正に向きます。'),
        const _PlanLine('夜', '成果を増やすより、明日の自分が迷わない形にメモを残すと安定します。'),
      ];
    }
    if (reading.overallScore <= 0.38) {
      return [
        const _PlanLine('午前', '新しい判断より確認から。予定、返信、支払いなど抜けやすいものを先に見る日です。'),
        const _PlanLine('午後', '人とのやり取りは短く丁寧に。結論を急がず、必要なら一度持ち帰って大丈夫です。'),
        const _PlanLine('夜', '回復を優先。考えすぎるより、入浴や睡眠など体を落ち着かせる行動が効きます。'),
      ];
    }
    return [
      const _PlanLine('午前', 'いつもの順番を崩さず、小さな用事から片づけるとリズムに乗れます。'),
      const _PlanLine('午後', '迷う話は即決しなくてOK。情報を集めて、判断材料をそろえる時間に向きます。'),
      const _PlanLine('夜', '今日できたことを一つだけ確認して、明日の最初の一手を決めておくと楽です。'),
    ];
  }

  List<String> get checklist {
    final aiChecklist = generated?.checklist;
    if (aiChecklist != null) return aiChecklist;
    final aspect = heroAspect;
    final base = reading.overallScore >= 0.62
        ? ['大事な連絡をひとつ先に済ませる', '人に見せるものは、完璧待ちせず一度出す']
        : reading.overallScore <= 0.38
        ? ['即答しない返信をひとつ決めておく', '予定を詰めず、余白をひと枠残す']
        : ['通常運転で終わらせたい用事をひとつ選ぶ', '迷っている件はメモ化して保留にする'];
    if (aspect == null) {
      return [...base, '寝る前に明日の最初のタスクだけ決める'];
    }
    final aspectAction = isTenseAspect(aspect.type)
        ? '${_bodyName(aspect.a)}と${_bodyName(aspect.b)}のテーマは、強く反応する前に一呼吸置く'
        : isHarmoniousAspect(aspect.type)
        ? '${_bodyName(aspect.a)}と${_bodyName(aspect.b)}のテーマは、小さく試して流れを見る'
        : '${_bodyName(aspect.a)}と${_bodyName(aspect.b)}のテーマを、今日の優先事項にひとつだけ入れる';
    return [...base, aspectAction];
  }

  AiDailyInput toAiInput() {
    final aspect = heroAspect;
    return AiDailyInput(
      date:
          '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}',
      score: (reading.overallScore * 100).round(),
      monthlyRank: rankLabel,
      tone: modeLabel,
      heroAspect: aspect == null
          ? null
          : AiAspectInput(
              leading: _bodyName(aspect.a),
              trailing: _bodyName(aspect.b),
              type: aspect.type.name,
              orb: aspect.orb,
            ),
      positionSeed: positionText,
      aspectSeed: aspectText,
      actionSeed: actionText,
      timePlan: usePlan
          .map((line) => AiPlanLine(line.label, line.body))
          .toList(),
      checklist: checklist,
    );
  }

  String _byMode({
    required String mild,
    required String sharp,
    required String direct,
  }) {
    switch (roastLevel) {
      case RoastLevel.mild:
        return mild;
      case RoastLevel.sharp:
        return sharp;
      case RoastLevel.extraHot:
        return direct;
    }
  }
}

class _PlanLine {
  final String label;
  final String body;

  const _PlanLine(this.label, this.body);
}
