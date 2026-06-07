// astro_service.dart
//
// 統合サービス層：エンジン × 辞書 × 組み立て × DB を一本化するオーケストレータ。
// UI からは `getTodayReading()` を呼ぶだけで、キャッシュ判定→必要なら計算→保存→
// DailyReading 返却まで完結する。
//
// 典型的なアプリ起動時の組み立て例（main.dart 等）:
//
//   import 'package:flutter/services.dart';
//   ...
//   final db = AppDatabase(openConnection());
//   final json = await rootBundle.loadString('assets/theme_dictionary.json');
//   final dict = ThemeDictionary.fromJsonString(json);
//   final service = AstroService(
//     db: db,
//     ephemeris: const LowPrecisionEphemeris(),
//     dictionary: dict,
//   );
//
// pubspec.yaml に下記の追加が必要：
//   flutter:
//     assets:
//       - assets/theme_dictionary.json

import 'package:drift/drift.dart';

import 'astro_core.dart';
import 'astro_narration.dart';
import 'astro_synastry.dart';
import 'app_database.dart';

class AstroService {
  final AppDatabase db;
  final EphemerisSource ephemeris;
  final ThemeDictionary dictionary;

  AstroService({
    required this.db,
    required this.ephemeris,
    required this.dictionary,
  });

  // ==========================================================
  // ユーザー / オンボーディング
  // ==========================================================

  /// ユーザー登録済みか
  Future<bool> hasUser() async => (await db.getCurrentUser()) != null;

  Future<UserProfile?> currentUser() => db.getCurrentUser();

  /// オンボーディング画面からの保存。
  /// - `birthLocal` は入力の現地日時。
  /// - `birthTimeUnknown=true` のときは内部で 12:00 を採用する。
  /// - 保存時に既存の出生図 / 日次キャッシュは自動破棄される（app_database 側の処理）。
  Future<int> saveUserBirthData({
    String? displayName,
    required DateTime birthLocal,
    required bool birthTimeUnknown,
    required String birthPlaceName,
    required double latitude,
    required double longitudeEast,
    int timezoneOffsetMinutes = 540, // JST 既定
  }) async {
    final adjustedLocal = birthTimeUnknown
        ? DateTime(birthLocal.year, birthLocal.month, birthLocal.day, 12, 0)
        : birthLocal;
    final utc = adjustedLocal.subtract(
      Duration(minutes: timezoneOffsetMinutes),
    );
    return db.upsertUser(
      UserProfilesCompanion(
        displayName: Value(displayName),
        birthUtc: Value(utc),
        birthLocalIso: Value(adjustedLocal.toIso8601String()),
        birthTimeUnknown: Value(birthTimeUnknown),
        birthPlaceName: Value(birthPlaceName),
        latitude: Value(latitude),
        longitudeEast: Value(longitudeEast),
        timezoneOffsetMinutes: Value(timezoneOffsetMinutes),
      ),
    );
  }

  // ==========================================================
  // 出生図（キャッシュ優先）
  // ==========================================================

  /// 有効なキャッシュがあればそれを使い、無ければ計算して保存する。
  Future<NatalChart?> resolveNatalChart() async {
    final user = await db.getCurrentUser();
    if (user == null) return null;

    final cached = await db.getValidChartCache(user.id);
    if (cached != null) {
      return _reconstructNatalChart(user, cached);
    }

    final chart = buildNatalChart(
      birthUtc: user.birthUtc,
      latitude: user.latitude,
      longitudeEast: user.longitudeEast,
      ephemeris: ephemeris,
      houseSystem: HouseSystem.wholeSign,
    );

    await db.saveChartCache(
      NatalChartCachesCompanion(
        userProfileId: Value(user.id),
        jd: Value(chart.jd),
        positions: Value(chart.positions),
        ascendant: Value(chart.angles.ascendant),
        midheaven: Value(chart.angles.midheaven),
        cusps: Value(chart.cusps),
        aspects: Value(chart.aspects),
        houseSystem: const Value('wholeSign'),
        ephemerisVersion: const Value(kEphemerisVersion),
      ),
    );

    return chart;
  }

  NatalChart _reconstructNatalChart(UserProfile user, NatalChartCache c) =>
      NatalChart(
        jd: c.jd,
        latitude: user.latitude,
        longitudeEast: user.longitudeEast,
        positions: c.positions,
        angles: Angles(c.ascendant, c.midheaven),
        cusps: c.cusps,
        aspects: findDisplayAspects(c.positions),
      );

