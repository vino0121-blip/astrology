// astro_core.dart
//
// 西洋占星術アプリ：天体計算コア（ライセンス費ゼロ・自前エンジン）
// Swiss Ephemeris は使わない。VSOP87系の自前計算 + 純粋な球面三角でハウス/アスペクト。
//
// ┌─ 信頼度の区分 ───────────────────────────────────────────────┐
// │ [FINAL]  検証済みの定型アルゴリズム。そのまま本番可。              │
// │ [VERIFY] 数値テーブルが要検証。astro.com / JPL と突き合わせるまで  │
// │          本番に出さない。差し替え可能な形で隔離してある。          │
// └────────────────────────────────────────────────────────────┘
//
// 精度の前提：占星術はオーブ数度。太陽は誤差±0.01°で確定。惑星/月は
// 低精度法でも数分角〜0.3°程度に収まり、サイン判定・アスペクト判定には十分。
// より高精度が必要なら EphemerisSource を Astronomy Engine 移植版に差し替える。

import 'dart:math' as math;

// ============================================================
// 角度ユーティリティ [FINAL]
// ============================================================
double _deg2rad(double d) => d * math.pi / 180.0;
double _rad2deg(double r) => r * 180.0 / math.pi;

/// 0–360 に正規化
double norm360(double deg) {
  var x = deg % 360.0;
  if (x < 0) x += 360.0;
  return x;
}

/// -180–180 に正規化
double norm180(double deg) {
  var x = norm360(deg);
  if (x > 180.0) x -= 360.0;
  return x;
}

// ============================================================
// 時刻 → ユリウス日 [FINAL]  (Meeus, Ch.7)
// 入力は UTC。JST は呼び出し側で UTC へ変換しておくこと。
// ============================================================
double julianDayUtc(DateTime utc) {
  final t = utc.toUtc();
  int y = t.year;
  int m = t.month;
  final double day =
      t.day +
      (t.hour +
              t.minute / 60.0 +
              (t.second + t.millisecond / 1000.0) / 3600.0) /
          24.0;
  if (m <= 2) {
    y -= 1;
    m += 12;
  }
  final int a = (y / 100).floor();
  final int b = 2 - a + (a / 4).floor();
  return (365.25 * (y + 4716)).floor() +
      (30.6001 * (m + 1)).floor() +
      day +
      b -
      1524.5;
}

/// J2000.0 からのユリウス世紀
double julianCenturies(double jd) => (jd - 2451545.0) / 36525.0;

// ============================================================
// 平均黄道傾斜角 [FINAL]  (Meeus 22.2)  単位: 度
// ============================================================
double meanObliquity(double jd) {
  final t = julianCenturies(jd);
  final seconds = 21.448 - t * (46.8150 + t * (0.00059 - t * 0.001813));
  return 23.0 + (26.0 + seconds / 60.0) / 60.0;
}

// ============================================================
// グリニッジ平均恒星時 GMST [FINAL]  (Meeus 12.4)  単位: 度
// ============================================================
double gmstDeg(double jd) {
  final t = julianCenturies(jd);
  final theta =
      280.46061837 +
      360.98564736629 * (jd - 2451545.0) +
      0.000387933 * t * t -
      (t * t * t) / 38710000.0;
  return norm360(theta);
}

/// 地方恒星時（東経プラス）単位: 度
double lstDeg(double jd, double longitudeEast) =>
    norm360(gmstDeg(jd) + longitudeEast);

// ============================================================
// 太陽の見かけ黄経 [FINAL]  (Meeus 25, 低精度 ±0.01°)  単位: 度
// ============================================================
double sunApparentLongitude(double jd) {
  final t = julianCenturies(jd);
  final l0 = 280.46646 + t * (36000.76983 + t * 0.0003032);
  final m = _deg2rad(norm360(357.52911 + t * (35999.05029 - t * 0.0001537)));
  final c =
      (1.914602 - t * (0.004817 + t * 0.000014)) * math.sin(m) +
      (0.019993 - t * 0.000101) * math.sin(2 * m) +
      0.000289 * math.sin(3 * m);
  final trueLong = l0 + c;
  final omega = _deg2rad(125.04 - 1934.136 * t);
  final lambda = trueLong - 0.00569 - 0.00478 * math.sin(omega);
  return norm360(lambda);
}

