import 'ap_course_chapters.dart';

/// AP Computer Science Principles chapters (condensed units with sample questions).
final List<APCourseChapter> apComputerSciencePrinciplesChapters = [
  APCourseChapter(
    name: 'Internet and Networks',
    description: 'Protocols, routing, and the Internet',
    unitNumber: 1,
    questions: [
      ChapterQuestion(
        questionText: 'The Internet is best described as:',
        options: ['A network of networks', 'A single server', 'A database', 'A programming language'],
        correctIndex: 0,
        explanation: 'The Internet connects many networks together.',
      ),
      ChapterQuestion(
        questionText: 'IP addresses identify:',
        options: ['Devices on a network', 'Web pages', 'Programs only', 'Users only'],
        correctIndex: 0,
        explanation: 'IP addresses uniquely identify devices on a network.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Data and Digital Information',
    description: 'Binary, data representation, and compression',
    unitNumber: 2,
    questions: [
      ChapterQuestion(
        questionText: 'Binary is a base:',
        options: ['2', '10', '8', '16'],
        correctIndex: 0,
        explanation: 'Binary uses base 2.',
      ),
      ChapterQuestion(
        questionText: 'Lossy compression:',
        options: ['Removes some data', 'Keeps all data', 'Increases size', 'Encrypts data'],
        correctIndex: 0,
        explanation: 'Lossy compression discards data to reduce size.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Algorithms',
    description: 'Algorithmic thinking and efficiency',
    unitNumber: 3,
    questions: [
      ChapterQuestion(
        questionText: 'An algorithm is:',
        options: ['A step-by-step procedure', 'A bug', 'A data type', 'A variable'],
        correctIndex: 0,
        explanation: 'Algorithms are step-by-step procedures.',
      ),
      ChapterQuestion(
        questionText: 'A linear search runs in:',
        options: ['O(n)', 'O(log n)', 'O(1)', 'O(n^2)'],
        correctIndex: 0,
        explanation: 'Linear search checks each item in sequence.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Programming',
    description: 'Programming concepts and abstraction',
    unitNumber: 4,
    questions: [
      ChapterQuestion(
        questionText: 'Abstraction helps by:',
        options: ['Managing complexity', 'Adding bugs', 'Removing variables', 'Ignoring logic'],
        correctIndex: 0,
        explanation: 'Abstraction hides details to manage complexity.',
      ),
      ChapterQuestion(
        questionText: 'A function is also called a:',
        options: ['Procedure', 'Loop', 'Variable', 'Library'],
        correctIndex: 0,
        explanation: 'Functions are procedures or methods.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Impact of Computing',
    description: 'Ethics, society, and computing impacts',
    unitNumber: 5,
    questions: [
      ChapterQuestion(
        questionText: 'A digital divide refers to:',
        options: ['Unequal access to technology', 'Binary numbers', 'Data loss', 'Compression'],
        correctIndex: 0,
        explanation: 'Digital divide is unequal access to technology.',
      ),
      ChapterQuestion(
        questionText: 'Crowdsourcing is:',
        options: ['Collecting input from many people', 'Encrypting data', 'Sorting arrays', 'Routing packets'],
        correctIndex: 0,
        explanation: 'Crowdsourcing collects input from large groups.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Cybersecurity',
    description: 'Threats, encryption, and security',
    unitNumber: 6,
    questions: [
      ChapterQuestion(
        questionText: 'Encryption is used to:',
        options: ['Protect data', 'Delete data', 'Compress images', 'Boost speed'],
        correctIndex: 0,
        explanation: 'Encryption protects data from unauthorized access.',
      ),
      ChapterQuestion(
        questionText: 'A strong password typically has:',
        options: ['Length and complexity', 'Only letters', 'Only numbers', 'No symbols'],
        correctIndex: 0,
        explanation: 'Long, complex passwords are stronger.',
      ),
    ],
  ),
];
