import 'ap_course_chapters.dart';

/// AP Physics 1 chapters (condensed units with sample questions).
final List<APCourseChapter> apPhysics1Chapters = [
  APCourseChapter(
    name: 'Kinematics',
    description: 'Motion in one and two dimensions',
    unitNumber: 1,
    questions: [
      ChapterQuestion(
        questionText: 'Velocity is the derivative of:',
        options: ['Position', 'Acceleration', 'Time', 'Displacement squared'],
        correctIndex: 0,
        explanation: 'Velocity is the rate of change of position.',
      ),
      ChapterQuestion(
        questionText: 'Acceleration is the derivative of:',
        options: ['Velocity', 'Position', 'Displacement', 'Time'],
        correctIndex: 0,
        explanation: 'Acceleration is the rate of change of velocity.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Dynamics',
    description: 'Forces and Newton’s laws',
    unitNumber: 2,
    questions: [
      ChapterQuestion(
        questionText: 'Newton’s second law states:',
        options: ['F = ma', 'F = mv', 'F = m/a', 'F = mg'],
        correctIndex: 0,
        explanation: 'Net force equals mass times acceleration.',
      ),
      ChapterQuestion(
        questionText: 'Action-reaction pairs act on:',
        options: ['Same object', 'Different objects', 'Only moving objects', 'Only resting objects'],
        correctIndex: 1,
        explanation: 'Newton’s third law pairs act on different objects.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Energy',
    description: 'Work, energy, and power',
    unitNumber: 3,
    questions: [
      ChapterQuestion(
        questionText: 'Work is defined as:',
        options: ['F·d·cosθ', 'F·d', 'F/d', 'F·t'],
        correctIndex: 0,
        explanation: 'Work equals force times displacement times cosine of angle.',
      ),
      ChapterQuestion(
        questionText: 'Kinetic energy is:',
        options: ['1/2 mv^2', 'mgh', 'mv', 'mg'],
        correctIndex: 0,
        explanation: 'KE = 1/2 mv^2.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Momentum',
    description: 'Impulse and conservation of momentum',
    unitNumber: 4,
    questions: [
      ChapterQuestion(
        questionText: 'Momentum is:',
        options: ['mv', 'ma', '1/2 mv^2', 'mgh'],
        correctIndex: 0,
        explanation: 'Momentum equals mass times velocity.',
      ),
      ChapterQuestion(
        questionText: 'Impulse equals:',
        options: ['Force × time', 'Force × distance', 'Mass × time', 'Energy × time'],
        correctIndex: 0,
        explanation: 'Impulse equals the change in momentum.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Circular Motion & Gravitation',
    description: 'Uniform circular motion and gravitation',
    unitNumber: 5,
    questions: [
      ChapterQuestion(
        questionText: 'Centripetal acceleration is:',
        options: ['v^2/r', 'v/r', 'r/v', 'v^2 r'],
        correctIndex: 0,
        explanation: 'a_c = v^2 / r.',
      ),
      ChapterQuestion(
        questionText: 'Gravitational force depends on:',
        options: ['Masses and distance', 'Velocity only', 'Charge only', 'Area only'],
        correctIndex: 0,
        explanation: 'F = G m1 m2 / r^2.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Rotation & SHM',
    description: 'Rotational motion and simple harmonic motion',
    unitNumber: 6,
    questions: [
      ChapterQuestion(
        questionText: 'Rotational analog of mass is:',
        options: ['Torque', 'Moment of inertia', 'Angular speed', 'Radius'],
        correctIndex: 1,
        explanation: 'Moment of inertia measures rotational inertia.',
      ),
      ChapterQuestion(
        questionText: 'In SHM, acceleration is proportional to:',
        options: ['Displacement', 'Velocity', 'Time', 'Mass'],
        correctIndex: 0,
        explanation: 'a = -ω^2 x, proportional to displacement.',
      ),
    ],
  ),
];
