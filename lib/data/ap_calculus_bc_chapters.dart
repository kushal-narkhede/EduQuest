import 'ap_course_chapters.dart';

/// AP Calculus BC chapters (condensed units with sample questions).
final List<APCourseChapter> apCalculusBCChapters = [
  APCourseChapter(
    name: 'Limits and Continuity',
    description: 'Limits, continuity, and asymptotic behavior',
    unitNumber: 1,
    questions: [
      ChapterQuestion(
        questionText: 'What does it mean for f(x) to be continuous at x = a?',
        options: [
          'lim(x→a) f(x) exists and equals f(a)',
          'f(a) is undefined',
          'lim(x→a) f(x) is infinite',
          'f(x) has a jump at x = a',
        ],
        correctIndex: 0,
        explanation: 'Continuity requires the limit to exist and match the function value.',
      ),
      ChapterQuestion(
        questionText: 'Evaluate lim(x→2) (x^2 - 4)/(x - 2).',
        options: ['0', '2', '4', 'Does not exist'],
        correctIndex: 2,
        explanation: 'Factor to (x+2) and substitute x=2 to get 4.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Derivatives',
    description: 'Differentiation rules and applications',
    unitNumber: 2,
    questions: [
      ChapterQuestion(
        questionText: 'What is d/dx of sin(x)?',
        options: ['cos(x)', '-cos(x)', 'sin(x)', '-sin(x)'],
        correctIndex: 0,
        explanation: 'The derivative of sin(x) is cos(x).',
      ),
      ChapterQuestion(
        questionText: 'If f(x)=x^3, what is f\'(x)?',
        options: ['x^2', '3x^2', '3x', 'x^3'],
        correctIndex: 1,
        explanation: 'Use the power rule: 3x^2.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Integrals',
    description: 'Antiderivatives and definite integrals',
    unitNumber: 3,
    questions: [
      ChapterQuestion(
        questionText: 'What is the integral of 2x dx?',
        options: ['x^2 + C', '2x + C', 'x + C', '2x^2 + C'],
        correctIndex: 0,
        explanation: 'The antiderivative of 2x is x^2 + C.',
      ),
      ChapterQuestion(
        questionText: 'The definite integral represents:',
        options: [
          'Slope at a point',
          'Area under a curve',
          'Instantaneous rate',
          'Limit of a sequence'
        ],
        correctIndex: 1,
        explanation: 'Definite integrals compute net area under a curve.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Series and Taylor',
    description: 'Convergence tests and Taylor series',
    unitNumber: 4,
    questions: [
      ChapterQuestion(
        questionText: 'Which test is used for alternating series convergence?',
        options: ['Ratio test', 'Alternating series test', 'Root test', 'Integral test'],
        correctIndex: 1,
        explanation: 'Alternating series are tested with the alternating series test.',
      ),
      ChapterQuestion(
        questionText: 'A Taylor series is a:',
        options: [
          'Polynomial approximation',
          'System of linear equations',
          'Type of limit',
          'Piecewise function'
        ],
        correctIndex: 0,
        explanation: 'Taylor series approximate functions with polynomials.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Parametric and Polar',
    description: 'Curves defined by parameter or polar coordinates',
    unitNumber: 5,
    questions: [
      ChapterQuestion(
        questionText: 'For parametric equations x(t), y(t), dy/dx equals:',
        options: ['(dy/dt)/(dx/dt)', 'dx/dt', 'dy/dt', 'dx/dy'],
        correctIndex: 0,
        explanation: 'Use the chain rule: dy/dx = (dy/dt)/(dx/dt).',
      ),
      ChapterQuestion(
        questionText: 'In polar coordinates, r is:',
        options: ['Angle', 'Distance from origin', 'Slope', 'x-coordinate'],
        correctIndex: 1,
        explanation: 'r is the distance from the origin.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Differential Equations',
    description: 'Modeling with differential equations',
    unitNumber: 6,
    questions: [
      ChapterQuestion(
        questionText: 'A slope field represents:',
        options: [
          'Derivative values at points',
          'Integral values at points',
          'A set of solutions only',
          'A graph of a sequence'
        ],
        correctIndex: 0,
        explanation: 'Slope fields visualize derivative values at points.',
      ),
      ChapterQuestion(
        questionText: 'Separable differential equations can be solved by:',
        options: [
          'Separating variables and integrating',
          'Using quadratic formula',
          'Substitution only',
          'Factoring'
        ],
        correctIndex: 0,
        explanation: 'Separate variables and integrate both sides.',
      ),
    ],
  ),
];
