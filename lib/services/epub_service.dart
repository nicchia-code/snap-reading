import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:xml/xml.dart';
import '../models/book.dart';

class EpubService {
  /// Parse an EPUB byte buffer into a Book model
  static Book parseEpub(Uint8List bytes, {String fallbackId = 'book'}) {
    final archive = ZipDecoder().decodeBytes(bytes);

    // 1. Locate rootfile from META-INF/container.xml
    String opfPath = 'OEBPS/content.opf';
    final containerFile = archive.findFile('META-INF/container.xml');
    if (containerFile != null) {
      try {
        final containerXml = utf8.decode(containerFile.content as List<int>);
        final doc = XmlDocument.parse(containerXml);
        final rootfile = doc.findAllElements('rootfile').firstOrNull;
        if (rootfile != null) {
          final fullPath = rootfile.getAttribute('full-path');
          if (fullPath != null && fullPath.isNotEmpty) {
            opfPath = fullPath;
          }
        }
      } catch (_) {
        // Fallback to default
      }
    }

    // 2. Read OPF file
    ArchiveFile? opfFile = archive.findFile(opfPath);
    if (opfFile == null) {
      // Search for any .opf file in the zip
      for (final file in archive.files) {
        if (file.name.toLowerCase().endsWith('.opf')) {
          opfFile = file;
          opfPath = file.name;
          break;
        }
      }
    }

    if (opfFile == null) {
      throw Exception('Formato EPUB non valido: file OPF mancante.');
    }

    final opfDir = opfPath.contains('/')
        ? opfPath.substring(0, opfPath.lastIndexOf('/') + 1)
        : '';
    final opfContent = utf8.decode(opfFile.content as List<int>);
    final opfDoc = XmlDocument.parse(opfContent);

    // Metadata
    final titleElem = opfDoc.findAllElements('dc:title').firstOrNull ??
        opfDoc.findAllElements('title').firstOrNull;
    final title = titleElem?.innerText.trim().isNotEmpty == true
        ? titleElem!.innerText.trim()
        : 'Libro senza titolo';

    final authorElem = opfDoc.findAllElements('dc:creator').firstOrNull ??
        opfDoc.findAllElements('creator').firstOrNull;
    final author = authorElem?.innerText.trim().isNotEmpty == true
        ? authorElem!.innerText.trim()
        : 'Autore sconosciuto';

    // Manifest: id -> relative href (using name.local to support any XML prefix/default namespace)
    final manifestMap = <String, String>{};
    for (final item in opfDoc.descendants.whereType<XmlElement>().where((e) => e.name.local == 'item')) {
      final id = item.getAttribute('id');
      final href = item.getAttribute('href');
      if (id != null && href != null) {
        manifestMap[id] = href;
      }
    }

    // Spine: ordered list of itemrefs
    final spineIds = <String>[];
    final spine = opfDoc.descendants.whereType<XmlElement>().where((e) => e.name.local == 'spine').firstOrNull;
    if (spine != null) {
      for (final itemref in spine.descendants.whereType<XmlElement>().where((e) => e.name.local == 'itemref')) {
        final idref = itemref.getAttribute('idref');
        if (idref != null) {
          spineIds.add(idref);
        }
      }
    }

    // Process chapters
    final chapters = <Chapter>[];
    int chapterCounter = 1;

    for (final idref in spineIds) {
      final href = manifestMap[idref];
      if (href == null) continue;

      // Normalize zip file path
      final fullPath = _resolvePath(opfDir, href);
      ArchiveFile? file = archive.findFile(fullPath);
      file ??= archive.files.cast<ArchiveFile?>().firstWhere(
            (f) => f != null && f.name.toLowerCase() == fullPath.toLowerCase(),
            orElse: () => null,
          );

      if (file == null) continue;

      final contentBytes = file.content as List<int>;
      final html = utf8.decode(contentBytes, allowMalformed: true);

      final (chapterTitle, cleanText) = _extractChapterData(html, defaultTitle: 'Capitolo $chapterCounter');

      // Tokenize text into words
      final tokens = _tokenize(cleanText);
      if (tokens.isNotEmpty) {
        chapters.add(Chapter(
          title: chapterTitle,
          tokens: tokens,
        ));
        chapterCounter++;
      }
    }

    // Fallback if no spine chapters found
    if (chapters.isEmpty) {
      chapters.add(Chapter(
        title: 'Contenuto',
        tokens: [WordToken.fromRaw('Nessun'), WordToken.fromRaw('testo'), WordToken.fromRaw('trovato.')],
      ));
    }

    return Book(
      id: fallbackId,
      title: title,
      author: author,
      chapters: chapters,
    );
  }

  static String _resolvePath(String baseDir, String relativePath) {
    if (baseDir.isEmpty) return relativePath;
    final combined = baseDir + relativePath;
    final parts = combined.split('/');
    final resolved = <String>[];
    for (final part in parts) {
      if (part == '.' || part.isEmpty) continue;
      if (part == '..') {
        if (resolved.isNotEmpty) resolved.removeLast();
      } else {
        resolved.add(part);
      }
    }
    return resolved.join('/');
  }

  static (String, String) _extractChapterData(String html, {required String defaultTitle}) {
    String title = defaultTitle;

    // Try finding title in <h1> or <h2> or <title>
    final h1Match = RegExp(r'<h[12][^>]*>(.*?)</h[12]>', caseSensitive: false, dotAll: true).firstMatch(html);
    if (h1Match != null) {
      final text = _stripHtml(h1Match.group(1) ?? '');
      if (text.isNotEmpty && text.length < 80) {
        title = text;
      }
    } else {
      final titleMatch = RegExp(r'<title[^>]*>(.*?)</title>', caseSensitive: false, dotAll: true).firstMatch(html);
      if (titleMatch != null) {
        final text = _stripHtml(titleMatch.group(1) ?? '');
        if (text.isNotEmpty && text.length < 80) {
          title = text;
        }
      }
    }

    final cleanText = _stripHtml(html);
    return (title, cleanText);
  }

  static String _stripHtml(String html) {
    // Replace breaks and paragraphs with spaces
    var text = html
        .replaceAll(RegExp(r'<style[\s\S]*?</style>', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'<script[\s\S]*?</script>', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'</?(?:p|div|br|h[1-6]|li|blockquote)[^>]*>', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'<[^>]+>'), ' ');

    // Decode standard HTML entities
    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'")
        .replaceAll('&#39;', "'")
        .replaceAll('&mdash;', '—')
        .replaceAll('&ndash;', '–')
        .replaceAll('&hellip;', '...');

    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static List<WordToken> _tokenize(String text) {
    if (text.isEmpty) return [];
    final words = text.split(RegExp(r'\s+'));
    final result = <WordToken>[];
    for (final w in words) {
      final trimmed = w.trim();
      if (trimmed.isNotEmpty) {
        result.add(WordToken.fromRaw(trimmed));
      }
    }
    return result;
  }
}
