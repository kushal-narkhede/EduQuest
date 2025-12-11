import 'dart:math';

import 'package:flutter/material.dart';

import '../main.dart' show getBackgroundForTheme;

/// Simple chooser UI for the Financial Literacy course.
/// Presents three primary paths: TextBook, Question Bank, and Portfolio.
class FinancialLiteracyScreen extends StatelessWidget {
  const FinancialLiteracyScreen({
    super.key,
    required this.onTextBook,
    required this.onQuestionBank,
    required this.onPortfolio,
    required this.currentTheme,
  });

  final VoidCallback onTextBook;
  final VoidCallback onQuestionBank;
  final VoidCallback onPortfolio;
  final String currentTheme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Reuse the global themed background for visual consistency
          getBackgroundForTheme(currentTheme),
          // Floating orbs similar to practice selector
          ...List.generate(
            3,
            (index) => Positioned(
              left: (index * 140.0) % MediaQuery.of(context).size.width,
              top: (index * 200.0 + 80) % MediaQuery.of(context).size.height,
              child: TweenAnimationBuilder(
                duration: Duration(seconds: 8 + index),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(
                      sin(value * 2 * pi) * 26,
                      cos(value * 2 * pi) * 18,
                    ),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF4facfe).withOpacity(0.12),
                            const Color(0xFF667eea).withOpacity(0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.16),
                            Colors.white.withOpacity(0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.18),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _Header(),
                  const SizedBox(height: 24),
                  _ChoiceCard(
                    icon: Icons.book,
                    title: 'TextBook',
                    subtitle: 'Learn from guided lessons and summaries.',
                    colors: const [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                    onTap: onTextBook,
                  ),
                  const SizedBox(height: 16),
                  _ChoiceCard(
                    icon: Icons.quiz,
                    title: 'Question Bank',
                    subtitle: 'Practice MCQs to test your understanding.',
                    colors: const [Color(0xFF2196F3), Color(0xFF42A5F5)],
                    onTap: onQuestionBank,
                  ),
                  const SizedBox(height: 16),
                  _ChoiceCard(
                    icon: Icons.trending_up,
                    title: 'Portfolio',
                    subtitle: 'Apply concepts with hands-on portfolio tasks.',
                    colors: const [Color(0xFFFF9800), Color(0xFFFFB74D)],
                    onTap: onPortfolio,
                  ),
                  const Spacer(),
                  Text(
                    'Pick a path to start learning. You can switch anytime.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.18),
            Colors.white.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Choose Your Path',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Dive into lessons, practice questions, or build a portfolio.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.last.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.white,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}
