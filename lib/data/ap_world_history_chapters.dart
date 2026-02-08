import 'ap_course_chapters.dart';

/// AP World History chapters (condensed units with sample questions).
final List<APCourseChapter> apWorldHistoryChapters = [
  APCourseChapter(
    name: '1200–1450',
    description: 'Global tapestry and regional interactions',
    unitNumber: 1,
    questions: [
      ChapterQuestion(
        questionText: 'The Silk Roads primarily connected:',
        options: ['Asia and Europe', 'Africa and Americas', 'Australia and Europe', 'Antarctica and Asia'],
        correctIndex: 0,
        explanation: 'The Silk Roads linked Asia with Europe.',
      ),
      ChapterQuestion(
        questionText: 'A major trade network in the Indian Ocean involved:',
        options: ['Monsoon winds', 'Railroads', 'Air travel', 'Polar routes'],
        correctIndex: 0,
        explanation: 'Monsoon winds enabled predictable sailing patterns.',
      ),
    ],
  ),
  APCourseChapter(
    name: '1450–1750',
    description: 'Transoceanic interconnections',
    unitNumber: 2,
    questions: [
      ChapterQuestion(
        questionText: 'The Columbian Exchange refers to:',
        options: ['Transfer of goods, people, and diseases', 'Peace treaty', 'Industrialization', 'Feudalism'],
        correctIndex: 0,
        explanation: 'It was the exchange between the Old and New Worlds.',
      ),
      ChapterQuestion(
        questionText: 'Mercantilism emphasized:',
        options: ['Accumulating wealth through trade', 'Free trade only', 'Isolationism', 'Democracy'],
        correctIndex: 0,
        explanation: 'Mercantilism focused on wealth through controlled trade.',
      ),
    ],
  ),
  APCourseChapter(
    name: '1750–1900',
    description: 'Revolutions and industrialization',
    unitNumber: 3,
    questions: [
      ChapterQuestion(
        questionText: 'The Industrial Revolution began in:',
        options: ['Britain', 'China', 'India', 'Spain'],
        correctIndex: 0,
        explanation: 'The Industrial Revolution began in Britain.',
      ),
      ChapterQuestion(
        questionText: 'The French Revolution was influenced by:',
        options: ['Enlightenment ideas', 'Cold War tensions', 'Renaissance art', 'Feudal Japan'],
        correctIndex: 0,
        explanation: 'Enlightenment ideas inspired revolutionary change.',
      ),
    ],
  ),
  APCourseChapter(
    name: '1900–Present',
    description: 'Global conflicts and globalization',
    unitNumber: 4,
    questions: [
      ChapterQuestion(
        questionText: 'World War I began in:',
        options: ['1914', '1905', '1939', '1929'],
        correctIndex: 0,
        explanation: 'WWI began in 1914.',
      ),
      ChapterQuestion(
        questionText: 'The Cold War was a:',
        options: ['Geopolitical tension', 'Direct military war', 'Colonial war only', 'Religious conflict only'],
        correctIndex: 0,
        explanation: 'The Cold War was geopolitical tension between superpowers.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Globalization & Technology',
    description: 'Modern global connections and innovation',
    unitNumber: 5,
    questions: [
      ChapterQuestion(
        questionText: 'Globalization increases:',
        options: ['Interconnectedness', 'Isolation', 'Autarky', 'Feudalism'],
        correctIndex: 0,
        explanation: 'Globalization increases economic and cultural interconnectedness.',
      ),
      ChapterQuestion(
        questionText: 'The Internet has primarily impacted:',
        options: ['Communication speed', 'Gravity', 'Plate tectonics', 'Weather'],
        correctIndex: 0,
        explanation: 'The Internet dramatically increased communication speed.',
      ),
    ],
  ),
];
