# RevenueCat 統合手順（Phase 2）

Phase 1 ではDartコード側のUI・ゲーティング・状態管理を全部スタブで動かしてる。
Phase 2 は実際の課金フローを RevenueCat 経由で繋ぐ。

`subscription_service.dart` の **public API は変わらない** ので、呼び出し側
（paywall_screen、compatibility_screen、ad_gate）は一切触らない。中身だけ
RevenueCat の API に差し替える。

---

## 段階1：アカウント・ストア・RevenueCatの設定

### 1.1 RevenueCatアカウント

https://app.revenuecat.com/ で Google アカウントでサインアップ。
無料枠：月間収益 $2,500 まで無料、それ以降は1%手数料。MVPなら当面無料。

### 1.2 App Store Connect で商品登録（iOS）

App Store Connect → 自分のアプリ → 「App内課金」 → 「サブスクリプション」

1. **サブスクリプショングループ**を作成（例：`premium`）
2. グループ内に2つの商品を作成：
   - **月額**：プロダクトID `premium_monthly_550`、価格 ¥550
   - **年額**：プロダクトID `premium_yearly_5500`、価格 ¥5,500
3. 各商品にローカライズ名・説明を入れる（日本語必須）
4. 商品状態を「審査の準備完了」に

※ プロダクトIDはなんでも良いが、後で RevenueCat 側でも同じ文字列で登録する。

### 1.3 Google Play Console で商品登録（Android）

Play Console → アプリ → 「収益化」 → 「定期購入」

1. 定期購入を作成：
   - 商品ID `premium_monthly_550`、月額 ¥550
   - 商品ID `premium_yearly_5500`、年額 ¥5,500
2. 各商品の「基本プラン」「オファー」を設定（基本プランだけでOK）
3. 商品をアクティブ化

※ Play は最初に **アプリの内部テスト版を1度アップロード**しないと
定期購入の登録ができない。AABを `flutter build appbundle` で作って、
Play Console の「内部テスト」トラックにアップする手順が先。

### 1.4 RevenueCat でアプリを登録

RevenueCat ダッシュボード → 「Project settings」 → 「Apps」

1. **iOS アプリを追加**：Bundle ID（例 `com.example.astrology_app`）と
   App Store Connect のApp-Specific Shared Secret（App Store Connect →
   ユーザーとアクセス → キー → 共有秘密キー）を入力
2. **Android アプリを追加**：Package name と、Google Play の Service Account
   credentials（JSON）をアップロード

### 1.5 RevenueCat で Products / Entitlements / Offerings

「Products」：ストアで作った商品をRevenueCat側にも登録
- iOS: プロダクトID `premium_monthly_550` を Apple Store と紐付け
- iOS: プロダクトID `premium_yearly_5500` を Apple Store と紐付け
- Android: 同様に2つ登録

「Entitlements」：機能の単位を定義
- `premium`（または好きな名前）を1つ作って、上記4つのproduct全部を紐付け
- → このエンタイトルメントが active かどうかでアプリ側は判定する

「Offerings」：表示するパッケージのセット
- `default` offering を作って、その中に2つの Package を入れる：
  - `$rc_monthly`：premium_monthly_550（iOS）+ premium_monthly_550（Android）
  - `$rc_annual`：premium_yearly_5500（iOS）+ premium_yearly_5500（Android）

### 1.6 API キー取得

「Project settings」 → 「API keys」
- iOS用：`appl_xxxxx...`
- Android用：`goog_xxxxx...`

両方コピーしておく。

---

## 段階2：Flutterに purchases_flutter を導入

### 2.1 `pubspec.yaml`

```yaml
dependencies:
  # ...既存...
  purchases_flutter: ^8.1.0
```

```
flutter pub get
```

### 2.2 `lib/main.dart` で初期化

```dart
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:io' show Platform;

// テスト用の判定（本番はsecure storageかenv経由で渡すのが推奨）
const _kRevenueCatApiKeyIOS = 'appl_xxxxxxxxxxxxxxxx';
const _kRevenueCatApiKeyAndroid = 'goog_xxxxxxxxxxxxxxxx';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();  // 既存

  // RevenueCat 初期化
  await Purchases.setLogLevel(LogLevel.warn);
  final configuration = PurchasesConfiguration(
    Platform.isIOS ? _kRevenueCatApiKeyIOS : _kRevenueCatApiKeyAndroid,
  );
  await Purchases.configure(configuration);

  // ...既存のDB・dict・warmup・runApp...
}
```

### 2.3 `lib/subscription_service.dart` を本実装に差し替え

stub だった purchase / restorePurchases を RevenueCat の呼び出しに置換。
**publicインターフェース（メソッド名・引数・戻り値）はそのまま**なので
呼び出し側は無修正。