  // ==========================================================
  // 日次運勢（キャッシュ優先）  ← UI の主要API
  // ==========================================================

  /// 「今日の運勢」を返す。ユーザー未登録なら null（UI 側はオンボーディングへ）。
  /// 同じローカル暦日内なら最初の1回だけ計算、以降はDBキャッシュから返す。
  Future<DailyReading?> getTodayReading({DateTime? now}) async {
    final user = await db.getCurrentUser();
    if (user == null) return null;

    final nowLocal = now ?? DateTime.now();
    final localDate = _formatLocalDate(nowLocal);

    final cached = await db.getDailyReading(
      userId: user.id,
      localDate: localDate,
    );
    if (cached != null) {
      await _touchLastSeen(localDate);
      return _reconstructDailyReading(cached, nowLocal);
    }

    final natal = await resolveNatalChart();
    if (natal == null) return null;

    final transit = computeTransitPositions(nowLocal.toUtc(), ephemeris);
    final reading = buildDailyReading(
      dateLocalForDisplay: nowLocal,
      natal: natal,
      transitPositions: transit,
      dict: dictionary,
      chartId: 'user-${user.id}',
    );

    final categoryTexts = <String, String>{
      for (final e in reading.byCategory.entries) e.key: e.value.text,
    };
    await db.saveDailyReading(
      DailyReadingCachesCompanion(
        userProfileId: Value(user.id),
        localDate: Value(localDate),
        overallHeadline: Value(reading.overallHeadline),
        overallScore: Value(reading.overallScore),
        categoryTexts: Value(categoryTexts),
        dictionaryVersion: const Value(kDictionaryVersion),
        ephemerisVersion: const Value(kEphemerisVersion),
      ),
    );

    await _touchLastSeen(localDate);
    return reading;
  }

  DailyReading _reconstructDailyReading(
    DailyReadingCache c,
    DateTime nowLocal,
  ) {
    final byCategory = <String, DailyReadingItem>{
      for (final e in c.categoryTexts.entries)
        e.key: DailyReadingItem(e.key, e.value, const []),
    };
    return DailyReading(
      dateLocal: nowLocal,
      overallHeadline: c.overallHeadline,
      overallScore: c.overallScore,
      byCategory: byCategory,
    );
  }

  // ==========================================================
  // 設定 / ハウスキーピング
  // ==========================================================

  /// 起動時に1度呼ぶ：Settings 初期化＋古いキャッシュ掃除。
  Future<void> warmup() async {
    await db.getSettings();
    await db.pruneOldDailyReadings(keepDays: 30);
  }

  Future<void> _touchLastSeen(String localDate) async {
    await db.updateSettings(
      AppSettingsCompanion(lastSeenLocalDate: Value(localDate)),
    );
  }

  // ==========================================================
  // 辛口モードの永続化（最後の選択を次回起動時にも復元）
  // ==========================================================

  /// 設定からRoastLevel文字列（'mild'/'sharp'/'extraHot'）を取得
  Future<String> getRoastLevel() async {
    final s = await db.getSettings();
    return s.roastLevel;
  }

  Future<void> setRoastLevel(String level) async {
    await db.updateSettings(AppSettingsCompanion(roastLevel: Value(level)));
  }

  // ==========================================================
  // 相性（パートナーCRUD のラッパー）— v1 簡易版
  // ==========================================================

  Future<List<Partner>> listPartners() async {
    final u = await db.getCurrentUser();
    if (u == null) return const [];
    return db.listPartners(u.id);
  }

  Future<bool> canAddPartner({required bool isPaid}) async {
    final u = await db.getCurrentUser();
    if (u == null) return false;
    return db.canAddPartner(userId: u.id, isPaid: isPaid);
  }

