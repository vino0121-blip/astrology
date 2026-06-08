// lib/onboarding_screen.dart
//
// オンボーディング画面：生年月日・出生時刻・出生地を入力して保存する。
// 保存後は currentUserProvider を invalidate し、ルータが自動的にホームへ
// 切り替える（初回時）、または Navigator.pop で戻る（編集時）。
//
// トーン：narration_spec.md の「やさしい・寄り添い・前向き」を画面側でも踏襲。
// 未入力時は黙ってボタン無効化せず、各フィールドに優しい誘導メッセージを表示。

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart' show UserProfile;
import 'chart_reveal_screen.dart';
import 'home_screen.dart';
import 'jp_locations.dart';
import 'main.dart'
    show astroServiceProvider, currentUserProvider, todayReadingProvider;

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  TimeOfDay? _birthTime;
  bool _timeUnknown = false;
  JpPrefecture? _prefecture;

  bool _saving = false;
  bool _editingExisting = false;
  String? _dateError;
  String? _placeError;
  String? _formError;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_loadExistingBirthData);
  }

  Future<void> _loadExistingBirthData() async {
    final user = await ref.read(astroServiceProvider).currentUser();
    if (!mounted || user == null) return;
    _applyUserProfile(user);
  }

  void _applyUserProfile(UserProfile user) {
    final birthLocal = DateTime.tryParse(user.birthLocalIso);
    setState(() {
      _editingExisting = true;
      _nameController.text = user.displayName ?? '';
      if (birthLocal != null) {
        _birthDate = DateTime(
          birthLocal.year,
          birthLocal.month,
          birthLocal.day,
        );
        _birthTime = user.birthTimeUnknown
            ? null
            : TimeOfDay(hour: birthLocal.hour, minute: birthLocal.minute);
      }
      _timeUnknown = user.birthTimeUnknown;
      _prefecture = _prefectureFor(user);
    });
  }

  JpPrefecture? _prefectureFor(UserProfile user) {
    for (final p in kJpPrefectures) {
      if (p.name == user.birthPlaceName) return p;
    }
    for (final p in kJpPrefectures) {
      final sameLat = (p.lat - user.latitude).abs() < 0.01;
      final sameLon = (p.lon - user.longitudeEast).abs() < 0.01;
      if (sameLat && sameLon) return p;
    }
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _birthDate ?? DateTime(now.year - 30, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900, 1, 1),
      lastDate: now,
      helpText: '生年月日',
    );
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _dateError = null;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _birthTime ?? const TimeOfDay(hour: 12, minute: 0),
      helpText: '生まれた時刻',
    );
    if (picked != null) {
      setState(() {
        _birthTime = picked;
        _timeUnknown = false;
      });
    }
  }

  Future<void> _submit() async {
    // バリデーション：未入力フィールドに優しいメッセージを表示
    final dateMissing = _birthDate == null;
    final placeMissing = _prefecture == null;
    if (dateMissing || placeMissing) {
      setState(() {
        _dateError = dateMissing ? '生年月日を選んでください' : null;
        _placeError = placeMissing ? '生まれた場所を選んでください' : null;
        _formError = null;
      });
      return;
    }

    setState(() {
      _saving = true;
      _formError = null;
    });
    try {
      final t = _timeUnknown
          ? const TimeOfDay(hour: 12, minute: 0)
          : (_birthTime ?? const TimeOfDay(hour: 12, minute: 0));
      final birthLocal = DateTime(
        _birthDate!.year,
        _birthDate!.month,
        _birthDate!.day,
        t.hour,
        t.minute,
      );
      final service = ref.read(astroServiceProvider);
      await service.saveUserBirthData(
        displayName: _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
        birthLocal: birthLocal,
        birthTimeUnknown: _timeUnknown || _birthTime == null,
        birthPlaceName: _prefecture!.name,
        latitude: _prefecture!.lat,
        longitudeEast: _prefecture!.lon,
      );
      final chart = await service.resolveNatalChart();
      if (chart == null) {
        throw StateError('出生図を生成できませんでした');
      }
      // キャッシュ更新を反映
      ref.invalidate(currentUserProvider);
      ref.invalidate(todayReadingProvider);
      // 入力完了の瞬間を「星図生成」の体験として見せる。
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ChartRevealScreen(
              chart: chart,
              onDone: (revealContext) {
                Navigator.of(revealContext).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (_) => false,
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _formError = '保存できませんでした。もう一度お試しください。');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('はじめに')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'あなたが生まれた瞬間の星の配置から、毎日のやさしい星よみをお届けします。',
                  style: TextStyle(fontSize: 15, height: 1.7),
                ),
              ),
              const SizedBox(height: 12),

              _SectionLabel('お名前（任意）'),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: '呼ばれたいお名前',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              _SectionLabel('生年月日'),
              _PickerTile(
                icon: Icons.calendar_today,
                label: _birthDate == null
                    ? 'タップして選択'
                    : '${_birthDate!.year}年${_birthDate!.month}月${_birthDate!.day}日',
                onTap: _pickDate,
                placeholder: _birthDate == null,
                errorText: _dateError,
              ),
              const SizedBox(height: 20),

              _SectionLabel('生まれた時刻'),
              _PickerTile(
                icon: Icons.access_time,
                label: _timeUnknown
                    ? 'わからない（12:00で計算します）'
                    : _birthTime == null
                    ? 'タップして選択（任意）'
                    : '${_birthTime!.hour.toString().padLeft(2, "0")}:'
                          '${_birthTime!.minute.toString().padLeft(2, "0")}',
                onTap: _timeUnknown ? null : _pickTime,
                placeholder: _birthTime == null && !_timeUnknown,
              ),
              const SizedBox(height: 4),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                value: _timeUnknown,
                onChanged: (v) => setState(() {
                  _timeUnknown = v ?? false;
                  if (_timeUnknown) _birthTime = null;
                }),
                title: const Text(
                  '生まれた時刻はわからない',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              Text(
                '時刻が分かるとより細やかな星よみになりますが、分からなくても大丈夫です。',
                style: TextStyle(
                  fontSize: 12.5,
                  color: scheme.onSurface.withValues(alpha: 0.65),
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 20),

              _SectionLabel('生まれた場所'),
              DropdownButtonFormField<JpPrefecture>(
                initialValue: _prefecture,
                decoration: InputDecoration(
                  hintText: '都道府県を選択',
                  border: const OutlineInputBorder(),
                  errorText: _placeError,
                ),
                isExpanded: true,
                items: [
                  for (final p in kJpPrefectures)
                    DropdownMenuItem(value: p, child: Text(p.name)),
                ],
                onChanged: (p) => setState(() {
                  _prefecture = p;
                  _placeError = null;
                }),
              ),
              const SizedBox(height: 28),

              if (_formError != null) ...[
                Text(
                  _formError!,
                  style: TextStyle(color: scheme.error, fontSize: 13),
                ),
                const SizedBox(height: 12),
              ],

              if (_editingExisting) ...[
                _AiRegenerationNotice(scheme: scheme),
                const SizedBox(height: 16),
              ],

              FilledButton(
                onPressed: _saving ? null : _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Text('はじめる'),
              ),
              const SizedBox(height: 24),

              Text(
                '入力された情報はこの端末内にのみ保存され、外部に送信されることはありません。',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.onSurface.withValues(alpha: 0.55),
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiRegenerationNotice extends StatelessWidget {
  final ColorScheme scheme;
  const _AiRegenerationNotice({required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome, size: 18, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '出生情報を編集した場合、今日のAI診断は当日1回まで再生成できます。2回目以降の変更は翌日から反映されます。',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.55,
                color: scheme.onSurface.withValues(alpha: 0.72),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.75),
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool placeholder;
  final String? errorText;
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.placeholder,
    this.errorText,
  });
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: const Color(0xFF11161C),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasError
                      ? scheme.error
                      : scheme.onSurface.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        color: placeholder
                            ? scheme.onSurface.withValues(alpha: 0.45)
                            : scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              errorText!,
              style: TextStyle(color: scheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
