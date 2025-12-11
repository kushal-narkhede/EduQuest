class TextbookChapter {
  final int chapterNumber;
  final String chapterName;
  final String context;
  final List<String> exercises;
  final List<String> resources;

  const TextbookChapter({
    required this.chapterNumber,
    required this.chapterName,
    required this.context,
    required this.exercises,
    required this.resources,
  });

  factory TextbookChapter.fromJson(Map<String, dynamic> json) {
    return TextbookChapter(
      chapterNumber: json['chapter_number'] ?? 0,
      chapterName: json['chapter_name'] ?? '',
      context: json['context'] ?? '',
      exercises: List<String>.from(json['exercises'] ?? []),
      resources: List<String>.from(json['resources'] ?? []),
    );
  }
}

class TextbookUnit {
  final String id;
  final int unitNumber;
  final String unitTitle;
  final List<TextbookChapter> chapters;

  const TextbookUnit({
    required this.id,
    required this.unitNumber,
    required this.unitTitle,
    required this.chapters,
  });

  factory TextbookUnit.fromJson(Map<String, dynamic> json) {
    return TextbookUnit(
      id: json['_id'] ?? '',
      unitNumber: json['unit_number'] ?? 0,
      unitTitle: json['unit_title'] ?? '',
      chapters: (json['chapters'] as List?)
              ?.map((ch) => TextbookChapter.fromJson(ch))
              .toList() ??
          [],
    );
  }
}
