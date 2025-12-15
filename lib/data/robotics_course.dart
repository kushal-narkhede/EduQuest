import 'dart:convert';

class RoboticsTag {
  final String domain; // e.g., Mechanics, Electronics
  final String subtopic; // e.g., Kinematics, Sensors
  final String difficulty; // Beginner | Intermediate | Advanced
  final List<String> modes; // Lightning | Survival | Memory Master | Puzzle Quest | Treasure Hunt | FRQ
  final String estimatedTime; // e.g., 20m, 1h
  final List<String> prerequisites;
  final List<String> standards; // NGSS-ish, engineering competencies

  RoboticsTag({
    required this.domain,
    required this.subtopic,
    required this.difficulty,
    required this.modes,
    required this.estimatedTime,
    required this.prerequisites,
    required this.standards,
  });

  Map<String, dynamic> toJson() => {
        'domain': domain,
        'subtopic': subtopic,
        'difficulty': difficulty,
        'modes': modes,
        'estimatedTime': estimatedTime,
        'prerequisites': prerequisites,
        'standards': standards,
      };
}

class GamificationRule {
  final int points; // base points
  final List<String> achievements; // course-specific achievements
  final Map<String, bool> powerUps; // e.g., { '50_50': true, 'time_freeze': true, 'skip_frq': false }

  GamificationRule({
    required this.points,
    required this.achievements,
    required this.powerUps,
  });

  Map<String, dynamic> toJson() => {
        'points': points,
        'achievements': achievements,
        'powerUps': powerUps,
      };
}

class LessonObjective {
  final String id;
  final String text;
  final RoboticsTag tags;

  LessonObjective({required this.id, required this.text, required this.tags});

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'tags': tags.toJson(),
      };
}

class AssessmentItem {
  final String id;
  final String type; // MCQ | FRQ | Lab | Card | Puzzle | Treasure
  final String prompt;
  final List<String>? options; // for MCQ
  final String? correctAnswer; // for MCQ
  final String? rubric; // for FRQ
  final RoboticsTag tags;

  AssessmentItem({
    required this.id,
    required this.type,
    required this.prompt,
    this.options,
    this.correctAnswer,
    this.rubric,
    required this.tags,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'prompt': prompt,
        'options': options,
        'correctAnswer': correctAnswer,
        'rubric': rubric,
        'tags': tags.toJson(),
      };
}

class Lesson {
  final String id;
  final String title;
  final List<LessonObjective> objectives;
  final List<AssessmentItem> assessments; // MCQs, FRQs, Labs, Cards, Puzzles, Treasure

  Lesson({
    required this.id,
    required this.title,
    required this.objectives,
    required this.assessments,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'objectives': objectives.map((e) => e.toJson()).toList(),
        'assessments': assessments.map((e) => e.toJson()).toList(),
      };
}

class Module {
  final String id;
  final String title;
  final String description;
  final List<Lesson> lessons;

  Module({
    required this.id,
    required this.title,
    required this.description,
    required this.lessons,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'lessons': lessons.map((e) => e.toJson()).toList(),
      };
}

class RoboticsCourse {
  final String id;
  final String name;
  final String description;
  final List<Module> modules;
  final GamificationRule gamification;

  RoboticsCourse({
    required this.id,
    required this.name,
    required this.description,
    required this.modules,
    required this.gamification,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'modules': modules.map((e) => e.toJson()).toList(),
        'gamification': gamification.toJson(),
      };

  String toPrettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());
}

RoboticsCourse buildRoboticsCoursePreview() {
  final beginnerTag = RoboticsTag(
    domain: 'Foundations',
    subtopic: 'Mechanics',
    difficulty: 'Beginner',
    modes: ['Lightning', 'Memory Master', 'Puzzle Quest'],
    estimatedTime: '30m',
    prerequisites: [],
    standards: ['ENG-Mechanics-01'],
  );

  final frqTag = RoboticsTag(
    domain: 'Programming',
    subtopic: 'Control',
    difficulty: 'Intermediate',
    modes: ['FRQ'],
    estimatedTime: '45m',
    prerequisites: ['Basics of loops'],
    standards: ['ENG-Software-02'],
  );

  final lesson1 = Lesson(
    id: 'L1',
    title: 'Introduction to Robotics & Mechanics',
    objectives: [
      LessonObjective(
        id: 'O1',
        text: 'Define robotics and core subsystems',
        tags: beginnerTag,
      ),
      LessonObjective(
        id: 'O2',
        text: 'Explain torque vs speed trade-offs',
        tags: beginnerTag,
      ),
    ],
    assessments: [
      AssessmentItem(
        id: 'Q1',
        type: 'MCQ',
        prompt: 'Which gear setup increases torque?',
        options: ['High gear ratio', 'Low gear ratio', 'Direct drive', 'Belt drive'],
        correctAnswer: 'High gear ratio',
        tags: beginnerTag,
      ),
      AssessmentItem(
        id: 'FRQ1',
        type: 'FRQ',
        prompt: 'Design a simple PID loop for motor speed control and justify parameter choices.',
        rubric: 'Rubric: Explains P/I/D roles, tuning approach, and stability considerations.',
        tags: frqTag,
      ),
    ],
  );

  final module1 = Module(
    id: 'M1',
    title: 'Foundations and Mechanics',
    description: 'Core concepts: mechanics, electronics, sensors, control basics.',
    lessons: [lesson1],
  );

  final gamification = GamificationRule(
    points: 100,
    achievements: [
      'Gear Guru',
      'Control Sage',
      'Sensor Scout',
    ],
    powerUps: {
      '50_50': true,
      'time_freeze': true,
      'skip_frq': false,
    },
  );

  return RoboticsCourse(
    id: 'ROB-101',
    name: 'Robotics',
    description: 'A comprehensive, gamified Robotics course for EduQuest.',
    modules: [module1],
    gamification: gamification,
  );
}
