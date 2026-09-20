import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../catalog.dart';
import '../models.dart';
import '../progress.dart';
import '../theme.dart';
import '../widgets/word_tile.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key, required this.slug, required this.title});

  final String slug;
  final String title;

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  List<Word> _words = [];
  List<Word> _english = [];
  List<Word> _russian = [];
  Selection? _selected;
  List<Selection> _wrong = [];
  final Set<String> _matched = {};
  bool _locked = false;
  int _combo = 0;
  int _bestCombo = 0;
  int _correct = 0;
  int _wrongCount = 0;
  final List<Word> _missed = [];
  RoundSummary? _summary;

  bool _dealt = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dealt) {
      _dealt = true;
      _deal(notify: false);
    }
  }

  List<Word> _pool(ProgressStore store) {
    if (widget.slug == 'daily') {
      return uniquePool(kAllWords);
    }
    return categoryBySlug(widget.slug)?.words ?? const [];
  }

  void _deal({bool notify = true}) {
    final store = ProgressScope.of(context);
    final source = _pool(store);
    final round = pickRound(source, store.masteredIds);
    void apply() {
      _words = round;
      _english = List<Word>.from(round)..shuffle();
      _russian = List<Word>.from(round)..shuffle();
      _selected = null;
      _wrong = [];
      _matched.clear();
      _locked = false;
      _combo = 0;
      _bestCombo = 0;
      _correct = 0;
      _wrongCount = 0;
      _missed.clear();
      _summary = null;
    }

    if (notify) {
      setState(apply);
    } else {
      apply();
    }
  }

  void _startRound() => _deal();

  WordVisual _visual(String id, Side side) {
    if (_matched.contains(id)) return WordVisual.matched;
    if (_wrong.any((w) => w.id == id && w.side == side))
      return WordVisual.wrong;
    if (_selected != null && _selected!.id == id && _selected!.side == side) {
      return WordVisual.selected;
    }
    return WordVisual.idle;
  }

  Future<void> _onPick(Side side, Word word) async {
    if (_locked || _matched.contains(word.id) || _summary != null) return;
    final store = ProgressScope.of(context);

    if (_selected == null) {
      setState(() => _selected = Selection(side: side, id: word.id));
      return;
    }

    if (_selected!.side == side) {
      setState(() {
        _selected = _selected!.id == word.id
            ? null
            : Selection(side: side, id: word.id);
      });
      return;
    }

    final other = _selected!;
    final correct = other.id == word.id;

    if (correct) {
      setState(() {
        _matched.add(word.id);
        _selected = null;
        _combo += 1;
        if (_combo > _bestCombo) _bestCombo = _combo;
        _correct += 1;
      });
      await store.recordMatch(word.id, true);
      if (!store.muted) HapticFeedback.lightImpact();
      if (_matched.length == _words.length) {
        await store.completeRound();
        if (!store.muted) HapticFeedback.mediumImpact();
        if (!mounted) return;
        setState(() {
          _summary = RoundSummary(
            title: widget.title,
            total: _matched.length,
            correct: _correct,
            wrong: _wrongCount,
            bestCombo: _bestCombo,
            missed: List<Word>.from(_missed),
          );
        });
      }
      return;
    }

    Word? missedWord;
    for (final w in _words) {
      if (w.id == other.id) {
        missedWord = w;
        break;
      }
    }
    final missed = missedWord;
    setState(() {
      _locked = true;
      _wrong = [other, Selection(side: side, id: word.id)];
      _combo = 0;
      _wrongCount += 1;
      if (missed != null && !_missed.any((m) => m.id == missed.id)) {
        _missed.add(missed);
      }
    });
    await store.recordMatch(other.id, false);
    await store.recordMatch(word.id, false);
    if (!store.muted) HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 480));
    if (!mounted) return;
    setState(() {
      _wrong = [];
      _selected = null;
      _locked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = ProgressScope.of(context);
    final total = _words.length;
    final done = _matched.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: displayStyle(size: 20)),
            const Text(
              'Нажмите слово и его перевод',
              style: TextStyle(fontSize: 12, color: PairlyColors.muted),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: store.muted ? 'Включить звук' : 'Выключить звук',
            onPressed: store.toggleMuted,
            icon: Icon(store.muted
                ? Icons.volume_off_outlined
                : Icons.volume_up_outlined),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'СОПОСТАВЛЕНИЕ',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                          color: PairlyColors.muted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('$done', style: displayStyle(size: 22)),
                          Text('/$total',
                              style: displayStyle(
                                  size: 22, color: PairlyColors.muted)),
                          if (_combo >= 2) ...[
                            const SizedBox(width: 10),
                            Text(
                              'серия ×$_combo',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: PairlyColors.sage,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text(
                      'Слева EN · справа RU',
                      style:
                          TextStyle(fontSize: 12, color: PairlyColors.subtle),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : done / total,
                  minHeight: 6,
                  backgroundColor: PairlyColors.surface2,
                  color: PairlyColors.sage,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'ENGLISH',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.6,
                        color: PairlyColors.subtle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'РУССКИЙ',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.6,
                        color: PairlyColors.subtle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        for (final word in _english) ...[
                          WordTile(
                            text: word.en,
                            state: _visual(word.id, Side.en),
                            onTap:
                                _locked ? null : () => _onPick(Side.en, word),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        for (final word in _russian) ...[
                          WordTile(
                            text: word.ru,
                            state: _visual(word.id, Side.ru),
                            onTap:
                                _locked ? null : () => _onPick(Side.ru, word),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_summary != null)
            _RoundDone(summary: _summary!, onReplay: _startRound),
        ],
      ),
    );
  }
}

class _RoundDone extends StatelessWidget {
  const _RoundDone({required this.summary, required this.onReplay});

  final RoundSummary summary;
  final VoidCallback onReplay;

  @override
  Widget build(BuildContext context) {
    final attempts = summary.correct + summary.wrong;
    final accuracy =
        attempts == 0 ? 100 : ((summary.correct / attempts) * 100).round();

    return ColoredBox(
      color: PairlyColors.ink.withOpacity(0.4),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            decoration: BoxDecoration(
              color: PairlyColors.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: PairlyColors.line),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: PairlyColors.sageSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.check, color: PairlyColors.sage),
                ),
                const SizedBox(height: 16),
                Text('Раунд пройден', style: displayStyle(size: 28)),
                const SizedBox(height: 4),
                Text(summary.title,
                    style: const TextStyle(color: PairlyColors.muted)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _MiniStat(label: 'Пары', value: '${summary.total}'),
                    const SizedBox(width: 8),
                    _MiniStat(label: 'Точность', value: '$accuracy%'),
                    const SizedBox(width: 8),
                    _MiniStat(
                      label: 'Серия',
                      value:
                          summary.bestCombo > 0 ? '×${summary.bestCombo}' : '—',
                    ),
                  ],
                ),
                if (summary.missed.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'ОШИБКИ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                      color: PairlyColors.muted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final word in summary.missed)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                              child:
                                  Text(word.en, style: displayStyle(size: 16))),
                          Text(word.ru,
                              style:
                                  const TextStyle(color: PairlyColors.muted)),
                        ],
                      ),
                    ),
                ] else ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Все пары с первой попытки.',
                    style: TextStyle(color: PairlyColors.sage, fontSize: 14),
                  ),
                ],
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: PairlyColors.sage,
                      foregroundColor: PairlyColors.sageFg,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: onReplay,
                    child: const Text('Ещё раунд'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: PairlyColors.ink,
                      side: const BorderSide(color: PairlyColors.line),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('К категориям'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: PairlyColors.bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                  fontSize: 11, color: PairlyColors.subtle, letterSpacing: 0.6),
            ),
            const SizedBox(height: 4),
            Text(value, style: displayStyle(size: 20)),
          ],
        ),
      ),
    );
  }
}
