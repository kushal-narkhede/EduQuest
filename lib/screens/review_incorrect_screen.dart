import 'package:flutter/material.dart';
import '../main.dart' show getBackgroundForTheme, ThemeColors, PracticeModeScreen;
import '../helpers/database_helper.dart';
import '../data/ap_calculus_ab_chapters.dart';

/// Screen for reviewing questions answered incorrectly
class ReviewIncorrectScreen extends StatefulWidget {
  final String username;
  final String currentTheme;
  final String course;
  final String? chapter; // Optional: filter by chapter

  const ReviewIncorrectScreen({
    super.key,
    required this.username,
    required this.currentTheme,
    required this.course,
    this.chapter,
  });

  @override
  State<ReviewIncorrectScreen> createState() => _ReviewIncorrectScreenState();
}

class _ReviewIncorrectScreenState extends State<ReviewIncorrectScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _incorrectQuestions = [];
  Map<String, List<Map<String, dynamic>>> _questionsByChapter = {};
  bool _isLoading = true;
  String? _selectedChapterFilter;

  @override
  void initState() {
    super.initState();
    _selectedChapterFilter = widget.chapter;
    _loadIncorrectQuestions();
  }

  Future<void> _loadIncorrectQuestions() async {
    setState(() => _isLoading = true);
    try {
      final history = await _dbHelper.getQuestionHistory(
        widget.username,
        course: widget.course,
        chapter: _selectedChapterFilter,
      );
      
      // Filter to only incorrect answers
      final incorrect = history.where((h) => h['isCorrect'] == false).toList();
      
      // Group by chapter
      final byChapter = <String, List<Map<String, dynamic>>>{};
      for (final item in incorrect) {
        final ch = item['chapter'] as String? ?? 'Unknown';
        if (!byChapter.containsKey(ch)) {
          byChapter[ch] = [];
        }
        byChapter[ch]!.add(item);
      }
      
      if (mounted) {
        setState(() {
          _incorrectQuestions = incorrect;
          _questionsByChapter = byChapter;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading incorrect questions: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                              'Review Incorrect',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: ThemeColors.getTextColor(widget.currentTheme),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_incorrectQuestions.length} questions to review',
                              style: TextStyle(
                                fontSize: 16,
                                color: ThemeColors.getTextColor(widget.currentTheme)
                                    .withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Filter button
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.filter_list,
                          color: ThemeColors.getTextColor(widget.currentTheme),
                        ),
                        onSelected: (value) {
                          setState(() {
                            _selectedChapterFilter = value == 'All' ? null : value;
                          });
                          _loadIncorrectQuestions();
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'All', child: Text('All Chapters')),
                          ...apCalculusABChapters.map((ch) => 
                            PopupMenuItem(value: ch.name, child: Text(ch.name)),
                          ),
                        ],
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
                      : _incorrectQuestions.isEmpty
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
                                    'No incorrect questions to review!',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: ThemeColors.getTextColor(widget.currentTheme)
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: _questionsByChapter.length,
                              itemBuilder: (context, index) {
                                final chapter = _questionsByChapter.keys.elementAt(index);
                                final questions = _questionsByChapter[chapter]!;
                                return _buildChapterSection(chapter, questions);
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterSection(String chapter, List<Map<String, dynamic>> questions) {
    final textColor = ThemeColors.getTextColor(widget.currentTheme);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            chapter,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          ...questions.map((item) => _buildQuestionCard(item)),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> item) {
    final textColor = ThemeColors.getTextColor(widget.currentTheme);
    final questionId = item['questionId'] as String? ?? '';
    final timestamp = item['timestamp'] != null 
        ? DateTime.parse(item['timestamp'].toString())
        : null;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Question ID: ${questionId.split('_').last.substring(0, 8)}...',
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ),
              if (timestamp != null)
                Text(
                  _formatDate(timestamp),
                  style: TextStyle(
                    fontSize: 11,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              // Navigate to practice mode with this question
              // For now, show a message that this feature is coming
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Reviewing individual questions coming soon!'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.2),
              foregroundColor: Colors.red,
            ),
            child: const Text('Review Question'),
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
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
