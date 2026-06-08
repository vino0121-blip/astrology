import 'dart:io';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'firebase_options.dart';

const aiApiBaseUrl = String.fromEnvironment('AI_API_BASE_URL');
const revenueCatAndroidApiKey = String.fromEnvironment(
  'REVENUECAT_ANDROID_API_KEY',
);
const revenueCatIosApiKey = String.fromEnvironment('REVENUECAT_IOS_API_KEY');
const useDebugAppCheck = bool.fromEnvironment(
  'USE_DEBUG_APP_CHECK',
  defaultValue: false,
);
const skipAiAppCheck = bool.fromEnvironment(
  'SKIP_AI_APP_CHECK',
  defaultValue: false,
);

class AiPlatformService {
  bool _initialized = false;
  bool _revenueCatConfigured = false;
  Object? _initializationError;

  bool get apiConfigured => aiApiBaseUrl.trim().isNotEmpty;
  bool get platformConfigured =>
      apiConfigured ||
      revenueCatAndroidApiKey.isNotEmpty ||
      revenueCatIosApiKey.isNotEmpty;
  bool get initialized => _initialized;
  bool get revenueCatConfigured => _revenueCatConfigured;
  Object? get initializationError => _initializationError;

  Future<void> initialize() async {
    if (!platformConfigured) return;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      if (!skipAiAppCheck) {
        await FirebaseAppCheck.instance.activate(
          providerAndroid: useDebugAppCheck
              ? const AndroidDebugProvider()
              : const AndroidPlayIntegrityProvider(),
          providerApple: useDebugAppCheck
              ? const AppleDebugProvider()
              : const AppleAppAttestWithDeviceCheckFallbackProvider(),
        );
      }

      final auth = FirebaseAuth.instance;
      final user = auth.currentUser ?? (await auth.signInAnonymously()).user;
      if (user == null) {
        throw StateError('Firebase anonymous authentication failed.');
      }

      await _configureRevenueCat(user.uid);
      _initialized = true;
    } catch (error) {
      _initializationError = error;
      debugPrint('AI platform initialization failed: $error');
    }
  }

  Future<void> _configureRevenueCat(String uid) async {
    final key = Platform.isIOS
        ? revenueCatIosApiKey
        : Platform.isAndroid
        ? revenueCatAndroidApiKey
        : '';
    if (key.isEmpty) return;

    await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.warn);
    final configuration = PurchasesConfiguration(key)..appUserID = uid;
    await Purchases.configure(configuration);
    _revenueCatConfigured = true;
  }

  Future<AiRequestCredentials?> requestCredentials() async {
    if (!_initialized) return null;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final idToken = await user.getIdToken();
    final appCheckToken = skipAiAppCheck
        ? null
        : await FirebaseAppCheck.instance.getToken();
    if (idToken == null) return null;
    return AiRequestCredentials(
      userId: user.uid,
      idToken: idToken,
      appCheckToken: appCheckToken,
    );
  }
}

class AiRequestCredentials {
  final String userId;
  final String idToken;
  final String? appCheckToken;

  const AiRequestCredentials({
    required this.userId,
    required this.idToken,
    required this.appCheckToken,
  });
}
