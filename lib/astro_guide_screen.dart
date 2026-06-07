import 'package:flutter/material.dart';

import 'ad_banner.dart';
import 'ad_gate.dart';
import 'aspect_mark.dart';
import 'astro_core.dart';

class AstroGuideScreen extends StatelessWidget {
  const AstroGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('用語・記号ガイド'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: '天体'),
              Tab(text: 'ハウス'),
              Tab(text: 'アスペクト'),
              Tab(text: '月相'),
            ],
          ),
        ),
        body: const SafeArea(
          child: TabBarView(
            children: [
              _PlanetGuide(),
              _HouseGuide(),
              _AspectGuide(),
              _MoonGuide(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanetGuide extends StatelessWidget {
  const _PlanetGuide();

  @override
  Widget build(BuildContext context) {
    const rows = [
      ('太陽', '自分らしさ、意思、人生の軸'),
      ('月', '感情、安心感、素の反応'),
      ('水星', '考え方、言葉、学び方'),
      ('金星', '好きなもの、恋愛、美意識'),
      ('火星', '行動力、怒り、勝負の仕方'),
      ('木星', '広がり、幸運、成長の方向'),
      ('土星', '課題、責任、時間をかけて強くなる場所'),
      ('天王星', '変化、独立、突然の切り替わり'),
      ('海王星', '夢、直感、境界がゆるむ場所'),
      ('冥王星', '深い変化、執着、根本から変わる力'),
    ];
    return _GuideList(
      intro: '天体は「何が働いているか」を表します。',
      children: [
        for (final row in rows) _GuideRow(title: row.$1, body: row.$2),
      ],
    );
  }
}

class _HouseGuide extends StatelessWidget {
  const _HouseGuide();

  @override
  Widget build(BuildContext context) {
    const rows = [
      ('第1ハウス', '第一印象・自分らしさ'),
      ('第2ハウス', 'お金・持ち物・安心感'),
      ('第3ハウス', '会話・学び・近い人間関係'),
      ('第4ハウス', '家・土台・心の居場所'),
      ('第5ハウス', '恋・遊び・自己表現'),
      ('第6ハウス', '仕事の習慣・健康管理'),
      ('第7ハウス', '対人関係・パートナーシップ'),
      ('第8ハウス', '深い関係・共有・変化'),
      ('第9ハウス', '遠くの世界・専門性・信念'),
      ('第10ハウス', '社会的な顔・キャリア'),
      ('第11ハウス', '仲間・未来計画・コミュニティ'),
      ('第12ハウス', '無意識・休息・見えない支え'),
    ];
    return _GuideList(
      intro: 'ハウスは「人生のどの場所で出るか」を表します。',
      children: [
        for (final row in rows) _GuideRow(title: row.$1, body: row.$2),
      ],
    );
  }
}

class _AspectGuide extends StatelessWidget {
  const _AspectGuide();

  @override
  Widget build(BuildContext context) {
    const rows = [
      (AspectType.conjunction, '重なる', '強調。良くも悪くもそのテーマが目立つ。'),
      (AspectType.semiSextile, '小さく助け合う', '少し意識すると使える補助的なつながり。'),
      (AspectType.semiSquare, '小さく引っかかる', '軽い違和感。放置すると地味に気になる調整点。'),
      (AspectType.sextile, 'ほどよく響く', '使いやすい追い風。小さく動くほど活きる。'),
      (AspectType.quintile, 'ひらめく', '工夫やセンスとして出やすい創造的なつながり。'),
      (AspectType.square, 'ぶつかる', '摩擦。課題は出るが、行動のきっかけにもなる。'),
      (AspectType.trine, '流れる', '自然にできること。楽に進みやすい。'),
      (AspectType.sesquiquadrate, 'じわっと刺激する', '強すぎないが無視しにくい摩擦。改善のサイン。'),
      (AspectType.quincunx, '調整を迫る', '噛み合わない部分を直すサイン。'),
      (AspectType.opposition, '向き合う', '相手や外側を通して気づくテーマ。'),
    ];
    final scheme = Theme.of(context).colorScheme;
    return _GuideList(
      intro: 'アスペクトは「天体同士の関係性」です。',
      children: [
        for (final row in rows)
          Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => _showGuideDetail(context, row.$2, row.$3),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Row(
                  children: [
                    AspectMark(type: row.$1, color: scheme.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _GuideRowContent(title: row.$2, body: row.$3),
                    ),
                    const Icon(Icons.chevron_right, size: 18),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MoonGuide extends StatelessWidget {
  const _MoonGuide();

  @override
  Widget build(BuildContext context) {
    const rows = [
      ('新月', '始まり。決める、仕込む、習慣を作るタイミング。'),
      ('上弦の月', '調整。始めたことに手を入れて前へ進める時期。'),
      ('満月', '結果や気づき。見えてきたものを受け取るタイミング。'),
      ('下弦の月', '整理。手放す、減らす、次に備える時期。'),
      ('天体移動', '天体が星座を移ること。空気感やテーマが切り替わる目安。'),
    ];
    return _GuideList(
      intro: '月相や天体移動は、日々の流れを読む目安になります。',
      children: [
        for (final row in rows) _GuideRow(title: row.$1, body: row.$2),
      ],
    );
  }
}

class _GuideList extends StatelessWidget {
  final String intro;
  final List<Widget> children;
  const _GuideList({required this.intro, required this.children});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        Text(
          intro,
          style: TextStyle(
            fontSize: 13.5,
            height: 1.6,
            color: scheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 12),
        ...children,
        const SizedBox(height: 12),
        const AdGate(child: AppBannerAd()),
      ],
    );
  }
}

class _GuideRow extends StatelessWidget {
  final String title;
  final String body;
  const _GuideRow({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showGuideDetail(context, title, body),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            children: [
              Expanded(
                child: _GuideRowContent(title: title, body: body),
              ),
              const Icon(Icons.chevron_right, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _GuideRowContent extends StatelessWidget {
  final String title;
  final String body;
  const _GuideRowContent({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        Text(
          body,
          style: TextStyle(
            fontSize: 13.5,
            height: 1.55,
            color: scheme.onSurface.withValues(alpha: 0.72),
          ),
        ),
      ],
    );
  }
}

void _showGuideDetail(BuildContext context, String title, String body) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => _GuideDetailSheet(
      title: title,
      body: body,
      detail: _guideDetail(title),
    ),
  );
}

class _GuideDetailSheet extends StatelessWidget {
  final String title;
  final String body;
  final String detail;
  const _GuideDetailSheet({
    required this.title,
    required this.body,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: TextStyle(
                color: scheme.primary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Text(detail, style: const TextStyle(fontSize: 14.5, height: 1.75)),
          ],
        ),
      ),
    );
  }
}

String _guideDetail(String title) {
  switch (title) {
    case '太陽':
      return 'その人が「こうありたい」と感じる中心です。日々の気分というより、人生の方向性や自分らしく立つ感覚に近いです。';
    case '月':
      return '安心したい時の反応や、疲れた時に戻りたくなる場所です。月が乱れると気分に出やすいので、休み方を見る時に大事です。';
    case '水星':
      return '話し方、考え方、情報の扱い方です。仕事の進め方や連絡の癖にも出ます。';
    case '金星':
      return '好きなもの、心地よさ、人との楽しみ方です。恋愛だけでなく、美意識やお金の使い方にも関わります。';
    case '火星':
      return '行動を起こす力です。怒り方、勝負の仕方、欲しいものへ向かう勢いとして出ます。';
    case '木星':
      return '広げる力です。チャンスを受け取る場所ですが、広げすぎると雑になることもあります。';
    case '土星':
      return '時間をかけて鍛える場所です。苦手意識として出やすい一方、続けるほど信頼や武器になります。';
    case '天王星':
      return '変化と自由の場所です。突然切り替わる感覚や、人と違う選択をしたくなる部分に出ます。';
    case '海王星':
      return '夢、直感、曖昧さの場所です。想像力として使えますが、境界がぼやけることもあります。';
    case '冥王星':
      return '根本から変える力です。軽く流せないこだわりや、人生で何度も向き合う深いテーマとして出ます。';
    case '第1ハウス':
      return '自分自身の入口です。第一印象、始め方、自然に外へ出る雰囲気を見ます。ホロスコープでここをタップした時は、あなたの見せ方の癖を見ています。';
    case '第2ハウス':
      return '安心をどう作るかの場所です。お金、持ち物、才能、自分の価値をどう感じるかに関わります。';
    case '第3ハウス':
      return '身近な学びと会話の場所です。話し方、情報収集、近い人とのやり取りに出ます。';
    case '第4ハウス':
      return '心の土台です。家、家族、帰る場所、安心して力を抜ける環境を見ます。';
    case '第5ハウス':
      return '喜びを外へ出す場所です。恋、遊び、創作、推し活、自分が楽しいと感じる表現に関わります。';
    case '第6ハウス':
      return '毎日の整え方です。働き方、習慣、健康管理、役割として引き受けることを見ます。';
    case '第7ハウス':
      return '一対一の関係です。恋人、配偶者、契約相手など、相手と向き合う時の癖が出ます。';
    case '第8ハウス':
      return '深く共有する場所です。信頼、親密さ、共有財産、簡単には切れない関係性に関わります。';
    case '第9ハウス':
      return '遠くへ広げる場所です。旅、専門的な学び、哲学、信念、自分の世界を広げることに出ます。';
    case '第10ハウス':
      return '社会的な顔です。キャリア、肩書き、外からどう見られるか、目標として形にしたいことを見ます。';
    case '第11ハウス':
      return '仲間と未来の場所です。友人、コミュニティ、チーム、これから作りたい世界に関わります。';
    case '第12ハウス':
      return '見えない心の奥です。休息、無意識、ひとり時間、言葉にしにくい感情の整理に関わります。';
    case '重なる':
      return '2つの天体が同じ方向を向く状態です。そのテーマが強く出ます。良い悪いより「目立つ」と考えると分かりやすいです。';
    case '小さく助け合う':
      return '大きな追い風ではありませんが、少し意識すると助けになる関係です。自然にできる小さな工夫として出ます。';
    case '小さく引っかかる':
      return '大事件ではないけれど、なんとなく噛み合わない感覚です。早めに直すほど、後のストレスを減らせます。';
    case 'ほどよく響く':
      return '自然に助け合う関係です。何もしなくても少し流れますが、小さく行動するとさらに使いやすくなります。';
    case 'ひらめく':
      return '人と違う発想やセンスとして出やすい関係です。効率よりも、工夫や表現の面で使いやすいです。';
    case 'ぶつかる':
      return '摩擦が出る関係です。しんどさもありますが、動く理由や成長のきっかけになりやすい配置です。';
    case '流れる':
      return 'スムーズに使える関係です。得意なこととして出やすい一方、当たり前すぎて自覚しにくいこともあります。';
    case 'じわっと刺激する':
      return '強い衝突ではありませんが、放っておくとじわじわ気になる配置です。生活の細部を見直すサインになります。';
    case '調整を迫る':
      return 'そのままだと噛み合いにくい関係です。生活リズムや距離感を少し直すことで使いやすくなります。';
    case '向き合う':
      return '外側や相手を通して気づく関係です。対立ではなく、鏡のように自分のテーマが見えます。';
    case '新月':
      return 'まだ形は見えないけれど、始まりの種を置く時期です。大きな結果を求めるより、まず決める・仕込むのに向きます。';
    case '上弦の月':
      return '始めたことに現実的な調整が入る時期です。迷ったら、続けるために何を直すかを見ます。';
    case '満月':
      return '結果や感情が見えやすい時期です。達成だけでなく、もう十分なものを手放す判断にも向きます。';
    case '下弦の月':
      return '整理と見直しの時期です。増やすより減らす、次の新月に向けて余白を作るタイミングです。';
    case '天体移動':
      return '天体が星座を移ることで、空気感やテーマが切り替わります。星模様アラートでは、あなたのどのハウスに影響するかも見ます。';
    default:
      return 'ホロスコープを読むための基本用語です。単体で覚えるより、あなたの出生図や今日の星模様の中で見ると使いやすくなります。';
  }
}
