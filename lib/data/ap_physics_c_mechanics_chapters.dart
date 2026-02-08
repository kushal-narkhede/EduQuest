import 'ap_course_chapters.dart';

/// AP Physics C: Mechanics chapters (condensed units with sample questions).
final List<APCourseChapter> apPhysicsCMechanicsChapters = [
  APCourseChapter(
    name: 'Kinematics',
    description: 'Motion in one and two dimensions',
    unitNumber: 1,
    questions: [
      ChapterQuestion(
        questionText: 'Average velocity equals:',
        options: ['Displacement / time', 'Distance / time', 'Acceleration / time', 'Time / displacement'],
        correctIndex: 0,
        explanation: 'Average velocity uses displacement, not total distance.',
      ),
      ChapterQuestion(
        questionText: 'Acceleration is the slope of:',
        options: ['Velocity vs time', 'Position vs time', 'Position vs velocity', 'Momentum vs time'],
        correctIndex: 0,
        explanation: 'Acceleration is the slope of a velocity-time graph.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Newton’s Laws',
    description: 'Forces and free-body analysis',
    unitNumber: 2,
    questions: [
      ChapterQuestion(
        questionText: 'Net force on an object is:',
        options: ['Sum of all forces', 'Largest force only', 'Mass × velocity', 'Zero always'],
        correctIndex: 0,
        explanation: 'Net force is the vector sum of all forces.',
      ),
      ChapterQuestion(
        questionText: 'A force diagram shows:',
        options: ['All forces on the object', 'Only gravity', 'Only friction', 'Only normal force'],
        correctIndex: 0,
        explanation: 'Free-body diagrams show all forces acting on the object.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Work and Energy',
    description: 'Work-energy theorem and conservation',
    unitNumber: 3,
    questions: [
      ChapterQuestion(
        questionText: 'Work-energy theorem states:',
        options: ['Net work = change in KE', 'KE = PE only', 'Work = mass × velocity', 'Energy is not conserved'],
        correctIndex: 0,
        explanation: 'Net work equals change in kinetic energy.',
      ),
      ChapterQuestion(
        questionText: 'Potential energy in a spring is:',
        options: ['1/2 kx^2', 'kx', 'kx^2', '1/2 mv^2'],
        correctIndex: 0,
        explanation: 'Spring potential energy = 1/2 kx^2.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Momentum',
    description: 'Impulse, collisions, and momentum',
    unitNumber: 4,
    questions: [
      ChapterQuestion(
        questionText: 'Impulse equals:',
        options: ['Change in momentum', 'Change in energy', 'Force × distance', 'Mass × velocity squared'],
        correctIndex: 0,
        explanation: 'Impulse equals the change in momentum.',
      ),
      ChapterQuestion(
        questionText: 'Total momentum is conserved when:',
        options: ['Net external force is zero', 'Objects stop', 'Energy is lost', 'Friction is large'],
        correctIndex: 0,
        explanation: 'Momentum is conserved if net external force is zero.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Rotation',
    description: 'Rotational dynamics and torque',
    unitNumber: 5,
    questions: [
      ChapterQuestion(
        questionText: 'Torque is:',
        options: ['r × F', 'F / r', 'r / F', 'm × v'],
        correctIndex: 0,
        explanation: 'Torque is the cross product of position and force.',
      ),
      ChapterQuestion(
        questionText: 'Angular acceleration is caused by:',
        options: ['Net torque', 'Net force', 'Velocity', 'Mass only'],
        correctIndex: 0,
        explanation: 'Net torque produces angular acceleration.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Gravitation & SHM',
    description: 'Gravitation and simple harmonic motion',
    unitNumber: 6,
    questions: [
      ChapterQuestion(
        questionText: 'Gravitational potential energy is:',
        options: ['-GMm/r', 'GMm/r^2', 'mg', '1/2 mv^2'],
        correctIndex: 0,
        explanation: 'U = -GMm/r for gravitational potential energy.',
      ),
      ChapterQuestion(
        questionText: 'In SHM, the period depends on:',
        options: ['System parameters only', 'Amplitude only', 'Mass only', 'Velocity only'],
        correctIndex: 0,
        explanation: 'Period depends on system parameters (like k and m), not amplitude.',
      ),
    ],
  ),
];
