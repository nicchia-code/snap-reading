class WordToken {
  final String raw;
  final String word;
  final int orpIndex;
  final double pauseMultiplier;

  WordToken({
    required this.raw,
    required this.word,
    required this.orpIndex,
    required this.pauseMultiplier,
  });

  /// Factory that calculates ORP and punctuation pause
  factory WordToken.fromRaw(String raw) {
    // Strip trailing/leading punctuation for word measurement
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return WordToken(raw: '', word: '', orpIndex: 0, pauseMultiplier: 1.0);
    }

    final orp = calculateOrpIndex(trimmed);
    final multiplier = calculatePauseMultiplier(trimmed);

    return WordToken(
      raw: raw,
      word: trimmed,
      orpIndex: orp.clamp(0, trimmed.length - 1),
      pauseMultiplier: multiplier,
    );
  }

  /// Classical Spritz ORP algorithm
  static int calculateOrpIndex(String word) {
    final len = word.length;
    if (len <= 1) return 0;
    if (len <= 5) return 1;
    if (len <= 9) return 2;
    if (len <= 13) return 3;
    return 4;
  }

  static double calculatePauseMultiplier(String word) {
    if (word.isEmpty) return 1.0;
    final lastChar = word[word.length - 1];
    if (lastChar == '.' || lastChar == '!' || lastChar == '?' || lastChar == ':') {
      return 2.0;
    }
    if (lastChar == ',' || lastChar == ';' || lastChar == '-' || lastChar == '—') {
      return 1.5;
    }
    if (word.length > 10) {
      return 1.2;
    }
    return 1.0;
  }

  String get prefix => word.isEmpty ? '' : word.substring(0, orpIndex);
  String get orpChar => word.isEmpty ? '' : word.substring(orpIndex, orpIndex + 1);
  String get suffix => (word.length > orpIndex + 1) ? word.substring(orpIndex + 1) : '';
}

class ReadingChunk {
  final List<WordToken> tokens;
  final int startIndex;

  ReadingChunk({required this.tokens, required this.startIndex});

  bool get isMultiWord => tokens.length > 1;
  int get wordCount => tokens.length;

  /// Relative weight: 1.0 for 1 word, 1.35 for 2-word foveal chunk
  /// scaled by the last token's pause multiplier
  double get weight {
    final base = isMultiWord ? 1.35 : 1.0;
    return base * tokens.last.pauseMultiplier;
  }

  // 1-word Spritz ORP helpers
  String get prefix => tokens.first.prefix;
  String get orpChar => tokens.first.orpChar;
  String get suffix => tokens.first.suffix;

  // 2-word Chunk helpers
  String get word1 => tokens.first.word;
  String get word2 => tokens.length > 1 ? tokens[1].word : '';
}

class Chapter {
  final String title;
  final List<WordToken> tokens;

  Chapter({
    required this.title,
    required this.tokens,
  });

  int get wordCount => tokens.length;

  List<ReadingChunk> buildChunks({required bool smartChunking}) {
    if (!smartChunking) {
      return List.generate(
        tokens.length,
        (i) => ReadingChunk(tokens: [tokens[i]], startIndex: i),
      );
    }

    final chunks = <ReadingChunk>[];
    int i = 0;
    while (i < tokens.length) {
      final t1 = tokens[i];
      if (i + 1 < tokens.length) {
        final t2 = tokens[i + 1];
        // Smart Chunking rules:
        // 1. Combined length with space <= 11 characters (foveal field limit)
        // 2. First token has no strong punctuation pause
        final combinedLen = t1.word.length + 1 + t2.word.length;
        if (combinedLen <= 11 && t1.pauseMultiplier == 1.0) {
          chunks.add(ReadingChunk(tokens: [t1, t2], startIndex: i));
          i += 2;
          continue;
        }
      }
      chunks.add(ReadingChunk(tokens: [t1], startIndex: i));
      i += 1;
    }
    return chunks;
  }
}

class Book {
  final String id;
  final String title;
  final String author;
  final List<Chapter> chapters;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.chapters,
  });

  int get totalWords => chapters.fold(0, (sum, chap) => sum + chap.wordCount);
}
