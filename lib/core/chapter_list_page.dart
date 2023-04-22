import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quran_app/core/single_chapter_page.dart';
import 'models/chapter_verses_model.dart';

class ChaptersListPage extends StatefulWidget {
  const ChaptersListPage({Key? key}) : super(key: key);

  @override
  State<ChaptersListPage> createState() => _ChaptersListPageState();
}

class _ChaptersListPageState extends State<ChaptersListPage> {
  List<Chapter> chapters = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChapters();
  }

  void fetchChapters() async {
    // Fetch chapters data from the quran.com REST API
    final response =  await http.get(Uri.parse('https://api.quran.com/api/v4/chapters'));

    if (response.statusCode == 200) {
      // Parse the response and update the UI
      final List<dynamic> chaptersData = jsonDecode(response.body)['chapters'];
      setState(() {
        chapters = chaptersData
            .map((chapterData) => Chapter(
          id: chapterData['id'],
          name: chapterData['name_arabic'],
          versesCount: chapterData['verses_count'],
        ))
            .toList();
        isLoading = false;
      });
    } else {
      // Handle error
      print('Failed to fetch chapters: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chapters List')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          final chapter = chapters[index];
          return ListTile(
            title: Text(chapter.name),
            subtitle: Text('Verses: ${chapter.versesCount}'),
            onTap: () {
              // Navigate to SingleChapterPage with the selected chapter
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SingleChapterPage(chapter: chapter),
                ),
              );
            },
          );
        },
      ),
    );
  }
}




