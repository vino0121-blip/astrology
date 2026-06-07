// lib/subscription_service.dart
//
// サブスクリプション状態の管理。AppSettings.subscriptionState を読み書きする
// 薄いラッパ。
//
// RevenueCatの公開SDKキーが設定済みならストア課金を使い、未設定中だけ
// 従来の開発用スタブでゲーティングのUXを確認できる。

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'ai_platform_service.dart';
import 'app_database.dart';

enum SubscriptionState { none, active, trial, expired }

enum SubscriptionPlan {
  monthly('monthly', '月額プラン', 550),
  yearly('yearly', '年額プラン', 5500);

  final String id;
  final String label;
  final int priceJpy;
  const SubscriptionPlan(this.id, this.label, this.priceJpy);
}

class SubscriptionService {
  final AppDatabase db;
  final AiPlatformService platform;
  SubscriptionService(this.db, this.platform);

  Future<SubscriptionState> currentState() async {
    if (platform.revenueCatConfigured) {
      try {
        final info = await Purchases.getCustomerInfo();
        final entitled = info.entitlements.active.containsKey('premium');
        await _storePaidState(entitled);
        return entitled ? SubscriptionState.active : SubscriptionState.none;
      } on Object {
        // オフライン時は端末に保存した直近の状態を返す。
      }
    }
    final s = await db.getSettings();
    return SubscriptionState.values.firstWhere(
      (e) => e.name == s.subscriptionState,
      orElse: () => SubscriptionState.none,
    );
  }

  Future<bool> get isPaid async {
    final s = await currentState();
    return s == SubscriptionState.active || s == SubscriptionState.trial;
  }

  Future<bool> purchase(SubscriptionPlan plan) async {
    if (platform.revenueCatConfigured) {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) return false;
      final package = plan == SubscriptionPlan.monthly
          ? current.monthly
          : current.annual;
      if (package == null) return false;
      try {
        final result = await Purchases.purchase(
          PurchaseParams.package(package),
        );
        final entitled = result.customerInfo.entitlements.active.containsKey(
          'premium',
        );
        await _storePaidState(entitled);
        return entitled;
      } on PlatformException catch (error) {
        final code = PurchasesErrorHelper.getErrorCode(error);
        if (code == PurchasesErrorCode.purchaseCancelledError) return false;
        rethrow;
      }
    }

    // ストア未設定中は従来の開発用スタブを維持する。
    await db.updateSettings(
      AppSettingsCompanion(
        subscriptionState: const Value('active'),
        adsDisabledByPurchase: const Value(true),
      ),
    );
    return true;
  }

  Future<bool> restorePurchases() async {
    if (platform.revenueCatConfigured) {
      final info = await Purchases.restorePurchases();
      final entitled = info.entitlements.active.containsKey('premium');
      await _storePaidState(entitled);
      return entitled;
    }
    return (await currentState()) == SubscriptionState.active;
  }

  /// PHASE 1 限定：ゲーティング再検証のための無料に戻すボタン用。
  /// PHASE 2 で削除（本番では絶対に呼ばれてはいけない）。
  Future<void> devResetToFree() async {
    if (platform.revenueCatConfigured) return;
    await _storePaidState(false);
  }

  Future<void> _storePaidState(bool entitled) async {
    await db.updateSettings(
      AppSettingsCompanion(
        subscriptionState: Value(entitled ? 'active' : 'none'),
        adsDisabledByPurchase: Value(entitled),
      ),
    );
  }
}
