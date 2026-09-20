import 'package:flutter/material.dart';

import '../catalog.dart';
import '../progress.dart';
import '../theme.dart';
import 'play_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = ProgressScope.of(context);
    final learned = progress.masteredIds.length;
    final totalWords = kAllWords.length;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
          children: [
            Text(
              'ENGLISH · РУССКИЙ',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.2,
                color: PairlyColors.muted,
              ),
            ),
            const SizedBox(height: 12),
            Text('Pairly', style: displayStyle(size: 48, height: 0.95)),
            const SizedBox(height: 12),
            Text(
              'Слева английское слово, справа перевод. Нажмите пару — верные слова загорятся зелёным.',
              style: TextStyle(
                  fontSize: 16, height: 1.45, color: PairlyColors.muted),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.local_fire_department_outlined,
                    label: 'Серия дней',
                    value: '${progress.streak}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.menu_book_outlined,
                    label: 'Выучено',
                    value: '$learned',
                    hint: 'из $totalWords',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Material(
              color: PairlyColors.ink,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () =>
                    _openPlay(context, slug: 'daily', title: 'Микс дня'),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: PairlyColors.surface.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.shuffle,
                            color: PairlyColors.surface, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Микс дня',
                              style: displayStyle(
                                  size: 20, color: PairlyColors.surface),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Шесть случайных пар из всех тем',
                              style: TextStyle(
                                fontSize: 13,
                                color: PairlyColors.surface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Начать',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: PairlyColors.surface.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Text('Категории', style: displayStyle(size: 24)),
                const Spacer(),
                Text(
                  '${kCategories.length} тем',
                  style:
                      const TextStyle(fontSize: 12, color: PairlyColors.subtle),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final category in kCategories) ...[
              _CategoryTile(
                title: category.title,
                icon: category.icon,
                done: masteredInCategory(category.words, progress.masteredIds),
                total: category.words.length,
                onTap: () => _openPlay(context,
                    slug: category.slug, title: category.title),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }

  void _openPlay(BuildContext context,
      {required String slug, required String title}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlayScreen(slug: slug, title: title),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.hint,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: PairlyColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PairlyColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: PairlyColors.subtle),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.8,
                  color: PairlyColors.subtle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: displayStyle(size: 28)),
              if (hint != null) ...[
                const SizedBox(width: 6),
                Text(hint!,
                    style: const TextStyle(
                        fontSize: 13, color: PairlyColors.subtle)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.title,
    required this.icon,
    required this.done,
    required this.total,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final int done;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : done / total;
    return Material(
      color: PairlyColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PairlyColors.line),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: PairlyColors.surface2,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: PairlyColors.ink),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Text(title, style: displayStyle(size: 18))),
                        Text(
                          '$done/$total',
                          style: const TextStyle(
                              fontSize: 12, color: PairlyColors.subtle),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 4,
                        backgroundColor: PairlyColors.bg,
                        color:
                            ratio == 1 ? PairlyColors.sage : PairlyColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
