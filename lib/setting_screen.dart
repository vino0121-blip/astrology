// lib/settings_screen.dart
//
// 設定画面：ストア提出に必要な導線を集約する。
//   - プラン状態 + paywall
//   - 出生情報の編集（onboarding 再利用）
//   - 文体（mild / sharp / 直球）— ホームと同じ永続化
//   - 利用規約・プライバシーポリシー・解約手順・お問い合わせ（外部ブラウザ）
//   - バージョン情報・ライセンス
//
// 外部URLは _kUrlXxx の定数。ホスティング先が決まったら差し替え。

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'astro_display.dart';
import 'astro_guide_screen.dart';
import 'main.dart' show astroServiceProvider, isPaidProvider;
import 'onboarding_screen.dart';
import 'paywall_screen.dart';

// 法務URL：ホスティング先（GitHub Pages / Netlify / 自社ドメイン等）に差し替え。
// テンプレ本文は legal/ 配下の md ファイル参照。
const _kUrlTerms =
    'https://vino0121-blip.github.io/astrology/legal/terms_of_service';
const _kUrlPrivacy =
    'https://vino0121-blip.github.io/astrology/legal/privacy_policy';
const _kUrlSubscription =
    'https://vino0121-blip.github.io/astrology/legal/subscription_terms';
const _kUrlContact = 'mailto:studioalveare.app@gmail.com';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  RoastLevel _roastLevel = RoastLevel.mild;
  String? _appVersion;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final svc = ref.read(astroServiceProvider);
    final stored = await svc.getRoastLevel();
    PackageInfo? info;
    try {
      info = await PackageInfo.fromPlatform();
    } catch (_) {
      // テスト環境やplatform未対応時は無視
    }
    if (!mounted) return;
    setState(() {
      _roastLevel = RoastLevel.values.firstWhere(
        (l) => l.name == stored,
        orElse: () => RoastLevel.mild,
      );
      if (info != null) {
        _appVersion = '${info.version}（${info.buildNumber}）';
      }
    });
  }

  void _onRoastChanged(RoastLevel level) {
    setState(() => _roastLevel = level);
    ref.read(astroServiceProvider).setRoastLevel(level.name);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('リンクを開けませんでした。')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPaid = ref.watch(isPaidProvider).valueOrNull ?? false;
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            // --- プラン ---
            const _SectionLabel('プラン'),
            _SettingsTile(
              title: 'プラン',
              trailing: _PlanBadge(isPaid: isPaid),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const PaywallScreen())),
            ),

            const SizedBox(height: 18),

            const _SectionLabel('星読み'),
            _SettingsTile(
              title: '用語・記号ガイド',
              icon: Icons.help_outline,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AstroGuideScreen()),
              ),
            ),

            const SizedBox(height: 18),

            // --- プロフィール ---
            const _SectionLabel('プロフィール'),
            _SettingsTile(
              title: '出生情報を編集',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
              ),
            ),

            const SizedBox(height: 18),

            // --- 表示 ---
            const _SectionLabel('表示'),
            _RoastSelector(level: _roastLevel, onChanged: _onRoastChanged),

            const SizedBox(height: 18),

            // --- サポート / 規約 ---
            const _SectionLabel('サポート / 規約'),
            _SettingsTile(
              title: '利用規約',
              icon: Icons.description_outlined,
              onTap: () => _openUrl(_kUrlTerms),
            ),
            _SettingsTile(
              title: 'プライバシーポリシー',
              icon: Icons.privacy_tip_outlined,
              onTap: () => _openUrl(_kUrlPrivacy),
            ),
            _SettingsTile(
              title: 'サブスクリプション',
              icon: Icons.cancel_outlined,
              onTap: () => _openUrl(_kUrlSubscription),
            ),
            _SettingsTile(
              title: 'お問い合わせ',
              icon: Icons.mail_outline,
              onTap: () => _openUrl(_kUrlContact),
            ),

            const SizedBox(height: 18),

            // --- アプリ情報 ---
            const _SectionLabel('アプリ情報'),
            _SettingsTile(
              title: 'バージョン',
              trailing: Text(
                _appVersion ?? '—',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
              onTap: null,
            ),
            _SettingsTile(
              title: 'ライセンス',
              onTap: () => showLicensePage(
                context: context,
                applicationName: '星巡',
                applicationVersion: _appVersion ?? '',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// パーツ
// ============================================================
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
      ),
    ),
  );
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _SettingsTile({
    required this.title,
    this.icon,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 18,
                  color: scheme.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(title, style: const TextStyle(fontSize: 14.5)),
              ),
              ?trailing,
              if (onTap != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: scheme.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  final bool isPaid;
  const _PlanBadge({required this.isPaid});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPaid
            ? scheme.primary.withValues(alpha: 0.12)
            : scheme.onSurface.withValues(alpha: 0.08),
        border: Border.all(
          color: isPaid
              ? scheme.primary.withValues(alpha: 0.5)
              : scheme.onSurface.withValues(alpha: 0.18),
        ),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        isPaid ? 'プレミアム' : '無料',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          color: isPaid
              ? scheme.primary
              : scheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

class _RoastSelector extends StatelessWidget {
  final RoastLevel level;
  final ValueChanged<RoastLevel> onChanged;
  const _RoastSelector({required this.level, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
              child: Text(
                '文体',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
            Row(
              children: [
                for (final l in RoastLevel.values) ...[
                  Expanded(
                    child: _RoastChip(
                      label: l.label,
                      selected: l == level,
                      onTap: () => onChanged(l),
                    ),
                  ),
                  if (l != RoastLevel.values.last) const SizedBox(width: 6),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoastChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _RoastChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          border: Border.all(
            color: selected
                ? scheme.primary.withValues(alpha: 0.6)
                : scheme.onSurface.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: selected
                  ? scheme.primary
                  : scheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
        ),
      ),
    );
  }
}
