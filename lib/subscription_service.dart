// lib/subscription_service.dart
//
// サブスクリプション状態の管理。AppSettings.subscriptionState を読み書きする
// 薄いラッパ。
//
// RevenueCatの公開SDKキーが設定済みならストア課金を使う。
// 開発用スタブはデバッグビルドでのみ利用できる。

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'ai_platform_service.dart';
import 'app_database.dart';

enum SubscriptionState { none, active, trial, expired }

const bool _allowDevSubscriptionStub = bool.fromEnvironment(
  'ALLOW_DEV_SUBSCRIPTION_STUB',
  defaultValue: true,
);

bool get devSubscriptionStubEnabled => kDebugMode && _allowDevSubscriptionStub;

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

  Future<Map<SubscriptionPlan, String>> priceLabels() async {
    if (!platform.revenueCatConfigured) return const {};
    try {
      final current = (await Purchases.getOfferings()).current;
      if (current == null) return const {};
      return {
        if (current.monthly != null)
          SubscriptionPlan.monthly: current.monthly!.storeProduct.priceString,
        if (current.annual != null)
          SubscriptionPlan.yearly: current.annual!.storeProduct.priceString,
      };
    } on Object {
      return const {};
    }
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

    if (!devSubscriptionStubEnabled) return false;

    // デバッグビルドで明示的に許可した場合だけ開発用スタブを使う。
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

  /// デバッグ時のゲーティング再検証用。
  Future<void> devResetToFree() async {
    if (platform.revenueCatConfigured || !devSubscriptionStubEnabled) return;
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
