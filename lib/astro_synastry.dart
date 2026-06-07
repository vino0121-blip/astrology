// lib/astro_synastry.dart
//
// 相性計算（シナストリー）：二つの NatalChart 間のクロスアスペクトを抽出し、
// 古典的な重み付け（Sun / Moon / Venus が主役）でスコアと主要アスペクトを返す。
//
// 設計の肝：
//  - 既存の astro_core のアスペクト角・オーブ仕様を流用（互換性維持）
//  - synastry 専用に body 重みを再定義（Venus=1.3, Sun/Moon=1.2 が古典の重み）
//  - 重みは「両側の天体の重み × tightness」の積（双方向の合致を評価）
//  - 表示用の文章は astro_display 側に分離（ここは数値とアスペクトだけ）

import 'astro_core.dart';

class SynastryAspect {
  /// あなた（user）側の天体
  final Body bodyA;

  /// 相手（partner）側の天体
  final Body bodyB;
  final AspectType type;
  final double orb;
  const SynastryAspect(this.bodyA, this.bodyB, this.type, this.orb);
}

class SynastryResult {
  /// 検出された全アスペクト（重み降順）
  final List<SynastryAspect> aspects;

  /// 主役（上位N件、表示用）
  final List<SynastryAspect> keyAspects;

  /// 0..1（>0.5＝調和寄り、<0.5＝緊張寄り）
  final double score;

  /// 'harmony' / 'tension' / 'mixed'
  final String quality;

  const SynastryResult({
    required this.aspects,
    required this.keyAspects,
    required this.score,
    required this.quality,
  });
}

// 古典的な synastry 重み（Venus と二大光源を最重視）
const _synBodyWeight = <Body, double>{
  Body.sun: 1.2,
  Body.moon: 1.2,
  Body.venus: 1.3,
  Body.mars: 1.1,
  Body.mercury: 0.9,
  Body.jupiter: 0.9,
  Body.saturn: 1.0,
};

const double _maxSynOrb = 8.0;

double _synWeight(SynastryAspect a) {
  final wa = _synBodyWeight[a.bodyA] ?? 0.7;
  final wb = _synBodyWeight[a.bodyB] ?? 0.7;
  final tight = (1.0 - a.orb / _maxSynOrb).clamp(0.0, 1.0);
  return wa * wb * tight;
}

const _synAspectAngle = <AspectType, double>{
  AspectType.conjunction: 0,
  AspectType.semiSextile: 30,
  AspectType.semiSquare: 45,
  AspectType.sextile: 60,
  AspectType.quintile: 72,
  AspectType.square: 90,
  AspectType.trine: 120,
  AspectType.sesquiquadrate: 135,
  AspectType.quincunx: 150,
  AspectType.opposition: 180,
};

const _synOrbAllowed = <AspectType, double>{
  AspectType.conjunction: 8,
  AspectType.semiSextile: 2,
  AspectType.semiSquare: 2,
  AspectType.sextile: 4,
  AspectType.quintile: 2,
  AspectType.square: 6,
  AspectType.trine: 6,
  AspectType.sesquiquadrate: 2,
  AspectType.quincunx: 3,
  AspectType.opposition: 8,
};

SynastryResult computeSynastry(NatalChart user, NatalChart partner) {
  final out = <SynastryAspect>[];
  for (final u in user.positions.entries) {
    for (final p in partner.positions.entries) {
      final sep = separation(u.value, p.value);
      for (final t in AspectType.values) {
        final orb = (sep - _synAspectAngle[t]!).abs();
        if (orb <= _synOrbAllowed[t]!) {
          out.add(SynastryAspect(u.key, p.key, t, orb));
        }
      }
    }
  }

  out.sort((x, y) => _synWeight(y).compareTo(_synWeight(x)));
  final key = out.take(5).toList();

  // スコア：調和系 − 緊張系のバランス
  double harm = 0, ten = 0;
  for (final a in out) {
    final w = _synWeight(a);
    if (isHarmoniousAspect(a.type)) {
      harm += w;
    } else if (isTenseAspect(a.type)) {
      ten += w;
    } else {
      // emphasis: 半々で配分（実際は天体組み合わせ依存だが、MVPは中立扱い）
      harm += w * 0.5;
      ten += w * 0.5;
    }
  }
  final score = (harm + ten) == 0 ? 0.5 : (harm / (harm + ten)).clamp(0.0, 1.0);
  final quality = score >= 0.6
      ? 'harmony'
      : score <= 0.4
      ? 'tension'
      : 'mixed';

  return SynastryResult(
    aspects: out,
    keyAspects: key,
    score: score,
    quality: quality,
  );
}
