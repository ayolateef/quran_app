class Chapter {
  final int id;
  final String name;
  final int versesCount;

  Chapter({required this.id, required this.name, required this.versesCount});
}

class Verse {
  final int chapterId;
  final int number;
  final String text;
  bool isBookmarked;

  Verse(
      {required this.chapterId,
        required this.number,
        required this.text,
        this.isBookmarked = false});
}
