// lib/add_partner_screen.dart
//
// 相手を追加するフォーム。オンボーディング画面と同じ入力部品（日付・時刻・
// 都道府県）に加えて、名前と関係性を入力する。
// 無料枠の判定は呼び出し側（compatibility_screen）で行う。

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'jp_locations.dart';
import 'main.dart' show astroServiceProvider;

/// 関係性ラベル（DB 値 ↔ 表示名）
const _relationships = <(String value, String label)>[
  ('lover', '恋人'),
  ('friend', '友人'),
  ('family', '家族'),
  ('work', '職場'),
  ('other', 'その他'),
];

class AddPartnerScreen extends ConsumerStatefulWidget {
  const AddPartnerScreen({super.key});
  @override
  ConsumerState<AddPartnerScreen> createState() => _AddPartnerScreenState();
}

class _AddPartnerScreenState extends ConsumerState<AddPartnerScreen> {
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  TimeOfDay? _birthTime;
  bool _timeUnknown = false;
  JpPrefecture? _prefecture;
  String _relationship = 'friend';

  bool _saving = false;
  String? _nameError;
  String? _dateError;
  String? _placeError;
  String? _formError;

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
    final name = _nameController.text.trim();
    final nameMissing = name.isEmpty;
    final dateMissing = _birthDate == null;
    final placeMissing = _prefecture == null;
    if (nameMissing || dateMissing || placeMissing) {
      setState(() {
        _nameError = nameMissing ? '名前を入力してください' : null;
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
      final svc = ref.read(astroServiceProvider);
      final id = await svc.addPartner(
        name: name,
        birthLocal: birthLocal,
        birthTimeUnknown: _timeUnknown || _birthTime == null,
        birthPlaceName: _prefecture!.name,
        latitude: _prefecture!.lat,
        longitudeEast: _prefecture!.lon,
        relationship: _relationship,
      );
      if (mounted) Navigator.of(context).pop(id);
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
      appBar: AppBar(title: const Text('相手を追加')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  '相手の生年月日と出生地を入力すると、星の配置から二人の相性を見られます。',
                  style: TextStyle(fontSize: 14, height: 1.7),
                ),
              ),
              const SizedBox(height: 12),

              _Label('お名前'),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: '相手のお名前',
                  errorText: _nameError,
                ),
                onChanged: (_) {
                  if (_nameError != null) setState(() => _nameError = null);
                },
              ),
              const SizedBox(height: 20),

              _Label('関係性'),
              DropdownButtonFormField<String>(
                initialValue: _relationship,
                items: [
                  for (final (v, l) in _relationships)
                    DropdownMenuItem(value: v, child: Text(l)),
                ],
                onChanged: (v) =>
                    setState(() => _relationship = v ?? 'other'),
                isExpanded: true,
              ),
              const SizedBox(height: 20),

              _Label('生年月日'),
              _Tile(
                icon: Icons.calendar_today,
                label: _birthDate == null
                    ? 'タップして選択'
                    : '${_birthDate!.year}年${_birthDate!.month}月${_birthDate!.day}日',
                placeholder: _birthDate == null,
                onTap: _pickDate,
                errorText: _dateError,
              ),
              const SizedBox(height: 20),

              _Label('生まれた時刻'),
              _Tile(
                icon: Icons.access_time,
                label: _timeUnknown
                    ? 'わからない（12:00で計算）'
                    : _birthTime == null
                        ? 'タップして選択（任意）'
                        : '${_birthTime!.hour.toString().padLeft(2, "0")}:'
                            '${_birthTime!.minute.toString().padLeft(2, "0")}',
                placeholder: _birthTime == null && !_timeUnknown,
                onTap: _timeUnknown ? null : _pickTime,
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                value: _timeUnknown,
                onChanged: (v) => setState(() {
                  _timeUnknown = v ?? false;
                  if (_timeUnknown) _birthTime = null;
                }),
                title: const Text('生まれた時刻はわからない',
                    style: TextStyle(fontSize: 14)),
              ),
              const SizedBox(height: 12),

              _Label('生まれた場所'),
              DropdownButtonFormField<JpPrefecture>(
                initialValue: _prefecture,
                decoration: InputDecoration(
                  hintText: '都道府県を選択',
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
                Text(_formError!,
                    style: TextStyle(color: scheme.error, fontSize: 13)),
                const SizedBox(height: 12),
              ],

              FilledButton(
                onPressed: _saving ? null : _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      )
                    : const Text('追加'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
            letterSpacing: 0.3,
          ),
        ),
      );
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool placeholder;
  final VoidCallback? onTap;
  final String? errorText;
  const _Tile({
    required this.icon,
    required this.label,
    required this.placeholder,
    required this.onTap,
    this.errorText,
  });
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final err = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: const Color(0xFF11161C),
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: err
                      ? scheme.error
                      : scheme.onSurface.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon,
                      size: 18,
                      color: scheme.onSurface.withValues(alpha: 0.6)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
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
        if (err)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(errorText!,
                style: TextStyle(color: scheme.error, fontSize: 12)),
          ),
      ],
    );
  }
}