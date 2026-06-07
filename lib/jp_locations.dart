// lib/jp_locations.dart
//
// 出生地選択用：日本の47都道府県＋代表座標（都道府県庁所在地）。
//
// 精度：0.01°（約1km）で、占星術用途には十分。
// 注：本番リリース前に正式な出典（国土地理院など）と突き合わせ推奨。
// 拡張：市区町村レベルが必要になったら、JSONアセットを別途用意して
// このリストの置き換え／統合ができる構造。

class JpPrefecture {
  final String name;
  final double lat;
  final double lon; // 東経
  const JpPrefecture(this.name, this.lat, this.lon);
}

const List<JpPrefecture> kJpPrefectures = [
  JpPrefecture('北海道', 43.06, 141.35),
  JpPrefecture('青森県', 40.82, 140.74),
  JpPrefecture('岩手県', 39.70, 141.15),
  JpPrefecture('宮城県', 38.27, 140.87),
  JpPrefecture('秋田県', 39.72, 140.10),
  JpPrefecture('山形県', 38.24, 140.36),
  JpPrefecture('福島県', 37.75, 140.47),
  JpPrefecture('茨城県', 36.34, 140.45),
  JpPrefecture('栃木県', 36.57, 139.88),
  JpPrefecture('群馬県', 36.39, 139.06),
  JpPrefecture('埼玉県', 35.86, 139.65),
  JpPrefecture('千葉県', 35.61, 140.12),
  JpPrefecture('東京都', 35.68, 139.69),
  JpPrefecture('神奈川県', 35.45, 139.64),
  JpPrefecture('新潟県', 37.90, 139.02),
  JpPrefecture('富山県', 36.70, 137.21),
  JpPrefecture('石川県', 36.59, 136.63),
  JpPrefecture('福井県', 36.07, 136.22),
  JpPrefecture('山梨県', 35.66, 138.57),
  JpPrefecture('長野県', 36.65, 138.18),
  JpPrefecture('岐阜県', 35.39, 136.72),
  JpPrefecture('静岡県', 34.98, 138.38),
  JpPrefecture('愛知県', 35.18, 136.91),
  JpPrefecture('三重県', 34.73, 136.51),
  JpPrefecture('滋賀県', 35.00, 135.87),
  JpPrefecture('京都府', 35.02, 135.76),
  JpPrefecture('大阪府', 34.69, 135.50),
  JpPrefecture('兵庫県', 34.69, 135.18),
  JpPrefecture('奈良県', 34.69, 135.83),
  JpPrefecture('和歌山県', 34.23, 135.17),
  JpPrefecture('鳥取県', 35.50, 134.24),
  JpPrefecture('島根県', 35.47, 133.05),
  JpPrefecture('岡山県', 34.66, 133.93),
  JpPrefecture('広島県', 34.40, 132.46),
  JpPrefecture('山口県', 34.19, 131.47),
  JpPrefecture('徳島県', 34.07, 134.56),
  JpPrefecture('香川県', 34.34, 134.04),
  JpPrefecture('愛媛県', 33.84, 132.77),
  JpPrefecture('高知県', 33.56, 133.53),
  JpPrefecture('福岡県', 33.61, 130.42),
  JpPrefecture('佐賀県', 33.25, 130.30),
  JpPrefecture('長崎県', 32.74, 129.87),
  JpPrefecture('熊本県', 32.79, 130.74),
  JpPrefecture('大分県', 33.24, 131.61),
  JpPrefecture('宮崎県', 31.91, 131.42),
  JpPrefecture('鹿児島県', 31.56, 130.56),
  JpPrefecture('沖縄県', 26.21, 127.68),
];