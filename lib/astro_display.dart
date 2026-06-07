// lib/astro_display.dart
//
// Presentation helpers for chart labels, aspect labels, and roast copy.

import 'astro_core.dart';
import 'astro_synastry.dart';

const astroSymbolFontFamily = 'AstroSymbols';
const astroSymbolFontFamilyFallback = <String>['AstroSymbols2'];

enum RoastLevel {
  mild('マイルド', 'MILD'),
  sharp('辛口', 'SHARP'),
  extraHot('直球', 'DIRECT');

  final String label;
  final String badge;
  const RoastLevel(this.label, this.badge);
}

const bodyJa = <Body, String>{
  Body.sun: '太陽',
  Body.moon: '月',
  Body.mercury: '水星',
  Body.venus: '金星',
  Body.mars: '火星',
  Body.jupiter: '木星',
  Body.saturn: '土星',
  Body.uranus: '天王星',
  Body.neptune: '海王星',
  Body.pluto: '冥王星',
};

const bodyGlyph = <Body, String>{
  Body.sun: '☀',
  Body.moon: '☽',
  Body.mercury: '☿',
  Body.venus: '♀',
  Body.mars: '♂',
  Body.jupiter: '♃',
  Body.saturn: '♄',
  Body.uranus: '♅',
  Body.neptune: '♆',
  Body.pluto: '♇',
};

const signGlyphs = <String>[
  '♈',
  '♉',
  '♊',
  '♋',
  '♌',
  '♍',
  '♎',
  '♏',
  '♐',
  '♑',
  '♒',
  '♓',
];

String bodyLabel(Body body) => bodyJa[body] ?? body.name;
String bodyMark(Body body) => bodyGlyph[body] ?? body.name.substring(0, 1);

String aspectGlyph(AspectType type) {
  switch (type) {
    case AspectType.conjunction:
      return '☌';
    case AspectType.semiSextile:
      return '⚺';
    case AspectType.semiSquare:
      return '∠';
    case AspectType.sextile:
      return '⚹';
    case AspectType.quintile:
      return 'Q';
    case AspectType.square:
      return '□';
    case AspectType.trine:
      return '△';
    case AspectType.sesquiquadrate:
      return '⚼';
    case AspectType.quincunx:
      return '⚻';
    case AspectType.opposition:
      return '☍';
  }
}

String aspectGlyphFontFamily(AspectType type) {
  switch (type) {
    case AspectType.square:
    case AspectType.trine:
      return 'AstroSymbols2';
    case AspectType.semiSquare:
    case AspectType.quintile:
      return 'AppText';
    case AspectType.conjunction:
    case AspectType.semiSextile:
    case AspectType.sextile:
    case AspectType.sesquiquadrate:
    case AspectType.quincunx:
    case AspectType.opposition:
      return astroSymbolFontFamily;
  }
}

List<String> aspectGlyphFontFamilyFallback(AspectType type) {
  switch (type) {
    case AspectType.square:
    case AspectType.trine:
      return const ['AppText', 'AstroSymbols'];
    case AspectType.semiSquare:
    case AspectType.quintile:
      return const ['AstroSymbols', 'AstroSymbols2'];
    case AspectType.conjunction:
    case AspectType.semiSextile:
    case AspectType.sextile:
    case AspectType.sesquiquadrate:
    case AspectType.quincunx:
    case AspectType.opposition:
      return astroSymbolFontFamilyFallback;
  }
}

double aspectGlyphSizeScale(AspectType type) {
  switch (type) {
    case AspectType.square:
    case AspectType.trine:
      return 0.82;
    case AspectType.quintile:
      return 0.92;
    case AspectType.conjunction:
    case AspectType.semiSextile:
    case AspectType.semiSquare:
    case AspectType.sextile:
    case AspectType.sesquiquadrate:
    case AspectType.quincunx:
    case AspectType.opposition:
      return 1;
  }
}

String aspectJa(AspectType type) {
  switch (type) {
    case AspectType.conjunction:
      return '重なる';
    case AspectType.semiSextile:
      return '小さく響く';
    case AspectType.semiSquare:
      return '小さく引っかかる';
    case AspectType.sextile:
      return 'ほどよく響く';
    case AspectType.quintile:
      return 'ひらめきを生む';
    case AspectType.square:
      return 'ぶつかる';
    case AspectType.trine:
      return '流れる';
    case AspectType.sesquiquadrate:
      return 'じわっと摩擦が出る';
    case AspectType.quincunx:
      return '調整を迫る';
    case AspectType.opposition:
      return '向き合う';
  }
}

String aspectShort(Aspect aspect) =>
    '${bodyLabel(aspect.a)} ${aspectJa(aspect.type)} ${bodyLabel(aspect.b)}';

String aspectPlainShort(Aspect aspect) =>
    '${bodyLabel(aspect.a)} ${aspectJa(aspect.type)} ${bodyLabel(aspect.b)}';

String placementLine(Body body, double longitude) {
  final sign = signName(longitude);
  final deg = degreeInSign(longitude).toStringAsFixed(1);
  return '${bodyLabel(body)} / $sign $deg°';
}

String categoryForNatalBody(Body body) {
  switch (body) {
    case Body.sun:
    case Body.jupiter:
      return '全体';
    case Body.moon:
      return '心の調子';
    case Body.venus:
      return '恋愛・対人';
    case Body.mercury:
    case Body.mars:
    case Body.saturn:
      return '仕事';
    default:
      return '全体';
  }
}

