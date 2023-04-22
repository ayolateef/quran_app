import 'package:flutter/material.dart';
import 'package:quran_app/core/quran_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/chapter_verses_model.dart';

class SingleChapterPage extends StatefulWidget {
   final Chapter chapter;
  const SingleChapterPage({Key? key, required this.chapter}) : super(key: key);



  @override
  State<SingleChapterPage> createState() => _SingleChapterPageState();
}

class _SingleChapterPageState extends State<SingleChapterPage> {
  final QuranService _quranService = QuranService();
  List<Map<String, dynamic>> _verses = [];
  List<int> _bookmarkedVerses = [];
  // List<Verse> _verses = [];
  bool isLoading = true;
  // List<int> _bookmarkedVerses = [];
  String _error = '';

  @override
  void initState() {
    super.initState();
    _quranService.initLogger(); // Initialize logger
    _fetchVerses(); // Fetch verses data
    _loadBookmarkedVerses(); // Load bookmarked verses from shared preferences
  }

  void _fetchVerses() async {
    try {
      final verses = await _quranService.fetchVerses(widget.chapter.id);
      setState(() {
        _verses = verses;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to fetch verses data';
      });
      _quranService.logger.warning('Failed to fetch verses data: $e');
    }
  }

  // Load bookmarked verses from shared preferences
  void _loadBookmarkedVerses() async {
    // Load bookmarked verses from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList('bookmarks_${widget.chapter.id}') ?? [];
    setState(() {
      _bookmarkedVerses = bookmarks.map(int.parse).toList();
    });
  }

// Bookmark a verse
  void _bookmarkVerse(int verseId) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarkedVerses = prefs.getStringList('bookmarkedVerses') ?? [];
    bookmarkedVerses.add(verseId.toString());
    prefs.setStringList('bookmarkedVerses', bookmarkedVerses);
    setState(() {
      _bookmarkedVerses.add(verseId);
    });
  }

  // Remove bookmark from a verse
  void _removeBookmark(int verseId) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarkedVerses = prefs.getStringList('bookmarkedVerses') ?? [];
    bookmarkedVerses.remove(verseId.toString());
    prefs.setStringList('bookmarkedVerses', bookmarkedVerses);
    setState(() {
      _bookmarkedVerses.remove(verseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chapter ${widget.chapter.name}')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _verses.length,
        itemBuilder: (context, index) {
          final verse = _verses[index];
          final verseId = verse['id'];
          final verseText = verse['text'];
          final isBookmarked = _bookmarkedVerses.contains(verseId);
          return ListTile(
            title: Text('Verse $verseId'),
            subtitle: Text(verseText),
            trailing: isBookmarked
                ? IconButton(
              icon: const Icon(Icons.bookmark),
              onPressed: () => _removeBookmark(verseId),
            )
                : IconButton(
              icon: const Icon(Icons.bookmark_border),
              onPressed: () => _bookmarkVerse(verseId),
            ),
          );
        },
      ),
    );
  }
}
