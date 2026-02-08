import 'ap_course_chapters.dart';

/// AP English Literature chapters (condensed units with sample questions).
final List<APCourseChapter> apEnglishLiteratureChapters = [
  APCourseChapter(
    name: 'Literary Analysis',
    description: 'Reading and interpreting literature',
    unitNumber: 1,
    questions: [
      ChapterQuestion(
        questionText: 'A theme is best described as:',
        options: ['Central idea or insight', 'Plot summary', 'Setting only', 'Character list'],
        correctIndex: 0,
        explanation: 'Themes are central ideas or messages in a text.',
      ),
      ChapterQuestion(
        questionText: 'Tone refers to the author’s:',
        options: ['Attitude', 'Grammar', 'Length', 'Point of view only'],
        correctIndex: 0,
        explanation: 'Tone is the author’s attitude toward the subject.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Poetry',
    description: 'Forms, figurative language, and analysis',
    unitNumber: 2,
    questions: [
      ChapterQuestion(
        questionText: 'Metaphor is a:',
        options: ['Direct comparison', 'Sound device', 'Plot twist', 'Narrative perspective'],
        correctIndex: 0,
        explanation: 'Metaphor compares without using like/as.',
      ),
      ChapterQuestion(
        questionText: 'Iambic pentameter is:',
        options: ['Five iambs per line', 'Five syllables per line', 'Ten stresses per line', 'Any rhyme scheme'],
        correctIndex: 0,
        explanation: 'Iambic pentameter has five iambs per line.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Drama',
    description: 'Plays, structure, and performance',
    unitNumber: 3,
    questions: [
      ChapterQuestion(
        questionText: 'A soliloquy is:',
        options: ['A character’s spoken thoughts', 'A dialogue', 'Stage directions', 'Narration'],
        correctIndex: 0,
        explanation: 'Soliloquy reveals a character’s inner thoughts.',
      ),
      ChapterQuestion(
        questionText: 'Dramatic irony occurs when:',
        options: ['Audience knows more than characters', 'Characters speak in rhyme', 'Plot ends early', 'Tone is humorous'],
        correctIndex: 0,
        explanation: 'Dramatic irony is knowledge gap between audience and characters.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Prose Fiction',
    description: 'Narrative techniques and analysis',
    unitNumber: 4,
    questions: [
      ChapterQuestion(
        questionText: 'Point of view in first person uses:',
        options: ['I or we', 'He or she', 'They only', 'No pronouns'],
        correctIndex: 0,
        explanation: 'First person narration uses “I” or “we.”',
      ),
      ChapterQuestion(
        questionText: 'An unreliable narrator:',
        options: ['Cannot be fully trusted', 'Is always honest', 'Is omniscient', 'Is third person only'],
        correctIndex: 0,
        explanation: 'Unreliable narrators distort or withhold truth.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Literary Criticism',
    description: 'Critical lenses and analysis strategies',
    unitNumber: 5,
    questions: [
      ChapterQuestion(
        questionText: 'A feminist lens focuses on:',
        options: ['Gender roles and power', 'Historical dates', 'Scientific facts', 'Syntax only'],
        correctIndex: 0,
        explanation: 'Feminist criticism analyzes gender roles and power.',
      ),
      ChapterQuestion(
        questionText: 'A historical lens considers:',
        options: ['Context of the time', 'Character traits only', 'Plot twist only', 'Grammar only'],
        correctIndex: 0,
        explanation: 'Historical criticism examines time period context.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Writing & Argument',
    description: 'Essay structure and evidence',
    unitNumber: 6,
    questions: [
      ChapterQuestion(
        questionText: 'A strong thesis is:',
        options: ['Specific and arguable', 'A summary only', 'A quote', 'A question'],
        correctIndex: 0,
        explanation: 'Theses should be specific and arguable.',
      ),
      ChapterQuestion(
        questionText: 'Textual evidence should:',
        options: ['Support the claim', 'Replace analysis', 'Be unrelated', 'Be avoided'],
        correctIndex: 0,
        explanation: 'Evidence should directly support the claim.',
      ),
    ],
  ),
];
