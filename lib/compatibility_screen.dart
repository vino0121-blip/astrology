// lib/compatibility_screen.dart
//
// 相性画面：パートナー一覧 → タップで詳細（シナストリー）。
// 出生図と同じく roastLevel を尊重し、トーン別の文章を出す。

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'add_partner_screen.dart';
import 'app_database.dart' show Partner;
import 'aspect_mark.dart';
import 'astro_display.dart';
import 'astro_synastry.dart';
import 'main.dart'
    show astroServiceProvider, isPaidProvider, subscriptionServiceProvider;
import 'paywall_screen.dart';

const _relationshipLabel = <String, String>{
  'lover': '恋人',
  'friend': '友人',
  'family': '家族',
  'work': '職場',
  'other': 'その他',
};

class CompatibilityScreen extends ConsumerStatefulWidget {
  const CompatibilityScreen({super.key});
  @override
  ConsumerState<CompatibilityScreen> createState() =>
      _CompatibilityScreenState();
}

class _CompatibilityScreenState extends ConsumerState<CompatibilityScreen> {
  late Future<List<Partner>> _partnersFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _partnersFuture = ref.read(astroServiceProvider).listPartners();
    setState(() {});
  }

  Future<void> _onAdd() async {
    final svc = ref.read(astroServiceProvider);
    final subSvc = ref.read(subscriptionServiceProvider);
    final isPaid = await subSvc.isPaid;
    final canAdd = await svc.canAddPartner(isPaid: isPaid);
    if (!canAdd) {
      if (!mounted) return;
      // 無料枠超過：paywall を出す。購入成功（true 戻り）したら追加フローへ続行。
      final purchased = await Navigator.of(
        context,
      ).push<bool>(MaterialPageRoute(builder: (_) => const PaywallScreen()));
      ref.invalidate(isPaidProvider);
      if (purchased != true) return;
    }
    if (!mounted) return;
    final added = await Navigator.of(
      context,
    ).push<int?>(MaterialPageRoute(builder: (_) => const AddPartnerScreen()));
    if (added != null) _refresh();
  }

  Future<void> _onDelete(int id) async {
    await ref.read(astroServiceProvider).deletePartner(id);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('相性'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_outlined),
            tooltip: '相手を追加',
            onPressed: _onAdd,
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<Partner>>(
          future: _partnersFuture,
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final partners = snap.data!;
            if (partners.isEmpty) return _EmptyView(onAdd: _onAdd);
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
              itemCount: partners.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final p = partners[i];
                return _PartnerCard(
                  partner: p,
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SynastryDetailScreen(partner: p),
                      ),
                    );
                    _refresh();
                  },
                  onDelete: () => _onDelete(p.id),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyView({required this.onAdd});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              size: 36,
              color: scheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 14),
            const Text(
              '相手を追加すると、星の配置から\n二人の相性が見られます。',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.7),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('相手を追加'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  final Partner partner;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  const _PartnerCard({
    required this.partner,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rel =
        _relationshipLabel[partner.relationship] ?? partner.relationship;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 8, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partner.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$rel  ·  ${partner.birthPlaceName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showMenu(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('削除'),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// 詳細画面：シナストリー
// ============================================================
class SynastryDetailScreen extends ConsumerStatefulWidget {
  final Partner partner;
  const SynastryDetailScreen({super.key, required this.partner});
  @override
  ConsumerState<SynastryDetailScreen> createState() =>
      _SynastryDetailScreenState();
}

class _SynastryDetailScreenState extends ConsumerState<SynastryDetailScreen> {
  Future<SynastryResult?>? _resultFuture;
  RoastLevel _roastLevel = RoastLevel.mild;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final svc = ref.read(astroServiceProvider);
    final stored = await svc.getRoastLevel();
    if (!mounted) return;
    setState(() {
      _roastLevel = RoastLevel.values.firstWhere(
        (l) => l.name == stored,
        orElse: () => RoastLevel.mild,
      );
      _resultFuture = svc.computeCompatibility(widget.partner.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.partner;
    final rel = _relationshipLabel[p.relationship] ?? p.relationship;
    return Scaffold(
      appBar: AppBar(
        title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: SafeArea(
        child: FutureBuilder<SynastryResult?>(
          future: _resultFuture,
          builder: (context, snap) {
            if (!snap.hasData && snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final r = snap.data;
            if (r == null) {
              return const _DetailError();
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
              children: [
                _SubHeader(rel: rel, place: p.birthPlaceName),
                const SizedBox(height: 16),
                _HeadlineCard(result: r, level: _roastLevel),
                const SizedBox(height: 18),
                _RoastSelector(
                  level: _roastLevel,
                  onChanged: (l) {
                    setState(() => _roastLevel = l);
                    ref.read(astroServiceProvider).setRoastLevel(l.name);
                  },
                ),
                const SizedBox(height: 18),
                const _SectionTitle('主要なクロスアスペクト'),
                const SizedBox(height: 10),
                for (final a in r.keyAspects) ...[
                  _AspectCard(aspect: a, level: _roastLevel),
                  const SizedBox(height: 10),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError();
  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        '相性を計算できませんでした。\nあなたの出生情報か相手の出生情報をご確認ください。',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, height: 1.7),
      ),
    ),
  );
}

class _SubHeader extends StatelessWidget {
  final String rel;
  final String place;
  const _SubHeader({required this.rel, required this.place});
  @override
  Widget build(BuildContext context) => Text(
    '$rel  ·  $place',
    style: TextStyle(
      fontSize: 12.5,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      letterSpacing: 0.5,
    ),
  );
}

class _HeadlineCard extends StatelessWidget {
  final SynastryResult result;
  final RoastLevel level;
  const _HeadlineCard({required this.result, required this.level});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              synastryHeadline(result, level),
              style: const TextStyle(
                fontSize: 16,
                height: 1.7,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            _ScoreBar(score: result.score, quality: result.quality),
          ],
        ),
      ),
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final double score;
  final String quality;
  const _ScoreBar({required this.score, required this.quality});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = quality == 'harmony'
        ? '調和寄り'
        : quality == 'tension'
        ? '緊張寄り'
        : '混在';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '相性バランス  ·  $label',
              style: TextStyle(
                fontSize: 11.5,
                color: scheme.onSurface.withValues(alpha: 0.55),
                letterSpacing: 0.4,
              ),
            ),
            const Spacer(),
            Text(
              '${(score * 100).round()} / 100',
              style: TextStyle(
                fontSize: 11.5,
                color: scheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: scheme.onSurface.withValues(alpha: 0.08),
            valueColor: AlwaysStoppedAnimation(
              scheme.primary.withValues(alpha: 0.75),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: 12.5,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
    ),
  );
}

class _AspectCard extends StatelessWidget {
  final SynastryAspect aspect;
  final RoastLevel level;
  const _AspectCard({required this.aspect, required this.level});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  bodyMark(aspect.bodyA),
                  style: TextStyle(
                    fontSize: 18,
                    color: scheme.primary.withValues(alpha: 0.95),
                    fontFamily: astroSymbolFontFamily,
                    fontFamilyFallback: astroSymbolFontFamilyFallback,
                  ),
                ),
                const SizedBox(width: 6),
                AspectMark(
                  type: aspect.type,
                  color: scheme.onSurface.withValues(alpha: 0.7),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  bodyMark(aspect.bodyB),
                  style: TextStyle(
                    fontSize: 18,
                    color: scheme.secondary.withValues(alpha: 0.95),
                    fontFamily: astroSymbolFontFamily,
                    fontFamilyFallback: astroSymbolFontFamilyFallback,
                  ),
                ),
                const Spacer(),
                Text(
                  'orb ${aspect.orb.toStringAsFixed(1)}°',
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              synastryAspectLine(aspect, level),
              style: const TextStyle(fontSize: 14.5, height: 1.7),
            ),
          ],
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
    return Row(
      children: [
        for (final l in RoastLevel.values) ...[
          _RoastChip(
            label: l.label,
            selected: l == level,
            onTap: () => onChanged(l),
          ),
          if (l != RoastLevel.values.last) const SizedBox(width: 8),
        ],
      ],
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          border: Border.all(
            color: selected
                ? scheme.primary.withValues(alpha: 0.6)
                : scheme.onSurface.withValues(alpha: 0.22),
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected
                ? scheme.primary
                : scheme.onSurface.withValues(alpha: 0.75),
          ),
        ),
      ),
    );
  }
}
