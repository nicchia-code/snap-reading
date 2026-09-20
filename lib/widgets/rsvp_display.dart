import 'package:flutter/material.dart';
import '../models/book.dart';

class RsvpDisplay extends StatelessWidget {
  final ReadingChunk? chunk;
  final double fontSize;
  final bool isPlaying;

  const RsvpDisplay({
    super.key,
    required this.chunk,
    required this.fontSize,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    const reticleColor = Color(0xFF383838);
    const orpColor = Color(0xFFFF5252);
    const textColor = Colors.white;

    final baseStyle = TextStyle(
      fontSize: fontSize,
      fontFamily: 'monospace',
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
      color: textColor,
    );

    final orpStyle = baseStyle.copyWith(
      color: orpColor,
      fontWeight: FontWeight.bold,
    );

    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 580),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: reticleColor, width: 2),
            bottom: BorderSide(color: reticleColor, width: 2),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Top crosshair tick
            Positioned(
              top: -28,
              child: Container(
                width: 3,
                height: 10,
                color: orpColor.withValues(alpha: 0.8),
              ),
            ),
            // Bottom crosshair tick
            Positioned(
              bottom: -28,
              child: Container(
                width: 3,
                height: 10,
                color: orpColor.withValues(alpha: 0.8),
              ),
            ),

            // Display content
            if (chunk != null && chunk!.tokens.isNotEmpty)
              if (chunk!.isMultiWord)
                // 2-Word Smart Chunk: focal center between word1 and word2
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        chunk!.word1,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: baseStyle,
                      ),
                    ),
                    // Centered gap where crosshairs meet
                    Container(
                      width: 14,
                      alignment: Alignment.center,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: orpColor.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        chunk!.word2,
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: baseStyle,
                      ),
                    ),
                  ],
                )
              else
                // 1-Word Spritz ORP: pivot letter anchored dead-center
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        chunk!.prefix,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: baseStyle,
                      ),
                    ),
                    Text(
                      chunk!.orpChar,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: orpStyle,
                    ),
                    Expanded(
                      child: Text(
                        chunk!.suffix,
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: baseStyle,
                      ),
                    ),
                  ],
                )
            else
              Text(
                isPlaying ? 'Caricamento...' : 'Tocca per iniziare',
                style: TextStyle(
                  fontSize: fontSize * 0.45,
                  color: Colors.grey[500],
                  letterSpacing: 0.8,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