// ============================================================
// 天体
// ============================================================
enum Body {
  sun,
  moon,
  mercury,
  venus,
  mars,
  jupiter,
  saturn,
  uranus,
  neptune,
  pluto,
  earthBary, // 内部用: 地球(EMB)の日心位置。mvpBodies/表示には含めない
}

const mvpBodies = <Body>[
  Body.sun,
  Body.moon,
  Body.mercury,
  Body.venus,
  Body.mars,
  Body.jupiter,
  Body.saturn,
];

// ============================================================
// 天体黄経の供給インターフェース
// ここを差し替えれば精度・実装を入れ替えられる（本設計の肝）。
// ============================================================
abstract class EphemerisSource {
  /// 指定天体の地心・黄道座標での黄経（度, 0–360）を返す。
  double eclipticLongitude(Body body, double jd);
}

// ------------------------------------------------------------
// 低精度エフェメリス [VERIFY]
//   ・太陽は [FINAL] の sunApparentLongitude を使う。
//   ・惑星は Standish 流の平均軌道要素法。
//   ・月は Meeus 主要項の簡約。
//   ＞＞ 下の数値テーブルは「記憶ベースの暫定値」。本番前に必ず
//      JPL (ssd.jpl.nasa.gov) または Astronomy Engine 生成コードの
//      値へ差し替え、astro.com と突き合わせて検証すること。 ＜＜
// ------------------------------------------------------------
class LowPrecisionEphemeris implements EphemerisSource {
  const LowPrecisionEphemeris();

  @override
  double eclipticLongitude(Body body, double jd) {
    switch (body) {
      case Body.sun:
        return sunApparentLongitude(jd);
      case Body.moon:
        return _moonLongitude(jd);
      default:
        return _planetGeocentricLongitude(body, jd);
    }
  }

  // ---- 惑星：平均軌道要素 [VERIFY] ----
  // 各要素: [a(AU), e, I(deg), L(deg), longPeri ϖ(deg), longNode Ω(deg)]
  //         と、それぞれの「per Julian century」変化率。
  // ※ Earth/EMB を含む。地心黄経は (惑星helio - 地球helio) から算出。
  // ※ 値は要検証（_KeplerElem の comment 参照）。
  static const Map<Body, _KeplerElem> _elements = {
    Body.mercury: _KeplerElem(
      0.38709927,
      0.20563593,
      7.00497902,
      252.25032350,
      77.45779628,
      48.33076593,
      0.00000037,
      0.00001906,
      -0.00594749,
      149472.67411175,
      0.16047689,
      -0.12534081,
    ),
    Body.venus: _KeplerElem(
      0.72333566,
      0.00677672,
      3.39467605,
      181.97909950,
      131.60246718,
      76.67984255,
      0.00000390,
      -0.00004107,
      -0.00078890,
      58517.81538729,
      0.00268329,
      -0.27769418,
    ),
    Body.earthBary: _KeplerElem(
      1.00000261,
      0.01671123,
      -0.00001531,
      100.46457166,
      102.93768193,
      0.0,
      0.00000562,
      -0.00004392,
      -0.01294668,
      35999.37244981,
      0.32327364,
      0.0,
    ),
    Body.mars: _KeplerElem(
      1.52371034,
      0.09339410,
      1.84969142,
      -4.55343205,
      -23.94362959,
      49.55953891,
      0.00001847,
      0.00007882,
      -0.00813131,
      19140.30268499,
      0.44441088,
      -0.29257343,
    ),
    Body.jupiter: _KeplerElem(
      5.20288700,
      0.04838624,
      1.30439695,
      34.39644051,
      14.72847983,
      100.47390909,
      -0.00011607,
      -0.00013253,
      -0.00183714,
      3034.74612775,
      0.21252668,
      0.20469106,
    ),
    Body.saturn: _KeplerElem(
      9.53667594,
      0.05386179,
      2.48599187,
      49.95424423,
      92.59887831,
      113.66242448,
      -0.00125060,
      -0.00050991,
      0.00193609,
      1222.49362201,
      -0.41897216,
      -0.28867794,
    ),
    Body.uranus: _KeplerElem(
      19.18916464,
      0.04725744,
      0.77263783,
      313.23810451,
      170.95427630,
      74.01692503,
      -0.00196176,
      -0.00004397,
      -0.00242939,
      428.48202785,
      0.40805281,
      0.04240589,
    ),
    Body.neptune: _KeplerElem(
      30.06992276,
      0.00859048,
      1.77004347,
      -55.12002969,
      44.96476227,
      131.78422574,
      0.00026291,
      0.00005105,
      0.00035372,
      218.45945325,
      -0.32241464,
      -0.00508664,
    ),
    // 冥王星は VSOP87/この表に厳密には含まれない。表示用の近似のみ。要差し替え。
    Body.pluto: _KeplerElem(
      39.48211675,
      0.24882730,
      17.14001206,
      238.92903833,
      224.06891629,
      110.30393684,
      -0.00031596,
      0.00005170,
      0.00004818,
      145.20780515,
      -0.04062942,
      -0.01183482,
    ),
  };

