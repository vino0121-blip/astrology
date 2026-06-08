// app_database.dart
//
// ローカル中心のデータ層（Drift / SQLite）。
//
// ┌─ pubspec の追加（参考）────────────────────────────────────┐
// │ dependencies:                                                │
// │   drift: ^2.18.0                                             │
// │   sqlite3_flutter_libs: ^0.5.0                               │
// │   path: ^1.9.0                                               │
// │   path_provider: ^2.1.0                                      │
// │ dev_dependencies:                                            │
// │   drift_dev: ^2.18.0                                         │
// │   build_runner: ^2.4.0                                       │
// └──────────────────────────────────────────────────────────────┘
//
// 生成: `dart run build_runner build`
// その後 `app_database.g.dart` が自動生成される。
//
// 設計上のポイント：
//  - 出生図キャッシュには `ephemerisVersion` を持たせる。エンジン精度を
//    上げた（惑星テーブル差し替え等）ときに自動で再計算される。
//  - 日次運勢キャッシュには `dictionaryVersion` を持たせる。テンプレ辞書
//    を更新したら同様に自動で再生成される。
//  - 無料/有料のパートナー保存数制限はリポジトリ層で判定（購読状態は
//    RevenueCat → Settings に同期される想定）。

import 'dart:convert';
import 'package:drift/drift.dart';
import 'astro_core.dart';

part 'app_database.g.dart';

// ============================================================
// バージョン定数
// ============================================================
/// エンジン（天体計算）のバージョン。出生図キャッシュ無効化用。
/// vsop87-planets-0.2: Astronomy Engine の VSOP87 切り詰めテーブルを移植
///   （惑星6天体＋Sun は ≤0.5分角精度、Moon は ±0.05°の Meeus 簡約のまま）
const String kEphemerisVersion = 'vsop87-planets-0.2';

/// テンプレ辞書のバージョン。日次キャッシュ無効化用。
const String kDictionaryVersion = '0.3-score-range';

/// 無料枠：パートナー保存数の上限
const int kFreeMaxPartners = 1;

// ============================================================
// 型コンバータ（JSON テキスト ↔ ドメイン型）
// ============================================================

/// Map<Body, double> ⇔ JSON
class BodyMapConverter extends TypeConverter<Map<Body, double>, String> {
  const BodyMapConverter();

  @override
  Map<Body, double> fromSql(String fromDb) {
    final raw = (jsonDecode(fromDb) as Map).cast<String, dynamic>();
    final out = <Body, double>{};
    for (final e in raw.entries) {
      final b = _bodyByName(e.key);
      if (b == null) continue;
      out[b] = (e.value as num).toDouble();
    }
    return out;
  }

  @override
  String toSql(Map<Body, double> value) =>
      jsonEncode({for (final e in value.entries) e.key.name: e.value});
}

/// List<double>（ハウスカスプ）⇔ JSON
class DoubleListConverter extends TypeConverter<List<double>, String> {
  const DoubleListConverter();
  @override
  List<double> fromSql(String fromDb) =>
      (jsonDecode(fromDb) as List).map((e) => (e as num).toDouble()).toList();
  @override
  String toSql(List<double> value) => jsonEncode(value);
}

/// List<Aspect> ⇔ JSON  （[aName, bName, typeName, orb] のタプル列）
class AspectListConverter extends TypeConverter<List<Aspect>, String> {
  const AspectListConverter();
  @override
  List<Aspect> fromSql(String fromDb) {
    final raw = jsonDecode(fromDb) as List;
    final out = <Aspect>[];
    for (final t in raw) {
      final l = t as List;
      final a = _bodyByName(l[0] as String);
      final b = _bodyByName(l[1] as String);
      final type = _aspectByName(l[2] as String);
      if (a == null || b == null || type == null) continue;
      out.add(Aspect(a, b, type, (l[3] as num).toDouble()));
    }
    return out;
  }

  @override
  String toSql(List<Aspect> value) => jsonEncode([
    for (final a in value) [a.a.name, a.b.name, a.type.name, a.orb],
  ]);
}

/// Map<String, String>（カテゴリ別文章）⇔ JSON
class StringMapConverter extends TypeConverter<Map<String, String>, String> {
  const StringMapConverter();
  @override
  Map<String, String> fromSql(String fromDb) =>
      (jsonDecode(fromDb) as Map).cast<String, String>();
  @override
  String toSql(Map<String, String> value) => jsonEncode(value);
}

Body? _bodyByName(String n) {
  for (final b in Body.values) {
    if (b.name == n) return b;
  }
  return null;
}

AspectType? _aspectByName(String n) {
  for (final t in AspectType.values) {
    if (t.name == n) return t;
  }
  return null;
}

// ============================================================
// テーブル
// ============================================================

