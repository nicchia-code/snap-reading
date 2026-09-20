import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/book.dart';
import '../services/epub_service.dart';
import '../services/storage_service.dart';
import 'reader_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  final List<Book> _books = [];
  final Map<String, ReadingProgress> _progressMap = {};

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _books.clear();
      _progressMap.clear();
    });

    try {
      // Find all assets in assets/books/ ending with .epub
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final allAssets = manifest.listAssets();
      final epubAssets = allAssets
          .where((path) => path.startsWith('assets/books/') && path.toLowerCase().endsWith('.epub'))
          .toList();

      if (epubAssets.isEmpty) {
        // Fallback check: try direct sample path if manifest filtering behaves differently
        epubAssets.add('assets/books/le_avventure_di_pinocchio.epub');
      }

      for (final assetPath in epubAssets) {
        try {
          final byteData = await rootBundle.load(assetPath);
          final bytes = byteData.buffer.asUint8List();
          final book = EpubService.parseEpub(bytes, fallbackId: assetPath);
          _books.add(book);

          final progress = await StorageService.getProgress(book.id);
          _progressMap[book.id] = progress;
        } catch (e) {
          debugPrint('Errore caricamento $assetPath: $e');
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Errore nel caricamento della libreria: $e';
      });
    }
  }

  void _openBook(Book book) {
    final progress = _progressMap[book.id] ?? const ReadingProgress(chapterIndex: 0, wordIndex: 0);

    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => ReaderScreen(
          book: book,
          initialChapterIndex: progress.chapterIndex,
          initialWordIndex: progress.wordIndex,
        ),
      ),
    )
        .then((_) {
      // Refresh progress upon return
      _refreshProgress();
    });
  }

  Future<void> _refreshProgress() async {
    for (final book in _books) {
      final progress = await StorageService.getProgress(book.id);
      _progressMap[book.id] = progress;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161616),
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF5252),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'SNAP',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Reading',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            tooltip: 'Ricarica libri',
            onPressed: _loadBooks,
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF5252),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadBooks,
                child: const Text('Riprova'),
              ),
            ],
          ),
        ),
      );
    }

    if (_books.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_stories, size: 64, color: Colors.grey[700]),
              const SizedBox(height: 16),
              const Text(
                'Nessun libro trovato in assets/books/',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Inserisci file .epub nella cartella assets/books/ del repository.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFFFF5252),
      onRefresh: _loadBooks,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _books.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final book = _books[index];
          final progress = _progressMap[book.id] ?? const ReadingProgress(chapterIndex: 0, wordIndex: 0);

          final currentChapterIndex = progress.chapterIndex.clamp(0, book.chapters.length - 1);
          final currentChap = book.chapters[currentChapterIndex];
          final chapWords = currentChap.wordCount;
          final percent = chapWords > 0 ? ((progress.wordIndex / chapWords) * 100).toInt().clamp(0, 100) : 0;

          return InkWell(
            onTap: () => _openBook(book),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF181818),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF262626)),
              ),
              child: Row(
                children: [
                  // Book icon / placeholder badge
                  Container(
                    width: 48,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF222222),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF333333)),
                    ),
                    child: const Icon(
                      Icons.book,
                      color: Color(0xFFFF5252),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book.author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '${book.chapters.length} capitoli',
                              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                            ),
                            const Text(' • ', style: TextStyle(color: Colors.grey)),
                            Text(
                              'Cap. ${currentChapterIndex + 1} ($percent%)',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFFFF5252),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white38),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
