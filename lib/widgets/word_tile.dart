import 'package:flutter/material.dart';

import '../models.dart';
import '../theme.dart';

class WordTile extends StatelessWidget {
  const WordTile({
    super.key,
    required this.text,
    required this.state,
    required this.onTap,
  });

  final String text;
  final WordVisual state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = switch (state) {
      WordVisual.idle => PairlyColors.surface,
      WordVisual.selected => PairlyColors.ink,
      WordVisual.wrong => PairlyColors.terraSoft,
      WordVisual.matched => PairlyColors.sage,
    };
    final fg = switch (state) {
      WordVisual.idle => PairlyColors.ink,
      WordVisual.selected => PairlyColors.surface,
      WordVisual.wrong => PairlyColors.terra,
      WordVisual.matched => PairlyColors.sageFg,
    };
    final border = switch (state) {
      WordVisual.idle => PairlyColors.line,
      WordVisual.selected => PairlyColors.ink,
      WordVisual.wrong => PairlyColors.terra,
      WordVisual.matched => PairlyColors.sage,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: displayStyle(size: 18, color: fg, height: 1.2),
                ),
                if (state == WordVisual.matched)
                  const Positioned(
                    top: 0,
                    right: 0,
                    child:
                        Icon(Icons.check, size: 14, color: PairlyColors.sageFg),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
