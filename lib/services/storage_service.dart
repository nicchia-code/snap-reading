import 'package:shared_preferences/shared_preferences.dart';

class ReadingProgress {
  final int chapterIndex;
  final int wordIndex;

  const ReadingProgress({required this.chapterIndex, required this.wordIndex});
}

class StorageService {
  static const String _wpmKey = 'snapreading_wpm';
  static const String _fontSizeKey = 'snapreading_fontsize';
  static const String _smartChunkingKey = 'snapreading_smart_chunking';
  static const String _lastBookKey = 'snapreading_last_book';
  static const String _prefixProgress = 'snapreading_progress_';

  static Future<bool> getSmartChunking() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_smartChunkingKey) ?? false;
  }

  static Future<void> setSmartChunking(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_smartChunkingKey, enabled);
  }

  static Future<int> getWpm() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_wpmKey) ?? 350;
  }

  static Future<void> setWpm(int wpm) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_wpmKey, wpm);
  }

  static Future<double> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_fontSizeKey) ?? 38.0;
  }

  static Future<void> setFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, size);
  }

  static Future<String?> getLastBookId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastBookKey);
  }

  static Future<void> setLastBookId(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastBookKey, bookId);
  }

  static Future<ReadingProgress> getProgress(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final chapter = prefs.getInt('$_prefixProgress${bookId}_chapter') ?? 0;
    final word = prefs.getInt('$_prefixProgress${bookId}_word') ?? 0;
    return ReadingProgress(chapterIndex: chapter, wordIndex: word);
  }

  static Future<void> saveProgress(String bookId, int chapterIndex, int wordIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_prefixProgress${bookId}_chapter', chapterIndex);
    await prefs.setInt('$_prefixProgress${bookId}_word', wordIndex);
  }
}