  Future<int?> addPartner({
    required String name,
    required DateTime birthLocal,
    required bool birthTimeUnknown,
    required String birthPlaceName,
    required double latitude,
    required double longitudeEast,
    int timezoneOffsetMinutes = 540,
    String relationship = 'other',
  }) async {
    final u = await db.getCurrentUser();
    if (u == null) return null;
    final adjusted = birthTimeUnknown
        ? DateTime(birthLocal.year, birthLocal.month, birthLocal.day, 12, 0)
        : birthLocal;
    final utc = adjusted.subtract(Duration(minutes: timezoneOffsetMinutes));
    return db.insertPartner(
      PartnersCompanion(
        userProfileId: Value(u.id),
        name: Value(name),
        birthUtc: Value(utc),
        birthLocalIso: Value(adjusted.toIso8601String()),
        birthTimeUnknown: Value(birthTimeUnknown),
        birthPlaceName: Value(birthPlaceName),
        latitude: Value(latitude),
        longitudeEast: Value(longitudeEast),
        timezoneOffsetMinutes: Value(timezoneOffsetMinutes),
        relationship: Value(relationship),
      ),
    );
  }

  Future<void> deletePartner(int id) => db.deletePartner(id);

  // ==========================================================
  // カレンダー画面用：月間スコア一括計算
  // ==========================================================

  /// 指定月の各日のオーバースコア(0..1)を返す。キー = 月内日付(1始まり)。
  /// 1日あたり計算 ~5ms × 30 = ~150ms。ユーザー未登録なら空マップ。
  Future<Map<int, double>> computeMonthlyScores(DateTime month) async {
    final user = await db.getCurrentUser();
    if (user == null) return {};
    final natal = await resolveNatalChart();
    if (natal == null) return {};

    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final out = <int, double>{};
    for (var d = 1; d <= daysInMonth; d++) {
      final dt = DateTime(month.year, month.month, d, 12, 0);
      final transit = computeTransitPositions(dt.toUtc(), ephemeris);
      final reading = buildDailyReading(
        dateLocalForDisplay: dt,
        natal: natal,
        transitPositions: transit,
        dict: dictionary,
        chartId: 'user-${user.id}',
      );
      out[d] = reading.overallScore;
    }
    return out;
  }

  /// 任意日の DailyReading を返す。今日ならキャッシュ優先、他日は毎回計算。
  Future<DailyReading?> getReadingForDate(DateTime localDate) async {
    final user = await db.getCurrentUser();
    if (user == null) return null;
    final natal = await resolveNatalChart();
    if (natal == null) return null;

    final today = DateTime.now();
    final isToday =
        localDate.year == today.year &&
        localDate.month == today.month &&
        localDate.day == today.day;
    if (isToday) return getTodayReading(now: localDate);

    final transit = computeTransitPositions(
      DateTime(localDate.year, localDate.month, localDate.day, 12, 0).toUtc(),
      ephemeris,
    );
    return buildDailyReading(
      dateLocalForDisplay: localDate,
      natal: natal,
      transitPositions: transit,
      dict: dictionary,
      chartId: 'user-${user.id}',
    );
  }

  /// 任意日の主役アスペクトを返す（重み降順1件）。詳細パネル用。
  Future<Aspect?> getHeroAspectForDate(DateTime localDate) async {
    final natal = await resolveNatalChart();
    if (natal == null) return null;
    final transit = computeTransitPositions(
      DateTime(localDate.year, localDate.month, localDate.day, 12, 0).toUtc(),
      ephemeris,
    );
    final aspects = findTransitAspects(transit, natal.positions);
    if (aspects.isEmpty) return null;
    // 同じ重みロジックを使うため astro_narration の関数を呼べないので、簡易版で代用：
    // tightest orb × 主要天体優先、で十分（厳密一致は astro_narration 内部に保持）
    aspects.sort((a, b) => a.orb.compareTo(b.orb));
    return aspects.first;
  }

  /// 指定の相手と本人の相性を計算して返す。本人未登録なら null。
  /// 相手の出生図はその場で計算（synastry は軽いのでキャッシュ不要、
  /// 必要になれば DB に NatalChartCache と同じ構造で乗せる）。
  Future<SynastryResult?> computeCompatibility(int partnerId) async {
    final userChart = await resolveNatalChart();
    if (userChart == null) return null;
    final partner = await db.getPartner(partnerId);
    if (partner == null) return null;
    final partnerChart = buildNatalChart(
      birthUtc: partner.birthUtc,
      latitude: partner.latitude,
      longitudeEast: partner.longitudeEast,
      ephemeris: ephemeris,
      houseSystem: HouseSystem.wholeSign,
    );
    return computeSynastry(userChart, partnerChart);
  }

  // ==========================================================
  // ユーティリティ
  // ==========================================================

  static String _formatLocalDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, "0")}-${d.day.toString().padLeft(2, "0")}';
}
