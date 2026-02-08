import 'ap_course_chapters.dart';

/// AP Calculus AB Chapter-based question structure
/// Organized by College Board curriculum units

/// All AP Calculus AB chapters with comprehensive question banks
final List<APCourseChapter> apCalculusABChapters = [
  // Unit 1: Limits and Continuity
  APCourseChapter(
    name: 'Limits and Continuity',
    description: 'Understanding limits, continuity, and asymptotic behavior',
    unitNumber: 1,
    questions: [
      ChapterQuestion(
        questionText: 'What is the limit of (x² - 4)/(x - 2) as x approaches 2?',
        options: ['0', '2', '4', 'Undefined'],
        correctIndex: 2,
        explanation:
            'This is an indeterminate form (0/0). Factor the numerator: (x² - 4) = (x + 2)(x - 2). Cancel (x - 2) from numerator and denominator to get (x + 2). As x approaches 2, this becomes 4.',
      ),
      ChapterQuestion(
        questionText: 'What is the limit of sin(x)/x as x approaches 0?',
        options: ['0', '1', '∞', 'Undefined'],
        correctIndex: 1,
        explanation:
            'This is a fundamental limit: lim(x→0) sin(x)/x = 1. This limit is often used in calculus and is the basis for the derivative of sin(x).',
      ),
      ChapterQuestion(
        questionText: 'What is the limit of (1 + 1/x)^x as x approaches ∞?',
        options: ['1', 'e', '∞', '0'],
        correctIndex: 1,
        explanation:
            'This is the definition of e: lim(x→∞) (1 + 1/x)^x = e ≈ 2.718. This limit is fundamental in calculus and defines the natural number e.',
      ),
      ChapterQuestion(
        questionText: 'What is the limit of (e^x - 1)/x as x approaches 0?',
        options: ['0', '1', 'e', '∞'],
        correctIndex: 1,
        explanation:
            'This is a fundamental limit: lim(x→0) (e^x - 1)/x = 1. This limit is often used in calculus and is the basis for the derivative of e^x.',
      ),
      ChapterQuestion(
        questionText: 'What is the limit of (x² - 9)/(x - 3) as x approaches 3?',
        options: ['0', '3', '6', 'Undefined'],
        correctIndex: 2,
        explanation:
            'Factor the numerator: (x² - 9) = (x + 3)(x - 3). Cancel (x - 3) to get (x + 3). As x approaches 3, this becomes 6.',
      ),
      ChapterQuestion(
        questionText: 'What is the limit of (√x - 2)/(x - 4) as x approaches 4?',
        options: ['1/4', '1/2', '1', 'Undefined'],
        correctIndex: 0,
        explanation:
            'Rationalize by multiplying numerator and denominator by (√x + 2). This gives (x - 4)/((x - 4)(√x + 2)) = 1/(√x + 2). As x approaches 4, this becomes 1/4.',
      ),
      ChapterQuestion(
        questionText: 'What is the limit of (1 - cos(x))/x as x approaches 0?',
        options: ['0', '1', '∞', 'Undefined'],
        correctIndex: 0,
        explanation:
            'Using L\'Hôpital\'s rule or trigonometric identities, lim(x→0) (1 - cos(x))/x = 0. This can be shown using the limit lim(x→0) sin²(x)/(x(1 + cos(x))) = 0.',
      ),
      ChapterQuestion(
        questionText: 'A function f(x) is continuous at x = a if:',
        options: [
          'lim(x→a) f(x) exists and equals f(a)',
          'f(a) is defined',
          'lim(x→a) f(x) exists',
          'f(x) has no jumps'
        ],
        correctIndex: 0,
        explanation:
            'A function is continuous at x = a if three conditions are met: f(a) is defined, lim(x→a) f(x) exists, and lim(x→a) f(x) = f(a).',
      ),
      ChapterQuestion(
        questionText: 'What is the limit of (x³ - 8)/(x - 2) as x approaches 2?',
        options: ['8', '12', '16', 'Undefined'],
        correctIndex: 1,
        explanation:
            'Factor using difference of cubes: x³ - 8 = (x - 2)(x² + 2x + 4). Cancel (x - 2) to get (x² + 2x + 4). As x approaches 2, this becomes 12.',
      ),
      ChapterQuestion(
        questionText: 'What is the limit of (tan(x))/x as x approaches 0?',
        options: ['0', '1', '∞', 'Undefined'],
        correctIndex: 1,
        explanation:
            'lim(x→0) tan(x)/x = lim(x→0) (sin(x)/x) · (1/cos(x)) = 1 · 1 = 1.',
      ),
      ChapterQuestion(
        questionText: 'What is the limit of (ln(x + 1))/x as x approaches 0?',
        options: ['0', '1', '∞', 'Undefined'],
        correctIndex: 1,
        explanation:
            'Using L\'Hôpital\'s rule: lim(x→0) (ln(x + 1))/x = lim(x→0) (1/(x + 1))/1 = 1.',
      ),
      ChapterQuestion(
        questionText: 'What is the limit of (3^x - 1)/x as x approaches 0?',
        options: ['0', 'ln(3)', '1', '∞'],
        correctIndex: 1,
        explanation:
            'Using L\'Hôpital\'s rule: lim(x→0) (3^x - 1)/x = lim(x→0) (3^x · ln(3))/1 = ln(3).',
      ),
      ChapterQuestion(
        questionText: 'What is the limit of (x² + 3x - 10)/(x - 2) as x approaches 2?',
        options: ['5', '7', '9', 'Undefined'],
        correctIndex: 1,
        explanation:
            'Factor: (x² + 3x - 10) = (x + 5)(x - 2). Cancel (x - 2) to get (x + 5). As x approaches 2, this becomes 7.',
      ),
      ChapterQuestion(
        questionText: 'What is the limit of (√(x + 4) - 2)/x as x approaches 0?',
        options: ['1/4', '1/2', '1', 'Undefined'],
        correctIndex: 0,
        explanation:
            'Rationalize: multiply by (√(x + 4) + 2)/(√(x + 4) + 2) to get x/(x(√(x + 4) + 2)) = 1/(√(x + 4) + 2). As x approaches 0, this becomes 1/4.',
      ),
      ChapterQuestion(
        questionText: 'What is the limit of (sin(3x))/x as x approaches 0?',
        options: ['0', '1', '3', '∞'],
        correctIndex: 2,
        explanation:
            'lim(x→0) sin(3x)/x = 3 · lim(x→0) sin(3x)/(3x) = 3 · 1 = 3.',
      ),
      ChapterQuestion(
        questionText: 'What is the limit of (1 - cos(2x))/x² as x approaches 0?',
        options: ['0', '1', '2', '4'],
        correctIndex: 2,
        explanation:
            'Using the identity 1 - cos(2x) = 2sin²(x), we get lim(x→0) 2sin²(x)/x² = 2 · (lim(x→0) sin(x)/x)² = 2.',
      ),
      ChapterQuestion(
        questionText: 'What is the limit of (e^(2x) - 1)/x as x approaches 0?',
        options: ['0', '1', '2', '∞'],
        correctIndex: 2,
        explanation:
            'Using L\'Hôpital\'s rule: lim(x→0) (e^(2x) - 1)/x = lim(x→0) (2e^(2x))/1 = 2.',
      ),
      ChapterQuestion(
        questionText: 'What is the limit of (x - sin(x))/x³ as x approaches 0?',
        options: ['0', '1/6', '1', '∞'],
        correctIndex: 1,
        explanation:
            'Using L\'Hôpital\'s rule three times or Taylor series expansion, lim(x→0) (x - sin(x))/x³ = 1/6.',
      ),
      ChapterQuestion(
        questionText: 'What is the limit of (ln(x))/x as x approaches ∞?',
        options: ['0', '1', '∞', 'Undefined'],
        correctIndex: 0,
        explanation:
            'Using L\'Hôpital\'s rule: lim(x→∞) (ln(x))/x = lim(x→∞) (1/x)/1 = 0.',
      ),
      ChapterQuestion(
        questionText: 'What is the limit of (x²)/(e^x) as x approaches ∞?',
        options: ['0', '1', '∞', 'Undefined'],
        correctIndex: 0,
        explanation:
            'Using L\'Hôpital\'s rule twice: lim(x→∞) x²/e^x = lim(x→∞) 2x/e^x = lim(x→∞) 2/e^x = 0.',
      ),
    ],
  ),

  // Unit 2: Derivatives
  APCourseChapter(
    name: 'Derivatives',
    description: 'Definition, rules, and techniques for finding derivatives',
    unitNumber: 2,
    questions: [
      ChapterQuestion(
        questionText: 'What is the derivative of f(x) = x³ + 2x² - 5x + 3?',
        options: ['3x² + 4x - 5', '3x² + 4x + 5', '3x² - 4x - 5', '3x² - 4x + 5'],
        correctIndex: 0,
        explanation:
            'To find the derivative, apply the power rule: d/dx(x^n) = nx^(n-1). For f(x) = x³ + 2x² - 5x + 3, the derivative is 3x² + 4x - 5. The constant term 3 becomes 0 when differentiated.',
      ),
      ChapterQuestion(
        questionText: 'Find the derivative of f(x) = e^x * sin(x)',
        options: [
          'e^x * cos(x)',
          'e^x * (sin(x) + cos(x))',
          'e^x * sin(x)',
          'e^x * (sin(x) - cos(x))'
        ],
        correctIndex: 1,
        explanation:
            'Use the product rule: d/dx[u*v] = u*dv/dx + v*du/dx. Here, u = e^x and v = sin(x). So d/dx[e^x * sin(x)] = e^x * cos(x) + sin(x) * e^x = e^x * (sin(x) + cos(x)).',
      ),
      ChapterQuestion(
        questionText: 'Find the derivative of f(x) = ln(x² + 1)',
        options: ['2x/(x² + 1)', '1/(x² + 1)', '2x', 'x² + 1'],
        correctIndex: 0,
        explanation:
            'Use the chain rule: d/dx[ln(u)] = (1/u) * du/dx. Here, u = x² + 1, so du/dx = 2x. Therefore, d/dx[ln(x² + 1)] = (1/(x² + 1)) * 2x = 2x/(x² + 1).',
      ),
      ChapterQuestion(
        questionText: 'What is the derivative of f(x) = cos(3x)?',
        options: ['-3sin(3x)', '3sin(3x)', '-sin(3x)', 'sin(3x)'],
        correctIndex: 0,
        explanation:
            'Use the chain rule: d/dx[cos(u)] = -sin(u) * du/dx. Here, u = 3x, so du/dx = 3. Therefore, d/dx[cos(3x)] = -sin(3x) * 3 = -3sin(3x).',
      ),
      ChapterQuestion(
        questionText: 'Find the derivative of f(x) = √(x² + 4)',
        options: [
          'x/√(x² + 4)',
          '2x/√(x² + 4)',
          '1/√(x² + 4)',
          'x/2√(x² + 4)'
        ],
        correctIndex: 0,
        explanation:
            'Use the chain rule: d/dx[√u] = (1/(2√u)) * du/dx. Here, u = x² + 4, so du/dx = 2x. Therefore, d/dx[√(x² + 4)] = (1/(2√(x² + 4))) * 2x = x/√(x² + 4).',
      ),
      ChapterQuestion(
        questionText: 'Find the derivative of f(x) = x²e^x',
        options: ['2xe^x + x²e^x', '2xe^x', 'x²e^x', '2x + e^x'],
        correctIndex: 0,
        explanation:
            'Use the product rule: d/dx[u*v] = u*dv/dx + v*du/dx. Here, u = x² and v = e^x. So d/dx[x²e^x] = x² * e^x + e^x * 2x = 2xe^x + x²e^x.',
      ),
      ChapterQuestion(
        questionText: 'Find the derivative of f(x) = tan(x)',
        options: ['sec²(x)', 'sec(x)', 'tan²(x)', '1/cos(x)'],
        correctIndex: 0,
        explanation:
            'The derivative of tan(x) is sec²(x). This can be derived using the quotient rule on tan(x) = sin(x)/cos(x).',
      ),
      ChapterQuestion(
        questionText: 'What is the derivative of f(x) = arcsin(x)?',
        options: ['1/√(1 - x²)', '1/√(1 + x²)', '1/(1 - x²)', '1/(1 + x²)'],
        correctIndex: 0,
        explanation:
            'The derivative of arcsin(x) is 1/√(1 - x²). This can be derived using implicit differentiation on sin(y) = x.',
      ),
      ChapterQuestion(
        questionText: 'Find the derivative of f(x) = x^x',
        options: ['x^x(ln(x) + 1)', 'x^x', 'x^x ln(x)', 'x^(x-1)'],
        correctIndex: 0,
        explanation:
            'Use logarithmic differentiation: ln(f(x)) = x ln(x). Differentiate both sides: f\'(x)/f(x) = ln(x) + 1. Therefore, f\'(x) = x^x(ln(x) + 1).',
      ),
      ChapterQuestion(
        questionText: 'What is the derivative of f(x) = sec(x)?',
        options: ['sec(x)tan(x)', 'sec²(x)', 'tan(x)', 'cos(x)'],
        correctIndex: 0,
        explanation:
            'The derivative of sec(x) is sec(x)tan(x). This can be derived using the quotient rule on sec(x) = 1/cos(x).',
      ),
      ChapterQuestion(
        questionText: 'Find the derivative of f(x) = arctan(x)',
        options: ['1/(1 + x²)', '1/√(1 - x²)', '1/(1 - x²)', '1/√(1 + x²)'],
        correctIndex: 0,
        explanation:
            'The derivative of arctan(x) is 1/(1 + x²). This can be derived using implicit differentiation on tan(y) = x.',
      ),
      ChapterQuestion(
        questionText: 'Find the derivative of f(x) = ln(√x)',
        options: ['1/(2x)', '1/x', '1/√x', '1/(2√x)'],
        correctIndex: 0,
        explanation:
            'Use the chain rule: d/dx[ln(√x)] = (1/√x) * d/dx[√x] = (1/√x) * (1/(2√x)) = 1/(2x).',
      ),
      ChapterQuestion(
        questionText: 'What is the derivative of f(x) = x^ln(x)',
        options: [
          'x^ln(x)(ln(x) + 1)',
          'x^ln(x)ln(x)',
          'x^ln(x)',
          'ln(x)x^(ln(x)-1)'
        ],
        correctIndex: 0,
        explanation:
            'Use logarithmic differentiation: ln(f(x)) = ln(x) * ln(x) = ln²(x). Differentiate both sides: f\'(x)/f(x) = 2ln(x)/x. Therefore, f\'(x) = x^ln(x) * 2ln(x)/x = x^ln(x)(ln(x) + 1).',
      ),
      ChapterQuestion(
        questionText: 'Find the derivative of f(x) = (x² + 1)/(x - 1)',
        options: [
          '(x² - 2x - 1)/(x - 1)²',
          '(2x)/(x - 1)',
          '(x² + 1)/(x - 1)²',
          '(2x - 1)/(x - 1)²'
        ],
        correctIndex: 0,
        explanation:
            'Use the quotient rule: (f/g)\' = (f\'g - fg\')/g². Here, f = x² + 1, g = x - 1. So f\' = 2x, g\' = 1. Therefore, (2x(x - 1) - (x² + 1)(1))/(x - 1)² = (x² - 2x - 1)/(x - 1)².',
      ),
      ChapterQuestion(
        questionText: 'What is the derivative of f(x) = sin(x)cos(x)',
        options: [
          'cos²(x) - sin²(x)',
          'sin²(x) - cos²(x)',
          '2sin(x)cos(x)',
          'sin²(x) + cos²(x)'
        ],
        correctIndex: 0,
        explanation:
            'Use the product rule: d/dx[sin(x)cos(x)] = cos(x)cos(x) + sin(x)(-sin(x)) = cos²(x) - sin²(x) = cos(2x).',
      ),
      ChapterQuestion(
        questionText: 'Find the derivative of f(x) = e^(2x) * sin(3x)',
        options: [
          'e^(2x)(2sin(3x) + 3cos(3x))',
          'e^(2x)(sin(3x) + cos(3x))',
          '2e^(2x)sin(3x)',
          '3e^(2x)cos(3x)'
        ],
        correctIndex: 0,
        explanation:
            'Use the product rule: d/dx[e^(2x)sin(3x)] = e^(2x) · 3cos(3x) + sin(3x) · 2e^(2x) = e^(2x)(2sin(3x) + 3cos(3x)).',
      ),
      ChapterQuestion(
        questionText: 'What is the derivative of f(x) = ln(x² + 3x + 2)',
        options: [
          '(2x + 3)/(x² + 3x + 2)',
          '1/(x² + 3x + 2)',
          '2x + 3',
          '(x² + 3x + 2)/(2x + 3)'
        ],
        correctIndex: 0,
        explanation:
            'Use the chain rule: d/dx[ln(u)] = (1/u) * du/dx. Here, u = x² + 3x + 2, so du/dx = 2x + 3. Therefore, d/dx[ln(x² + 3x + 2)] = (2x + 3)/(x² + 3x + 2).',
      ),
      ChapterQuestion(
        questionText: 'Find the derivative of f(x) = (x + 1)^(x + 1)',
        options: [
          '(x + 1)^(x + 1)(ln(x + 1) + 1)',
          '(x + 1)^x',
          '(x + 1)^(x + 1)ln(x + 1)',
          '(x + 1)^x(ln(x + 1) + 1)'
        ],
        correctIndex: 0,
        explanation:
            'Use logarithmic differentiation: ln(f(x)) = (x + 1)ln(x + 1). Differentiate: f\'(x)/f(x) = ln(x + 1) + (x + 1)/(x + 1) = ln(x + 1) + 1. Therefore, f\'(x) = (x + 1)^(x + 1)(ln(x + 1) + 1).',
      ),
      ChapterQuestion(
        questionText: 'What is the derivative of f(x) = cot(x)',
        options: ['-csc²(x)', 'csc²(x)', '-sec²(x)', 'sec²(x)'],
        correctIndex: 0,
        explanation:
            'The derivative of cot(x) = cos(x)/sin(x) is -csc²(x). This can be derived using the quotient rule.',
      ),
      ChapterQuestion(
        questionText: 'Find the derivative of f(x) = csc(x)',
        options: ['-csc(x)cot(x)', 'csc(x)cot(x)', '-sec(x)tan(x)', 'sec(x)tan(x)'],
        correctIndex: 0,
        explanation:
            'The derivative of csc(x) = 1/sin(x) is -csc(x)cot(x). This can be derived using the quotient rule.',
      ),
    ],
  ),

  // Unit 3: Applications of Derivatives
  APCourseChapter(
    name: 'Applications of Derivatives',
    description: 'Using derivatives to analyze functions, optimization, and related rates',
    unitNumber: 3,
    questions: [
      ChapterQuestion(
        questionText: 'If f\'(x) > 0 on an interval, then f(x) is:',
        options: [
          'Increasing on that interval',
          'Decreasing on that interval',
          'Constant on that interval',
          'Undefined on that interval'
        ],
        correctIndex: 0,
        explanation:
            'If the derivative is positive on an interval, the function is increasing on that interval. This is a fundamental property of derivatives.',
      ),
      ChapterQuestion(
        questionText: 'A function has a local maximum at x = c if:',
        options: [
          'f\'(c) = 0 and f\'\'(c) < 0',
          'f\'(c) = 0 and f\'\'(c) > 0',
          'f\'(c) > 0',
          'f\'(c) < 0'
        ],
        correctIndex: 0,
        explanation:
            'For a local maximum, the first derivative must be zero (critical point) and the second derivative must be negative (concave down).',
      ),
      ChapterQuestion(
        questionText: 'A function has a local minimum at x = c if:',
        options: [
          'f\'(c) = 0 and f\'\'(c) > 0',
          'f\'(c) = 0 and f\'\'(c) < 0',
          'f\'(c) > 0',
          'f\'(c) < 0'
        ],
        correctIndex: 0,
        explanation:
            'For a local minimum, the first derivative must be zero (critical point) and the second derivative must be positive (concave up).',
      ),
      ChapterQuestion(
        questionText: 'If f\'\'(x) > 0 on an interval, then f(x) is:',
        options: [
          'Concave up on that interval',
          'Concave down on that interval',
          'Linear on that interval',
          'Constant on that interval'
        ],
        correctIndex: 0,
        explanation:
            'If the second derivative is positive, the function is concave up (shaped like a U) on that interval.',
      ),
      ChapterQuestion(
        questionText: 'A point of inflection occurs when:',
        options: [
          'f\'\'(x) changes sign',
          'f\'(x) = 0',
          'f(x) = 0',
          'f\'\'(x) = 0'
        ],
        correctIndex: 0,
        explanation:
            'A point of inflection occurs where the concavity changes, which happens when f\'\'(x) changes sign (from positive to negative or vice versa).',
      ),
      ChapterQuestion(
        questionText: 'What is the Mean Value Theorem?',
        options: [
          'If f is continuous on [a,b] and differentiable on (a,b), then there exists c in (a,b) such that f\'(c) = (f(b) - f(a))/(b - a)',
          'If f is continuous, then f has a maximum and minimum',
          'If f\'(x) = 0, then f has an extremum',
          'If f is differentiable, then f is continuous'
        ],
        correctIndex: 0,
        explanation:
            'The Mean Value Theorem states that for a function continuous on [a,b] and differentiable on (a,b), there exists at least one point c where the instantaneous rate of change equals the average rate of change.',
      ),
      ChapterQuestion(
        questionText: 'What is L\'Hôpital\'s Rule used for?',
        options: [
          'Evaluating limits of indeterminate forms',
          'Finding derivatives',
          'Finding integrals',
          'Solving differential equations'
        ],
        correctIndex: 0,
        explanation:
            'L\'Hôpital\'s Rule is used to evaluate limits that result in indeterminate forms like 0/0 or ∞/∞ by taking derivatives of the numerator and denominator.',
      ),
      ChapterQuestion(
        questionText: 'If a rectangle has perimeter P, what is the maximum area?',
        options: [
          'P²/16',
          'P²/4',
          'P²/8',
          'P²/2'
        ],
        correctIndex: 0,
        explanation:
            'For a rectangle with perimeter P = 2l + 2w, the area A = lw. Expressing w in terms of l: w = (P - 2l)/2, so A = l(P - 2l)/2. Taking derivative and setting to zero gives l = P/4, so maximum area is P²/16.',
      ),
      ChapterQuestion(
        questionText: 'What is the linear approximation of f(x) near x = a?',
        options: [
          'L(x) = f(a) + f\'(a)(x - a)',
          'L(x) = f(a) + f\'(x)(x - a)',
          'L(x) = f\'(a)(x - a)',
          'L(x) = f(a) + f(x)(x - a)'
        ],
        correctIndex: 0,
        explanation:
            'The linear approximation (tangent line approximation) at x = a is L(x) = f(a) + f\'(a)(x - a), which uses the function value and derivative at point a.',
      ),
      ChapterQuestion(
        questionText: 'In a related rates problem, if the radius of a circle is increasing at 3 cm/s, how fast is the area changing when r = 5?',
        options: ['30π cm²/s', '15π cm²/s', '25π cm²/s', '10π cm²/s'],
        correctIndex: 0,
        explanation:
            'Area A = πr², so dA/dt = 2πr(dr/dt). When r = 5 and dr/dt = 3, dA/dt = 2π(5)(3) = 30π cm²/s.',
      ),
      ChapterQuestion(
        questionText: 'What is Newton\'s Method used for?',
        options: [
          'Finding roots of equations',
          'Finding derivatives',
          'Finding integrals',
          'Finding limits'
        ],
        correctIndex: 0,
        explanation:
            'Newton\'s Method is an iterative algorithm for finding successively better approximations to the roots (zeros) of a real-valued function.',
      ),
      ChapterQuestion(
        questionText: 'If f\'(x) changes from positive to negative at x = c, then:',
        options: [
          'f has a local maximum at x = c',
          'f has a local minimum at x = c',
          'f has a point of inflection at x = c',
          'f is undefined at x = c'
        ],
        correctIndex: 0,
        explanation:
            'When the first derivative changes from positive to negative, the function changes from increasing to decreasing, indicating a local maximum.',
      ),
      ChapterQuestion(
        questionText: 'What is the formula for the error in linear approximation?',
        options: [
          'E(x) = f(x) - L(x)',
          'E(x) = f\'(x) - L\'(x)',
          'E(x) = f\'\'(x)',
          'E(x) = f(x) + L(x)'
        ],
        correctIndex: 0,
        explanation:
            'The error in linear approximation is the difference between the actual function value and the linear approximation: E(x) = f(x) - L(x).',
      ),
      ChapterQuestion(
        questionText: 'If a ladder 10 feet long is sliding down a wall at 2 ft/s, how fast is the bottom moving when the top is 6 feet from the ground?',
        options: ['1.5 ft/s', '2 ft/s', '2.67 ft/s', '3 ft/s'],
        correctIndex: 0,
        explanation:
            'Using x² + y² = 100, differentiate: 2x(dx/dt) + 2y(dy/dt) = 0. When y = 6, x = 8. With dy/dt = -2, solve: 2(8)(dx/dt) + 2(6)(-2) = 0, so dx/dt = 1.5 ft/s.',
      ),
      ChapterQuestion(
        questionText: 'What is the critical point of a function?',
        options: [
          'A point where f\'(x) = 0 or f\'(x) is undefined',
          'A point where f(x) = 0',
          'A point where f\'\'(x) = 0',
          'A point where f(x) is maximum'
        ],
        correctIndex: 0,
        explanation:
            'A critical point is where the derivative is zero or undefined. These are candidates for local extrema.',
      ),
      ChapterQuestion(
        questionText: 'What does Rolle\'s Theorem state?',
        options: [
          'If f is continuous on [a,b], differentiable on (a,b), and f(a) = f(b), then there exists c in (a,b) where f\'(c) = 0',
          'If f is continuous, then f has a maximum',
          'If f\'(x) = 0, then f is constant',
          'If f is differentiable, then f is continuous'
        ],
        correctIndex: 0,
        explanation:
            'Rolle\'s Theorem states that if a function is continuous on [a,b], differentiable on (a,b), and f(a) = f(b), then there exists at least one point c where the derivative is zero.',
      ),
      ChapterQuestion(
        questionText: 'What is the Extreme Value Theorem?',
        options: [
          'A continuous function on a closed interval has both a maximum and minimum',
          'A differentiable function has critical points',
          'A function with f\'(x) = 0 has an extremum',
          'A continuous function is always differentiable'
        ],
        correctIndex: 0,
        explanation:
            'The Extreme Value Theorem guarantees that a continuous function on a closed interval [a,b] attains both a maximum and minimum value on that interval.',
      ),
      ChapterQuestion(
        questionText: 'If f\'\'(x) < 0 on an interval, the function is:',
        options: [
          'Concave down',
          'Concave up',
          'Increasing',
          'Decreasing'
        ],
        correctIndex: 0,
        explanation:
            'If the second derivative is negative, the function is concave down (shaped like an inverted U) on that interval.',
      ),
      ChapterQuestion(
        questionText: 'What is the first derivative test?',
        options: [
          'If f\'(x) changes sign at a critical point, there is an extremum',
          'If f\'(x) = 0, there is an extremum',
          'If f\'\'(x) = 0, there is an extremum',
          'If f(x) = 0, there is an extremum'
        ],
        correctIndex: 0,
        explanation:
            'The first derivative test states that if f\'(x) changes from positive to negative (or vice versa) at a critical point, that point is a local extremum.',
      ),
      ChapterQuestion(
        questionText: 'What is the second derivative test?',
        options: [
          'If f\'(c) = 0 and f\'\'(c) > 0, then f has a local minimum at c',
          'If f\'(c) = 0, then f has an extremum',
          'If f\'\'(c) = 0, then f has an extremum',
          'If f(c) = 0, then f has an extremum'
        ],
        correctIndex: 0,
        explanation:
            'The second derivative test: if f\'(c) = 0 and f\'\'(c) > 0, then f has a local minimum at c. If f\'\'(c) < 0, then f has a local maximum at c.',
      ),
    ],
  ),

  // Unit 4: Integrals
  APCourseChapter(
    name: 'Integrals',
    description: 'Antiderivatives, definite integrals, and integration techniques',
    unitNumber: 4,
    questions: [
      ChapterQuestion(
        questionText: 'Find the integral of ∫(2x + 3)dx',
        options: ['x² + 3x + C', 'x² + 3x', '2x² + 3x + C', 'x² + 6x + C'],
        correctIndex: 0,
        explanation:
            'To integrate ∫(2x + 3)dx, use the power rule for integration: ∫x^n dx = x^(n+1)/(n+1) + C. So ∫2x dx = x² + C and ∫3 dx = 3x + C. Therefore, the answer is x² + 3x + C.',
      ),
      ChapterQuestion(
        questionText: 'What is the area under the curve y = x² from x = 0 to x = 2?',
        options: ['2', '4', '8/3', '16/3'],
        correctIndex: 2,
        explanation:
            'The area is ∫₀² x² dx = [x³/3]₀² = (2³/3) - (0³/3) = 8/3 - 0 = 8/3.',
      ),
      ChapterQuestion(
        questionText: 'Find ∫(x² + 2x + 1)dx',
        options: [
          'x³/3 + x² + x + C',
          'x³ + x² + x + C',
          'x³/3 + x² + C',
          'x³ + 2x² + x + C'
        ],
        correctIndex: 0,
        explanation:
            'Integrate term by term: ∫x² dx = x³/3, ∫2x dx = x², ∫1 dx = x. Therefore, ∫(x² + 2x + 1)dx = x³/3 + x² + x + C.',
      ),
      ChapterQuestion(
        questionText: 'What is the integral of ∫(1/x)dx?',
        options: ['ln|x| + C', '1/x² + C', 'x + C', 'ln(x) + C'],
        correctIndex: 0,
        explanation:
            'The integral of 1/x is ln|x| + C. The absolute value is important because ln(x) is only defined for x > 0, but ln|x| is defined for all x ≠ 0.',
      ),
      ChapterQuestion(
        questionText: 'What is the integral of ∫(e^x)dx?',
        options: ['e^x + C', 'e^x', 'x + C', 'ln(x) + C'],
        correctIndex: 0,
        explanation:
            'The integral of e^x is e^x + C. The exponential function is unique in that its derivative and integral are the same function.',
      ),
      ChapterQuestion(
        questionText: 'Find ∫(x³ + 3x² + 3x + 1)dx',
        options: [
          'x⁴/4 + x³ + 3x²/2 + x + C',
          'x⁴ + x³ + 3x² + x + C',
          'x⁴/4 + x³ + x² + x + C',
          'x⁴ + 3x³ + 3x² + x + C'
        ],
        correctIndex: 0,
        explanation:
            'Integrate term by term: ∫x³ dx = x⁴/4, ∫3x² dx = x³, ∫3x dx = 3x²/2, ∫1 dx = x. Therefore, the answer is x⁴/4 + x³ + 3x²/2 + x + C.',
      ),
      ChapterQuestion(
        questionText: 'What is the integral of ∫(x²e^x)dx?',
        options: [
          'x²e^x - 2xe^x + 2e^x + C',
          'x²e^x + 2xe^x + 2e^x + C',
          'x²e^x - 2xe^x + C',
          'x²e^x + C'
        ],
        correctIndex: 0,
        explanation:
            'Use integration by parts twice: ∫x²e^x dx = x²e^x - ∫2xe^x dx = x²e^x - 2(xe^x - ∫e^x dx) = x²e^x - 2xe^x + 2e^x + C.',
      ),
      ChapterQuestion(
        questionText: 'Find the integral of ∫(sin(x)cos(x))dx',
        options: [
          'sin²(x)/2 + C',
          'cos²(x)/2 + C',
          'sin(x)cos(x) + C',
          'sin²(x) + C'
        ],
        correctIndex: 0,
        explanation:
            'Use the double angle identity: sin(2x) = 2sin(x)cos(x). So sin(x)cos(x) = sin(2x)/2. Therefore, ∫sin(x)cos(x)dx = ∫sin(2x)/2 dx = -cos(2x)/4 + C = sin²(x)/2 + C.',
      ),
      ChapterQuestion(
        questionText: 'What is the integral of ∫(1/√(1 - x²))dx?',
        options: [
          'arcsin(x) + C',
          'arccos(x) + C',
          'arctan(x) + C',
          'arccot(x) + C'
        ],
        correctIndex: 0,
        explanation:
            'The integral of 1/√(1 - x²) is arcsin(x) + C. This is the antiderivative of the derivative of arcsin(x).',
      ),
      ChapterQuestion(
        questionText: 'Find ∫(cos(x))dx',
        options: ['sin(x) + C', '-cos(x) + C', 'tan(x) + C', 'sec(x) + C'],
        correctIndex: 0,
        explanation:
            'The integral of cos(x) is sin(x) + C, since the derivative of sin(x) is cos(x).',
      ),
      ChapterQuestion(
        questionText: 'Find ∫(sin(x))dx',
        options: ['-cos(x) + C', 'cos(x) + C', 'tan(x) + C', 'cot(x) + C'],
        correctIndex: 0,
        explanation:
            'The integral of sin(x) is -cos(x) + C, since the derivative of -cos(x) is sin(x).',
      ),
      ChapterQuestion(
        questionText: 'What is the integral of ∫(sec²(x))dx?',
        options: ['tan(x) + C', 'sec(x) + C', 'cot(x) + C', 'csc(x) + C'],
        correctIndex: 0,
        explanation:
            'The integral of sec²(x) is tan(x) + C, since the derivative of tan(x) is sec²(x).',
      ),
      ChapterQuestion(
        questionText: 'Find ∫(1/(1 + x²))dx',
        options: ['arctan(x) + C', 'arcsin(x) + C', 'arccos(x) + C', 'ln(1 + x²) + C'],
        correctIndex: 0,
        explanation:
            'The integral of 1/(1 + x²) is arctan(x) + C, since the derivative of arctan(x) is 1/(1 + x²).',
      ),
      ChapterQuestion(
        questionText: 'What is the Fundamental Theorem of Calculus Part 1?',
        options: [
          'If F(x) = ∫[a to x] f(t)dt, then F\'(x) = f(x)',
          'If F\'(x) = f(x), then ∫[a to b] f(x)dx = F(b) - F(a)',
          'The derivative of an integral is the original function',
          'Integration and differentiation are inverse operations'
        ],
        correctIndex: 0,
        explanation:
            'The Fundamental Theorem of Calculus Part 1 states that if F(x) = ∫[a to x] f(t)dt, then F\'(x) = f(x). This connects differentiation and integration.',
      ),
      ChapterQuestion(
        questionText: 'What is the Fundamental Theorem of Calculus Part 2?',
        options: [
          'If F\'(x) = f(x), then ∫[a to b] f(x)dx = F(b) - F(a)',
          'If F(x) = ∫[a to x] f(t)dt, then F\'(x) = f(x)',
          'The integral of a derivative is the original function',
          'All continuous functions are integrable'
        ],
        correctIndex: 0,
        explanation:
            'The Fundamental Theorem of Calculus Part 2 states that if F is an antiderivative of f, then ∫[a to b] f(x)dx = F(b) - F(a). This allows us to evaluate definite integrals.',
      ),
      ChapterQuestion(
        questionText: 'Find ∫(x·ln(x))dx',
        options: [
          'x²ln(x)/2 - x²/4 + C',
          'x²ln(x) + C',
          'xln(x) - x + C',
          'x²/2 + C'
        ],
        correctIndex: 0,
        explanation:
            'Use integration by parts with u = ln(x), dv = x dx. Then du = 1/x dx, v = x²/2. So ∫x·ln(x)dx = x²ln(x)/2 - ∫x/2 dx = x²ln(x)/2 - x²/4 + C.',
      ),
      ChapterQuestion(
        questionText: 'What is integration by parts formula?',
        options: [
          '∫u dv = uv - ∫v du',
          '∫u dv = uv + ∫v du',
          '∫u dv = u\'v - ∫v\' du',
          '∫u dv = uv\' - ∫v\' du'
        ],
        correctIndex: 0,
        explanation:
            'Integration by parts formula is ∫u dv = uv - ∫v du. This is derived from the product rule for differentiation.',
      ),
      ChapterQuestion(
        questionText: 'Find ∫(e^(2x))dx',
        options: ['e^(2x)/2 + C', 'e^(2x) + C', '2e^(2x) + C', 'e^(2x)/4 + C'],
        correctIndex: 0,
        explanation:
            'Using substitution u = 2x, du = 2dx, so dx = du/2. Then ∫e^(2x)dx = ∫e^u (du/2) = e^u/2 + C = e^(2x)/2 + C.',
      ),
      ChapterQuestion(
        questionText: 'What is the integral of ∫(1/(x² + 1))dx?',
        options: ['arctan(x) + C', 'arcsin(x) + C', 'ln(x² + 1) + C', 'x/(x² + 1) + C'],
        correctIndex: 0,
        explanation:
            'The integral of 1/(x² + 1) is arctan(x) + C. This is a standard antiderivative.',
      ),
      ChapterQuestion(
        questionText: 'Find ∫(x·e^x)dx',
        options: ['xe^x - e^x + C', 'xe^x + e^x + C', 'x²e^x/2 + C', 'e^x + C'],
        correctIndex: 0,
        explanation:
            'Use integration by parts with u = x, dv = e^x dx. Then du = dx, v = e^x. So ∫xe^x dx = xe^x - ∫e^x dx = xe^x - e^x + C.',
      ),
    ],
  ),

  // Unit 5: Applications of Integrals
  APCourseChapter(
    name: 'Applications of Integrals',
    description: 'Area, volume, and other applications of integration',
    unitNumber: 5,
    questions: [
      ChapterQuestion(
        questionText:
            'What is the area between y = x² and y = x from x = 0 to x = 1?',
        options: ['1/6', '1/3', '1/2', '1'],
        correctIndex: 0,
        explanation:
            'The area is ∫₀¹ (x - x²) dx = [x²/2 - x³/3]₀¹ = (1/2 - 1/3) - (0 - 0) = 1/6.',
      ),
      ChapterQuestion(
        questionText:
            'What is the area between y = sin(x) and y = cos(x) from x = 0 to x = π/4?',
        options: ['√2 - 1', '1 - √2', '√2', '1'],
        correctIndex: 0,
        explanation:
            'Area = ∫₀^(π/4) (cos(x) - sin(x)) dx = [sin(x) + cos(x)]₀^(π/4) = (sin(π/4) + cos(π/4)) - (sin(0) + cos(0)) = (√2/2 + √2/2) - (0 + 1) = √2 - 1.',
      ),
      ChapterQuestion(
        questionText:
            'Find the volume of revolution when y = x² is rotated around the x-axis from x = 0 to x = 2',
        options: ['32π/5', '16π/5', '8π/5', '64π/5'],
        correctIndex: 0,
        explanation:
            'Volume = π∫₀² (x²)² dx = π∫₀² x⁴ dx = π[x⁵/5]₀² = π(32/5 - 0) = 32π/5.',
      ),
      ChapterQuestion(
        questionText: 'What is the formula for volume by disk method?',
        options: [
          'V = π∫[a to b] [R(x)]² dx',
          'V = π∫[a to b] R(x) dx',
          'V = ∫[a to b] [R(x)]² dx',
          'V = 2π∫[a to b] R(x) dx'
        ],
        correctIndex: 0,
        explanation:
            'The disk method formula for volume of revolution around the x-axis is V = π∫[a to b] [R(x)]² dx, where R(x) is the radius.',
      ),
      ChapterQuestion(
        questionText: 'What is the formula for volume by washer method?',
        options: [
          'V = π∫[a to b] ([R(x)]² - [r(x)]²) dx',
          'V = π∫[a to b] (R(x) - r(x)) dx',
          'V = ∫[a to b] ([R(x)]² - [r(x)]²) dx',
          'V = 2π∫[a to b] (R(x) - r(x)) dx'
        ],
        correctIndex: 0,
        explanation:
            'The washer method formula is V = π∫[a to b] ([R(x)]² - [r(x)]²) dx, where R(x) is the outer radius and r(x) is the inner radius.',
      ),
      ChapterQuestion(
        questionText: 'What is the formula for volume by shell method?',
        options: [
          'V = 2π∫[a to b] x·f(x) dx',
          'V = π∫[a to b] [f(x)]² dx',
          'V = ∫[a to b] x·f(x) dx',
          'V = 2π∫[a to b] f(x) dx'
        ],
        correctIndex: 0,
        explanation:
            'The shell method formula for volume of revolution around the y-axis is V = 2π∫[a to b] x·f(x) dx.',
      ),
      ChapterQuestion(
        questionText: 'What is the average value of a function f(x) on [a,b]?',
        options: [
          '(1/(b-a))∫[a to b] f(x) dx',
          '∫[a to b] f(x) dx',
          '(b-a)∫[a to b] f(x) dx',
          'f((a+b)/2)'
        ],
        correctIndex: 0,
        explanation:
            'The average value of f(x) on [a,b] is (1/(b-a))∫[a to b] f(x) dx. This gives the "mean height" of the function.',
      ),
      ChapterQuestion(
        questionText: 'What is the area between two curves y = f(x) and y = g(x)?',
        options: [
          '∫[a to b] |f(x) - g(x)| dx',
          '∫[a to b] (f(x) - g(x)) dx',
          '∫[a to b] f(x) dx - ∫[a to b] g(x) dx',
          '|∫[a to b] f(x) dx - ∫[a to b] g(x) dx|'
        ],
        correctIndex: 0,
        explanation:
            'The area between two curves is ∫[a to b] |f(x) - g(x)| dx, where a and b are the intersection points. The absolute value ensures positive area.',
      ),
      ChapterQuestion(
        questionText: 'Find the volume when y = √x is rotated around the x-axis from x = 0 to x = 4',
        options: ['8π', '4π', '16π', '32π'],
        correctIndex: 0,
        explanation:
            'Volume = π∫₀⁴ (√x)² dx = π∫₀⁴ x dx = π[x²/2]₀⁴ = π(16/2 - 0) = 8π.',
      ),
      ChapterQuestion(
        questionText: 'What is the arc length formula?',
        options: [
          'L = ∫[a to b] √(1 + [f\'(x)]²) dx',
          'L = ∫[a to b] f\'(x) dx',
          'L = ∫[a to b] √(f(x)) dx',
          'L = ∫[a to b] (1 + f\'(x)) dx'
        ],
        correctIndex: 0,
        explanation:
            'The arc length of a curve y = f(x) from x = a to x = b is L = ∫[a to b] √(1 + [f\'(x)]²) dx.',
      ),
      ChapterQuestion(
        questionText: 'Find the area under y = e^x from x = 0 to x = 1',
        options: ['e - 1', 'e', 'e + 1', '1'],
        correctIndex: 0,
        explanation:
            'Area = ∫₀¹ e^x dx = [e^x]₀¹ = e¹ - e⁰ = e - 1.',
      ),
      ChapterQuestion(
        questionText: 'What is the volume when the region bounded by y = x², y = 0, and x = 2 is rotated around the y-axis?',
        options: ['8π', '16π', '32π/3', '64π/3'],
        correctIndex: 0,
        explanation:
            'Using shell method: V = 2π∫₀² x·x² dx = 2π∫₀² x³ dx = 2π[x⁴/4]₀² = 2π(16/4) = 8π.',
      ),
      ChapterQuestion(
        questionText: 'What is the average value of f(x) = x² on [0, 2]?',
        options: ['4/3', '2', '8/3', '4'],
        correctIndex: 0,
        explanation:
            'Average value = (1/(2-0))∫₀² x² dx = (1/2)[x³/3]₀² = (1/2)(8/3) = 4/3.',
      ),
      ChapterQuestion(
        questionText: 'Find the area between y = x³ and y = x from x = -1 to x = 1',
        options: ['1/2', '1', '2', '0'],
        correctIndex: 0,
        explanation:
            'Area = ∫₋₁¹ |x³ - x| dx. Since x³ - x = x(x² - 1) = x(x-1)(x+1), the function is negative on (-1,0) and positive on (0,1). Area = ∫₋₁⁰ (x - x³) dx + ∫₀¹ (x³ - x) dx = 1/2.',
      ),
      ChapterQuestion(
        questionText: 'What is the volume when y = 1/x is rotated around the x-axis from x = 1 to x = 2?',
        options: ['π/2', 'π', '2π', 'π/4'],
        correctIndex: 0,
        explanation:
            'Volume = π∫₁² (1/x)² dx = π∫₁² 1/x² dx = π[-1/x]₁² = π(-1/2 + 1) = π/2.',
      ),
      ChapterQuestion(
        questionText: 'Find the arc length of y = x^(3/2) from x = 0 to x = 4',
        options: ['(8/27)(10^(3/2) - 1)', '(8/27)(10^(3/2))', '10^(3/2)', '8/27'],
        correctIndex: 0,
        explanation:
            'f\'(x) = (3/2)x^(1/2), so [f\'(x)]² = (9/4)x. Arc length = ∫₀⁴ √(1 + 9x/4) dx. Using substitution u = 1 + 9x/4, the result is (8/27)(10^(3/2) - 1).',
      ),
      ChapterQuestion(
        questionText: 'What is the volume when the region bounded by y = x, y = 0, and x = 4 is rotated around x = 4?',
        options: ['128π/3', '64π/3', '32π/3', '16π/3'],
        correctIndex: 0,
        explanation:
            'Using shell method with radius (4-x): V = 2π∫₀⁴ (4-x)·x dx = 2π[2x² - x³/3]₀⁴ = 2π(32 - 64/3) = 128π/3.',
      ),
      ChapterQuestion(
        questionText: 'Find the area of the region bounded by y = x² and y = 2x',
        options: ['4/3', '2/3', '8/3', '1'],
        correctIndex: 0,
        explanation:
            'Intersection points: x² = 2x, so x = 0 or x = 2. Area = ∫₀² (2x - x²) dx = [x² - x³/3]₀² = 4 - 8/3 = 4/3.',
      ),
      ChapterQuestion(
        questionText: 'What is the volume when y = sin(x) is rotated around the x-axis from x = 0 to x = π?',
        options: ['π²/2', 'π', '2π', 'π/2'],
        correctIndex: 0,
        explanation:
            'Volume = π∫₀^π sin²(x) dx = π∫₀^π (1 - cos(2x))/2 dx = π[x/2 - sin(2x)/4]₀^π = π²/2.',
      ),
      ChapterQuestion(
        questionText: 'What is the average value of f(x) = sin(x) on [0, π]?',
        options: ['2/π', '1/π', '1', 'π/2'],
        correctIndex: 0,
        explanation:
            'Average value = (1/π)∫₀^π sin(x) dx = (1/π)[-cos(x)]₀^π = (1/π)(1 + 1) = 2/π.',
      ),
    ],
  ),

  // Unit 6: Differential Equations
  APCourseChapter(
    name: 'Differential Equations',
    description: 'Solving separable differential equations and slope fields',
    unitNumber: 6,
    questions: [
      ChapterQuestion(
        questionText: 'What is a separable differential equation?',
        options: [
          'An equation that can be written as dy/dx = f(x)g(y)',
          'An equation with only x terms',
          'An equation with only y terms',
          'An equation that cannot be solved'
        ],
        correctIndex: 0,
        explanation:
            'A separable differential equation can be written in the form dy/dx = f(x)g(y), allowing separation of variables: dy/g(y) = f(x)dx.',
      ),
      ChapterQuestion(
        questionText: 'How do you solve dy/dx = 2xy?',
        options: [
          'Separate: dy/y = 2x dx, integrate to get ln|y| = x² + C, so y = Ce^(x²)',
          'y = 2x + C',
          'y = x² + C',
          'y = e^(2x) + C'
        ],
        correctIndex: 0,
        explanation:
            'Separate variables: dy/y = 2x dx. Integrate both sides: ln|y| = x² + C. Exponentiate: y = e^(x² + C) = Ce^(x²), where C = e^C.',
      ),
      ChapterQuestion(
        questionText: 'What is a slope field?',
        options: [
          'A graphical representation showing slopes at various points',
          'A field where functions are defined',
          'A method for finding derivatives',
          'A type of integral'
        ],
        correctIndex: 0,
        explanation:
            'A slope field (direction field) is a graphical representation of a differential equation showing the slope of the solution curve at various points in the plane.',
      ),
      ChapterQuestion(
        questionText: 'Solve dy/dx = y with initial condition y(0) = 3',
        options: ['y = 3e^x', 'y = e^x + 2', 'y = 3x', 'y = x + 3'],
        correctIndex: 0,
        explanation:
            'Separate: dy/y = dx. Integrate: ln|y| = x + C. With y(0) = 3: ln(3) = C, so ln|y| = x + ln(3), giving y = 3e^x.',
      ),
      ChapterQuestion(
        questionText: 'What is the general solution to dy/dx = ky?',
        options: ['y = Ce^(kx)', 'y = kx + C', 'y = Ce^x', 'y = kx'],
        correctIndex: 0,
        explanation:
            'Separating variables: dy/y = k dx. Integrating: ln|y| = kx + C. Exponentiating: y = Ce^(kx), where C is determined by initial conditions.',
      ),
      ChapterQuestion(
        questionText: 'Solve dy/dx = x/y with y(1) = 2',
        options: ['y = √(x² + 3)', 'y = x + 1', 'y = 2x', 'y = x²'],
        correctIndex: 0,
        explanation:
            'Separate: y dy = x dx. Integrate: y²/2 = x²/2 + C. With y(1) = 2: 4/2 = 1/2 + C, so C = 3/2. Therefore, y² = x² + 3, so y = √(x² + 3).',
      ),
      ChapterQuestion(
        questionText: 'What is an initial value problem?',
        options: [
          'A differential equation with a specified value at a point',
          'A differential equation without constants',
          'A differential equation that cannot be solved',
          'A differential equation with multiple solutions'
        ],
        correctIndex: 0,
        explanation:
            'An initial value problem is a differential equation along with a specified value (initial condition) that determines the particular solution from the general solution.',
      ),
      ChapterQuestion(
        questionText: 'Solve dy/dx = -2y with y(0) = 5',
        options: ['y = 5e^(-2x)', 'y = -2x + 5', 'y = 5e^(2x)', 'y = -10x'],
        correctIndex: 0,
        explanation:
            'Separate: dy/y = -2 dx. Integrate: ln|y| = -2x + C. With y(0) = 5: ln(5) = C, so y = 5e^(-2x).',
      ),
      ChapterQuestion(
        questionText: 'What does a slope field show?',
        options: [
          'The direction of solution curves at various points',
          'The value of the function',
          'The derivative of the function',
          'The integral of the function'
        ],
        correctIndex: 0,
        explanation:
            'A slope field shows the direction (slope) that solution curves would have at various points, helping visualize the behavior of solutions to a differential equation.',
      ),
      ChapterQuestion(
        questionText: 'Solve dy/dx = (x + 1)/y with y(0) = 1',
        options: ['y = √(x² + 2x + 1)', 'y = x + 1', 'y = x² + 1', 'y = √(x + 1)'],
        correctIndex: 0,
        explanation:
            'Separate: y dy = (x + 1) dx. Integrate: y²/2 = x²/2 + x + C. With y(0) = 1: 1/2 = C, so y² = x² + 2x + 1 = (x + 1)², giving y = √(x² + 2x + 1) = |x + 1|.',
      ),
      ChapterQuestion(
        questionText: 'What is exponential growth?',
        options: [
          'Growth modeled by dy/dt = ky where k > 0',
          'Growth that is constant',
          'Growth that decreases over time',
          'Growth that is linear'
        ],
        correctIndex: 0,
        explanation:
            'Exponential growth occurs when the rate of change is proportional to the current amount, modeled by dy/dt = ky where k > 0. The solution is y = y₀e^(kt).',
      ),
      ChapterQuestion(
        questionText: 'What is exponential decay?',
        options: [
          'Decay modeled by dy/dt = -ky where k > 0',
          'Decay that is constant',
          'Decay that increases over time',
          'Decay that is linear'
        ],
        correctIndex: 0,
        explanation:
            'Exponential decay occurs when the rate of change is proportional to the current amount but negative, modeled by dy/dt = -ky where k > 0. The solution is y = y₀e^(-kt).',
      ),
      ChapterQuestion(
        questionText: 'Solve dy/dx = y/x with y(1) = 2',
        options: ['y = 2x', 'y = x + 1', 'y = x²', 'y = 2/x'],
        correctIndex: 0,
        explanation:
            'Separate: dy/y = dx/x. Integrate: ln|y| = ln|x| + C = ln|x| + ln|C| = ln|Cx|. So y = Cx. With y(1) = 2: 2 = C, so y = 2x.',
      ),
      ChapterQuestion(
        questionText: 'What is the half-life in exponential decay?',
        options: [
          'The time for half the substance to remain: t = (ln 2)/k',
          'The time for all substance to decay',
          'The initial amount divided by 2',
          'The decay constant k'
        ],
        correctIndex: 0,
        explanation:
            'Half-life is the time required for half of a substance to decay. For y = y₀e^(-kt), setting y = y₀/2 gives t = (ln 2)/k.',
      ),
      ChapterQuestion(
        questionText: 'Solve dy/dx = e^x · y with y(0) = 1',
        options: ['y = e^(e^x - 1)', 'y = e^x', 'y = e^(x²)', 'y = e^(2x)'],
        correctIndex: 0,
        explanation:
            'Separate: dy/y = e^x dx. Integrate: ln|y| = e^x + C. With y(0) = 1: 0 = e⁰ + C = 1 + C, so C = -1. Therefore, y = e^(e^x - 1).',
      ),
      ChapterQuestion(
        questionText: 'What is a logistic growth model?',
        options: [
          'dy/dt = ky(1 - y/L) where L is carrying capacity',
          'dy/dt = ky',
          'dy/dt = k',
          'dy/dt = -ky'
        ],
        correctIndex: 0,
        explanation:
            'Logistic growth models growth that is limited by a carrying capacity L. The equation is dy/dt = ky(1 - y/L), where growth slows as y approaches L.',
      ),
      ChapterQuestion(
        questionText: 'Solve dy/dx = y² with y(0) = 1',
        options: ['y = 1/(1 - x)', 'y = 1 + x', 'y = x²', 'y = e^x'],
        correctIndex: 0,
        explanation:
            'Separate: dy/y² = dx. Integrate: -1/y = x + C. With y(0) = 1: -1 = C, so -1/y = x - 1, giving y = 1/(1 - x).',
      ),
      ChapterQuestion(
        questionText: 'What is the method of separation of variables?',
        options: [
          'Rewriting dy/dx = f(x)g(y) as dy/g(y) = f(x)dx and integrating',
          'Substituting variables',
          'Using the chain rule',
          'Finding antiderivatives'
        ],
        correctIndex: 0,
        explanation:
            'Separation of variables involves rewriting a separable differential equation so that all y terms are on one side and all x terms are on the other, then integrating both sides.',
      ),
      ChapterQuestion(
        questionText: 'Solve dy/dx = (y + 1)/x with y(1) = 0',
        options: ['y = x - 1', 'y = x', 'y = 1/x - 1', 'y = x + 1'],
        correctIndex: 0,
        explanation:
            'Separate: dy/(y + 1) = dx/x. Integrate: ln|y + 1| = ln|x| + C. With y(1) = 0: ln(1) = ln(1) + C, so C = 0. Therefore, y + 1 = x, so y = x - 1.',
      ),
      ChapterQuestion(
        questionText: 'What does it mean if a differential equation is autonomous?',
        options: [
          'dy/dx depends only on y, not on x',
          'dy/dx depends only on x, not on y',
          'dy/dx is constant',
          'The equation cannot be solved'
        ],
        correctIndex: 0,
        explanation:
            'An autonomous differential equation has the form dy/dx = f(y), where the derivative depends only on y, not explicitly on x. Examples include exponential growth/decay.',
      ),
    ],
  ),
];
