import 'package:flutter/material.dart';
import '../models/book.dart';

class RsvpDisplay extends StatelessWidget {
  final WordToken? token;
  final double fontSize;
  final bool isPlaying;

  const RsvpDisplay({
    super.key,
    required this.token,
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
        constraints: const BoxConstraints(maxWidth: 540),
        margin: const EdgeInsets.symmetric(horizontal: 24),
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

            // RSVP Word with anchored ORP
            if (token != null && token!.word.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Left side (aligned to right)
                  Expanded(
                    child: Text(
                      token!.prefix,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: baseStyle,
                    ),
                  ),
                  // Centered ORP anchor character
                  Text(
                    token!.orpChar,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: orpStyle,
                  ),
                  // Right side (aligned to left)
                  Expanded(
                    child: Text(
                      token!.suffix,
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
