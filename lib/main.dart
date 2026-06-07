// lib/main.dart
//
// 起動シーケンス：
//   1. WidgetsFlutterBinding.ensureInitialized()
//   2. SQLite を path_provider で開いて AppDatabase を作る
//   3. theme_dictionary.json をアセットから読み込んで ThemeDictionary 化
//   4. AstroService.warmup() で設定初期化＋古いキャッシュ掃除
//   5. ProviderScope に override を渡して runApp
//
// UI 側からは ref.watch(astroServiceProvider) で AstroService が取れる。

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'app.dart';
import 'app_database.dart';
import 'ai_diagnosis_service.dart';
import 'ai_platform_service.dart';
import 'astro_engine_vsop.dart';
import 'astro_narration.dart';
import 'astro_service.dart';
import 'subscription_service.dart';

// ============================================================
// Providers
// ============================================================

/// アプリ起動時に main() で override される（DB インスタンス本体）。
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('overridden in main()');
});

/// 同じく main() で override される（辞書ロード済みインスタンス）。
final dictionaryProvider = Provider<ThemeDictionary>((ref) {
  throw UnimplementedError('overridden in main()');
});

final aiPlatformServiceProvider = Provider<AiPlatformService>((ref) {
  throw UnimplementedError('overridden in main()');
});

final aiDiagnosisServiceProvider = Provider<AiDiagnosisService>((ref) {
  return AiDiagnosisService(ref.watch(aiPlatformServiceProvider));
});

/// 統合サービス。DB と辞書から組み立てる。
final astroServiceProvider = Provider<AstroService>((ref) {
  return AstroService(
    db: ref.watch(databaseProvider),
    ephemeris: const Vsop87Ephemeris(),
    dictionary: ref.watch(dictionaryProvider),
  );
});

/// 現在ユーザーの取得（未登録なら null）。
final currentUserProvider = FutureProvider<UserProfile?>((ref) async {
  final svc = ref.watch(astroServiceProvider);
  return svc.currentUser();
});

/// 今日の運勢（未登録なら null）。
final todayReadingProvider = FutureProvider<DailyReading?>((ref) async {
  final svc = ref.watch(astroServiceProvider);
  return svc.getTodayReading();
});

/// サブスクリプション。Phase 1 はスタブ実装、Phase 2 で RevenueCat に置換。
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService(
    ref.watch(databaseProvider),
    ref.watch(aiPlatformServiceProvider),
  );
});

/// 有料状態。purchase/restore/reset 後に invalidate して再評価する。
final isPaidProvider = FutureProvider<bool>((ref) async {
  return ref.watch(subscriptionServiceProvider).isPaid;
});

// ============================================================
// 起動
// ============================================================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();

  // 1. SQLite 接続
  final docsDir = await getApplicationDocumentsDirectory();
  final dbFile = File(p.join(docsDir.path, 'astro_app.sqlite'));
  final db = AppDatabase(NativeDatabase.createInBackground(dbFile));

  final aiPlatform = AiPlatformService();
  await aiPlatform.initialize();

  // 2. テンプレ辞書の読み込み
  final jsonStr = await rootBundle.loadString('assets/theme_dictionary.json');
  final dict = ThemeDictionary.fromJsonString(jsonStr);

  // 3. ウォームアップ（Settings 初期化＋古いキャッシュ掃除）
  final bootService = AstroService(
    db: db,
    ephemeris: const Vsop87Ephemeris(),
    dictionary: dict,
  );
  await bootService.warmup();

  // 4. 起動
  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        dictionaryProvider.overrideWithValue(dict),
        aiPlatformServiceProvider.overrideWithValue(aiPlatform),
      ],
      child: const AstroApp(),
    ),
  );
}
