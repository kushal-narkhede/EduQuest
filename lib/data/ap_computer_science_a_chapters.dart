import 'ap_course_chapters.dart';

/// AP Computer Science A chapters (condensed units with sample questions).
final List<APCourseChapter> apComputerScienceAChapters = [
  APCourseChapter(
    name: 'Java Fundamentals',
    description: 'Variables, data types, and expressions',
    unitNumber: 1,
    questions: [
      ChapterQuestion(
        questionText: 'Which type is used for whole numbers in Java?',
        options: ['int', 'double', 'String', 'boolean'],
        correctIndex: 0,
        explanation: 'int is used for integer values.',
      ),
      ChapterQuestion(
        questionText: 'Which operator compares equality?',
        options: ['==', '=', '!=', '>='],
        correctIndex: 0,
        explanation: '== checks equality in Java.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Control Structures',
    description: 'Conditionals and loops',
    unitNumber: 2,
    questions: [
      ChapterQuestion(
        questionText: 'A while loop repeats while:',
        options: ['Condition is true', 'Condition is false', 'Loop count is zero', 'It compiles'],
        correctIndex: 0,
        explanation: 'while loops run while the condition is true.',
      ),
      ChapterQuestion(
        questionText: 'Which statement chooses among multiple options?',
        options: ['if/else', 'switch', 'for', 'return'],
        correctIndex: 1,
        explanation: 'switch selects among multiple cases.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Classes and Objects',
    description: 'Classes, objects, and methods',
    unitNumber: 3,
    questions: [
      ChapterQuestion(
        questionText: 'A constructor is used to:',
        options: ['Initialize objects', 'Destroy objects', 'Loop', 'Compare values'],
        correctIndex: 0,
        explanation: 'Constructors initialize new objects.',
      ),
      ChapterQuestion(
        questionText: 'Encapsulation means:',
        options: ['Hiding internal details', 'Using loops', 'Sorting arrays', 'Overriding methods'],
        correctIndex: 0,
        explanation: 'Encapsulation hides data behind an interface.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Arrays and ArrayList',
    description: 'Collections and iteration',
    unitNumber: 4,
    questions: [
      ChapterQuestion(
        questionText: 'Array indices start at:',
        options: ['0', '1', '-1', 'Any number'],
        correctIndex: 0,
        explanation: 'Java arrays are zero-indexed.',
      ),
      ChapterQuestion(
        questionText: 'ArrayList size changes:',
        options: ['Dynamically', 'Never', 'Only on compile', 'Only at runtime start'],
        correctIndex: 0,
        explanation: 'ArrayList can grow or shrink dynamically.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Inheritance and Polymorphism',
    description: 'Inheritance, overriding, and polymorphism',
    unitNumber: 5,
    questions: [
      ChapterQuestion(
        questionText: 'Inheritance is established using:',
        options: ['extends', 'implements', 'import', 'package'],
        correctIndex: 0,
        explanation: 'extends creates a subclass.',
      ),
      ChapterQuestion(
        questionText: 'Method overriding requires:',
        options: ['Same signature', 'Different name', 'Different return type only', 'No parameters'],
        correctIndex: 0,
        explanation: 'Overriding uses the same method signature.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Recursion',
    description: 'Self-referential methods',
    unitNumber: 6,
    questions: [
      ChapterQuestion(
        questionText: 'A base case in recursion:',
        options: ['Stops the recursion', 'Starts the recursion', 'Calls itself', 'Allocates memory'],
        correctIndex: 0,
        explanation: 'Base cases end recursive calls.',
      ),
      ChapterQuestion(
        questionText: 'Recursive calls should:',
        options: ['Approach the base case', 'Avoid termination', 'Skip parameters', 'Loop forever'],
        correctIndex: 0,
        explanation: 'Each call should move toward the base case.',
      ),
    ],
  ),
];