String roastCopy({
  required RoastLevel level,
  required Aspect? aspect,
  required String fallbackText,
}) {
  if (level == RoastLevel.mild || aspect == null) return fallbackText;
  final tense = isTenseAspect(aspect.type);
  final domain = categoryForNatalBody(aspect.b);
  if (level == RoastLevel.sharp) {
    return _sharpCopy(domain, aspect.a, tense);
  }
  return _extraHotCopy(domain, aspect.a, tense);
}

String _sharpCopy(String domain, Body transit, bool tense) {
  if (domain == '恋愛・対人') {
    return tense
        ? '相手の反応を読みすぎ。察してほしい顔をする前に、言葉を人間に戻して。'
        : '今日は感じよく動ける日。ただし愛想と迎合を混ぜると、あとで自分が面倒になります。';
  }
  if (domain == '仕事') {
    return tense
        ? '正論を投げるタイミングが雑。勝ちたいなら、まず段取りで勝って。'
        : '手を動かせば進む日。考えすぎを仕事してるふりに変換しないで。';
  }
  if (domain == '心の調子') {
    return tense
        ? '平気なふりが効きにくい日。休むのも判断のうちです。'
        : '気分は整いやすい日。余計な通知まで抱きしめなくていいです。';
  }
  return tense
      ? '今日は勢いで突破しようとすると雑さが出ます。急ぐほど、一回黙って確認して。'
      : '流れは悪くありません。いい感じの日ほど、調子に乗る前に足元を見て。';
}

String _extraHotCopy(String domain, Body transit, bool tense) {
  if (domain == '恋愛・対人') {
    return tense ? '言葉を出すか、期待を下ろすか。中間が一番しんどい。' : '魅力は出てる。全方位より、合う相手の方が燃費がいい。';
  }
  if (domain == '仕事') {
    return tense ? 'タスクが詰まる日。一個に絞れば、空回りが止まる。' : '動けば勝てる。脳内会議で出した気にならない。';
  }
  if (domain == '心の調子') {
    return tense ? '無理が積もる日。寝る・断る・離れる、選んでいい。' : '回復しやすい日。ざわつく場所からは距離。';
  }
  return tense ? '結論を先送りしてる日。一回小さく決めれば、視界が戻る。' : '追い風。遠慮しすぎると、機会損失。';
}

// ============================================================
// Synastry copy（相性画面用）
//
// 文体ルールは narration_spec.md §6.5 を踏襲：
//   - 動機の断定をしない、ケアを否定しない、命令を畳みかけない
//   - 関係を「裁断」せず「観察＋小さな行動」を出す
// ============================================================

String synastryHeadline(SynastryResult r, RoastLevel level) {
  final score = r.score;
  switch (level) {
    case RoastLevel.mild:
      if (score >= 0.65) return '響きが合いやすい二人です。自然な距離で深まっていきそう。';
      if (score <= 0.35) return '違いがはっきり出る二人。お互いを学び合える関係になりそう。';
      return 'うまく噛み合うところと、すれ違うところが混ざる二人。';
    case RoastLevel.sharp:
      if (score >= 0.65) return '基本構造が噛み合うペア。雑に扱わなければ伸びる関係。';
      if (score <= 0.35) return '構造的に摩擦が出やすいペア。違いを資産にするか負債にするかは扱い方次第。';
      return '噛み合いとズレが両方ある構造。両面が見えてる時点で扱いやすい。';
    case RoastLevel.extraHot:
      if (score >= 0.65) return '相性は強い。雑に育てれば、普通に壊れる。';
      if (score <= 0.35) return '摩擦の多いペア。逃げれば終わる、向き合えば深まる。二択。';
      return '混ざるペア。当たり前に向き合わないと、ぶれる。';
  }
}

String synastryAspectLine(SynastryAspect a, RoastLevel level) {
  // 天体グリフはカード上部の badge で既に表示されてるので本文には繰り返さない。
  // 本文は「この関係性が日常でどう感じられるか」を日常語で。
  final quality = _qualityOf(a.type);
  switch (level) {
    case RoastLevel.mild:
      return _synMild(quality);
    case RoastLevel.sharp:
      return _synSharp(quality);
    case RoastLevel.extraHot:
      return _synExtraHot(quality);
  }
}

String _qualityOf(AspectType t) {
  if (isHarmoniousAspect(t)) return 'harmony';
  if (isTenseAspect(t)) return 'tension';
  return 'emphasis';
}

String _synMild(String q) {
  if (q == 'harmony') {
    return '自然に分かり合いやすい部分です。お互いの心地よさが、関係を育ててくれそうです。';
  }
  if (q == 'tension') {
    return '価値観の違いが出やすい部分ですが、お互いを理解する手がかりにもなります。';
  }
  return 'お互いに強く影響を与え合う部分です。良くも悪くも、無視できない関係性。';
}

String _synSharp(String q) {
  if (q == 'harmony') {
    return '無理せず通じやすいライン。ここに頼りすぎると深まらない。';
  }
  if (q == 'tension') {
    return '摩擦が出やすい構造。ぶつかった時、逃げず観察に変えると意味になる。';
  }
  return '強く混ざる構造。良くも悪くも、無視できないライン。';
}

String _synExtraHot(String q) {
  if (q == 'harmony') {
    return '楽に通じる。慣れで雑にしない。';
  }
  if (q == 'tension') {
    return '構造的にぶつかる。避けるほど深まらない。';
  }
  return '濃く混ざる。記憶に残るライン。';
}
