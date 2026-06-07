// astro_narration.dart
//
// ランタイム組み立て：エンジン出力（astro_core）× 辞書（theme_dictionary.json）
// → 「今日の運勢」の構造化テキスト（カテゴリ別＋全体ヘッドライン）。
//
// 設計の肝：
//  - LLMはランタイムで使わない。辞書からの決定論的選択のみ。
//  - 同じ「日付＋出生図」なら必ず同じ文面（再現性＝根拠の担保）。
//  - 文面の変化は、日付シードで variant を回すことで生む。

import 'dart:convert';
import 'astro_core.dart';

// ============================================================
// 辞書モデル
// ============================================================
class ThemeEntry {
  final String quality; // 'emphasis' / 'harmony' / 'tension'
  final List<String> variants;
  const ThemeEntry(this.quality, this.variants);
}

class BodyDomain {
  final String category;
  final String facet;
  const BodyDomain(this.category, this.facet);
}

class ThemeDictionary {
  final Map<String, ThemeEntry> theme;
  final Map<String, String> aspectQuality; // aspectName -> quality
  final Map<Body, BodyDomain> bodyDomain;
  final Map<String, List<String>> hints; // quality -> phrases

  const ThemeDictionary({
    required this.theme,
    required this.aspectQuality,
    required this.bodyDomain,
    required this.hints,
  });

  factory ThemeDictionary.fromJsonString(String src) =>
      ThemeDictionary.fromJson(jsonDecode(src) as Map<String, dynamic>);

  factory ThemeDictionary.fromJson(Map<String, dynamic> json) {
    // theme
    final themeMap = <String, ThemeEntry>{};
    final tRaw = (json['theme'] as Map).cast<String, dynamic>();
    tRaw.forEach((k, v) {
      final m = (v as Map).cast<String, dynamic>();
      themeMap[k] = ThemeEntry(
        m['quality'] as String,
        (m['variants'] as List).cast<String>(),
      );
    });

    // aspectQuality
    final aq = (json['aspectQuality'] as Map).cast<String, dynamic>();
    final aspectQuality = {for (final k in aq.keys) k: aq[k] as String};
    for (final type in AspectType.values) {
      aspectQuality.putIfAbsent(type.name, () {
        if (isHarmoniousAspect(type)) return 'harmony';
        if (isTenseAspect(type)) return 'tension';
        return 'emphasis';
      });
    }

    // bodyDomain（_provisional キーにも対応）
    final bdRaw =
        (json['bodyDomain'] ?? json['_bodyDomain_provisional']) as Map?;
    final bd = <Body, BodyDomain>{};
    if (bdRaw != null) {
      bdRaw.forEach((k, v) {
        if (k is! String || k.startsWith('_')) return;
        final b = _bodyByName(k);
        if (b == null) return;
        final m = (v as Map).cast<String, dynamic>();
        bd[b] = BodyDomain(m['category'] as String, m['facet'] as String);
      });
    }

    // hint
    final hRaw = (json['hint'] ?? json['_hint_provisional']) as Map?;
    final hints = <String, List<String>>{};
    if (hRaw != null) {
      hRaw.forEach((k, v) {
        if (k is! String || k.startsWith('_')) return;
        if (v is List) hints[k] = v.cast<String>();
      });
    }

    return ThemeDictionary(
      theme: themeMap,
      aspectQuality: aspectQuality,
      bodyDomain: bd,
      hints: hints,
    );
  }

  static Body? _bodyByName(String n) {
    for (final b in Body.values) {
      if (b.name == n) return b;
    }
    return null;
  }

  ThemeEntry? lookup(Body transit, AspectType type) =>
      theme['${transit.name}_${type.name}'] ??
      theme['${transit.name}_${_themeFallbackType(type).name}'];
}

AspectType _themeFallbackType(AspectType type) {
  switch (type) {
    case AspectType.semiSextile:
    case AspectType.quintile:
      return AspectType.sextile;
    case AspectType.semiSquare:
    case AspectType.sesquiquadrate:
    case AspectType.quincunx:
      return AspectType.square;
    case AspectType.conjunction:
    case AspectType.sextile:
    case AspectType.square:
    case AspectType.trine:
    case AspectType.opposition:
      return type;
  }
}

// ============================================================
// 重み付け（どのアスペクトを「主役」として採用するかの基準）
// ============================================================
const _bodyWeight = <Body, double>{
  Body.sun: 1.0,
  Body.moon: 0.9,
  Body.mercury: 0.7,
  Body.venus: 0.8,
  Body.mars: 0.9,
  Body.jupiter: 1.1,
  Body.saturn: 1.2,
  Body.uranus: 1.0,
  Body.neptune: 1.0,
  Body.pluto: 1.0,
};
double _aspectWeight(Aspect a) {
  final bw = _bodyWeight[a.a] ?? 0.7;
  final limit = aspectOrbLimit(a.type);
  final tight = (1.0 - (a.orb / limit)).clamp(0.0, 1.0);
  return bw * tight;
}

