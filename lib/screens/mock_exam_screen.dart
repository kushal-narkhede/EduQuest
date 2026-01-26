import 'package:flutter/material.dart';
import 'dart:async';
import '../main.dart' show getBackgroundForTheme, ThemeColors;
import '../helpers/database_helper.dart';
import '../data/ap_calculus_ab_chapters.dart';

/// Full-length mock exam mode for AP Calculus AB
class MockExamScreen extends StatefulWidget {
  final String username;
  final String currentTheme;
  final String course;

  const MockExamScreen({
    super.key,
    required this.username,
    required this.currentTheme,
    required this.course,
  });

  @override
  State<MockExamScreen> createState() => _MockExamScreenState();
}

class _MockExamScreenState extends State<MockExamScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _examQuestions = [];
  int _currentQuestionIndex = 0;
  Map<int, String?> _selectedAnswers = {};
  Map<int, int> _timeSpentPerQuestion = {};
  Timer? _examTimer;
  Duration _remainingTime = const Duration(hours: 3); // 3 hours for AP Calc AB
  bool _isExamStarted = false;
  bool _isExamPaused = false;
  bool _isExamComplete = false;
  List<bool> _answeredCorrectly = [];

  @override
  void initState() {
    super.initState();
    _loadAllQuestions();
  }

  @override
  void dispose() {
    _examTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAllQuestions() async {
    // Collect all questions from all chapters
    final allQuestions = <Map<String, dynamic>>[];
    for (final chapter in apCalculusABChapters) {
      for (final question in chapter.questions) {
        allQuestions.add({
          'question': question.questionText,
          'options': question.options,
          'correct': question.correctIndex,
          'explanation': question.explanation,
          'chapter': chapter.name,
        });
      }
    }
    
    // Shuffle and select 45 questions (typical AP exam length)
    allQuestions.shuffle();
    final examQuestions = allQuestions.take(45).toList();
    
    setState(() {
      _examQuestions = examQuestions;
    });
  }

  void _startExam() {
    setState(() {
      _isExamStarted = true;
      _remainingTime = const Duration(hours: 3);
    });
    
    _examTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isExamPaused && _remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
        });
      } else if (_remainingTime.inSeconds <= 0) {
        _submitExam();
      }
    });
  }

  void _pauseExam() {
    setState(() {
      _isExamPaused = !_isExamPaused;
    });
  }

  void _submitExam() {
    _examTimer?.cancel();
    
    // Calculate results
    final results = <bool>[];
    for (int i = 0; i < _examQuestions.length; i++) {
      final selected = _selectedAnswers[i];
      final question = _examQuestions[i];
      final correctIndex = question['correct'] as int;
      final options = question['options'] as List<String>;
      final correctAnswer = options[correctIndex];
      final isCorrect = selected == correctAnswer;
      results.add(isCorrect);
    }
    
    final correctCount = results.where((r) => r).length;
    final accuracy = (correctCount / _examQuestions.length) * 100;
    
    // Calculate predicted AP score (1-5 scale)
    int predictedScore;
    if (accuracy >= 80) {
      predictedScore = 5;
    } else if (accuracy >= 70) {
      predictedScore = 4;
    } else if (accuracy >= 60) {
      predictedScore = 3;
    } else if (accuracy >= 50) {
      predictedScore = 2;
    } else {
      predictedScore = 1;
    }
    
    setState(() {
      _isExamComplete = true;
      _answeredCorrectly = results;
    });
    
    // Save exam results
    _saveExamResults(correctCount, accuracy, predictedScore);
  }

  Future<void> _saveExamResults(int correctCount, double accuracy, int predictedScore) async {
    // Save each question attempt
    for (int i = 0; i < _examQuestions.length; i++) {
      final question = _examQuestions[i];
      final chapter = question['chapter'] as String;
      final questionText = question['question'] as String;
      final questionId = '${widget.course}_${chapter}_exam_q${i}_${questionText.hashCode}';
      final isCorrect = _answeredCorrectly[i];
      final timeSpent = _timeSpentPerQuestion[i] ?? 0;
      
      await _dbHelper.saveQuestionAttempt(
        widget.username,
        questionId,
        widget.course,
        chapter,
        isCorrect,
        timeSpent: timeSpent,
      );
    }
  }

  String _formatTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          getBackgroundForTheme(widget.currentTheme),
          SafeArea(
            child: _isExamComplete
                ? _buildResultsScreen()
                : _isExamStarted
                    ? _buildExamScreen()
                    : _buildStartScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildStartScreen() {
    final textColor = ThemeColors.getTextColor(widget.currentTheme);
    
    return Column(
      children: [
        // Header with back button
        Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: textColor,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Text(
                  'Mock Exam',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.quiz, size: 64, color: textColor),
                const SizedBox(height: 24),
                Text(
                  widget.course,
                  style: TextStyle(
                    fontSize: 20,
                    color: textColor.withOpacity(0.8),
                  ),
                ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildInfoRow('Questions', '${_examQuestions.length}'),
                const SizedBox(height: 12),
                _buildInfoRow('Time Limit', '3 hours'),
                const SizedBox(height: 12),
                _buildInfoRow('Format', 'Multiple Choice'),
              ],
            ),
          ),
          const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _startExam,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  ),
                  child: const Text(
                    'Start Exam',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final textColor = ThemeColors.getTextColor(widget.currentTheme);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: textColor)),
        Text(value, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildExamScreen() {
    final textColor = ThemeColors.getTextColor(widget.currentTheme);
    if (_examQuestions.isEmpty) {
      return Center(
        child: Text(
          'No questions loaded',
          style: TextStyle(color: textColor),
        ),
      );
    }
    final currentQuestion = _examQuestions[_currentQuestionIndex];
    final options = (currentQuestion['options'] as List).cast<String>();
    final selectedAnswer = _selectedAnswers[_currentQuestionIndex];
    
    return Column(
      children: [
        // Timer and controls
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Time Remaining',
                      style: TextStyle(color: textColor, fontSize: 12),
                    ),
                    Text(
                      _formatTime(_remainingTime),
                      style: TextStyle(
                        color: _remainingTime.inMinutes < 30 ? Colors.red : Colors.green,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  _isExamPaused ? Icons.play_arrow : Icons.pause,
                  color: textColor,
                ),
                onPressed: _pauseExam,
              ),
              IconButton(
                icon: Icon(Icons.check_circle, color: Colors.green),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Submit Exam?'),
                      content: const Text('Are you sure you want to submit your exam? You cannot change your answers after submitting.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _submitExam();
                          },
                          child: const Text('Submit'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        // Question counter
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Question ${_currentQuestionIndex + 1} of ${_examQuestions.length}',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
        ),
        // Question and options
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentQuestion['question'] as String,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 24),
                ...options.map((option) {
                  final isSelected = selectedAnswer == option;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedAnswers[_currentQuestionIndex] = option;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue.withOpacity(0.3) : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.white.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? Colors.blue : Colors.transparent,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(color: textColor, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        // Navigation buttons
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: _currentQuestionIndex > 0
                    ? () {
                        setState(() {
                          _currentQuestionIndex--;
                        });
                      }
                    : null,
                child: const Text('Previous'),
              ),
              ElevatedButton(
                onPressed: _currentQuestionIndex < _examQuestions.length - 1
                    ? () {
                        setState(() {
                          _currentQuestionIndex++;
                        });
                      }
                    : null,
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultsScreen() {
    final textColor = ThemeColors.getTextColor(widget.currentTheme);
    final correctCount = _answeredCorrectly.where((r) => r).length;
    final accuracy = (correctCount / _examQuestions.length) * 100;
    
    // Calculate predicted AP score
    int predictedScore;
    if (accuracy >= 80) {
      predictedScore = 5;
    } else if (accuracy >= 70) {
      predictedScore = 4;
    } else if (accuracy >= 60) {
      predictedScore = 3;
    } else if (accuracy >= 50) {
      predictedScore = 2;
    } else {
      predictedScore = 1;
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.emoji_events, size: 64, color: Colors.amber),
          const SizedBox(height: 16),
          Text(
            'Exam Complete!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Score: $correctCount / ${_examQuestions.length}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Accuracy: ${accuracy.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 24,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Predicted AP Score',
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$predictedScore',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            ),
            child: const Text(
              'Return to Chapters',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
