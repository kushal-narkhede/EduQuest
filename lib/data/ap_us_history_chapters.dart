import 'ap_course_chapters.dart';

/// AP US History chapters (condensed units with sample questions).
final List<APCourseChapter> apUSHistoryChapters = [
  APCourseChapter(
    name: 'Colonial & Early Republic',
    description: 'Colonization, independence, and founding',
    unitNumber: 1,
    questions: [
      ChapterQuestion(
        questionText: 'The Declaration of Independence was adopted in:',
        options: ['1776', '1787', '1801', '1865'],
        correctIndex: 0,
        explanation: 'The Declaration was adopted in 1776.',
      ),
      ChapterQuestion(
        questionText: 'The Constitution was written in:',
        options: ['1787', '1776', '1812', '1861'],
        correctIndex: 0,
        explanation: 'The Constitutional Convention was in 1787.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Early Nation & Expansion',
    description: 'Growth, reform, and sectionalism',
    unitNumber: 2,
    questions: [
      ChapterQuestion(
        questionText: 'The Louisiana Purchase occurred in:',
        options: ['1803', '1791', '1814', '1820'],
        correctIndex: 0,
        explanation: 'The Louisiana Purchase was in 1803.',
      ),
      ChapterQuestion(
        questionText: 'Manifest Destiny refers to:',
        options: ['Westward expansion', 'Industrialization', 'Civil rights', 'Isolationism'],
        correctIndex: 0,
        explanation: 'Manifest Destiny was the belief in westward expansion.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Civil War & Reconstruction',
    description: 'Conflict, emancipation, and rebuilding',
    unitNumber: 3,
    questions: [
      ChapterQuestion(
        questionText: 'The Civil War began in:',
        options: ['1861', '1850', '1877', '1848'],
        correctIndex: 0,
        explanation: 'The Civil War began in 1861.',
      ),
      ChapterQuestion(
        questionText: 'Reconstruction ended in:',
        options: ['1877', '1865', '1890', '1901'],
        correctIndex: 0,
        explanation: 'Reconstruction ended with the Compromise of 1877.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Gilded Age & Progressive Era',
    description: 'Industrialization and reform',
    unitNumber: 4,
    questions: [
      ChapterQuestion(
        questionText: 'The Progressive Era focused on:',
        options: ['Reform and regulation', 'Isolationism', 'Colonization', 'Abolition'],
        correctIndex: 0,
        explanation: 'Progressives sought reforms in government and society.',
      ),
      ChapterQuestion(
        questionText: 'A hallmark of the Gilded Age was:',
        options: ['Rapid industrial growth', 'Agrarian dominance', 'No immigration', 'No cities'],
        correctIndex: 0,
        explanation: 'The Gilded Age saw rapid industrial growth and urbanization.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'World Wars & Great Depression',
    description: 'Global conflict and economic crisis',
    unitNumber: 5,
    questions: [
      ChapterQuestion(
        questionText: 'The Great Depression began in:',
        options: ['1929', '1918', '1939', '1945'],
        correctIndex: 0,
        explanation: 'The stock market crash of 1929 began the Great Depression.',
      ),
      ChapterQuestion(
        questionText: 'The New Deal was introduced by:',
        options: ['Franklin D. Roosevelt', 'Woodrow Wilson', 'Herbert Hoover', 'Harry Truman'],
        correctIndex: 0,
        explanation: 'FDR introduced the New Deal programs.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Cold War & Modern Era',
    description: 'Cold War, civil rights, and modern US',
    unitNumber: 6,
    questions: [
      ChapterQuestion(
        questionText: 'The Cold War was between:',
        options: ['US and Soviet Union', 'US and Germany', 'US and China', 'US and Japan'],
        correctIndex: 0,
        explanation: 'The Cold War was primarily US vs. Soviet Union.',
      ),
      ChapterQuestion(
        questionText: 'Brown v. Board of Education ruled:',
        options: ['School segregation unconstitutional', 'Income tax illegal', 'Voting age 21', 'Prohibition repeal'],
        correctIndex: 0,
        explanation: 'The decision ended legal school segregation.',
      ),
    ],
  ),
];
