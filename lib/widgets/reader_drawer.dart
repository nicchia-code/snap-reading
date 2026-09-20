import 'package:flutter/material.dart';
import '../models/book.dart';

class ReaderDrawer extends StatelessWidget {
  final Book book;
  final int currentChapterIndex;
  final int currentWordIndex;
  final int wpm;
  final double fontSize;
  final ValueChanged<int> onWpmChanged;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<int> onChapterSelected;
  final ValueChanged<int> onWordSeek;
  final VoidCallback onBackToLibrary;

  const ReaderDrawer({
    super.key,
    required this.book,
    required this.currentChapterIndex,
    required this.currentWordIndex,
    required this.wpm,
    required this.fontSize,
    required this.onWpmChanged,
    required this.onFontSizeChanged,
    required this.onChapterSelected,
    required this.onWordSeek,
    required this.onBackToLibrary,
  });

  @override
  Widget build(BuildContext context) {
    final currentChapter = book.chapters[currentChapterIndex];
    final chapterWords = currentChapter.wordCount;
    final wordsLeft = (chapterWords - currentWordIndex).clamp(0, chapterWords);
    final minutesLeft = (wordsLeft / wpm).ceil();
    final progressFraction = chapterWords > 0 ? (currentWordIndex / chapterWords).clamp(0.0, 1.0) : 0.0;
    final progressPercent = (progressFraction * 100).toInt();

    return Drawer(
      backgroundColor: const Color(0xFF161616),
      surfaceTintColor: Colors.transparent,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          book.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF282828), height: 1),

            // Scrollable Settings & Stats
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  // Real-time Stats Grid
                  const Text(
                    'STATISTICHE DI LETTURA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF5252),
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _StatCard(
                        title: 'Progresso',
                        value: '$progressPercent%',
                        subtitle: '$currentWordIndex / $chapterWords parole',
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        title: 'Tempo Rimasto',
                        value: '$minutesLeft min',
                        subtitle: '$wordsLeft parole rimanenti',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'VELOCITÀ (WPM)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF5252),
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$wpm WPM',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          _QuickSpeedButton(
                            label: '-50',
                            onTap: () => onWpmChanged((wpm - 50).clamp(150, 900)),
                          ),
                          const SizedBox(width: 6),
                          _QuickSpeedButton(
                            label: '-25',
                            onTap: () => onWpmChanged((wpm - 25).clamp(150, 900)),
                          ),
                          const SizedBox(width: 6),
                          _QuickSpeedButton(
                            label: '+25',
                            onTap: () => onWpmChanged((wpm + 25).clamp(150, 900)),
                          ),
                          const SizedBox(width: 6),
                          _QuickSpeedButton(
                            label: '+50',
                            onTap: () => onWpmChanged((wpm + 50).clamp(150, 900)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFFFF5252),
                      inactiveTrackColor: const Color(0xFF333333),
                      thumbColor: const Color(0xFFFF5252),
                      overlayColor: const Color(0xFFFF5252).withValues(alpha: 0.2),
                    ),
                    child: Slider(
                      min: 150,
                      max: 900,
                      divisions: 30,
                      value: wpm.toDouble(),
                      onChanged: (val) => onWpmChanged(val.round()),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'DIMENSIONE CARATTERE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF5252),
                      letterSpacing: 1.1,
                    ),
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: const Color(0xFF333333),
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      min: 24,
                      max: 56,
                      value: fontSize,
                      onChanged: onFontSizeChanged,
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'POSIZIONE NEL CAPITOLO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF5252),
                      letterSpacing: 1.1,
                    ),
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFFFF5252),
                      inactiveTrackColor: const Color(0xFF333333),
                      thumbColor: const Color(0xFFFF5252),
                    ),
                    child: Slider(
                      min: 0,
                      max: (chapterWords > 1 ? chapterWords - 1 : 1).toDouble(),
                      value: currentWordIndex.toDouble().clamp(0, (chapterWords > 1 ? chapterWords - 1 : 1).toDouble()),
                      onChanged: (val) => onWordSeek(val.toInt()),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    'CAPITOLI',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF5252),
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(book.chapters.length, (index) {
                    final chap = book.chapters[index];
                    final isCurrent = index == currentChapterIndex;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: isCurrent ? const Color(0xFF262626) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isCurrent
                            ? Border.all(color: const Color(0xFFFF5252).withValues(alpha: 0.5))
                            : null,
                      ),
                      child: ListTile(
                        dense: true,
                        title: Text(
                          chap.title,
                          style: TextStyle(
                            color: isCurrent ? Colors.white : Colors.grey[400],
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        trailing: Text(
                          '${chap.wordCount} parole',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        onTap: () {
                          onChapterSelected(index);
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),

            const Divider(color: Color(0xFF282828), height: 1),
            // Bottom Action
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF444444)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.auto_stories, size: 18),
                label: const Text('Libreria'),
                onPressed: () {
                  Navigator.of(context).pop();
                  onBackToLibrary();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF202020),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF2F2F2F)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 11, color: Colors.grey[400]),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickSpeedButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickSpeedButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF262626),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF383838)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
