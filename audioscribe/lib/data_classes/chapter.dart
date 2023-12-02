class Chapter {
  String title;
  String contents;

  Chapter({required this.title, required this.contents});
}

Map<int, Chapter> chapters = {};
// Thanks to Chatgpt for helping with Regex
RegExp chapterRegex = RegExp(r"Chapter (\d+)(.*?)(?=\r?\n|$)");

parseChapters(String text) {
  Iterable<RegExpMatch> matches = chapterRegex.allMatches(text);

  for (int i = 0; i < matches.length; i++) {
    var match = matches.elementAt(i);
    int chapterNumber = int.parse(match.group(1)!);

    // Check for a title after the Chapter <number>
    // match.group(2)!.trim() should grab everything after Chapter <n> and remove whitespace
    String titlePart = match.group(2)!.trim();
    String chapterTitle =
        titlePart.isEmpty ? "Chapter $chapterNumber" : titlePart;

    int start = match.end;
    int end =
        i == matches.length - 1 ? text.length : matches.elementAt(i + 1).start;

    String chapterContent = text.substring(start, end).trim();

    chapters[chapterNumber] =
        Chapter(title: chapterTitle, contents: chapterContent);
  }
  return chapters;
}
