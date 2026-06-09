# 星巡 AI診断セットアップ

アプリ内にOpenAIのAPIキーを置かず、Cloud Run経由で今日・月間のAI診断を生成する構成です。
未設定、通信失敗、上限到達時は端末内のルール診断へ自動的に戻ります。

## 構成

- Firebase匿名認証: ユーザーごとの非推測UID
- Firebase App Check: 改造アプリや単純な外部呼び出しを抑制
- RevenueCat: バックエンドでも`premium` entitlementを確認
- Firestore: 同一診断のキャッシュ、日次生成回数、同時生成ロック
- OpenAI Responses API: Structured Outputsで画面用JSONを生成
- Cloud Run: APIキーとRevenueCat secretをSecret Managerから参照

出生日時、出生地、本名はOpenAIへ送信しません。アプリ内で計算済みのスコア、アスペクト、
重要日、既存の行動案だけを送ります。

## 1. Windows設定

Flutterプラグイン作成にsymlinkが必要です。

```powershell
start ms-settings:developers
```

「開発者モード」を有効にしてから、プロジェクトで以下を実行します。

```powershell
flutter pub get
```

## 2. Firebase

1. Firebase Consoleでプロジェクトを作成
2. Authenticationで「匿名」を有効化
3. Firestoreを本番モードで作成
4. Android/iOSアプリをFirebaseへ追加
5. FlutterFire CLIを導入してプロジェクト直下で実行

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

6. App CheckでAndroidはPlay Integrity、iOSはApp Attestを登録
7. デバッグ時はアプリログに出るApp Check debug tokenをFirebase Consoleへ登録

## 3. RevenueCat

1. entitlement IDを`premium`で作成
2. RevenueCat SDK用の公開キーをiOS/Androidそれぞれ取得
3. Secret API keyを作成。これはCloud Runだけに保存
4. アプリはFirebase UIDをRevenueCat App User IDとして使用

ストア商品、Offering、Entitlementの作成は`revenuecat_integration.md`も参照してください。

## 4. OpenAI

OpenAI Platformで本番用Projectを作成し、Project API keyを発行します。
キーはFlutterへ入れず、Google Secret Managerへ保存します。

```powershell
gcloud secrets create openai-api-key --replication-policy=automatic
gcloud secrets versions add openai-api-key --data-file=-

gcloud secrets create revenuecat-secret-api-key --replication-policy=automatic
gcloud secrets versions add revenuecat-secret-api-key --data-file=-
```

## 5. Cloud Runへデプロイ

Google CloudでFirestoreとCloud Run APIを有効化し、`backend`からデプロイします。

```powershell
gcloud run deploy hoshimeguri-ai `
  --source backend `
  --region asia-northeast1 `
  --allow-unauthenticated `
  --set-secrets OPENAI_API_KEY=openai-api-key:latest,REVENUECAT_SECRET_API_KEY=revenuecat-secret-api-key:latest `
  --set-env-vars OPENAI_MODEL=gpt-5.4-mini,REVENUECAT_ENTITLEMENT_ID=premium,REQUIRE_APP_CHECK=true,ALLOW_TEST_PREMIUM=false,MAX_DAILY_REGENERATIONS_AFTER_PROFILE_CHANGE=1,MAX_MONTHLY_GENERATIONS_PER_DAY=3
```

Cloud Run自体は公開URLですが、各診断リクエストはFirebase ID token、App Check、
RevenueCat entitlementの3段階で拒否されます。

日次AI診断は日本時間0時に回数をリセットします。通常生成1回に加えて、
出生情報を変更した後の再生成を
`MAX_DAILY_REGENERATIONS_AFTER_PROFILE_CHANGE` 回まで許可します。
同じ出生情報のまま文体などを変更しても再生成枠は使えず、
異なる出生情報に対してのみ再生成できます。

Cloud Runの実行サービスアカウントには、最低限以下を付与します。

- `Cloud Datastore User`
- `Secret Manager Secret Accessor`

## 6. アプリの実行

Cloud Run URLとRevenueCat公開SDKキーを`dart-define`で渡します。

```powershell
flutter run `
  --dart-define=AI_API_BASE_URL=https://YOUR-CLOUD-RUN-URL `
  --dart-define=REVENUECAT_ANDROID_API_KEY=goog_xxxxx `
  --dart-define=REVENUECAT_IOS_API_KEY=appl_xxxxx `
  --dart-define=USE_DEBUG_APP_CHECK=true
```

リリースビルドでは`USE_DEBUG_APP_CHECK`を渡さないでください。

```powershell
flutter build appbundle `
  --dart-define=AI_API_BASE_URL=https://YOUR-CLOUD-RUN-URL `
  --dart-define=REVENUECAT_ANDROID_API_KEY=goog_xxxxx `
  --dart-define=REVENUECAT_IOS_API_KEY=appl_xxxxx
```

## 7. デプロイ前チェック

- `ALLOW_TEST_PREMIUM=false`
- `REQUIRE_APP_CHECK=true`
- OpenAIとRevenueCatのsecretがFlutterやGitへ入っていない
- RevenueCatの公開SDKキーだけを`dart-define`で渡している
- Firebase UIDとRevenueCat App User IDが一致
- Firestoreの`aiDiagnosisCache`と`aiUsage`へ書き込みがある
- 同じ日・同じ月を再表示すると`cached: true`になる
- 無料ユーザーのAPIが`403 premium_required`になる
- OpenAI停止時にも端末診断が表示される