  double _planetGeocentricLongitude(Body body, double jd) {
    final t = julianCenturies(jd);
    final p = _helioRect(_elements[body]!, t);
    final e = _helioRect(_elements[Body.earthBary]!, t);
    final x = p.$1 - e.$1;
    final y = p.$2 - e.$2;
    return norm360(_rad2deg(math.atan2(y, x)));
  }

  /// 平均要素 → 黄道面（J2000）における日心直交座標 (x, y, z)
  (double, double, double) _helioRect(_KeplerElem el, double t) {
    final a = el.a + el.aDot * t;
    final e = el.e + el.eDot * t;
    final i = _deg2rad(el.i + el.iDot * t);
    final l = el.l + el.lDot * t;
    final peri = el.peri + el.periDot * t;
    final node = el.node + el.nodeDot * t;

    final wArg = _deg2rad(peri - node); // 近点引数 ω
    final node_ = _deg2rad(node);
    final m = _deg2rad(norm180(l - peri)); // 平均近点角 M

    // ケプラー方程式を反復で解く（ラジアン）
    double eAnom = m + e * math.sin(m);
    for (var k = 0; k < 8; k++) {
      final dM = m - (eAnom - e * math.sin(eAnom));
      eAnom += dM / (1 - e * math.cos(eAnom));
    }

    // 軌道面内座標
    final xp = a * (math.cos(eAnom) - e);
    final yp = a * math.sqrt(1 - e * e) * math.sin(eAnom);

    // 黄道面（J2000）へ回転： ω, i, Ω
    final cw = math.cos(wArg), sw = math.sin(wArg);
    final ci = math.cos(i), si = math.sin(i);
    final cn = math.cos(node_), sn = math.sin(node_);

    final x = (cw * cn - sw * sn * ci) * xp + (-sw * cn - cw * sn * ci) * yp;
    final y = (cw * sn + sw * cn * ci) * xp + (-sw * sn + cw * cn * ci) * yp;
    final z = (sw * si) * xp + (cw * si) * yp;
    return (x, y, z);
  }