/// ユーザー本人の出生情報（MVP は単一行運用、設計上は複数可）
class UserProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get displayName => text().nullable()();

  /// 出生時刻（UTC、JD計算用）
  DateTimeColumn get birthUtc => dateTime()();

  /// 表示用：現地日時の文字列（"1990-05-15T09:30"）
  TextColumn get birthLocalIso => text()();

  /// 出生時刻が不明か（true のとき内部で 12:00 を使用、ASC/ハウスは注意付き表示）
  BoolColumn get birthTimeUnknown =>
      boolean().withDefault(const Constant(false))();

  /// 表示用の出生地名（"東京都" など）
  TextColumn get birthPlaceName => text()();

  RealColumn get latitude => real()();
  RealColumn get longitudeEast => real()();

  /// UTCからの分単位オフセット（JST=+540）
  IntColumn get timezoneOffsetMinutes => integer()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// 出生図の計算結果キャッシュ（ユーザーごとに 1 行）
class NatalChartCaches extends Table {
  IntColumn get userProfileId =>
      integer().references(UserProfiles, #id, onDelete: KeyAction.cascade)();

  RealColumn get jd => real()();
  TextColumn get positions => text().map(const BodyMapConverter())();
  RealColumn get ascendant => real()();
  RealColumn get midheaven => real()();
  TextColumn get cusps => text().map(const DoubleListConverter())();
  TextColumn get aspects => text().map(const AspectListConverter())();

  /// 'wholeSign' / 'equal'
  TextColumn get houseSystem => text()();

  /// 計算したエンジンのバージョン（差分があれば再計算）
  TextColumn get ephemerisVersion => text()();
  DateTimeColumn get generatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {userProfileId};
}

/// 相性診断の相手データ
class Partners extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userProfileId =>
      integer().references(UserProfiles, #id, onDelete: KeyAction.cascade)();

  TextColumn get name => text()();
  DateTimeColumn get birthUtc => dateTime()();
  TextColumn get birthLocalIso => text()();
  BoolColumn get birthTimeUnknown =>
      boolean().withDefault(const Constant(false))();
  TextColumn get birthPlaceName => text()();
  RealColumn get latitude => real()();
  RealColumn get longitudeEast => real()();
  IntColumn get timezoneOffsetMinutes => integer()();

  /// 'lover' / 'friend' / 'family' / 'work' / 'other'
  TextColumn get relationship => text().withDefault(const Constant('other'))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// 日次運勢のキャッシュ（ユーザー × ローカル暦日 で一意）
class DailyReadingCaches extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userProfileId =>
      integer().references(UserProfiles, #id, onDelete: KeyAction.cascade)();

  /// その日のローカル暦日（"2026-06-02"）
  TextColumn get localDate => text()();

  TextColumn get overallHeadline => text()();
  RealColumn get overallScore => real()();

  /// カテゴリ → 文章
  TextColumn get categoryTexts => text().map(const StringMapConverter())();

  /// 生成時の辞書バージョン（差分があれば再生成）
  TextColumn get dictionaryVersion => text()();

  /// 生成時のエンジンバージョン
  TextColumn get ephemerisVersion => text()();

  DateTimeColumn get generatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {userProfileId, localDate},
  ];
}

class AiDiagnosisCaches extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 'daily' / 'monthly'
  TextColumn get type => text()();

  /// daily: yyyy-MM-dd, monthly: yyyy-MM
  TextColumn get period => text()();

  /// Birth data + calculated input JSON. If birth time/place changes, this key changes.
  TextColumn get payloadKey => text()();

  TextColumn get resultJson => text()();
  DateTimeColumn get generatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {type, period, payloadKey},
  ];
}

/// アプリ設定（id=1 のシングルトン運用）
class AppSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();

  BoolColumn get notificationsEnabled =>
      boolean().withDefault(const Constant(true))();

  /// 通知時刻（"08:00"）
  TextColumn get dailyNotificationTimeLocal =>
      text().withDefault(const Constant('08:00'))();

  /// 'system' / 'light' / 'dark'
  TextColumn get themePreference =>
      text().withDefault(const Constant('system'))();

  /// 'mild' / 'sharp' / 'extraHot'
  TextColumn get roastLevel => text().withDefault(const Constant('mild'))();

  /// 'none' / 'active' / 'expired' / 'trial'
  /// 起動時に RevenueCat から同期
  TextColumn get subscriptionState =>
      text().withDefault(const Constant('none'))();
  BoolColumn get adsDisabledByPurchase =>
      boolean().withDefault(const Constant(false))();

  /// 最後にアプリを開いたローカル暦日（"日次運勢が更新されたか"の判定用）
  TextColumn get lastSeenLocalDate => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================
