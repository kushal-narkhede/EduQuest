import express from 'express';

const router = express.Router();

/**
 * GET /financial-literacy/textbook/unit/:unitNumber
 * Fetch a specific Financial Literacy textbook unit with chapters.
 */
router.get('/financial-literacy/textbook/unit/:unitNumber', async (req, res) => {
  try {
    const { unitNumber } = req.params;
    const db = req.app.locals.db;

    if (!db) {
      return res.status(500).json({ error: 'Database not initialized' });
    }

    const unit = await db
      .collection('financial_literacy_textbook')
      .findOne({ unit_number: parseInt(unitNumber) });

    if (!unit) {
      return res.status(404).json({ error: `Unit ${unitNumber} not found` });
    }

    res.json(unit);
  } catch (error) {
    console.error('Error fetching textbook unit:', error);
    res.status(500).json({ error: error.message });
  }
});

/**
 * POST /financial-literacy/textbook/seed
 * Seed the database with all Financial Literacy textbook units.
 * (Admin endpoint - can be called once during setup)
 */
router.post('/financial-literacy/textbook/seed', async (req, res) => {
  try {
    const db = req.app.locals.db;

    if (!db) {
      return res.status(500).json({ error: 'Database not initialized' });
    }

    const units = [
      {
        unit_number: 1,
        unit_title: 'Budgeting and Saving',
        chapters: [
          {
            chapter_number: 1,
            chapter_name: 'Why Budgeting Matters',
            context:
              'Financial literacy is the foundation of understanding how money works. Budgeting allows you to take control of your finances and plan for your future.',
            exercises: [
              'Write down your monthly income and expenses.',
              'Apply the 50/30/20 rule to your budget.',
            ],
            resources: ['https://example.com/budgeting-guide'],
          },
          {
            chapter_number: 2,
            chapter_name: 'Understanding Income and Expenses',
            context:
              'Financial literacy is not only about numbers and budgets; it is also about understanding where your money comes from and where it goes.',
            exercises: ['Categorize your last 10 purchases into needs vs wants.'],
            resources: [],
          },
        ],
      },
      {
        unit_number: 2,
        unit_title: 'Consumer Credit',
        chapters: [
          {
            chapter_number: 1,
            chapter_name: 'Credit Scores Explained',
            context:
              'Your credit score is a three-digit number that represents your creditworthiness. Lenders use it to determine if they will loan you money.',
            exercises: [
              'Check your credit report for errors.',
              'List the top 3 factors affecting your score.',
            ],
            resources: ['https://example.com/credit-score-guide'],
          },
          {
            chapter_number: 2,
            chapter_name: 'Credit Cards vs Debit Cards',
            context:
              'Understanding the difference between credit and debit cards is crucial for responsible financial management.',
            exercises: [
              'Compare the benefits and drawbacks of credit vs debit.',
            ],
            resources: [],
          },
          {
            chapter_number: 3,
            chapter_name: 'Payment Methods',
            context:
              'There are many ways to pay for goods and services. Each method has its own advantages and disadvantages.',
            exercises: ['Research 3 payment methods and their security features.'],
            resources: [],
          },
        ],
      },
      {
        unit_number: 3,
        unit_title: 'Financial Goals',
        chapters: [
          {
            chapter_number: 1,
            chapter_name: 'Money Personality',
            context:
              'Your money personality reflects your attitudes and behaviors toward money. Understanding this helps you make better financial decisions.',
            exercises: ['Identify your money personality type.'],
            resources: [],
          },
          {
            chapter_number: 2,
            chapter_name: 'Charitable Giving',
            context:
              'Charitable giving is an important part of a balanced financial life and can provide tax benefits.',
            exercises: ['Decide on a cause and set a giving goal.'],
            resources: [],
          },
          {
            chapter_number: 3,
            chapter_name: 'SMART Goals',
            context:
              'SMART goals are Specific, Measurable, Achievable, Relevant, and Time-bound. They help you achieve your financial objectives.',
            exercises: [
              'Write a SMART financial goal for the next 12 months.',
            ],
            resources: [],
          },
          {
            chapter_number: 4,
            chapter_name: 'Short-, Medium-, and Long-term Goals',
            context:
              'Financial planning involves setting goals at different time horizons. Each requires a different strategy.',
            exercises: ['Create goals for 1, 5, and 20 years from now.'],
            resources: [],
          },
          {
            chapter_number: 5,
            chapter_name: 'Net Worth',
            context:
              'Net worth is the total value of your assets minus your liabilities. It is a key indicator of financial health.',
            exercises: ['Calculate your current net worth.'],
            resources: [],
          },
        ],
      },
      {
        unit_number: 4,
        unit_title: 'Loans and Debt',
        chapters: [
          {
            chapter_number: 1,
            chapter_name: 'Borrowing Money',
            context:
              'Borrowing money can be a useful financial tool when used responsibly. Understanding the costs and benefits is essential.',
            exercises: ['Compare interest rates from different lenders.'],
            resources: [],
          },
          {
            chapter_number: 2,
            chapter_name: 'Types of Loans',
            context:
              'There are many types of loans available, each with different terms and conditions. Choosing the right one matters.',
            exercises: ['Research 3 types of loans and their use cases.'],
            resources: [],
          },
          {
            chapter_number: 3,
            chapter_name: 'Terms of Borrowing',
            context:
              'Understanding loan terms like APR, amortization, and fees helps you make informed borrowing decisions.',
            exercises: ['Calculate the total cost of a sample loan.'],
            resources: [],
          },
          {
            chapter_number: 4,
            chapter_name: 'Debt Management',
            context:
              'Managing debt effectively can help you maintain good credit and achieve financial goals.',
            exercises: ['Create a debt repayment plan.'],
            resources: [],
          },
          {
            chapter_number: 5,
            chapter_name: 'Bankruptcy',
            context:
              'Bankruptcy is a legal process for dealing with debt. Understanding it can help you avoid it or navigate it if necessary.',
            exercises: ['Research the types of bankruptcy and their implications.'],
            resources: [],
          },
        ],
      },
      {
        unit_number: 5,
        unit_title: 'Insurance',
        chapters: [
          {
            chapter_number: 1,
            chapter_name: 'What is Risk and How to Manage It',
            context:
              'Risk is the possibility of losing money or assets. Insurance helps transfer risk to a company.',
            exercises: ['Identify risks in your life and how to mitigate them.'],
            resources: [],
          },
          {
            chapter_number: 2,
            chapter_name: 'Insurance Basics and Terminology',
            context:
              'Understanding insurance terms like premium, deductible, and coverage is important.',
            exercises: ['Define 5 insurance terms.'],
            resources: [],
          },
          {
            chapter_number: 3,
            chapter_name: 'Health Insurance Options and Costs',
            context:
              'Health insurance is a critical part of financial planning. There are many options available.',
            exercises: ['Compare different health insurance plans.'],
            resources: [],
          },
          {
            chapter_number: 4,
            chapter_name: 'Disability and Long-term Care Insurance',
            context:
              'These types of insurance protect you if you cannot work due to illness or injury.',
            exercises: ['Calculate how much disability insurance you need.'],
            resources: [],
          },
          {
            chapter_number: 5,
            chapter_name: 'Life Insurance',
            context:
              'Life insurance provides financial protection for your loved ones if you pass away.',
            exercises: ['Determine your life insurance needs.'],
            resources: [],
          },
          {
            chapter_number: 6,
            chapter_name: 'Property Insurance Options and Costs',
            context:
              'Property insurance protects your home and personal belongings from damage or loss.',
            exercises: ['Review your home insurance policy.'],
            resources: [],
          },
          {
            chapter_number: 7,
            chapter_name: 'Car Insurance Options and Cost',
            context:
              'Car insurance is mandatory in most places and comes in different types and coverage levels.',
            exercises: ['Compare car insurance quotes.'],
            resources: [],
          },
          {
            chapter_number: 8,
            chapter_name: 'Supplemental Insurance and Warranties',
            context:
              'Supplemental insurance and warranties can provide additional protection for specific items.',
            exercises: ['Evaluate whether extended warranties are worth it.'],
            resources: [],
          },
          {
            chapter_number: 9,
            chapter_name: 'Estate Planning and Legal Instruments',
            context:
              'Estate planning ensures your assets are distributed according to your wishes after you pass away.',
            exercises: ['Create a simple will or living trust outline.'],
            resources: [],
          },
        ],
      },
      {
        unit_number: 6,
        unit_title: 'Investments and Retirement',
        chapters: [
          {
            chapter_number: 1,
            chapter_name: 'Introduction to Saving and Investing',
            context:
              'Saving puts money aside; investing puts that money to work for you through growth.',
            exercises: [
              'Open a savings or investment account.',
              'Set an investment goal.',
            ],
            resources: [],
          },
          {
            chapter_number: 2,
            chapter_name: 'Risk and Return of Investment Options',
            context:
              'Different investments carry different levels of risk and potential return. Understanding this helps you build a balanced portfolio.',
            exercises: ['Compare risk/return profiles of stocks, bonds, and CDs.'],
            resources: [],
          },
          {
            chapter_number: 3,
            chapter_name: 'Planning for Retirement',
            context:
              'Retirement planning starts early. The power of compound interest means the sooner you start, the better.',
            exercises: ['Calculate how much you need to retire.'],
            resources: [],
          },
        ],
      },
      {
        unit_number: 7,
        unit_title: 'Scams and Fraud',
        chapters: [
          {
            chapter_number: 1,
            chapter_name: 'How to Protect Your Personal Information',
            context:
              'Protecting your personal information is the first line of defense against fraud and identity theft.',
            exercises: [
              'Audit your online accounts for security settings.',
              'Set up multi-factor authentication.',
            ],
            resources: [],
          },
          {
            chapter_number: 2,
            chapter_name: 'Common Scams',
            context:
              'Understanding common scams helps you recognize and avoid them. Scammers are always evolving their tactics.',
            exercises: ['Research 3 current scams and their red flags.'],
            resources: [],
          },
          {
            chapter_number: 3,
            chapter_name: 'Consumer Protection Agencies',
            context:
              'If you are a victim of fraud, consumer protection agencies can help you report it and recover.',
            exercises: ['Locate the relevant agencies in your area.'],
            resources: [],
          },
        ],
      },
      {
        unit_number: 8,
        unit_title: 'Careers and Education',
        chapters: [
          {
            chapter_number: 1,
            chapter_name: 'Education and Earnings',
            context:
              'Education can significantly increase your earning potential over your lifetime.',
            exercises: [
              'Research salary differences by education level in your field.',
            ],
            resources: [],
          },
          {
            chapter_number: 2,
            chapter_name: 'College, Post-secondary Education and Training',
            context:
              'There are many pathways to career success, from traditional college to vocational training.',
            exercises: ['Compare the costs and benefits of different pathways.'],
            resources: [],
          },
          {
            chapter_number: 3,
            chapter_name: 'Cost of Post-secondary Education and Training',
            context:
              'The cost of education is a major financial decision. Understanding all options helps you make the best choice.',
            exercises: [
              'Research the total cost of your preferred program.',
              'Explore funding options.',
            ],
            resources: [],
          },
          {
            chapter_number: 4,
            chapter_name: 'Choosing Where to Go',
            context:
              'Choosing the right school or program is important for your career and financial future.',
            exercises: ['Create a rubric for comparing schools.'],
            resources: [],
          },
        ],
      },
      {
        unit_number: 9,
        unit_title: 'Taxes and Tax Forms',
        chapters: [
          {
            chapter_number: 1,
            chapter_name: 'What are Taxes?',
            context:
              'Taxes are mandatory payments to the government. Understanding how they work helps you plan your finances.',
            exercises: [
              'Calculate your estimated tax liability.',
              'Identify tax deductions you may qualify for.',
            ],
            resources: [],
          },
          {
            chapter_number: 2,
            chapter_name: 'Tax Forms',
            context:
              'Tax forms like W-2, 1099, and 1098 are important documents for filing your taxes correctly.',
            exercises: ['Learn to read and understand a W-2 form.'],
            resources: [],
          },
        ],
      },
      {
        unit_number: 10,
        unit_title: 'Employment',
        chapters: [
          {
            chapter_number: 1,
            chapter_name: 'Understanding Your Pay',
            context:
              'Your paycheck may be confusing with all the deductions. Understanding each line item is important.',
            exercises: ['Analyze your last paycheck and each deduction.'],
            resources: [],
          },
          {
            chapter_number: 2,
            chapter_name: 'Compensation: More than Pay',
            context:
              'Compensation includes salary, benefits, and other perks. Evaluating the total package is important.',
            exercises: ['Calculate your total compensation package.'],
            resources: [],
          },
          {
            chapter_number: 3,
            chapter_name: 'Non-typical Pay Structures',
            context:
              'Not all jobs pay a traditional salary. Understanding different pay structures helps in negotiations.',
            exercises: ['Research pay structures for your industry.'],
            resources: [],
          },
          {
            chapter_number: 4,
            chapter_name: 'Hiring Process: Forms and Documents',
            context:
              'When you get hired, you will fill out many forms. Understanding them ensures you do not miss benefits.',
            exercises: ['Review common hiring forms and their purposes.'],
            resources: [],
          },
          {
            chapter_number: 5,
            chapter_name: 'Paycheck',
            context:
              'Your paycheck reflects your efforts and negotiations. Understanding it helps you plan your budget.',
            exercises: ['Create a monthly budget based on your paycheck.'],
            resources: [],
          },
        ],
      },
      {
        unit_number: 11,
        unit_title: 'Banking',
        chapters: [
          {
            chapter_number: 1,
            chapter_name: 'Banking and Financial Institutions',
            context:
              'Banks and financial institutions are central to managing your money. Understanding how they work is essential.',
            exercises: ['Compare different types of financial institutions.'],
            resources: [],
          },
          {
            chapter_number: 2,
            chapter_name: 'Understanding Bank Accounts',
            context:
              'There are different types of bank accounts, each with different features and benefits.',
            exercises: ['Compare checking, savings, and money market accounts.'],
            resources: [],
          },
          {
            chapter_number: 3,
            chapter_name: 'Tracking, Reconciling and More',
            context:
              'Keeping track of your bank accounts helps you detect fraud and manage your finances.',
            exercises: [
              'Reconcile a bank account statement.',
              'Set up transaction tracking.',
            ],
            resources: [],
          },
          {
            chapter_number: 4,
            chapter_name: 'Banking Regulations and Agencies',
            context:
              'Banking is heavily regulated to protect consumers. Understanding these protections is important.',
            exercises: ['Research FDIC insurance and what it covers.'],
            resources: [],
          },
          {
            chapter_number: 5,
            chapter_name: 'Interest: From Savings to Investing',
            context:
              'Interest is the return you earn on your money. Understanding how it works helps you grow wealth.',
            exercises: ['Compare interest rates across different institutions.'],
            resources: [],
          },
          {
            chapter_number: 6,
            chapter_name: 'Inflation',
            context:
              'Inflation erodes the buying power of your money. Planning for inflation is important for long-term financial success.',
            exercises: ['Calculate the impact of inflation on your savings.'],
            resources: [],
          },
        ],
      },
      {
        unit_number: 12,
        unit_title: 'Car Buying',
        chapters: [
          {
            chapter_number: 1,
            chapter_name: 'Car Buying Experience',
            context:
              'Buying a car is often the second-largest purchase after a home. Preparing helps you get the best deal.',
            exercises: [
              'Research the true cost of ownership for a car you want.',
            ],
            resources: [],
          },
          {
            chapter_number: 2,
            chapter_name: 'Car Loans',
            context:
              'Understanding car loans helps you make the best financing decision.',
            exercises: [
              'Compare auto loan options and calculate total interest.',
            ],
            resources: [],
          },
          {
            chapter_number: 3,
            chapter_name: 'Owning vs Leasing',
            context:
              'Owning and leasing have different advantages and disadvantages. Choosing depends on your situation.',
            exercises: ['Compare the costs of owning vs leasing a specific car.'],
            resources: [],
          },
          {
            chapter_number: 4,
            chapter_name: 'Additional Costs of Car Ownership',
            context:
              'Beyond the purchase price, cars have ongoing costs like insurance, maintenance, and fuel.',
            exercises: [
              'Create a budget for all car ownership costs.',
              'Research insurance quotes.',
            ],
            resources: [],
          },
        ],
      },
      {
        unit_number: 13,
        unit_title: 'Housing',
        chapters: [
          {
            chapter_number: 1,
            chapter_name: 'Renting vs Homeownership',
            context:
              'Renting and homeownership each have advantages and disadvantages. Your choice depends on your situation.',
            exercises: [
              'Compare the lifetime cost of renting vs buying in your area.',
            ],
            resources: [],
          },
          {
            chapter_number: 2,
            chapter_name: 'Finding Your Next Home',
            context:
              'Finding the right home involves research, planning, and sometimes compromise on your priorities.',
            exercises: ['Create a list of must-haves and nice-to-haves in a home.'],
            resources: [],
          },
          {
            chapter_number: 3,
            chapter_name: 'Lease Agreements',
            context:
              'A lease agreement is a legal contract. Understanding it protects your rights as a tenant.',
            exercises: ['Review and annotate a sample lease agreement.'],
            resources: [],
          },
          {
            chapter_number: 4,
            chapter_name: 'Mortgages',
            context:
              'A mortgage is a long-term loan for a home. Understanding the terms and options helps you make the best choice.',
            exercises: [
              'Calculate the total cost of a mortgage.',
              'Compare fixed vs variable rate mortgages.',
            ],
            resources: [],
          },
        ],
      },
    ];

    // Insert units into database (will skip if they already exist)
    const result = await db
      .collection('financial_literacy_textbook')
      .insertMany(units, { ordered: false });

    res.json({
      message: `Seeded ${result.insertedCount} units`,
      insertedCount: result.insertedCount,
    });
  } catch (error) {
    // Handle duplicate key error gracefully
    if (error.code === 11000) {
      return res.json({
        message: 'Units already seeded',
        error: 'Duplicate entries - data already exists',
      });
    }
    console.error('Error seeding textbook data:', error);
    res.status(500).json({ error: error.message });
  }
});

export default router;