  // ---- 月：Meeus 主要項の簡約 [VERIFY] (±0.3°程度) ----
  // 本番では項を増やすか Astronomy Engine 移植版に差し替え。
  double _moonLongitude(double jd) {
    final t = julianCenturies(jd);
    final lp = 218.3164477 + 481267.88123421 * t; // 平均黄経 L'
    final d = _deg2rad(297.8501921 + 445267.1114034 * t); // 平均離角 D
    final m = _deg2rad(357.5291092 + 35999.0502909 * t); // 太陽平均近点角
    final mp = _deg2rad(134.9633964 + 477198.8675055 * t); // 月平均近点角 M'
    final f = _deg2rad(93.272095 + 483202.0175233 * t); // 緯度引数 F

    final lonDeg =
        lp +
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
    return norm360(lonDeg);
  }
}

/// 軌道要素（値＋世紀変化率）
class _KeplerElem {
  final double a, e, i, l, peri, node;
  final double aDot, eDot, iDot, lDot, periDot, nodeDot;
  const _KeplerElem(
    this.a,
    this.e,
    this.i,
    this.l,
    this.peri,
    this.node,
    this.aDot,
    this.eDot,
    this.iDot,
    this.lDot,
    this.periDot,
    this.nodeDot,
  );
}

// 地球(EMB)は Body.earthBary をキーに _elements 内へ保持し、地心黄経は
// (惑星helio - 地球helio) で算出する。earthBary は表示・mvpBodies に含めない。
// 惑星/地球/月の軌道要素テーブル自体は [VERIFY]（JPL値へ差し替え＋検証）。

// ============================================================
// ハウス・感受点 [FINAL]（ASC/MC の式は定型。検証推奨）
// ============================================================
class Angles {
  final double ascendant; // 度
  final double midheaven; // 度
  const Angles(this.ascendant, this.midheaven);
}

Angles computeAngles({
  required double jd,
  required double latitude,
  required double longitudeEast,
}) {
  final ramc = _deg2rad(lstDeg(jd, longitudeEast)); // MCの赤経 = 地方恒星時
  final eps = _deg2rad(meanObliquity(jd));
  final phi = _deg2rad(latitude);

  // MC 黄経
  final mc = norm360(
    _rad2deg(math.atan2(math.sin(ramc), math.cos(ramc) * math.cos(eps))),
  );

  // ASC 黄経（Meeus 由来の定型式）
  var asc = norm360(
    _rad2deg(
      math.atan2(
        math.cos(ramc),
        -(math.sin(ramc) * math.cos(eps) + math.tan(phi) * math.sin(eps)),
      ),
    ),
  );
  // ASC は MC から東回りに来るべき。中高緯度では下の補正で安定。
  if (norm360(asc - mc) > 180.0) asc = norm360(asc + 180.0);

  return Angles(asc, mc);
}

enum HouseSystem { wholeSign, equal }

/// 12ハウスのカスプ黄経（度）。index0 = 第1ハウス。
List<double> houseCusps({
  required Angles angles,
  HouseSystem system = HouseSystem.wholeSign,
}) {
  switch (system) {
    case HouseSystem.wholeSign:
      final start = (angles.ascendant / 30.0).floor() * 30.0;
      return List.generate(12, (k) => norm360(start + 30.0 * k));
    case HouseSystem.equal:
      return List.generate(12, (k) => norm360(angles.ascendant + 30.0 * k));
  }
}

// ============================================================
// 12星座 [FINAL]
// ============================================================
const zodiacSigns = <String>[
  '牡羊座',
  '牡牛座',
  '双子座',
  '蟹座',
  '獅子座',
  '乙女座',
  '天秤座',
  '蠍座',
  '射手座',
  '山羊座',
  '水瓶座',
  '魚座',
];

int signIndex(double longitude) => (norm360(longitude) / 30.0).floor();
String signName(double longitude) => zodiacSigns[signIndex(longitude)];
double degreeInSign(double longitude) => norm360(longitude) % 30.0;

