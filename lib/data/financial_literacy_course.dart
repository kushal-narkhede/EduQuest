import 'premade_study_sets.dart';

/// Structured model for the Financial Literacy course.
class FinancialLiteracyCourse {
  final List<FinancialLesson> textbookLessons;
  final List<Question> questionBank;
  final List<FinancialPortfolioTask> portfolioTasks;

  const FinancialLiteracyCourse({
    required this.textbookLessons,
    required this.questionBank,
    required this.portfolioTasks,
  });
}

/// Brief lesson entry for the TextBook path.
class FinancialLesson {
  final String title;
  final String summary;

  const FinancialLesson({
    required this.title,
    required this.summary,
  });
}

/// Hands-on portfolio exercises and simulations.
class FinancialPortfolioTask {
  final String title;
  final String objective;

  const FinancialPortfolioTask({
    required this.title,
    required this.objective,
  });
}

/// Canonical instance with the current Financial Literacy content.
const FinancialLiteracyCourse kFinancialLiteracyCourse = FinancialLiteracyCourse(
  textbookLessons: [
    FinancialLesson(
      title: 'Money Basics',
      summary: 'Budgeting, emergency funds, and spending plans.',
    ),
    FinancialLesson(
      title: 'Credit & Debt',
      summary: 'Credit scores, cards vs. debit, and responsible borrowing.',
    ),
    FinancialLesson(
      title: 'Investing Foundations',
      summary: 'Compound interest, diversification, and inflation.',
    ),
    FinancialLesson(
      title: 'Big Purchases',
      summary: 'Mortgages, loans, and comparing total costs.',
    ),
  ],
  questionBank: [
    Question(
      questionText: 'What is the difference between a credit card and a debit card?',
      options: [
        'Credit cards borrow money, debit cards use your own money',
        'Debit cards borrow money, credit cards use your own money',
        'They are the same thing',
        'Credit cards are only for online purchases'
      ],
      correctAnswer: 'Credit cards borrow money, debit cards use your own money',
    ),
    Question(
      questionText: 'What is a credit score used for?',
      options: [
        'To determine your creditworthiness and loan eligibility',
        'To calculate your income tax',
        'To determine your age',
        'To track your shopping habits'
      ],
      correctAnswer: 'To determine your creditworthiness and loan eligibility',
    ),
    Question(
      questionText: 'What is compound interest?',
      options: [
        'Interest earned on interest',
        'Interest that stays the same each year',
        'Interest only on the principal',
        'Interest paid monthly instead of yearly'
      ],
      correctAnswer: 'Interest earned on interest',
    ),
    Question(
      questionText: 'What is a budget?',
      options: [
        'A plan for spending and saving money',
        'Money borrowed from a bank',
        'A tax return form',
        'Money saved in a savings account'
      ],
      correctAnswer: 'A plan for spending and saving money',
    ),
    Question(
      questionText: 'What is an emergency fund?',
      options: [
        'Savings set aside for unexpected expenses',
        'Money for vacation',
        'Money for shopping',
        'Money for investments'
      ],
      correctAnswer: 'Savings set aside for unexpected expenses',
    ),
    Question(
      questionText: 'What is diversification in investing?',
      options: [
        'Spreading investments across different asset types to reduce risk',
        'Investing all money in one stock',
        'Trading frequently',
        'Borrowing money to invest'
      ],
      correctAnswer: 'Spreading investments across different asset types to reduce risk',
    ),
    Question(
      questionText: 'What is inflation?',
      options: [
        'The increase in prices of goods and services over time',
        'The decrease in prices of goods and services over time',
        'A type of tax',
        'A type of insurance'
      ],
      correctAnswer: 'The increase in prices of goods and services over time',
    ),
    Question(
      questionText: 'What is a mortgage?',
      options: [
        'A loan used to purchase a home',
        'A type of insurance',
        'A type of investment',
        'A type of savings account'
      ],
      correctAnswer: 'A loan used to purchase a home',
    ),
  ],
  portfolioTasks: [
    FinancialPortfolioTask(
      title: 'Build a Starter Budget',
      objective: 'Create a 50/30/20 budget with an emergency fund line item.',
    ),
    FinancialPortfolioTask(
      title: 'Track a Credit Score',
      objective: 'List the biggest score factors and plan actions to improve them.',
    ),
    FinancialPortfolioTask(
      title: 'Simulate Compound Growth',
      objective: 'Model monthly contributions and 6% annual return over 5 years.',
    ),
    FinancialPortfolioTask(
      title: 'Compare Loan Offers',
      objective: 'Calculate total interest for fixed vs. variable mortgage options.',
    ),
  ],
);
