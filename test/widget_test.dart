import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snap_reading/models/book.dart';
import 'package:snap_reading/services/epub_service.dart';
import 'package:snap_reading/main.dart';

void main() {
  group('RSVP & WordToken Tests', () {
    test('Calculates correct ORP index for various word lengths', () {
      expect(WordToken.calculateOrpIndex('a'), 0);
      expect(WordToken.calculateOrpIndex('it'), 1);
      expect(WordToken.calculateOrpIndex('read'), 1);
      expect(WordToken.calculateOrpIndex('flutter'), 2);
      expect(WordToken.calculateOrpIndex('presentation'), 3);
      expect(WordToken.calculateOrpIndex('incomprehensibility'), 4);
    });

    test('Splits word into prefix, ORP, and suffix correctly', () {
      final token = WordToken.fromRaw('reading');
      // length 7 -> ORP index 2 ('a')
      expect(token.orpIndex, 2);
      expect(token.prefix, 're');
      expect(token.orpChar, 'a');
      expect(token.suffix, 'ding');
    });

    test('Applies pause multipliers on punctuation', () {
      final normal = WordToken.fromRaw('ciao');
      final comma = WordToken.fromRaw('ciao,');
      final period = WordToken.fromRaw('fine.');

      expect(normal.pauseMultiplier, 1.0);
      expect(comma.pauseMultiplier, 1.5);
      expect(period.pauseMultiplier, 2.0);
    });
  });

  group('EpubService Tests', () {
    test('Parses generated sample EPUB correctly', () {
      final file = File('assets/books/le_avventure_di_pinocchio.epub');
      expect(file.existsSync(), isTrue, reason: 'Sample EPUB must exist in assets/books');

      final bytes = file.readAsBytesSync();
      final book = EpubService.parseEpub(bytes, fallbackId: 'pinocchio');

      expect(book.title, 'Le Avventure di Pinocchio');
      expect(book.author, 'Carlo Collodi');
      expect(book.chapters.length, 3);
      expect(book.chapters[0].title, contains('Capitolo I'));
      expect(book.chapters[0].tokens.isNotEmpty, isTrue);
    });
  });

  group('App Smoke Test', () {
    testWidgets('Renders SnapReadingApp with fullscreen actions', (tester) async {
      await tester.pumpWidget(const SnapReadingApp());
      expect(find.text('SNAP'), findsOneWidget);
      expect(find.text('Reading'), findsOneWidget);
      expect(find.byIcon(Icons.fullscreen), findsOneWidget);
    });
  });
}