double _presentationScore(double rawScore) {
  final expanded = 0.5 + (rawScore - 0.5) * 1.75;
  return expanded.clamp(0.12, 0.88).toDouble();
}

// ============================================================
// 決定論シード（32-bit FNV-1a。web/モバイル共通で安全）
// ============================================================
int _stableSeed(DateTime d, String chartId, String key) {
  final s =
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}|$chartId|$key';
  int h = 2166136261;
  for (final c in s.codeUnits) {
    h ^= c;
    h = (h * 16777619) & 0xFFFFFFFF;
  }
  return h;
}

// ============================================================
// カテゴリ・フォールバック（辞書側に移すまでの暫定プール）
// ============================================================
const _categoriesOrder = ['全体', '恋愛・対人', '仕事', '心の調子'];

const _neutralByCategory = <String, List<String>>{
  '全体': ['穏やかに流れる一日。等身大の自分で過ごせそうです。', '大きな波のない一日。日々のリズムを大切にしてください。'],
  '恋愛・対人': ['いつものやり取りが心地よく感じられそう。気の合う人に小さな挨拶を。', '無理に動かさず、ふだんの距離感を楽しんでみてください。'],
  '仕事': ['いつものペースが力になりそう。基本に丁寧に取り組んでみて。', '小さなタスクを片づけると、すっきり進みそうです。'],
  '心の調子': ['心は落ち着いていそう。好きなものに少し触れる時間を。', '静かな時間を作ると、気持ちが整いそうです。'],
};

// ============================================================
// 結果モデル
// ============================================================
class DailyReadingItem {
  final String category;
  final String text;
  final List<Aspect> usedAspects;
  const DailyReadingItem(this.category, this.text, this.usedAspects);
}

class DailyReading {
  final DateTime dateLocal;
  final String overallHeadline;
  final double overallScore; // 0..1（0.5中庸、>調和寄り、<緊張寄り）
  final Map<String, DailyReadingItem> byCategory;
  const DailyReading({
    required this.dateLocal,
    required this.overallHeadline,
    required this.overallScore,
    required this.byCategory,
  });
}

// ============================================================
// 当日のトランジット位置を計算する小ヘルパー
// ============================================================
Map<Body, double> computeTransitPositions(
  DateTime instantUtc,
  EphemerisSource ephemeris, {
  List<Body> bodies = mvpBodies,
}) {
  final jd = julianDayUtc(instantUtc);
  return {for (final b in bodies) b: ephemeris.eclipticLongitude(b, jd)};
}

// ============================================================
// メイン組み立て
// ============================================================
DailyReading buildDailyReading({
  required DateTime dateLocalForDisplay,
  required NatalChart natal,
  required Map<Body, double> transitPositions,
  required ThemeDictionary dict,
  required String chartId,
}) {
  // 1. transit × natal アスペクト
  final aspects = findTransitAspects(transitPositions, natal.positions);

  // 2. カテゴリ振り分け（natal天体のドメインで）
  final byCat = <String, List<Aspect>>{};
  for (final a in aspects) {
    final dom = dict.bodyDomain[a.b];
    if (dom == null) continue;
    byCat.putIfAbsent(dom.category, () => []).add(a);
  }
  byCat.forEach((_, list) {
    list.sort((x, y) => _aspectWeight(y).compareTo(_aspectWeight(x)));
  });

  // 3. カテゴリごとに主役を1件採用→文章化
  final out = <String, DailyReadingItem>{};
  for (final cat in _categoriesOrder) {
    final list = byCat[cat] ?? const <Aspect>[];
    if (list.isEmpty) {
      final pool = _neutralByCategory[cat]!;
      final idx =
          _stableSeed(dateLocalForDisplay, chartId, 'neutral_$cat') %
          pool.length;
      out[cat] = DailyReadingItem(cat, pool[idx], const []);
      continue;
    }
    final primary = list.first;
    final entry = dict.lookup(primary.a, primary.type);

    String text;
    if (entry == null || entry.variants.isEmpty) {
      text = _neutralByCategory[cat]!.first;
    } else {
      final key = '${primary.a.name}_${primary.type.name}';
      final vIdx =
          _stableSeed(dateLocalForDisplay, chartId, key) %
          entry.variants.length;
      text = entry.variants[vIdx];
      final hintPool = dict.hints[entry.quality];
      if (hintPool != null && hintPool.isNotEmpty) {
        final hIdx =
            _stableSeed(dateLocalForDisplay, chartId, 'h_$key') %
            hintPool.length;
        text = '$text ${hintPool[hIdx]}';
      }
    }
    out[cat] = DailyReadingItem(cat, text, [primary]);
  }

  // 4. 全体スコア＆ヘッドライン（簡易：調和−緊張のバランス）
  double score = 0;
  double total = 0;
  for (final a in aspects) {
    final w = _aspectWeight(a);
    total += w;
    final q = dict.aspectQuality[a.type.name];
    if (q == 'harmony') {
      score += w;
    } else if (q == 'tension') {
      score -= w;
    } // emphasis は中立
  }
  final rawNorm = total == 0 ? 0.5 : (score / total + 1) / 2;
  final norm = _presentationScore(rawNorm);

  String headline;
  if (norm >= 0.65) {
    headline = '追い風のある一日。自然な流れに乗っていけそうです。';
  } else if (norm <= 0.35) {
    headline = '少しペースを落として整える日。無理せず大丈夫です。';
  } else {
    headline = '穏やかに巡る一日。等身大で過ごせそうです。';
  }

  return DailyReading(
    dateLocal: dateLocalForDisplay,
    overallHeadline: headline,
    overallScore: norm,
    byCategory: out,
  );
}

