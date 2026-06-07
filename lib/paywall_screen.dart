// lib/paywall_screen.dart
//
// 有料プラン購入画面。
//   - 月額 ¥550 / 年額 ¥5,500（年は17%off訴求）
//   - プラン選択 → 「プレミアムに登録」CTA
//   - 「購入を復元」リンク
//   - 既加入時は「ストアで管理」表示
//   - PHASE 1 限定で「Dev：無料に戻す」ボタン（再検証用）
//
// 成功時は Navigator.pop(context, true) で戻る。呼び出し側はその bool で
// 「課金成功したから本来の動作（パートナー追加など）に進む」を判断する。

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'main.dart' show isPaidProvider, subscriptionServiceProvider;
import 'subscription_service.dart';

// 法務URL：settings_screen.dart と同じ値を使う想定（同期の責任は手動）
const _kUrlTerms =
    'https://vino0121-blip.github.io/astrology/legal/terms_of_service';
const _kUrlPrivacy =
    'https://vino0121-blip.github.io/astrology/legal/privacy_policy';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});
  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  SubscriptionPlan _selected = SubscriptionPlan.yearly;
  bool _busy = false;
  String? _error;
  SubscriptionState _state = SubscriptionState.none;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final s = await ref.read(subscriptionServiceProvider).currentState();
    if (!mounted) return;
    setState(() => _state = s);
  }

  Future<void> _onPurchase() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final ok = await ref
          .read(subscriptionServiceProvider)
          .purchase(_selected);
      if (!mounted) return;
      if (ok) {
        ref.invalidate(isPaidProvider);
        Navigator.of(context).pop(true);
      } else {
        setState(() => _error = '購入を完了できませんでした。');
      }
    } catch (e) {
      if (mounted) setState(() => _error = '購入処理でエラーが発生しました。');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _onRestore() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final ok = await ref.read(subscriptionServiceProvider).restorePurchases();
      if (!mounted) return;
      ref.invalidate(isPaidProvider);
      if (ok) {
        Navigator.of(context).pop(true);
      } else {
        setState(() => _error = '復元できる購入が見つかりませんでした。');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _devResetToFree() async {
    await ref.read(subscriptionServiceProvider).devResetToFree();
    if (!mounted) return;
    ref.invalidate(isPaidProvider);
    await _loadState();
  }

  @override
  Widget build(BuildContext context) {
    final paid =
        _state == SubscriptionState.active || _state == SubscriptionState.trial;
    return Scaffold(
      appBar: AppBar(title: const Text('プレミアム')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: paid ? _buildPaidView() : _buildPaywallView(),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // 未加入：プラン選択 → 購入
  // --------------------------------------------------
  Widget _buildPaywallView() {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'プレミアム',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 4,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Center(
          child: Text(
            'いつものあなたを、もう少し深く。',
            style: TextStyle(fontSize: 15, height: 1.7),
          ),
        ),
        const SizedBox(height: 28),

        const _BenefitRow(icon: Icons.auto_awesome, text: '今日の詳しいAI診断'),
        const SizedBox(height: 12),
        const _BenefitRow(
          icon: Icons.insights_outlined,
          text: '前1年〜未来3年の月間AI診断',
        ),
        const SizedBox(height: 12),
        const _BenefitRow(
          icon: Icons.notifications_none,
          text: '新月・満月・天体移動の星模様アラート',
        ),
        const SizedBox(height: 12),
        const _BenefitRow(icon: Icons.favorite_border, text: '相性診断の人数制限なし'),
        const SizedBox(height: 12),
        const _BenefitRow(icon: Icons.block, text: '広告非表示'),
        const SizedBox(height: 28),

        _PlanCard(
          plan: SubscriptionPlan.monthly,
          selected: _selected == SubscriptionPlan.monthly,
          onTap: () => setState(() => _selected = SubscriptionPlan.monthly),
        ),
        const SizedBox(height: 10),
        _PlanCard(
          plan: SubscriptionPlan.yearly,
          selected: _selected == SubscriptionPlan.yearly,
          badge: 'おすすめ',
          subtitle: '約 ¥458/月（17% off）',
          onTap: () => setState(() => _selected = SubscriptionPlan.yearly),
        ),
        const SizedBox(height: 24),

        if (_error != null) ...[
          Text(
            _error!,
            style: TextStyle(color: scheme.error, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
        ],

        FilledButton(
          onPressed: _busy ? null : _onPurchase,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _busy
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                )
              : const Text('プレミアムに登録'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _busy ? null : _onRestore,
          child: const Text('購入を復元'),
        ),
        const SizedBox(height: 18),

        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Text(
                  '購入確定後、自動的に更新されます。\n更新は期間終了の24時間以上前にキャンセルしてください。\nアカウント設定からいつでも管理・解約できます。',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.7,
                    color: scheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: [
                    _LegalLink(label: '利用規約', url: _kUrlTerms),
                    Text(
                      '·',
                      style: TextStyle(
                        color: scheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                    _LegalLink(label: 'プライバシーポリシー', url: _kUrlPrivacy),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------
  // 既加入：状態表示＋管理導線
  // --------------------------------------------------
  Widget _buildPaidView() {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.12),
              border: Border.all(color: scheme.primary.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'プレミアム加入中',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: scheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        const Center(
          child: Text(
            'ご利用ありがとうございます。',
            style: TextStyle(fontSize: 15, height: 1.7),
          ),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
          icon: const Icon(Icons.home_outlined),
          label: const Text('ホームでプレミアム機能を見る'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            // PHASE 2: ストアの管理画面に飛ばす（url_launcher で
            //   iOS: https://apps.apple.com/account/subscriptions
            //   Android: https://play.google.com/store/account/subscriptions
            // を開く）
          },
          child: const Text('プランを管理（ストア）'),
        ),
        const SizedBox(height: 40),

        // PHASE 1 限定：ゲーティング再検証用。PHASE 2 で削除すること。
        Center(
          child: TextButton(
            onPressed: _devResetToFree,
            child: Text(
              'Dev：無料に戻す',
              style: TextStyle(
                fontSize: 11,
                color: scheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _BenefitRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: scheme.primary.withValues(alpha: 0.9)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 15, height: 1.6)),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool selected;
  final String? badge;
  final String? subtitle;
  final VoidCallback onTap;
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.onTap,
    this.badge,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final price =
        '¥${plan.priceJpy.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} / ${plan == SubscriptionPlan.monthly ? '月' : '年'}';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withValues(alpha: 0.10)
              : const Color(0xFF11161C),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? scheme.primary.withValues(alpha: 0.7)
                : scheme.onSurface.withValues(alpha: 0.18),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? scheme.primary
                      : scheme.onSurface.withValues(alpha: 0.35),
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: scheme.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        plan.label,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.secondary.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            badge!,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: scheme.secondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: scheme.onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: scheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  final String label;
  final String url;
  const _LegalLink({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          color: scheme.primary.withValues(alpha: 0.85),
          decoration: TextDecoration.underline,
          decorationColor: scheme.primary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
