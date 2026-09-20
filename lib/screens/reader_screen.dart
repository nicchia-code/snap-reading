import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/book.dart';
import '../services/storage_service.dart';
import '../widgets/reader_drawer.dart';
import '../widgets/rsvp_display.dart';

class ReaderScreen extends StatefulWidget {
  final Book book;
  final int initialChapterIndex;
  final int initialWordIndex;

  const ReaderScreen({
    super.key,
    required this.book,
    this.initialChapterIndex = 0,
    this.initialWordIndex = 0,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FocusNode _focusNode = FocusNode();

  late int _currentChapterIndex;
  late int _currentWordIndex;
  int _wpm = 350;
  double _fontSize = 38.0;
  bool _isPlaying = false;
  Timer? _stepTimer;

  Chapter get _currentChapter => widget.book.chapters[_currentChapterIndex];
  WordToken? get _currentToken {
    if (_currentWordIndex >= 0 && _currentWordIndex < _currentChapter.tokens.length) {
      return _currentChapter.tokens[_currentWordIndex];
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _currentChapterIndex = widget.initialChapterIndex.clamp(0, widget.book.chapters.length - 1);
    final maxWords = widget.book.chapters[_currentChapterIndex].wordCount;
    _currentWordIndex = widget.initialWordIndex.clamp(0, maxWords > 0 ? maxWords - 1 : 0);

    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final savedWpm = await StorageService.getWpm();
    final savedFont = await StorageService.getFontSize();
    if (mounted) {
      setState(() {
        _wpm = savedWpm;
        _fontSize = savedFont;
      });
    }
  }

  @override
  void dispose() {
    _stopPlayback();
    _saveProgress();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveProgress() {
    StorageService.saveProgress(widget.book.id, _currentChapterIndex, _currentWordIndex);
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _pausePlayback();
    } else {
      _startPlayback();
    }
  }

  void _startPlayback() {
    // If we're at the end of the chapter, wrap or advance
    if (_currentWordIndex >= _currentChapter.tokens.length - 1) {
      if (_currentChapterIndex < widget.book.chapters.length - 1) {
        _currentChapterIndex++;
        _currentWordIndex = 0;
      } else {
        _currentWordIndex = 0;
      }
    }

    setState(() {
      _isPlaying = true;
    });
    _scheduleNextWord();
  }

  void _pausePlayback() {
    _stopPlayback();
    setState(() {
      _isPlaying = false;
    });
    _saveProgress();
  }

  void _stopPlayback() {
    _stepTimer?.cancel();
    _stepTimer = null;
  }

  void _scheduleNextWord() {
    if (!_isPlaying || !mounted) return;

    final token = _currentToken;
    final baseDurationMs = (60000 / _wpm).round();
    final multiplier = token?.pauseMultiplier ?? 1.0;
    final delayMs = (baseDurationMs * multiplier).round().clamp(20, 2000);

    _stepTimer = Timer(Duration(milliseconds: delayMs), () {
      if (!_isPlaying || !mounted) return;

      if (_currentWordIndex < _currentChapter.tokens.length - 1) {
        setState(() {
          _currentWordIndex++;
        });
        _scheduleNextWord();
      } else {
        // End of chapter reached
        if (_currentChapterIndex < widget.book.chapters.length - 1) {
          // Pause slightly between chapters
          setState(() {
            _currentChapterIndex++;
            _currentWordIndex = 0;
          });
          _saveProgress();
          _stepTimer = Timer(const Duration(milliseconds: 900), _scheduleNextWord);
        } else {
          // End of entire book
          _pausePlayback();
        }
      }
    });
  }

  void _seekRelative(int offset) {
    setState(() {
      final newIndex = (_currentWordIndex + offset).clamp(0, _currentChapter.tokens.length - 1);
      _currentWordIndex = newIndex;
    });
    _saveProgress();
  }

  void _changeWpm(int newWpm) {
    setState(() {
      _wpm = newWpm;
    });
    StorageService.setWpm(newWpm);
  }

  void _changeFontSize(double newSize) {
    setState(() {
      _fontSize = newSize;
    });
    StorageService.setFontSize(newSize);
  }

  void _selectChapter(int index) {
    _pausePlayback();
    setState(() {
      _currentChapterIndex = index.clamp(0, widget.book.chapters.length - 1);
      _currentWordIndex = 0;
    });
    _saveProgress();
  }

  void _seekWord(int index) {
    setState(() {
      _currentWordIndex = index.clamp(0, _currentChapter.tokens.length - 1);
    });
    _saveProgress();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space) {
        _togglePlayPause();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _seekRelative(-10);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _seekRelative(10);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _changeWpm((_wpm + 25).clamp(150, 900));
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _changeWpm((_wpm - 25).clamp(150, 900));
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final chapterWords = _currentChapter.wordCount;
    final progressFraction = chapterWords > 0 ? (_currentWordIndex / chapterWords).clamp(0.0, 1.0) : 0.0;

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFF101010),
        endDrawer: ReaderDrawer(
          book: widget.book,
          currentChapterIndex: _currentChapterIndex,
          currentWordIndex: _currentWordIndex,
          wpm: _wpm,
          fontSize: _fontSize,
          onWpmChanged: _changeWpm,
          onFontSizeChanged: _changeFontSize,
          onChapterSelected: _selectChapter,
          onWordSeek: _seekWord,
          onBackToLibrary: () => Navigator.of(context).pop(),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              // Main Tap Area for RSVP
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _togglePlayPause,
                child: SizedBox.expand(
                  child: Center(
                    child: RsvpDisplay(
                      token: _currentToken,
                      fontSize: _fontSize,
                      isPlaying: _isPlaying,
                    ),
                  ),
                ),
              ),

              // Minimal Top Bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: _isPlaying ? 0.25 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back to Library Button
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white70),
                          tooltip: 'Libreria',
                          onPressed: () {
                            _pausePlayback();
                            Navigator.of(context).pop();
                          },
                        ),
                        // Chapter Title
                        Expanded(
                          child: Text(
                            _currentChapter.title,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        // Open Settings & Stats Drawer
                        IconButton(
                          icon: const Icon(Icons.menu_rounded, size: 24, color: Colors.white70),
                          tooltip: 'Controlli e Statistiche',
                          onPressed: () {
                            _pausePlayback();
                            _scaffoldKey.currentState?.openEndDrawer();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Minimal Bottom Status & Progress Bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: _isPlaying ? 0.35 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Sub-progress controls
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Rewind 10 words button
                            IconButton(
                              icon: const Icon(Icons.replay_10, size: 22, color: Colors.white60),
                              tooltip: '-10 parole',
                              onPressed: () => _seekRelative(-10),
                            ),
                            // Play/Pause pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFF333333)),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _isPlaying ? Icons.pause : Icons.play_arrow,
                                    size: 14,
                                    color: const Color(0xFFFF5252),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$_wpm WPM',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Forward 10 words button
                            IconButton(
                              icon: const Icon(Icons.forward_10, size: 22, color: Colors.white60),
                              tooltip: '+10 parole',
                              onPressed: () => _seekRelative(10),
                            ),
                          ],
                        ),
                      ),
                      // Chapter Progress Line
                      LinearProgressIndicator(
                        value: progressFraction,
                        minHeight: 3,
                        backgroundColor: const Color(0xFF222222),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF5252)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
