import 'package:flutter/material.dart';

class Word {
  const Word({required this.id, required this.en, required this.ru});

  final String id;
  final String en;
  final String ru;
}

class Category {
  const Category({
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.words,
  });

  final String slug;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Word> words;
}

class WordStat {
  const WordStat({this.hits = 0, this.misses = 0});

  final int hits;
  final int misses;

  WordStat copyWith({int? hits, int? misses}) {
    return WordStat(hits: hits ?? this.hits, misses: misses ?? this.misses);
  }

  Map<String, dynamic> toJson() => {'hits': hits, 'misses': misses};

  factory WordStat.fromJson(Map<String, dynamic> json) {
    return WordStat(
      hits: (json['hits'] as num?)?.toInt() ?? 0,
      misses: (json['misses'] as num?)?.toInt() ?? 0,
    );
  }
}

enum Side { en, ru }

enum WordVisual { idle, selected, wrong, matched }

class Selection {
  const Selection({required this.side, required this.id});

  final Side side;
  final String id;
}

class RoundSummary {
  const RoundSummary({
    required this.title,
    required this.total,
    required this.correct,
    required this.wrong,
    required this.bestCombo,
    required this.missed,
  });

  final String title;
  final int total;
  final int correct;
  final int wrong;
  final int bestCombo;
  final List<Word> missed;
}
