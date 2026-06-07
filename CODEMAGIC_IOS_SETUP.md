# Codemagic iOSビルド

Macがなくても、CodemagicのmacOSビルドマシンでiOSのコンパイル、コード署名、IPA作成、App Store Connectへのアップロードができます。

## Apple Developerの有効化待ち中

1. このフォルダをGitHub、GitLab、またはBitbucketのリポジトリへ登録します。
2. Codemagicでそのリポジトリを追加します。
3. `codemagic.yaml`を検出させ、`ios-unsigned-check`を実行します。

このワークフローはAppleの証明書を使わず、iOSアプリがコンパイルできるか確認します。

`GoogleService-Info.plist`と`google-services.json`はCodemagicへ渡すため、リポジトリに含めます。これらはFirebaseのクライアント設定であり、サービスアカウント秘密鍵ではありません。保護はFirebase Security RulesとApp Checkで行います。

## Apple Developerが有効になった後

### 1. Apple側

1. Apple Developerで明示的App IDを作成します。
2. Bundle IDを`com.studioalveare.hoshimeguri`にします。
3. App Attestを有効にします。
4. App Store Connectで「星巡」のアプリレコードを作成します。

### 2. App Store Connect APIキー

App Store Connectの「ユーザとアクセス」からCodemagic専用APIキーを作成します。

- 名前: `codemagic`
- 権限: `App Manager`
- Issuer IDを控える
- Key IDを控える
- `.p8`をダウンロードして保管する

`.p8`は再ダウンロードできないため、紛失しないように保管します。

### 3. Codemagic

Codemagicの`Team settings > Integrations > Developer Portal`でApp Store Connect APIキーを追加します。

- Integration name: `codemagic`
- Issuer ID
- Key ID
- ダウンロードした`.p8`

`codemagic.yaml`の`ios_signing`を使い、Codemagicが証明書とプロビジョニングプロファイルを取得します。

App Attestを後から有効にした場合は、古いプロビジョニングプロファイルを使わず、新しく取得してください。

### 4. 実行時変数

CodemagicのEnvironment variablesで`app_runtime`グループを作成します。

- `AI_API_BASE_URL`: Cloud RunのURL
- `REVENUECAT_IOS_API_KEY`: RevenueCatのiOS Public SDK Key

OpenAI APIキーやRevenueCatのSecret APIキーは登録しません。これらはCloud RunのSecret Managerだけで管理します。

### 5. TestFlight

`ios-testflight`を実行します。最初はIPAを作成してApp Store Connectへアップロードしますが、TestFlightベータ審査やApp Store審査には自動提出しません。アップロード結果を確認後、必要に応じて`codemagic.yaml`の次の値を変更してTestFlightベータ審査への自動提出を有効にします。

```yaml
submit_to_testflight: true
submit_to_app_store: false
```
