// lib/ad_gate.dart
//
// 広告ウィジェットを有料時に非表示にするラッパ。
//
// 使い方：
//   AdGate(child: _AdBanner())
//
// 有料（isPaid == true）のときは SizedBox.shrink() を返し、それ以外は child を
// そのまま描画する。プレースホルダ・本物のBannerAdどちらにも被せられる。

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'main.dart' show isPaidProvider;

class AdGate extends ConsumerWidget {
  final Widget child;
  const AdGate({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paid = ref.watch(isPaidProvider).valueOrNull ?? false;
    if (paid) return const SizedBox.shrink();
    return child;
  }
}