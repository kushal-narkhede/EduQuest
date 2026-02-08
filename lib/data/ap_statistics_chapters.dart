import 'ap_course_chapters.dart';

/// AP Statistics chapters (condensed units with sample questions).
final List<APCourseChapter> apStatisticsChapters = [
  APCourseChapter(
    name: 'Exploring Data',
    description: 'Distributions, center, spread, and shape',
    unitNumber: 1,
    questions: [
      ChapterQuestion(
        questionText: 'Which measure is resistant to outliers?',
        options: ['Mean', 'Median', 'Standard deviation', 'Range'],
        correctIndex: 1,
        explanation: 'The median is resistant to extreme values.',
      ),
      ChapterQuestion(
        questionText: 'A boxplot shows:',
        options: ['Mean only', 'Quartiles and median', 'Correlation', 'Slope'],
        correctIndex: 1,
        explanation: 'Boxplots display quartiles, median, and spread.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Sampling and Experimentation',
    description: 'Study design, bias, and randomization',
    unitNumber: 2,
    questions: [
      ChapterQuestion(
        questionText: 'A simple random sample means:',
        options: [
          'Every subject is selected',
          'Every subset of size n is equally likely',
          'Only volunteers are used',
          'Sampling stops early'
        ],
        correctIndex: 1,
        explanation: 'SRS gives every subset of size n an equal chance.',
      ),
      ChapterQuestion(
        questionText: 'Random assignment helps with:',
        options: ['Causation', 'Bias reduction', 'Both', 'Neither'],
        correctIndex: 2,
        explanation: 'Random assignment reduces bias and supports causation.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Probability',
    description: 'Rules of probability and distributions',
    unitNumber: 3,
    questions: [
      ChapterQuestion(
        questionText: 'If events are independent, P(A and B) =',
        options: ['P(A)+P(B)', 'P(A)P(B)', 'P(A)/P(B)', 'P(B)-P(A)'],
        correctIndex: 1,
        explanation: 'Independence implies multiplication of probabilities.',
      ),
      ChapterQuestion(
        questionText: 'A random variable assigns:',
        options: ['Outcomes to numbers', 'Numbers to outcomes', 'Means to samples', 'Samples to populations'],
        correctIndex: 1,
        explanation: 'Random variables map outcomes to numerical values.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Random Variables',
    description: 'Expected value and standard deviation',
    unitNumber: 4,
    questions: [
      ChapterQuestion(
        questionText: 'Expected value is:',
        options: ['Median', 'Long-run average', 'Mode', 'Range'],
        correctIndex: 1,
        explanation: 'Expected value is the long-run average.',
      ),
      ChapterQuestion(
        questionText: 'Standard deviation measures:',
        options: ['Center', 'Spread', 'Shape', 'Bias'],
        correctIndex: 1,
        explanation: 'Standard deviation measures variability/spread.',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Inference',
    description: 'Confidence intervals and hypothesis tests',
    unitNumber: 5,
    questions: [
      ChapterQuestion(
        questionText: 'A confidence interval gives a range for:',
        options: ['Sample statistic', 'Population parameter', 'Outliers', 'Random error'],
        correctIndex: 1,
        explanation: 'Confidence intervals estimate population parameters.',
      ),
      ChapterQuestion(
        questionText: 'A p-value is:',
        options: [
          'Probability the null is true',
          'Probability of data given the null',
          'Confidence level',
          'Type I error rate'
        ],
        correctIndex: 1,
        explanation: 'p-value is P(data or more extreme | null).',
      ),
    ],
  ),
  APCourseChapter(
    name: 'Regression',
    description: 'Correlation, regression, and residuals',
    unitNumber: 6,
    questions: [
      ChapterQuestion(
        questionText: 'Correlation r measures:',
        options: ['Causation', 'Linear association', 'Nonlinear association', 'Outliers only'],
        correctIndex: 1,
        explanation: 'Correlation measures the strength of linear association.',
      ),
      ChapterQuestion(
        questionText: 'A residual is:',
        options: ['Observed - predicted', 'Predicted - observed', 'Mean - median', 'Slope - intercept'],
        correctIndex: 0,
        explanation: 'Residual = observed value minus predicted value.',
      ),
    ],
  ),
];
