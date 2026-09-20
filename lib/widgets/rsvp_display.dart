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
      letterSpacing: 1.1,
      color: textColor,
    );

    final orpStyle = baseStyle.copyWith(
      color: orpColor,
      fontWeight: FontWeight.bold,
    );

    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 540),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
              top: -24,
              child: Container(
                width: 3,
                height: 8,
                color: orpColor.withValues(alpha: 0.8),
              ),
            ),
            // Bottom crosshair tick
            Positioned(
              bottom: -24,
              child: Container(
                width: 3,
                height: 8,
                color: orpColor.withValues(alpha: 0.8),
              ),
            ),

            // Display content with FittedBox for perfect containment
            if (chunk != null && chunk!.tokens.isNotEmpty)
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
                child: chunk!.isMultiWord
                    ? Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: chunk!.word1, style: baseStyle),
                            TextSpan(
                              text: '   ',
                              style: baseStyle.copyWith(color: orpColor.withValues(alpha: 0.5)),
                            ),
                            TextSpan(text: chunk!.word2, style: baseStyle),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      )
                    : Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: chunk!.prefix, style: baseStyle),
                            TextSpan(text: chunk!.orpChar, style: orpStyle),
                            TextSpan(text: chunk!.suffix, style: baseStyle),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
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
