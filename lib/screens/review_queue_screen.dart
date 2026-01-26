import 'package:flutter/material.dart';
import '../main.dart' show getBackgroundForTheme, ThemeColors, PracticeModeScreen;
import '../helpers/database_helper.dart';
import '../helpers/spaced_repetition_helper.dart';

/// Screen showing questions due for spaced repetition review
class ReviewQueueScreen extends StatefulWidget {
  final String username;
  final String currentTheme;
  final String? course; // Optional: filter by course

  const ReviewQueueScreen({
    super.key,
    required this.username,
    required this.currentTheme,
    this.course,
  });

  @override
  State<ReviewQueueScreen> createState() => _ReviewQueueScreenState();
}

class _ReviewQueueScreenState extends State<ReviewQueueScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _overdueQuestions = [];
  List<Map<String, dynamic>> _dueTodayQuestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviewQueue();
  }

  Future<void> _loadReviewQueue() async {
    setState(() => _isLoading = true);
    try {
      final history = await _dbHelper.getQuestionHistory(
        widget.username,
        course: widget.course,
      );
      
      // Filter to questions that have review dates
      final withReviewDates = history.where((h) => h['reviewDate'] != null).toList();
      
      // Separate into overdue and due today
      final overdue = SpacedRepetitionHelper.getOverdueQuestions(withReviewDates);
      final dueToday = SpacedRepetitionHelper.getQuestionsDueTodayOnly(withReviewDates);
      
      if (mounted) {
        setState(() {
          _overdueQuestions = overdue;
          _dueTodayQuestions = dueToday;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading review queue: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalDue = _overdueQuestions.length + _dueTodayQuestions.length;
    
    return Scaffold(
      body: Stack(
        children: [
          getBackgroundForTheme(widget.currentTheme),
          SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: ThemeColors.getTextColor(widget.currentTheme),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Review Queue',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: ThemeColors.getTextColor(widget.currentTheme),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$totalDue questions due for review',
                              style: TextStyle(
                                fontSize: 16,
                                color: ThemeColors.getTextColor(widget.currentTheme)
                                    .withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: ThemeColors.getTextColor(widget.currentTheme),
                          ),
                        )
                      : totalDue == 0
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 64,
                                    color: ThemeColors.getTextColor(widget.currentTheme)
                                        .withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No questions due for review!',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: ThemeColors.getTextColor(widget.currentTheme)
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Great job staying on top of your reviews!',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: ThemeColors.getTextColor(widget.currentTheme)
                                          .withOpacity(0.6),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_overdueQuestions.isNotEmpty) ...[
                                    _buildSectionHeader('Overdue', Colors.red, _overdueQuestions.length),
                                    const SizedBox(height: 12),
                                    ..._overdueQuestions.map((q) => _buildQuestionCard(q, isOverdue: true)),
                                    const SizedBox(height: 24),
                                  ],
                                  if (_dueTodayQuestions.isNotEmpty) ...[
                                    _buildSectionHeader('Due Today', Colors.orange, _dueTodayQuestions.length),
                                    const SizedBox(height: 12),
                                    ..._dueTodayQuestions.map((q) => _buildQuestionCard(q, isOverdue: false)),
                                  ],
                                ],
                              ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color, int count) {
    final textColor = ThemeColors.getTextColor(widget.currentTheme);
    
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> item, {required bool isOverdue}) {
    final textColor = ThemeColors.getTextColor(widget.currentTheme);
    final questionId = item['questionId'] as String? ?? '';
    final reviewDateStr = item['reviewDate']?.toString();
    final chapter = item['chapter'] as String? ?? 'Unknown';
    
    DateTime? reviewDate;
    if (reviewDateStr != null) {
      try {
        reviewDate = DateTime.parse(reviewDateStr);
      } catch (e) {
        // Ignore parse errors
      }
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isOverdue ? Colors.red : Colors.orange).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isOverdue ? Colors.red : Colors.orange).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isOverdue ? Icons.warning : Icons.schedule,
                color: isOverdue ? Colors.red : Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  chapter,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              if (reviewDate != null)
                Text(
                  _formatDate(reviewDate),
                  style: TextStyle(
                    fontSize: 11,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Question ID: ${questionId.split('_').last.substring(0, 8)}...',
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              // Navigate to practice mode with this question
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reviewing individual questions coming soon!'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: (isOverdue ? Colors.red : Colors.orange).withOpacity(0.2),
              foregroundColor: isOverdue ? Colors.red : Colors.orange,
            ),
            child: const Text('Review Now'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 0) {
      return '${(-difference.inDays)} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