```dart
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:drift/drift.dart';
import 'app_database.dart';

// ... enum SubscriptionState / SubscriptionPlan は既存のまま ...

const _kEntitlementId = 'premium';  // RevenueCat側で作ったentitlement名

class SubscriptionService {
  final AppDatabase db;
  SubscriptionService(this.db);

  Future<SubscriptionState> currentState() async {
    try {
      final info = await Purchases.getCustomerInfo();
      final entitled = info.entitlements.active.containsKey(_kEntitlementId);
      final state = entitled ? 'active' : 'none';
      // DB側にも同期（オフライン時の参照用キャッシュ）
      await db.updateSettings(AppSettingsCompanion(
        subscriptionState: Value(state),
        adsDisabledByPurchase: Value(entitled),
      ));
      return SubscriptionState.values.firstWhere(
        (e) => e.name == state,
        orElse: () => SubscriptionState.none,
      );
    } catch (_) {
      // オフライン等：DBのキャッシュを返す
      final s = await db.getSettings();
      return SubscriptionState.values.firstWhere(
        (e) => e.name == s.subscriptionState,
        orElse: () => SubscriptionState.none,
      );
    }
  }

  Future<bool> get isPaid async {
    final s = await currentState();
    return s == SubscriptionState.active || s == SubscriptionState.trial;
  }

  Future<bool> purchase(SubscriptionPlan plan) async {
    final offerings = await Purchases.getOfferings();
    final current = offerings.current;
    if (current == null) return false;

    final pkg = plan == SubscriptionPlan.monthly
        ? current.monthly
        : current.annual;
    if (pkg == null) return false;

    try {
      final info = await Purchases.purchasePackage(pkg);
      final entitled = info.entitlements.active.containsKey(_kEntitlementId);
      if (entitled) {
        await db.updateSettings(const AppSettingsCompanion(
          subscriptionState: Value('active'),
          adsDisabledByPurchase: Value(true),
        ));
      }
      return entitled;
    } on PlatformException catch (e) {
      // ユーザーキャンセルは正常系
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) return false;
      rethrow;
    }
  }

  Future<bool> restorePurchases() async {
    final info = await Purchases.restorePurchases();
    final entitled = info.entitlements.active.containsKey(_kEntitlementId);
    await db.updateSettings(AppSettingsCompanion(
      subscriptionState: Value(entitled ? 'active' : 'none'),
      adsDisabledByPurchase: Value(entitled),
    ));
    return entitled;
  }

  // ★ devResetToFree は削除すること（本番に残してはいけない）
}
```

### 2.4 paywall_screen.dart の Dev ボタン削除

`_buildPaidView()` の末尾にある「Dev：無料に戻す」TextButton と
`_devResetToFree()` メソッドを削除。

---

## 段階3：テスト

### 3.1 iOS Sandbox

1. App Store Connect → ユーザーとアクセス → Sandbox → Apple Sandbox Tester を1つ作成
2. iPhone実機の「設定 → App Store → Sandboxアカウント」でログイン
3. アプリ起動 → paywall → 購入 → Apple のシート出てサンドボックスアカウントで「購入」
4. 即時で課金完了扱い、料金は発生しない
5. 12分（月額）/ 1時間（年額）でサブスク更新が走る → 5回更新で自動キャンセル
   （Apple のサンドボックス仕様）

### 3.2 Android Internal Testing

1. Play Console → 内部テスト → テスター追加（Googleアカウント）
2. テスターにオプトインリンクを送って「インストール」を承諾
3. アプリ起動 → paywall → 購入 → ライセンスが「テスト」扱いになる
4. テストカードで購入完了、料金発生せず
5. 「設定 → 定期購入」でいつでもキャンセル可能

注意：
- Android は **必ず Play 経由でインストールしたAPK**じゃないとテスト購入できない
  （Android Studio から直接インストールしたものは不可）。`flutter build appbundle`
  でAABを作って Play Console にアップロード → 内部テストトラックから配信。
- iOS Simulator では購入できない、実機必須

### 3.3 RevenueCat ダッシュボードで確認

Customers タブで購入したテスターのデータが見える。Active subscription 表示と
イベントログ（purchase, renewal, cancellation など）を確認。

---

## 段階4：リリース前チェックリスト

- [ ] `devResetToFree` 削除済み
- [ ] iOS: 「App内課金」が App Store Connect で承認待ち→承認済み
- [ ] iOS: アプリレビュー時に**自動更新サブスクの説明文**が必要
      （アプリ説明欄、規約画面、アプリ内表示など）
- [ ] Android: 定期購入が「アクティブ」状態
- [ ] アプリ内に **利用規約 / プライバシーポリシー / 解約手順** へのリンク表示
      （これがないとAppleで100%リジェクト）
- [ ] サブスクの自動更新を明記（「自動的に更新されます」「いつでもキャンセル可能」）
- [ ] 解約方法を案内（iOS: 設定 → Apple ID → サブスクリプション、
      Android: Play Store → 定期購入）
- [ ] RevenueCat ダッシュボードで本番イベントが流れることを確認

---

## トラブルシューティング

### `There is no singleton instance...`
→ `Purchases.configure(...)` を呼ぶ前に他のRevenueCat APIを呼んでる。
main.dart で `await` で完了を待ってから他処理を実行する。

### 「サブスクリプション情報を取得できません」
→ ストア側で商品が「準備完了」「アクティブ」になっていない可能性。
App Store Connect / Play Console で商品状態を再確認。

### iOS Sandbox で購入できない
→ 「設定」のAppleIDではなく「設定 → App Store → Sandboxアカウント」で
ログインする必要がある。本番Apple IDのままだと購入できない。

### `purchases_flutter` インポートで Gradle エラー
→ Android の minSdk が低すぎる可能性。`android/app/build.gradle` で
`minSdk 24` 以上に。