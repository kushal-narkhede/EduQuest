/// Shared chapter/question models for AP course study content.

class APCourseChapter {
  final String name;
  final String description;
  final int unitNumber;
  final List<ChapterQuestion> questions;

  const APCourseChapter({
    required this.name,
    required this.description,
    required this.unitNumber,
    required this.questions,
  });
}

class ChapterQuestion {
  final String questionText;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const ChapterQuestion({
    required this.questionText,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}
