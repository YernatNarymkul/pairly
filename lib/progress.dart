import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class ProgressStore extends ChangeNotifier {
  static const _key = 'pairly-progress';
  static const _version = 1;

  int streak = 0;
  String? lastPlayDate;
  Map<String, WordStat> stats = {};
  List<String> masteredIds = [];
  bool muted = false;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      streak = (data['streak'] as num?)?.toInt() ?? 0;
      lastPlayDate = data['lastPlayDate'] as String?;
      muted = data['muted'] == true;
      final rawStats = data['stats'];
      if (rawStats is Map<String, dynamic>) {
        stats = {
          for (final e in rawStats.entries)
            if (e.value is Map<String, dynamic>)
              e.key: WordStat.fromJson(e.value as Map<String, dynamic>),
        };
      }
      final rawMastered = data['masteredIds'];
      if (rawMastered is List) {
        masteredIds = rawMastered.whereType<String>().toList();
      }
    } catch (_) {
      /* keep defaults */
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode({
        'version': _version,
        'streak': streak,
        'lastPlayDate': lastPlayDate,
        'muted': muted,
        'stats': {for (final e in stats.entries) e.key: e.value.toJson()},
        'masteredIds': masteredIds,
      }),
    );
  }

  bool isMastered(WordStat? stat) {
    if (stat == null) return false;
    return stat.hits >= 1 && stat.hits > stat.misses;
  }

  Future<void> recordMatch(String wordId, bool correct) async {
    final prev = stats[wordId] ?? const WordStat();
    final next = correct
        ? prev.copyWith(hits: prev.hits + 1)
        : prev.copyWith(misses: prev.misses + 1);
    stats = {...stats, wordId: next};
    final mastered = {...masteredIds};
    if (isMastered(next)) {
      mastered.add(wordId);
    } else {
      mastered.remove(wordId);
    }
    masteredIds = mastered.toList();
    notifyListeners();
    await _persist();
  }

  Future<void> completeRound() async {
    final today = _todayKey();
    if (lastPlayDate == today) return;
    streak = lastPlayDate == _yesterdayKey() ? streak + 1 : 1;
    lastPlayDate = today;
    notifyListeners();
    await _persist();
  }

  Future<void> toggleMuted() async {
    muted = !muted;
    notifyListeners();
    await _persist();
  }

  String _todayKey([DateTime? date]) {
    final d = date ?? DateTime.now();
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  String _yesterdayKey() {
    return _todayKey(DateTime.now().subtract(const Duration(days: 1)));
  }
}

class ProgressScope extends InheritedNotifier<ProgressStore> {
  const ProgressScope({
    super.key,
    required ProgressStore store,
    required super.child,
  }) : super(notifier: store);

  static ProgressStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ProgressScope>();
    assert(scope != null, 'ProgressScope not found');
    return scope!.notifier!;
  }
}