// ============================================================
// デモ／検証ハーネス
//   実行: dart run astro_narration.dart
//   出生図とその日のトランジット位置を疑似生成して、組み立てが
//   正しく走るかを目視確認するためのもの。
// ============================================================
void main() {
  // 出生図（前のコアと同じ例）
  final birthJst = DateTime(1990, 5, 15, 9, 30);
  final birthUtc = birthJst.subtract(const Duration(hours: 9));
  final natal = buildNatalChart(
    birthUtc: birthUtc,
    latitude: 35.6812,
    longitudeEast: 139.6917,
  );

  // その日（例: 2026-06-02）のトランジット位置
  final today = DateTime(2026, 6, 2, 9, 0);
  final todayUtc = today.subtract(const Duration(hours: 9));
  final transit = computeTransitPositions(
    todayUtc,
    const LowPrecisionEphemeris(),
  );

  // 辞書をインライン（実機では rootBundle.loadString('assets/theme_dictionary.json')）
  final dict = ThemeDictionary.fromJsonString(_sampleDictJson);

  final reading = buildDailyReading(
    dateLocalForDisplay: today,
    natal: natal,
    transitPositions: transit,
    dict: dict,
    chartId: 'demo-1',
  );

  print(
    '=== ${today.year}-${today.month.toString().padLeft(2, "0")}-'
    '${today.day.toString().padLeft(2, "0")} の運勢 ===',
  );
  print('Score: ${(reading.overallScore * 100).toStringAsFixed(0)} / 100');
  print('Headline: ${reading.overallHeadline}');
  for (final cat in _categoriesOrder) {
    final item = reading.byCategory[cat]!;
    print('---');
    print('[$cat] ${item.text}');
    for (final a in item.usedAspects) {
      print(
        '   ↳ ${a.a.name} ${a.type.name} ${a.b.name} (orb ${a.orb.toStringAsFixed(1)}°)',
      );
    }
  }
}

// === デモ用の最小辞書（数キーのみ） ===
const _sampleDictJson = '''
{
  "aspectQuality": {
    "conjunction": "emphasis",
    "trine": "harmony",
    "sextile": "harmony",
    "square": "tension",
    "opposition": "tension"
  },
  "theme": {
    "sun_trine":   { "quality": "harmony",  "variants": [
      "心と体に活力が満ちやすい日。やりたいことに自然と手が伸びていきそうです。"
    ]},
    "mars_square": { "quality": "tension",  "variants": [
      "やる気が空回りしやすい日。急がず一歩ずつ進めると、力が良い方向に流れていきます。"
    ]},
    "venus_sextile": { "quality": "harmony", "variants": [
      "人との縁が広がりやすい日。誘いには軽い気持ちで乗ってみると良さそうです。"
    ]}
  },
  "_bodyDomain_provisional": {
    "sun":     { "category": "全体",       "facet": "自分らしさ・活力" },
    "moon":    { "category": "心の調子",   "facet": "感情・休息" },
    "mercury": { "category": "仕事",       "facet": "思考・会話" },
    "venus":   { "category": "恋愛・対人", "facet": "愛情・楽しみ" },
    "mars":    { "category": "仕事",       "facet": "行動・情熱" },
    "jupiter": { "category": "全体",       "facet": "成長・チャンス" },
    "saturn":  { "category": "仕事",       "facet": "継続・責任" }
  },
  "_hint_provisional": {
    "harmony":  ["気になる人に一言、連絡してみては。"],
    "emphasis": ["大切にしたいことを、ひとつ書き出してみては。"],
    "tension":  ["深呼吸をひとつ。"]
  }
}
''';