// ============================================================
// アスペクト [FINAL]
// ============================================================
enum AspectType {
  conjunction,
  semiSextile,
  semiSquare,
  sextile,
  quintile,
  square,
  trine,
  sesquiquadrate,
  quincunx,
  opposition,
}

const _aspectAngle = <AspectType, double>{
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

// 既定オーブ（度）。設計確定時に調整。
const _defaultOrb = <AspectType, double>{
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

const _displayOrb = <AspectType, double>{
  AspectType.conjunction: 9,
  AspectType.semiSextile: 1.5,
  AspectType.semiSquare: 1.5,
  AspectType.sextile: 5,
  AspectType.quintile: 1.5,
  AspectType.square: 7,
  AspectType.trine: 7,
  AspectType.sesquiquadrate: 1.5,
  AspectType.quincunx: 2.5,
  AspectType.opposition: 9,
};

double aspectAngle(AspectType type) => _aspectAngle[type]!;
double aspectOrbLimit(AspectType type) => _defaultOrb[type]!;

bool isTenseAspect(AspectType type) {
  switch (type) {
    case AspectType.square:
    case AspectType.opposition:
    case AspectType.semiSquare:
    case AspectType.sesquiquadrate:
    case AspectType.quincunx:
      return true;
    case AspectType.conjunction:
    case AspectType.semiSextile:
    case AspectType.sextile:
    case AspectType.quintile:
    case AspectType.trine:
      return false;
  }
}

bool isHarmoniousAspect(AspectType type) {
  switch (type) {
    case AspectType.semiSextile:
    case AspectType.sextile:
    case AspectType.quintile:
    case AspectType.trine:
      return true;
    case AspectType.conjunction:
    case AspectType.semiSquare:
    case AspectType.square:
    case AspectType.sesquiquadrate:
    case AspectType.quincunx:
    case AspectType.opposition:
      return false;
  }
}

class Aspect {
  final Body a;
  final Body b;
  final AspectType type;
  final double orb; // 厳密角からのズレ（度）
  const Aspect(this.a, this.b, this.type, this.orb);
}

/// 2点間の最小角距離（0–180度）
double separation(double lon1, double lon2) {
  final d = (norm360(lon1) - norm360(lon2)).abs() % 360.0;
  return d > 180.0 ? 360.0 - d : d;
}

List<Aspect> findAspects(
  Map<Body, double> positions, {
  Map<AspectType, double> orbs = _defaultOrb,
}) {
  final bodies = positions.keys.toList();
  final result = <Aspect>[];
  for (var i = 0; i < bodies.length; i++) {
    for (var j = i + 1; j < bodies.length; j++) {
      final sep = separation(positions[bodies[i]]!, positions[bodies[j]]!);
      for (final type in AspectType.values) {
        final diff = (sep - _aspectAngle[type]!).abs();
        if (diff <= orbs[type]!) {
          result.add(Aspect(bodies[i], bodies[j], type, diff));
        }
      }
    }
  }
  return result;
}

List<Aspect> findDisplayAspects(Map<Body, double> positions, {int limit = 28}) {
  final aspects = findAspects(positions, orbs: _displayOrb);
  aspects.sort(
    (a, b) => _displayAspectScore(b).compareTo(_displayAspectScore(a)),
  );
  return aspects.take(limit).toList();
}

double _displayAspectScore(Aspect aspect) {
  final orbLimit = _displayOrb[aspect.type]!;
  final tight = (1 - (aspect.orb / orbLimit)).clamp(0.0, 1.0);
  final major = switch (aspect.type) {
    AspectType.conjunction ||
    AspectType.sextile ||
    AspectType.square ||
    AspectType.trine ||
    AspectType.opposition => 1.0,
    AspectType.quincunx => 0.74,
    AspectType.semiSextile ||
    AspectType.semiSquare ||
    AspectType.quintile ||
    AspectType.sesquiquadrate => 0.58,
  };
  return tight * major;
}

/// トランジット（当日天体）× ネイタル（出生天体）のアスペクト
List<Aspect> findTransitAspects(
  Map<Body, double> transit,
  Map<Body, double> natal, {
  Map<AspectType, double> orbs = _defaultOrb,
}) {
  final result = <Aspect>[];
  transit.forEach((tb, tlon) {
    natal.forEach((nb, nlon) {
      final sep = separation(tlon, nlon);
      for (final type in AspectType.values) {
        final diff = (sep - _aspectAngle[type]!).abs();
        if (diff <= orbs[type]!) {
          result.add(Aspect(tb, nb, type, diff));
        }
      }
    });
  });
  return result;
}

// ============================================================
// 出生図の組み立て [FINAL]
// ============================================================
class BodyPosition {
  final Body body;
  final double longitude; // 黄経（度）
  const BodyPosition(this.body, this.longitude);

  String get sign => signName(longitude);
  double get degInSign => degreeInSign(longitude);
}

class NatalChart {
  final double jd;
  final double latitude;
  final double longitudeEast;
  final Map<Body, double> positions;
  final Angles angles;
  final List<double> cusps;
  final List<Aspect> aspects;

  const NatalChart({
    required this.jd,
    required this.latitude,
    required this.longitudeEast,
    required this.positions,
    required this.angles,
    required this.cusps,
    required this.aspects,
  });
}

NatalChart buildNatalChart({
  required DateTime birthUtc,
  required double latitude,
  required double longitudeEast,
  EphemerisSource ephemeris = const LowPrecisionEphemeris(),
  List<Body> bodies = mvpBodies,
  HouseSystem houseSystem = HouseSystem.wholeSign,
}) {
  final jd = julianDayUtc(birthUtc);
  final positions = <Body, double>{
    for (final b in bodies) b: ephemeris.eclipticLongitude(b, jd),
  };
  final angles = computeAngles(
    jd: jd,
    latitude: latitude,
    longitudeEast: longitudeEast,
  );
  return NatalChart(
    jd: jd,
    latitude: latitude,
    longitudeEast: longitudeEast,
    positions: positions,
    angles: angles,
    cusps: houseCusps(angles: angles, system: houseSystem),
    aspects: findDisplayAspects(positions),
  );
}

// ============================================================
// 使い方の例 / 簡易検証ハーネス
//   実行: dart run astro_core.dart
//   出力を astro.com の同条件チャートと比較して、惑星/月テーブルの
//   [VERIFY] を潰すこと（太陽・ASC・MCは概ね一致するはず）。
// ============================================================
void main() {
  // 例: 1990-05-15 09:30 JST, 東京 (lat 35.68, lonE 139.69)
  final birthJst = DateTime(1990, 5, 15, 9, 30);
  final birthUtc = birthJst.subtract(const Duration(hours: 9)); // JST→UTC

  final chart = buildNatalChart(
    birthUtc: birthUtc,
    latitude: 35.6812,
    longitudeEast: 139.6917,
  );

  print('=== Natal Chart (検証用) ===');
  print('JD: ${chart.jd.toStringAsFixed(5)}');
  print(
    'ASC: ${signName(chart.angles.ascendant)} '
    '${degreeInSign(chart.angles.ascendant).toStringAsFixed(2)}°',
  );
  print(
    'MC : ${signName(chart.angles.midheaven)} '
    '${degreeInSign(chart.angles.midheaven).toStringAsFixed(2)}°',
  );
  print('--- 天体 ---');
  chart.positions.forEach((b, lon) {
    print(
      '${b.name.padRight(8)} ${signName(lon).padRight(4)} '
      '${degreeInSign(lon).toStringAsFixed(2)}°  (λ=${lon.toStringAsFixed(2)})',
    );
  });
  print('--- アスペクト ---');
  for (final a in chart.aspects) {
    print(
      '${a.a.name} - ${a.b.name}: ${a.type.name} '
      '(orb ${a.orb.toStringAsFixed(2)}°)',
    );
  }
}
