import 'ap_course_chapters.dart';

/// AP Physics 2 chapters (condensed units with sample questions).
final List<APCourseChapter> apPhysics2Chapters = [
  APCourseChapter(
    name: 'Fluids',
    description: 'Pressure, buoyancy, and flow',
    unitNumber: 1,
    questions: [
      ChapterQuestion(
        questionText: 'Pressure is defined as:',
        options: ['Force/area', 'Force×area', 'Area/force', 'Mass/volume'],
        correctIndex: 0,
        explanation: 'Pressure equals force per unit area.',
      ),
      ChapterQuestion(
        questionText: 'Buoyant force equals the weight of:',
        options: ['Displaced fluid', 'Object', 'Container', 'Air'],
        correctIndex: 0,
        explanation: 'Archimedes’ principle: buoyant force equals weight of displaced fluid.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Thermodynamics',
    description: 'Heat, temperature, and energy transfer',
    unitNumber: 2,
    questions: [
      ChapterQuestion(
        questionText: 'Heat transfer due to temperature difference is:',
        options: ['Thermal energy', 'Work', 'Potential energy', 'Momentum'],
        correctIndex: 0,
        explanation: 'Heat is energy transfer due to temperature difference.',
      ),
      ChapterQuestion(
        questionText: 'First law of thermodynamics is:',
        options: ['ΔU = Q - W', 'W = Q', 'U = 0', 'Q = mcΔT only'],
        correctIndex: 0,
        explanation: 'Change in internal energy equals heat in minus work done.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Electrostatics',
    description: 'Electric charge and Coulomb’s law',
    unitNumber: 3,
    questions: [
      ChapterQuestion(
        questionText: 'Coulomb’s law relates:',
        options: ['Force and charge', 'Force and mass', 'Energy and mass', 'Voltage and current'],
        correctIndex: 0,
        explanation: 'Coulomb’s law gives electric force between charges.',
      ),
      ChapterQuestion(
        questionText: 'Electric field direction is the direction of force on a:',
        options: ['Positive test charge', 'Negative test charge', 'Neutral charge', 'Any mass'],
        correctIndex: 0,
        explanation: 'Field direction is defined by force on a positive test charge.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Circuits',
    description: 'Current, resistance, and circuits',
    unitNumber: 4,
    questions: [
      ChapterQuestion(
        questionText: 'Ohm’s law is:',
        options: ['V = IR', 'V = I/R', 'I = VR', 'R = VI'],
        correctIndex: 0,
        explanation: 'Voltage equals current times resistance.',
      ),
      ChapterQuestion(
        questionText: 'Series circuits have:',
        options: ['Same current', 'Same voltage', 'Zero resistance', 'Infinite current'],
        correctIndex: 0,
        explanation: 'Current is the same through all components in series.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Magnetism',
    description: 'Magnetic fields and forces',
    unitNumber: 5,
    questions: [
      ChapterQuestion(
        questionText: 'Magnetic force on a moving charge is:',
        options: ['qvB sinθ', 'qE', 'mv^2/r', 'Gm1m2/r^2'],
        correctIndex: 0,
        explanation: 'F = qvB sinθ.',
      ),
      ChapterQuestion(
        questionText: 'Magnetic field lines form:',
        options: ['Closed loops', 'Open rays', 'Straight lines only', 'No pattern'],
        correctIndex: 0,
        explanation: 'Magnetic field lines are continuous closed loops.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Optics & Modern',
    description: 'Light, lenses, and modern physics',
    unitNumber: 6,
    questions: [
      ChapterQuestion(
        questionText: 'Convex lenses are:',
        options: ['Converging', 'Diverging', 'Neutral', 'Opaque'],
        correctIndex: 0,
        explanation: 'Convex lenses converge light rays.',
      ),
      ChapterQuestion(
        questionText: 'Photoelectric effect supports:',
        options: ['Particle nature of light', 'Wave only', 'No energy transfer', 'Classical theory'],
        correctIndex: 0,
        explanation: 'It supports the particle model (photons).',
      ),
    ],
  ),
];
