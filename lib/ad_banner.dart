import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

const String _kBannerAdUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111';
const String _kBannerAdUnitIdIOS = String.fromEnvironment(
  'ADMOB_IOS_BANNER_ID',
);

String get _kBannerAdUnitId =>
    Platform.isAndroid ? _kBannerAdUnitIdAndroid : _kBannerAdUnitIdIOS;

bool get adsConfigured =>
    Platform.isAndroid || _kBannerAdUnitIdIOS.trim().isNotEmpty;

class AppBannerAd extends StatefulWidget {
  const AppBannerAd({super.key});

  @override
  State<AppBannerAd> createState() => _AppBannerAdState();
}

class _AppBannerAdState extends State<AppBannerAd> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (!adsConfigured) return;
    _ad = BannerAd(
      adUnitId: _kBannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!adsConfigured) return const SizedBox.shrink();
    if (!_loaded || _ad == null) return const SizedBox(height: 50);
    return Center(
      child: SizedBox(
        width: _ad!.size.width.toDouble(),
        height: _ad!.size.height.toDouble(),
        child: AdWidget(ad: _ad!),
      ),
    );
  }
}
