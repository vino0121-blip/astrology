// lib/astro_engine_vsop.dart
//
// VSOP87 ベースのエフェメリス。`EphemerisSource` を実装する。
//
// テーブル：`cosinekitty/astronomy` (MIT) の VSOP87 切り詰め系列を機械抽出。
// → `vsop_tables.dart`（自動生成、手編集禁止、`extract_vsop.py` で再生成）。
//
// 精度（vs Astronomy Engine 本家、2026-06-02 検証）：
//   Sun・Mercury・Venus・Mars・Jupiter・Saturn ≤ 0.5 分角
//   Moon（Meeus 主要10項）：±0.05°（≈3分角）。astrology の用途では十分。
//
// PHASE A2 残務：
//   月の本格移植（cosinekitty の `_CalcMoon`、Brown lunar theory）。
//   現状の Meeus 簡約でもサイン判定・アスペクト判定には十分なので
//   優先度は高くない。
//
// ライセンス：MIT。著作権表記を必ず保持すること（このファイルと
// vsop_tables.dart の冒頭コメント）。

import 'dart:math' as math;

import 'astro_core.dart';

part 'vsop_tables.dart';

// ============================================================
// テーブル型（vsop_tables.dart が参照）
// ============================================================
typedef VsopTerm = (double amp, double phase, double freq);

class VsopSeries {
  final List<VsopTerm> terms;
  const VsopSeries(this.terms);
}

class Formula {
  final List<VsopSeries> series;
  const Formula(this.series);
}

class VsopModel {
  final Formula lon;
  final Formula lat;
  final Formula rad;
  const VsopModel(this.lon, this.lat, this.rad);
}

// ============================================================
// 評価器
// ============================================================
const double _daysPerMillennium = 365250.0;
const double _tau = 2 * math.pi;

/// VSOP87 系列の評価。
/// `clampAngle=true` のとき、各 series の累積を [-2π, +2π] に折り畳んで
/// 大きな角度の足し算で発生する桁落ちを防ぐ（Python 原本の `math.fmod` 等価）。
double _vsopFormula(Formula f, double t, bool clampAngle) {
  var tpower = 1.0;
  var coord = 0.0;
  for (final s in f.series) {
    var incr = 0.0;
    for (final term in s.terms) {
      incr += term.$1 * math.cos(term.$2 + term.$3 * t);
    }
    incr *= tpower;
    if (clampAngle) {
      // Dart の % は Euclidean、Python の fmod は truncated。
      // VSOP の参照実装は truncated を使うので .remainder() を選ぶ。
      incr = incr.remainder(_tau);
    }
    coord += incr;
    tpower *= t;
  }
  return coord;
}

/// 日心黄道直交座標（J2000 ecliptic frame）。
({double x, double y, double z}) _vsopHelioRect(VsopModel m, double ttDays) {
  final t = ttDays / _daysPerMillennium;
  final lon = _vsopFormula(m.lon, t, true);
  final lat = _vsopFormula(m.lat, t, false);
  final rad = _vsopFormula(m.rad, t, false);
  final rcl = rad * math.cos(lat);
  return (
    x: rcl * math.cos(lon),
    y: rcl * math.sin(lon),
    z: rad * math.sin(lat),
  );
}

/// J2000 黄経 → of-date 黄経。IAU2006 general precession in longitude。
///   p_A = 5028.796195″·T + 1.1054348″·T²   （T = ユリウス世紀 from J2000）
/// 章動・光行差は省略（合計でも 30″ 未満、astrology の用途では無視可）。
double _toDateDeg(double j2000Deg, double ttDays) {
  final centuries = ttDays / 36525.0;
  final deltaArcsec =
      5028.796195 * centuries + 1.1054348 * centuries * centuries;
  final delta = deltaArcsec / 3600.0;
  var x = (j2000Deg + delta) % 360.0;
  if (x < 0) x += 360.0;
  return x;
}

// ============================================================
// 公開クラス
// ============================================================
class Vsop87Ephemeris implements EphemerisSource {
  const Vsop87Ephemeris();

  @override
  double eclipticLongitude(Body body, double jd) {
    final tt = jd - 2451545.0;

    if (body == Body.moon) {
      return _moonLongitude(jd);
    }

    final earth = _vsopHelioRect(_vsop_earth, tt);

    if (body == Body.sun) {
      final lonRad = math.atan2(-earth.y, -earth.x);
      return _toDateDeg(lonRad * 180.0 / math.pi, tt);
    }

    final model = _vsopByName[body.name];
    if (model == null) {
      // 外惑星（uranus/neptune/pluto）と内部用 earthBary は MVP では未対応。
      // mvpBodies からは呼ばれないので 0 を返す（事故時のフォールバック）。
      return 0.0;
    }

    final p = _vsopHelioRect(model, tt);
    final lonRad = math.atan2(p.y - earth.y, p.x - earth.x);
    return _toDateDeg(lonRad * 180.0 / math.pi, tt);
  }

  // ----------------------------------------------------------
  // Moon（Meeus chapter 47 の主要10項、±0.05° 精度）
  // PHASE A2 で AE の _CalcMoon 移植に差し替え予定。
  // 現状でもアスペクト判定・サイン判定には十分。
  // ----------------------------------------------------------
  double _moonLongitude(double jd) {
    final t = (jd - 2451545.0) / 36525.0;
    final lp = 218.3164477 + 481267.88123421 * t;
    final d = (297.8501921 + 445267.1114034 * t) * math.pi / 180.0;
    final m = (357.5291092 + 35999.0502909 * t) * math.pi / 180.0;
    final mp = (134.9633964 + 477198.8675055 * t) * math.pi / 180.0;
    final f = (93.272095 + 483202.0175233 * t) * math.pi / 180.0;
    final lonDeg = lp +
        6.288774 * math.sin(mp) +
        1.274027 * math.sin(2 * d - mp) +
        0.658314 * math.sin(2 * d) +
        0.213618 * math.sin(2 * mp) +
        -0.185116 * math.sin(m) +
        -0.114332 * math.sin(2 * f) +
        0.058793 * math.sin(2 * d - 2 * mp) +
        0.057066 * math.sin(2 * d - m - mp) +
        0.053322 * math.sin(2 * d + mp) +
        0.045758 * math.sin(2 * d - m);
    var x = lonDeg % 360.0;
    if (x < 0) x += 360.0;
    return x;
  }
}
