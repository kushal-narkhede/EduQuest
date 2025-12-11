class FinancialTextbookUnit {
  final int unitNumber;
  final String title;
  final String description;
  final List<String> lessons;

  const FinancialTextbookUnit({
    required this.unitNumber,
    required this.title,
    required this.description,
    required this.lessons,
  });
}

// All Financial Literacy TextBook units (excluding the Welcome unit)
final List<FinancialTextbookUnit> financialLiteracyUnits = [
  FinancialTextbookUnit(
    unitNumber: 1,
    title: 'Budgeting and Saving',
    description:
        'Do you know how to design and balance a budget? What about the 50-30-20 budgeting rule? Whether you\'re looking to pay off debt, save for a rainy day or just want to be more in control of your money, this unit may help you learn how to budget and save like an expert.',
    lessons: ['Budgeting', 'Reducing expenses', 'Saving money'],
  ),
  FinancialTextbookUnit(
    unitNumber: 2,
    title: 'Consumer Credit',
    description:
        'Understanding credit is an essential part of making smart financial decisions. Find out how to use credit to your advantage with these lessons.',
    lessons: ['Credit score', 'Credit cards', 'Payment methods'],
  ),
  FinancialTextbookUnit(
    unitNumber: 3,
    title: 'Financial Goals',
    description:
        'Explore the importance of setting clear, achievable goals that help pave the way for a stable financial future. Plus, learn how to prioritize your financial aspirations, create actionable plans and stay committed to your progress.',
    lessons: [
      'Money personality',
      'Charitable giving',
      'SMART goals',
      'Short-, medium- and long-term goals',
      'Net worth'
    ],
  ),
  FinancialTextbookUnit(
    unitNumber: 4,
    title: 'Loans and Debt',
    description:
        'The world of loans and debt can feel overwhelming. This unit breaks down the complexities of borrowing money to help you make smart decisions about debt. That way, you may transform loans and debt into useful tools for your financial well-being.',
    lessons: [
      'Borrowing money',
      'Types of loans',
      'Terms of borrowing',
      'Debt',
      'Bankruptcy'
    ],
  ),
  FinancialTextbookUnit(
    unitNumber: 5,
    title: 'Insurance',
    description:
        'Insurance can be a complex topic. But insurance plays a vital role in safeguarding your financial future. Gain the vital knowledge and tools you need to help secure your financial future and peace of mind.',
    lessons: [
      'What is risk and how to manage it',
      'Insurance basics and terminology',
      'Health insurance options and costs',
      'Disability and long-term care insurance',
      'Life insurance',
      'Property insurance options and costs',
      'Car insurance options and cost',
      'Supplemental insurance and warranties',
      'Estate planning and legal instruments'
    ],
  ),
  FinancialTextbookUnit(
    unitNumber: 6,
    title: 'Investments and Retirement',
    description:
        'Dive into different investment options and strategies so you can try to grow and secure wealth for the long term. Find out how to harness the power of investing to help achieve financial freedom.',
    lessons: [
      'Introduction to saving and investing',
      'Risk and return of investment options',
      'Planning for retirement'
    ],
  ),
  FinancialTextbookUnit(
    unitNumber: 7,
    title: 'Scams and Fraud',
    description:
        'Scammers are always evolving and coming up with new ways to trick people out of their money. Find out about different types of scams, the red flags to watch out for and ways to help protect yourself.',
    lessons: [
      'How to protect your personal information',
      'Common scams',
      'Consumer protection agencies'
    ],
  ),
  FinancialTextbookUnit(
    unitNumber: 8,
    title: 'Careers and Education',
    description:
        'Investing in your career and education is an important part of helping yourself succeed and reach your goals. Learning new skills and information may open up opportunities for better jobs and a brighter future.',
    lessons: [
      'Education and earnings',
      'College, post-secondary education and training',
      'Cost of post-secondary education and training',
      'Choosing where to go'
    ],
  ),
  FinancialTextbookUnit(
    unitNumber: 9,
    title: 'Taxes and Tax Forms',
    description:
        'Figuring out taxes on your own can be daunting. These practical tips and step-by-step instructions simplify complex tax information so you may confidently manage your taxes.',
    lessons: ['What are taxes?', 'Tax forms'],
  ),
  FinancialTextbookUnit(
    unitNumber: 10,
    title: 'Employment',
    description:
        'This unit teaches you how to understand your pay, compare job offers, and understand the difference between hard and soft benefits. You\'ll also learn about different types of jobs and how to read your paycheck.',
    lessons: [
      'Understanding your pay',
      'Compensation: More than pay',
      'Non-typical pay structures',
      'Hiring process: Forms and documents',
      'Paycheck'
    ],
  ),
  FinancialTextbookUnit(
    unitNumber: 11,
    title: 'Banking',
    description:
        'Whether it\'s depositing your paycheck, managing daily expenses, saving for future goals or navigating financial emergencies, understanding banking is critical.',
    lessons: [
      'Banking and financial institutions',
      'Understanding bank accounts',
      'Tracking, reconciling and more',
      'Banking regulations and agencies',
      'Interest: From savings to investing',
      'Inflation'
    ],
  ),
  FinancialTextbookUnit(
    unitNumber: 12,
    title: 'Car Buying',
    description:
        'In this unit, you\'ll learn how to prepare for buying a car, arm yourself with knowledge, and make decisions that are right for you.',
    lessons: [
      'Car buying experience',
      'Car loans',
      'Owning vs. leasing',
      'Additional costs of car ownership'
    ],
  ),
  FinancialTextbookUnit(
    unitNumber: 13,
    title: 'Housing',
    description:
        'Whether you\'re thinking about renting or buying, understanding housing is essential. Explore how to budget for living costs and navigate the home buying process.',
    lessons: [
      'Renting vs. homeownership',
      'Finding your next home',
      'Lease agreements',
      'Mortgages'
    ],
  ),
];
