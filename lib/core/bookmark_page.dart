import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  BookmarksPageState createState() => BookmarksPageState();
}

class BookmarksPageState extends State<BookmarksPage> {
  List<int> bookmarkedVerses = [];

  @override
  void initState() {
    super.initState();
    loadBookmarkedVerses();
  }

  void loadBookmarkedVerses() async {
    // Load bookmarked verses from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList('bookmarks_${getCurrentIpAddress()}') ?? [];
    setState(() {
      bookmarkedVerses = bookmarks.map(int.parse).toList();
    });
  }

  String getCurrentIpAddress() {

    return '192.168.0.1';
  }

  void removeBookmark(int verseNumber) async {
    // Remove bookmark for the given verse number
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bookmarkedVerses.remove(verseNumber);
    });
    await prefs.setStringList('bookmarks_${getCurrentIpAddress()}', bookmarkedVerses.map((verseNumber) => verseNumber.toString()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: ListView.builder(
        itemCount: bookmarkedVerses.length,
        itemBuilder: (context, index) {
          final verseNumber = bookmarkedVerses[index];
          return ListTile(
            title: Text('Verse $verseNumber'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => removeBookmark(verseNumber),
            ),
          );
        },
      ),
    );
  }
}

