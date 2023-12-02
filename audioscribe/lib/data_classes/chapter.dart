class Chapter {
  String title;
  String contents;

  Chapter({required this.title, required this.contents});
}

Map<int, Chapter> chapters = {};
// Thanks to Chatgpt for helping with Regex
RegExp chapterRegex = RegExp(r"Chapter (\d+)(:?\s*(.*?))?\b");

// Need to add the following things
// 1. If no chapter titles found - set to chapter <number>
// 2. If no chapters found - either ignore it (so just return null) or set the whole thing to 1 chapter
parseChapters(String text) {
  Iterable<RegExpMatch> matches = chapterRegex.allMatches(text);

  for (int i = 0; i < matches.length; i++) {
    var match = matches.elementAt(i);
    int chapterNumber = int.parse(match.group(1)!);

    // Use the provided title or default to "Chapter <number>" if no title is given
    String? chapterTitle = match.group(3)?.trim();
    if (chapterTitle == null || chapterTitle.isEmpty) {
      chapterTitle = "Chapter $chapterNumber";
    }

    int start = match.end;
    int end =
        i == matches.length - 1 ? text.length : matches.elementAt(i + 1).start;

    String chapterContent = text.substring(start, end).trim();

    chapters[chapterNumber] =
        Chapter(title: chapterTitle, contents: chapterContent);
  }
  return chapters;
}