// データベース本体
// ============================================================
@DriftDatabase(
  tables: [
    UserProfiles,
    NatalChartCaches,
    Partners,
    DailyReadingCaches,
    AiDiagnosisCaches,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(appSettings, appSettings.roastLevel);
      }
      if (from < 3) {
        await m.createTable(aiDiagnosisCaches);
      }
    },
  );

  // --- UserProfile ---

  Future<UserProfile?> getCurrentUser() async {
    final rows = await (select(userProfiles)..limit(1)).get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<int> upsertUser(UserProfilesCompanion u) async {
    final existing = await getCurrentUser();
    if (existing == null) {
      return into(userProfiles).insert(u);
    } else {
      final next = u.copyWith(
        id: Value(existing.id),
        updatedAt: Value(DateTime.now()),
      );
      await (update(
        userProfiles,
      )..where((t) => t.id.equals(existing.id))).write(next);
      // 出生情報が変わったらキャッシュを破棄
      await (delete(
        natalChartCaches,
      )..where((t) => t.userProfileId.equals(existing.id))).go();
      await (delete(
        dailyReadingCaches,
      )..where((t) => t.userProfileId.equals(existing.id))).go();
      await delete(aiDiagnosisCaches).go();
      return existing.id;
    }
  }

  // --- NatalChartCache ---

  /// キャッシュが有効ならそれを返す。期限切れ/未生成なら null。
  Future<NatalChartCache?> getValidChartCache(int userId) async {
    final row =
        await (select(natalChartCaches)..where(
              (t) =>
                  t.userProfileId.equals(userId) &
                  t.ephemerisVersion.equals(kEphemerisVersion),
            ))
            .getSingleOrNull();
    return row;
  }

  Future<void> saveChartCache(NatalChartCachesCompanion c) async {
    await into(natalChartCaches).insert(c, mode: InsertMode.insertOrReplace);
  }

  // --- Partners ---

  Future<List<Partner>> listPartners(int userId) =>
      (select(partners)..where((t) => t.userProfileId.equals(userId))).get();

  Future<Partner?> getPartner(int partnerId) => (select(
    partners,
  )..where((t) => t.id.equals(partnerId))).getSingleOrNull();

  Future<int> countPartners(int userId) async {
    final q = selectOnly(partners)
      ..addColumns([partners.id.count()])
      ..where(partners.userProfileId.equals(userId));
    final row = await q.getSingle();
    return row.read(partners.id.count()) ?? 0;
  }

  /// 無料/有料を踏まえた追加可否チェック
  Future<bool> canAddPartner({
    required int userId,
    required bool isPaid,
  }) async {
    if (isPaid) return true;
    final n = await countPartners(userId);
    return n < kFreeMaxPartners;
  }

  Future<int> insertPartner(PartnersCompanion p) => into(partners).insert(p);

  Future<void> deletePartner(int id) =>
      (delete(partners)..where((t) => t.id.equals(id))).go();

  // --- DailyReadingCache ---

  Future<DailyReadingCache?> getDailyReading({
    required int userId,
    required String localDate,
  }) async {
    return (select(dailyReadingCaches)..where(
          (t) =>
              t.userProfileId.equals(userId) &
              t.localDate.equals(localDate) &
              t.dictionaryVersion.equals(kDictionaryVersion) &
              t.ephemerisVersion.equals(kEphemerisVersion),
        ))
        .getSingleOrNull();
  }

  Future<void> saveDailyReading(DailyReadingCachesCompanion d) async {
    await into(dailyReadingCaches).insert(d, mode: InsertMode.insertOrReplace);
  }

  /// 古い日次キャッシュの掃除（30日より前を削除）
  Future<void> pruneOldDailyReadings({int keepDays = 30}) async {
    final cutoff = DateTime.now().subtract(Duration(days: keepDays));
    await (delete(
      dailyReadingCaches,
    )..where((t) => t.generatedAt.isSmallerThanValue(cutoff))).go();
  }

  // --- AI diagnosis cache ---

  Future<AiDiagnosisCache?> getAiDiagnosisCache({
    required String type,
    required String period,
    required String payloadKey,
  }) {
    return (select(aiDiagnosisCaches)
          ..where(
            (t) =>
                t.type.equals(type) &
                t.period.equals(period) &
                t.payloadKey.equals(payloadKey),
          )
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> saveAiDiagnosisCache({
    required String type,
    required String period,
    required String payloadKey,
    required String resultJson,
  }) {
    return into(aiDiagnosisCaches).insert(
      AiDiagnosisCachesCompanion(
        type: Value(type),
        period: Value(period),
        payloadKey: Value(payloadKey),
        resultJson: Value(resultJson),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  // --- Settings ---

  Future<AppSetting> getSettings() async {
    final row = await (select(appSettings)..limit(1)).getSingleOrNull();
    if (row != null) return row;
    // 初期行を作る
    await into(appSettings).insert(const AppSettingsCompanion(id: Value(1)));
    return (select(appSettings)..limit(1)).getSingle();
  }

  Future<void> updateSettings(AppSettingsCompanion patch) async {
    await getSettings();
    await (update(appSettings)..where((t) => t.id.equals(1))).write(patch);
  }
}

// ============================================================
// 接続作成のテンプレ（実機ではこちらを使う）
// ============================================================
//
// import 'package:drift/native.dart';
// import 'package:path/path.dart' as p;
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';
//
// LazyDatabase openConnection() {
//   return LazyDatabase(() async {
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File(p.join(dir.path, 'astro_app.sqlite'));
//     return NativeDatabase.createInBackground(file);
//   });
// }
//
// // 使い方:
// // final db = AppDatabase(openConnection());
