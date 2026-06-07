// lib/home_screen.dart
//
// Astrology-first home: a large interactive chart, roast-level copy, and
// SNS-card export entry point.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ad_banner.dart';
import 'ad_gate.dart';
import 'aspect_mark.dart';
import 'app_database.dart' show UserProfile;
import 'astro_alerts_screen.dart';
import 'astro_core.dart';
import 'astro_display.dart';
import 'astro_narration.dart'
    show DailyReading, DailyReadingItem, computeTransitPositions;
import 'calendar_screen.dart';
import 'compatibility_screen.dart';
import 'daily_ai_diagnosis_screen.dart';
import 'horoscope_chart.dart';
import 'main.dart'
    show astroServiceProvider, currentUserProvider, todayReadingProvider;
import 'premium_report_screen.dart';
import 'setting_screen.dart';
import 'share_card_screen.dart';

final natalChartProvider = FutureProvider<NatalChart?>((ref) async {
  final service = ref.watch(astroServiceProvider);
  return service.resolveNatalChart();
});

final transitProvider = FutureProvider<Map<Body, double>>((ref) async {
  final service = ref.watch(astroServiceProvider);
  return computeTransitPositions(DateTime.now().toUtc(), service.ephemeris);
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  RoastLevel _roastLevel = RoastLevel.mild;
  Body? _selectedBody;
  bool _chartGestureActive = false;

  @override
  void initState() {
    super.initState();
    _restoreRoastLevel();
  }

  Future<void> _restoreRoastLevel() async {
    final svc = ref.read(astroServiceProvider);
    final stored = await svc.getRoastLevel();
    if (!mounted) return;
    final restored = RoastLevel.values.firstWhere(
      (l) => l.name == stored,
      orElse: () => RoastLevel.mild,
    );
    if (restored != _roastLevel) {
      setState(() => _roastLevel = restored);
    }
  }

  void _showHouseInfo(int house, NatalChart chart) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => _HouseInfoSheet(house: house, chart: chart),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reading = ref.watch(todayReadingProvider);
    final natal = ref.watch(natalChartProvider);
    final transit = ref.watch(transitProvider);
    final user = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('今日の星図'),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_outlined),
            tooltip: '共有カード',
            onPressed: () {
              final chart = natal.valueOrNull;
              final r = reading.valueOrNull;
              final t = transit.valueOrNull;
              if (chart == null || r == null || t == null) return;
              final hero = _heroAspect(chart, t);
              final text = _heroMessage(r, hero, _roastLevel);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ShareCardScreen(
                    chart: chart,
                    roastLevel: _roastLevel,
                    heroAspect: hero,
                    message: text,
                    date: r.dateLocal,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            tooltip: '相性',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CompatibilityScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: 'カレンダー',
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const CalendarScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.insights_outlined),
            tooltip: '月間AI診断',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PremiumReportScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            tooltip: '星模様アラート',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AstroAlertsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: '設定',
            onPressed: () async {
              await Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
              await _restoreRoastLevel();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: reading.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorView(
            onRetry: () {
              ref.invalidate(todayReadingProvider);
              ref.invalidate(natalChartProvider);
              ref.invalidate(transitProvider);
            },
          ),
          data: (r) {
            if (r == null) return const SizedBox.shrink();
            return natal.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  _ErrorView(onRetry: () => ref.invalidate(natalChartProvider)),
              data: (chart) {
                if (chart == null) return const SizedBox.shrink();
                return transit.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => _ErrorView(
                    onRetry: () => ref.invalidate(transitProvider),
                  ),
                  data: (transits) => _AstrologyHome(
                    reading: r,
                    chart: chart,
                    transitPositions: transits,
                    user: user,
                    roastLevel: _roastLevel,
                    selectedBody: _selectedBody,
                    chartGestureActive: _chartGestureActive,
                    onBodySelected: (body) =>
                        setState(() => _selectedBody = body),
                    onHouseSelected: (house) => _showHouseInfo(house, chart),
                    onChartGestureChanged: (active) {
                      if (_chartGestureActive == active) return;
                      setState(() => _chartGestureActive = active);
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _AstrologyHome extends StatelessWidget {
  final DailyReading reading;
  final NatalChart chart;
  final Map<Body, double> transitPositions;
  final UserProfile? user;
  final RoastLevel roastLevel;
  final Body? selectedBody;
  final bool chartGestureActive;
  final ValueChanged<Body> onBodySelected;
  final ValueChanged<int> onHouseSelected;
  final ValueChanged<bool> onChartGestureChanged;

  const _AstrologyHome({
    required this.reading,
    required this.chart,
    required this.transitPositions,
    required this.user,
    required this.roastLevel,
    required this.selectedBody,
    required this.chartGestureActive,
    required this.onBodySelected,
    required this.onHouseSelected,
    required this.onChartGestureChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hero = _heroAspect(chart, transitPositions);
    final selectedAspect = selectedBody == null
        ? null
        : _bodyAspect(selectedBody!, chart, transitPositions);
    final activeAspect = selectedAspect ?? hero;
    final highlight = activeAspect == null ? const <Aspect>[] : [activeAspect];
    final message = _heroMessage(reading, activeAspect, roastLevel);
    return ListView(
      physics: chartGestureActive
          ? const NeverScrollableScrollPhysics()
          : const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        _DateStrip(date: reading.dateLocal, user: user),
        const SizedBox(height: 4),
        _ChartStage(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.50,
            child: HoroscopeChart(
              chart: chart,
              highlightedAspects: highlight,
              selectedBody: selectedBody,
              onBodySelected: onBodySelected,
              onHouseSelected: onHouseSelected,
              onGestureActiveChanged: onChartGestureChanged,
            ),
          ),
        ),
        const SizedBox(height: 10),
        _HeroCard(
          reading: reading,
          heroAspect: activeAspect,
          message: message,
          score: reading.overallScore,
          selectedBody: selectedBody,
          roastLevel: roastLevel,
        ),
        const SizedBox(height: 12),
        if (selectedBody != null) ...[
          _PlacementCard(body: selectedBody!, chart: chart),
          const SizedBox(height: 10),
        ],
        _PlacementHintCard(chart: chart),
        const SizedBox(height: 12),
        _CategoryGrid(
          reading: reading,
          chart: chart,
          transits: transitPositions,
          roastLevel: roastLevel,
          onBodySelected: onBodySelected,
        ),
        const SizedBox(height: 8),
        const AdGate(child: AppBannerAd()),
      ],
    );
  }
}

class _ChartStage extends StatelessWidget {
  final Widget child;
  const _ChartStage({required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF080A0D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF26303A)),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.08),
            blurRadius: 32,
            spreadRadius: -12,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _DateStrip extends StatelessWidget {
  final DateTime date;
  final UserProfile? user;
  const _DateStrip({required this.date, required this.user});

  @override
  Widget build(BuildContext context) {
    const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    final wd = weekdays[date.weekday - 1];
    final name = user?.displayName;
    return Row(
      children: [
        Text(
          '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} $wd',
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.62),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        if (name != null && name.isNotEmpty)
          Text(
            name,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final DailyReading reading;
  final Aspect? heroAspect;
  final String message;
  final double score;
  final Body? selectedBody;
  final RoastLevel roastLevel;
  const _HeroCard({
    required this.reading,
    required this.heroAspect,
    required this.message,
    required this.score,
    required this.selectedBody,
    required this.roastLevel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (heroAspect != null)
                  Expanded(
                    child: _AspectNameSymbolLabel(
                      aspect: heroAspect!,
                      color: scheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  )
                else
                  const Spacer(),
                const Spacer(),
                Text(
                  '${(score * 100).round()} / 100',
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.55),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        DailyAiDiagnosisScreen(roastLevel: roastLevel),
                  ),
                ),
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('詳しいAI診断'),
              ),
            ),
          ],
        ),
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

class _PlacementCard extends StatelessWidget {
  final Body body;
  final NatalChart chart;
  const _PlacementCard({required this.body, required this.chart});

  @override
  Widget build(BuildContext context) {
    final lon = chart.positions[body];
    if (lon == null) return const SizedBox.shrink();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              bodyMark(body),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                fontFamily: astroSymbolFontFamily,
                fontFamilyFallback: astroSymbolFontFamilyFallback,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    placementLine(body, lon),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _bodyInsight(body),
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.68),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlacementHintCard extends StatelessWidget {
  final NatalChart chart;
  const _PlacementHintCard({required this.chart});

  @override
  Widget build(BuildContext context) {
    final asc =
        '${signName(chart.angles.ascendant)} ${degreeInSign(chart.angles.ascendant).toStringAsFixed(1)}°';
    final mc =
        '${signName(chart.angles.midheaven)} ${degreeInSign(chart.angles.midheaven).toStringAsFixed(1)}°';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _AngleValue(label: 'ASC', value: asc),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AngleValue(label: 'MC', value: mc),
            ),
          ],
        ),
      ),
    );
  }
}

class _AngleValue extends StatelessWidget {
  final String label;
  final String value;
  const _AngleValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _HouseInfoSheet extends StatelessWidget {
  final int house;
  final NatalChart chart;
  const _HouseInfoSheet({required this.house, required this.chart});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cusp = chart.cusps[house - 1];
    final sign = signName(cusp);
    final bodyEntries =
        chart.positions.entries
            .where((e) => norm360(e.value - cusp) < 30)
            .toList()
          ..sort((a, b) => a.value.compareTo(b.value));
    final meaning = _houseMeaning(house);
    final personal = _personalHouseMessage(house, sign, bodyEntries);
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '第$houseハウス',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    sign,
                    style: TextStyle(
                      color: scheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                meaning.title,
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.68),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'あなたの場合',
                style: TextStyle(
                  color: scheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                personal,
                style: const TextStyle(fontSize: 15, height: 1.75),
              ),
              const SizedBox(height: 16),
              Text(
                '使い方',
                style: TextStyle(
                  color: scheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _houseAdvice(house, bodyEntries.isNotEmpty),
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.65,
                  color: scheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
              if (bodyEntries.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'ここにある天体',
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                for (final entry in bodyEntries) ...[
                  _HouseBodyLine(body: entry.key, house: house),
                  const SizedBox(height: 8),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HouseBodyLine extends StatelessWidget {
  final Body body;
  final int house;
  const _HouseBodyLine({required this.body, required this.house});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: scheme.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _bodyName(body),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _bodyHouseLine(body, house),
              style: TextStyle(
                fontSize: 13,
                height: 1.55,
                color: scheme.onSurface.withValues(alpha: 0.76),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

({String title, String body}) _houseMeaning(int house) {
  switch (house) {
    case 1:
      return (
        title: '第一印象・自分らしさ',
        body: '人からどう見られやすいか、自然に出る振る舞いを表します。ここが強い人は、考える前に雰囲気や存在感が先に伝わります。',
      );
    case 2:
      return (
        title: 'お金・持ち物・安心感',
        body: '稼ぎ方、価値観、手元に残したいものを表します。自分のペースや安心できる環境づくりに出やすい場所です。',
      );
    case 3:
      return (
        title: '会話・学び・近い人間関係',
        body: '話し方、情報の拾い方、兄弟姉妹や近所のつながりを表します。軽い学びや発信の癖が出ます。',
      );
    case 4:
      return (
        title: '家・土台・心の居場所',
        body: '家族、住まい、安心して戻れる場所を表します。外で頑張るための根っこにあたるテーマです。',
      );
    case 5:
      return (
        title: '恋・遊び・自己表現',
        body: '好きなこと、創作、恋愛の楽しみ方を表します。自分の喜びをどう外に出すかが見えます。',
      );
    case 6:
      return (
        title: '仕事の習慣・健康管理',
        body: '日々の作業、体調、役割を表します。派手さよりも、毎日の整え方や働き方に出る場所です。',
      );
    case 7:
      return (
        title: '対人関係・パートナーシップ',
        body: '一対一の関係、契約、相手との向き合い方を表します。自分にない要素を人を通して学ぶ場所です。',
      );
    case 8:
      return (
        title: '深い関係・共有・変化',
        body: '信頼、共有財産、深く関わることで変わるテーマを表します。軽く済ませられない縁に出やすい場所です。',
      );
    case 9:
      return (
        title: '遠くの世界・専門性・信念',
        body: '旅、哲学、専門的な学び、信じるものを表します。視野を広げるほど運が動きやすい場所です。',
      );
    case 10:
      return (
        title: '社会的な顔・キャリア',
        body: '仕事上の立場、目標、外から見た肩書きを表します。社会にどう見せていくかの場所です。',
      );
    case 11:
      return (
        title: '仲間・未来計画・コミュニティ',
        body: '友人、チーム、未来の理想を表します。一人で完結しない夢やネットワークに出ます。',
      );
    case 12:
      return (
        title: '無意識・休息・見えない支え',
        body: '言葉にしにくい感情、休む力、裏側で働くテーマを表します。一人の時間で整いやすい場所です。',
      );
    default:
      return (title: 'ハウス', body: '出生図の人生テーマを分ける領域です。');
  }
}

String _personalHouseMessage(
  int house,
  String sign,
  List<MapEntry<Body, double>> bodies,
) {
  final base =
      'あなたの第$houseハウスは$signから始まります。'
      '${_signHouseTone(sign)} ${_housePersonalTheme(house)}';
  if (bodies.isEmpty) {
    return '$base ここに主要天体はないので、このテーマは常に前面に出るというより、必要な場面で静かに働きます。意識しすぎるより「困った時に戻る場所」として見ると使いやすいです。';
  }
  final names = bodies.map((e) => _bodyName(e.key)).join('、');
  return '$base さらに$namesがこのハウスにあるため、このテーマはあなたの中で意識に上がりやすい部分です。日常の選択や人との関わりに、わりとはっきり出ます。';
}

String _signHouseTone(String sign) {
  switch (sign) {
    case '牡羊座':
      return '考え込むより先に動くことで、そのテーマが開きやすい配置です。';
    case '牡牛座':
      return '急がず、感覚に合う形を選ぶほど安定しやすい配置です。';
    case '双子座':
      return '話す、試す、情報を集めることで動き出しやすい配置です。';
    case '蟹座':
      return '安心できる人や場所とのつながりが、そのテーマを育てます。';
    case '獅子座':
      return '自分の喜びや誇りを隠さないほど、そのテーマが強くなります。';
    case '乙女座':
      return '整える、観察する、具体的に改善することで力を使いやすい配置です。';
    case '天秤座':
      return '人とのバランスや美意識を通して、そのテーマが動きやすい配置です。';
    case '蠍座':
      return '浅く広くより、深く関わることで本音が見えてくる配置です。';
    case '射手座':
      return '広い視点、学び、遠くへの関心がそのテーマを広げます。';
    case '山羊座':
      return '時間をかけて形にするほど、信頼や結果につながりやすい配置です。';
    case '水瓶座':
      return '人と違う視点や自由な距離感が、そのテーマを動かします。';
    case '魚座':
      return '直感、共感、余白を大事にすると、そのテーマが自然に流れます。';
    default:
      return 'その星座らしいペースで、このテーマが動きます。';
  }
}

String _housePersonalTheme(int house) {
  switch (house) {
    case 1:
      return '第一印象や始め方に出るので、無理に作り込むより自然に出る反応を味方にしてください。';
    case 2:
      return 'お金や安心感に出るので、何を持つと落ち着くかを知ることが大事です。';
    case 3:
      return '会話や学び方に出るので、考えを外に出すほど整理されます。';
    case 4:
      return '家や心の土台に出るので、休める場所を整えるほど外でも安定します。';
    case 5:
      return '恋や表現に出るので、好きなものを遠慮しすぎないことが鍵です。';
    case 6:
      return '働き方や体調管理に出るので、毎日の小さな習慣が運を作ります。';
    case 7:
      return '一対一の関係に出るので、相手を通して自分の癖に気づきやすいです。';
    case 8:
      return '深い関係や共有に出るので、信頼できる相手との距離感が大事です。';
    case 9:
      return '学びや視野に出るので、知らない世界へ触れるほど動きが出ます。';
    case 10:
      return 'キャリアや社会的な見られ方に出るので、目標を形にするほど強くなります。';
    case 11:
      return '仲間や未来計画に出るので、ひとりで抱えず場を選ぶことが大事です。';
    case 12:
      return '無意識や休息に出るので、ひとりで整える時間がかなり効きます。';
    default:
      return '人生の一部のテーマとして働きます。';
  }
}

String _houseAdvice(int house, bool hasBodies) {
  final prefix = hasBodies
      ? 'このハウスはあなたの中で反応が出やすい場所です。'
      : 'このハウスは強く意識しすぎなくて大丈夫です。';
  switch (house) {
    case 1:
      return '$prefix 人前に出る時は、完璧なキャラを作るより最初の自然な一言を大切にしてください。';
    case 2:
      return '$prefix お金の判断では、得かどうかだけでなく「長く安心できるか」を見ると合います。';
    case 3:
      return '$prefix モヤモヤしたら、頭の中で抱えず短いメモや会話に出すと整理されます。';
    case 4:
      return '$prefix 疲れた時ほど、予定追加より部屋・睡眠・食事の土台を先に整えると戻りやすいです。';
    case 5:
      return '$prefix 好きなことを後回しにしすぎると鈍ります。小さく遊ぶ時間を残してください。';
    case 6:
      return '$prefix 大きな改革より、毎日10分続く仕組みを作るほうが効きます。';
    case 7:
      return '$prefix 人間関係では、合わせる前に自分が何を望んでいるか確認してください。';
    case 8:
      return '$prefix 深い話ほど急がないこと。信頼は一気に作るより積み上げるほうが合います。';
    case 9:
      return '$prefix 視野が狭くなったら、知らない場所・本・専門知識に触れると流れが戻ります。';
    case 10:
      return '$prefix 目標は曖昧にせず、今月やる一手まで落とすと動きやすいです。';
    case 11:
      return '$prefix 仲間選びが大事です。気を使いすぎる場より、未来の話ができる場を選んでください。';
    case 12:
      return '$prefix 何もしていない時間も必要です。休むことをサボり扱いしないでください。';
    default:
      return '$prefix 必要な場面で意識して使うと整いやすくなります。';
  }
}

String _bodyHouseLine(Body body, int house) {
  final theme = switch (body) {
    Body.sun => '自分らしさや意思',
    Body.moon => '感情や安心感',
    Body.mercury => '考え方や言葉',
    Body.venus => '好きなものや人との楽しみ',
    Body.mars => '行動力や怒り',
    Body.jupiter => '広げる力やチャンス',
    Body.saturn => '責任感や苦手意識',
    Body.uranus => '変化や自由さ',
    Body.neptune => '直感や曖昧さ',
    Body.pluto => '深い変化やこだわり',
    Body.earthBary => '土台',
  };
  return '$themeが第$houseハウスのテーマに乗ります。${_bodyHouseAdvice(body)}';
}

String _bodyHouseAdvice(Body body) {
  switch (body) {
    case Body.sun:
      return 'ここは自分の軸として大事にしたい場所です。';
    case Body.moon:
      return 'ここが乱れると気分にも出やすいので、安心できる形を作ると安定します。';
    case Body.mercury:
      return '考えたり話したりすることで、このテーマが整理されます。';
    case Body.venus:
      return '楽しさや好き嫌いを無視しないほうが、このテーマはうまく回ります。';
    case Body.mars:
      return '我慢し続けるより、健全に動かす出口を作ると強みになります。';
    case Body.jupiter:
      return '広げすぎに気をつけつつ、チャンスを受け取る場所です。';
    case Body.saturn:
      return '最初は重く感じても、時間をかけるほど武器になります。';
    default:
      return '無意識に強く働きやすいので、変化のサインとして見てください。';
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

class _CategoryGrid extends StatelessWidget {
  final DailyReading reading;
  final NatalChart chart;
  final Map<Body, double> transits;
  final RoastLevel roastLevel;
  final ValueChanged<Body> onBodySelected;
  const _CategoryGrid({
    required this.reading,
    required this.chart,
    required this.transits,
    required this.roastLevel,
    required this.onBodySelected,
  });

  @override
  Widget build(BuildContext context) {
    const cats = ['全体', '恋愛・対人', '仕事', '心の調子'];
    return Column(
      children: [
        for (final cat in cats)
          if (reading.byCategory[cat] != null) ...[
            _CategoryCard(
              item: reading.byCategory[cat]!,
              aspect: reading.byCategory[cat]!.usedAspects.isEmpty
                  ? _categoryAspect(cat, chart, transits)
                  : reading.byCategory[cat]!.usedAspects.first,
              roastLevel: roastLevel,
              onBodySelected: onBodySelected,
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final DailyReadingItem item;
  final Aspect? aspect;
  final RoastLevel roastLevel;
  final ValueChanged<Body> onBodySelected;
  const _CategoryCard({
    required this.item,
    required this.aspect,
    required this.roastLevel,
    required this.onBodySelected,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = _categoryMessage(item, aspect, roastLevel);
    return Card(
      child: InkWell(
        onTap: aspect == null ? null : () => onBodySelected(aspect!.b),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    item.category,
                    style: TextStyle(
                      color: scheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  if (aspect != null)
                    _AspectNameSymbolLabel(
                      aspect: aspect!,
                      color: scheme.onSurface.withValues(alpha: 0.54),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                ],
              ),
              const SizedBox(height: 9),
              Text(text, style: const TextStyle(fontSize: 15, height: 1.65)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '星図を取得できませんでした。\n少し時間をおいて、もう一度お試しください。',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.75),
            ),
            const SizedBox(height: 16),
            TextButton(onPressed: onRetry, child: const Text('もう一度')),
          ],
        ),
      ),
    );
  }
}

Aspect? _heroAspect(NatalChart chart, Map<Body, double> transits) {
  final aspects = findTransitAspects(transits, chart.positions);
  if (aspects.isEmpty) return null;
  aspects.sort((a, b) => _aspectScore(b).compareTo(_aspectScore(a)));
  return aspects.first;
}

Aspect? _categoryAspect(
  String category,
  NatalChart chart,
  Map<Body, double> transits,
) {
  final aspects = findTransitAspects(
    transits,
    chart.positions,
  ).where((a) => categoryForNatalBody(a.b) == category).toList();
  if (aspects.isEmpty) return null;
  aspects.sort((a, b) => _aspectScore(b).compareTo(_aspectScore(a)));
  return aspects.first;
}

Aspect? _bodyAspect(Body body, NatalChart chart, Map<Body, double> transits) {
  final aspects = findTransitAspects(
    transits,
    chart.positions,
  ).where((a) => a.b == body || a.a == body).toList();
  if (aspects.isEmpty) return null;
  aspects.sort((a, b) => _aspectScore(b).compareTo(_aspectScore(a)));
  return aspects.first;
}

double _aspectScore(Aspect aspect) {
  final bodyWeight = switch (aspect.a) {
    Body.saturn => 1.2,
    Body.jupiter => 1.1,
    Body.sun => 1.0,
    Body.mars => 0.95,
    Body.moon => 0.9,
    Body.venus => 0.82,
    Body.mercury => 0.75,
    _ => 0.7,
  };
  final limit = aspectOrbLimit(aspect.type);
  final tight = (1 - (aspect.orb / limit)).clamp(0.0, 1.0);
  return bodyWeight * tight;
}

String _heroMessage(DailyReading reading, Aspect? hero, RoastLevel level) {
  if (hero == null) return reading.overallHeadline;
  if (level == RoastLevel.mild) return _mildAspectSpotlight(hero);
  if (level == RoastLevel.sharp) return _heroSharp(hero);
  return _heroExtraHot(hero);
}

String _heroSharp(Aspect aspect) {
  final domain = categoryForNatalBody(aspect.b);
  final tense = isTenseAspect(aspect.type);
  if (domain == '恋愛・対人') {
    return tense ? '相手の反応を読みすぎる日。自分の期待を、先に言葉にして。' : '自然体で通る日。盛ると、逆に薄く見える。';
  }
  if (domain == '仕事') {
    return tense
        ? '段取りにノイズが乗る日。勢いより、確認で事故を減らして。'
        : '判断と作業が噛み合う日。小さく決めて、小さく終わらせる。';
  }
  if (domain == '心の調子') {
    return tense ? '感情のセンサーが過敏な日。人の機嫌まで背負わなくていい。' : '整いやすい日。静かな回復を、ちゃんと予定に入れて。';
  }
  return tense ? '反応が早く出やすい日。何を守ろうとしてるか、先に見て。' : '流れが使える日。遠慮より実行を選ぶと、空気が変わる。';
}

String _heroExtraHot(Aspect aspect) {
  final domain = categoryForNatalBody(aspect.b);
  final tense = isTenseAspect(aspect.type);
  if (domain == '恋愛・対人') {
    return tense ? '言葉か、期待を下ろすか。中間で消耗するだけ。' : '魅力は出てる。全方位を狙うと、燃費が悪い。';
  }
  if (domain == '仕事') {
    return tense ? '詰まる日。一個に絞れば、空回りが止まる。' : '動ける日。脳内会議を閉じて、外に一手。';
  }
  if (domain == '心の調子') {
    return tense ? '無理が積もる日。休む側に振っていい。' : '回復しやすい日。ざわつく場所からは距離。';
  }
  return tense ? '反応が早すぎる日。一拍。何に反応してるか、先に見る。' : '追い風の日。遠慮しすぎると、ただの機会損失。';
}

String _categoryMessage(
  DailyReadingItem item,
  Aspect? aspect,
  RoastLevel level,
) {
  if (level == RoastLevel.mild || aspect == null) return item.text;
  final domain = item.category;
  final tense = isTenseAspect(aspect.type);
  return level == RoastLevel.sharp
      ? _categorySharp(domain, tense)
      : _categoryExtraHot(domain, tense);
}

String _categorySharp(String domain, bool tense) {
  if (domain == '恋愛・対人') {
    return tense
        ? '察してもらう前提で動くとズレます。今日は、期待より言葉を使って。'
        : '人との空気は悪くありません。好かれようと盛りすぎると、逆に薄く見えます。';
  }
  if (domain == '仕事') {
    return tense
        ? '急ぐほど雑さが出ます。今日は速さより、確認の回数で勝って。'
        : '進められる日です。考えすぎを「準備」と呼ぶのはそろそろ終わり。';
  }
  if (domain == '心の調子') {
    return tense
        ? '平気なふりが効きにくい日。今日は余白を予定に入れて。'
        : '整いやすい日です。余計な刺激まで拾いに行かなければ、ちゃんと回復します。';
  }
  return tense ? '今日は反応が早すぎると損します。一回止まってから動いて。' : '流れは使えます。遠慮しすぎず、小さく前へ出て。';
}

String _categoryExtraHot(String domain, bool tense) {
  if (domain == '恋愛・対人') {
    return tense ? '伝えるか、期待を下ろすか。沈黙を続けるほど消耗する。' : '感じはいい。全方位を狙うと、コスパが悪い。';
  }
  if (domain == '仕事') {
    return tense ? '忙しさが空回りする日。一個に絞れば、勢いが戻る。' : '動けば進む。脳内会議は閉じて、外に一手。';
  }
  if (domain == '心の調子') {
    return tense ? '無理が積もる日。寝る・断る・離れる、選んでいい。' : '回復できる日。ざわつく場所からは距離。';
  }
  return tense ? '結論を先送りしてる日。一回小さく決めれば、視界が戻る。' : '追い風。遠慮しすぎると、機会損失。';
}

String _mildAspectSpotlight(Aspect aspect) {
  final domain = categoryForNatalBody(aspect.b);
  final tense = isTenseAspect(aspect.type);
  if (domain == '恋愛・対人') {
    return tense
        ? '距離感に迷いやすい一日。相手を見る前に、自分の期待を確かめてみてください。'
        : '人との空気がやわらかくなりそうな日。自然な反応を選ぶと、いい時間になりそうです。';
  }
  if (domain == '仕事') {
    return tense
        ? '段取りや言葉にズレが出やすい日。勢いより確認を大事にしてください。'
        : '考えたことを小さく形にしやすい日。動きながら整えてみてください。';
  }
  if (domain == '心の調子') {
    return tense
        ? '気持ちが外側の刺激に反応しやすい日。予定を詰めすぎないでください。'
        : '心がやわらかく整いやすい日。静かな時間を少し多めに取ってください。';
  }
  return tense
      ? '自分の出方を見直したくなる日。急ぐ前に、何に反応しているか確かめてみてください。'
      : '全体の流れが使いやすい日。小さく動くほど、いい方向に進みそうです。';
}

String _bodyInsight(Body body) {
  switch (body) {
    case Body.sun:
      return '自分らしさ、意志、見せ方の核。';
    case Body.moon:
      return '感情、安心、素の反応が出る場所。';
    case Body.mercury:
      return '考え方、言葉、情報処理の癖。';
    case Body.venus:
      return '恋愛、好み、楽しみ方の傾向。';
    case Body.mars:
      return '行動力、怒り方、突破力の出方。';
    case Body.jupiter:
      return '広げ方、楽観、チャンスの拾い方。';
    case Body.saturn:
      return '責任、苦手意識、鍛えられる場所。';
    default:
      return '深い世代テーマに触れる天体。';
  }
}
