import 'package:flutter/material.dart';
import '../main.dart' show getBackgroundForTheme, ThemeColors;
import '../helpers/database_helper.dart';
import '../helpers/analytics_helper.dart';
import '../data/ap_calculus_ab_chapters.dart';

/// Screen displaying study statistics and analytics for a course
class StudyStatisticsScreen extends StatefulWidget {
  final String username;
  final String currentTheme;
  final String course;

  const StudyStatisticsScreen({
    super.key,
    required this.username,
    required this.currentTheme,
    required this.course,
  });

  @override
  State<StudyStatisticsScreen> createState() => _StudyStatisticsScreenState();
}

class _StudyStatisticsScreenState extends State<StudyStatisticsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, Map<String, dynamic>> _chapterProgress = {};
  List<String> _weakAreas = [];
  List<Map<String, dynamic>> _questionHistory = [];
  bool _isLoading = true;
  List<String> _recommendations = [];
  int _studyStreak = 0;
  String _performanceTrend = 'stable';
  
  // Overall statistics
  int _totalQuestionsAnswered = 0;
  int _totalQuestionsCorrect = 0;
  double _overallAccuracy = 0.0;
  int _totalTimeSpent = 0; // seconds

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    try {
      // Load course progress
      final courseProgress = await _dbHelper.getCourseProgress(widget.username, widget.course);
      final chapters = courseProgress['chapters'] as Map<String, dynamic>? ?? {};
      
      final progressMap = <String, Map<String, dynamic>>{};
      int totalAttempted = 0;
      int totalCorrect = 0;
      int totalTime = 0;
      
      for (final chapter in apCalculusABChapters) {
        final chapterData = chapters[chapter.name] as Map<String, dynamic>?;
        final data = chapterData ?? {
          'questionsAttempted': 0,
          'questionsCorrect': 0,
          'accuracy': 0.0,
          'masteryLevel': 'Novice',
          'lastStudied': null,
          'timeSpent': 0,
        };
        progressMap[chapter.name] = data;
        totalAttempted += data['questionsAttempted'] as int? ?? 0;
        totalCorrect += data['questionsCorrect'] as int? ?? 0;
        totalTime += data['timeSpent'] as int? ?? 0;
      }
      
      // Load weak areas
      final weakAreas = await _dbHelper.getWeakAreas(widget.username, widget.course);
      
      // Load question history
      final history = await _dbHelper.getQuestionHistory(widget.username, course: widget.course);
      
      // Generate analytics
      final recommendations = AnalyticsHelper.generateRecommendations(progressMap, history);
      final streak = AnalyticsHelper.calculateStreak(history);
      final trend = AnalyticsHelper.getPerformanceTrend(history);
      
      if (mounted) {
        setState(() {
          _chapterProgress = progressMap;
          _weakAreas = weakAreas;
          _questionHistory = history;
          _totalQuestionsAnswered = totalAttempted;
          _totalQuestionsCorrect = totalCorrect;
          _overallAccuracy = totalAttempted > 0 ? totalCorrect / totalAttempted : 0.0;
          _totalTimeSpent = totalTime;
          _recommendations = recommendations;
          _studyStreak = streak;
          _performanceTrend = trend;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading statistics: $e');
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
                              widget.course,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: ThemeColors.getTextColor(widget.currentTheme),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Study Statistics',
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
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildOverallStats(),
                              const SizedBox(height: 24),
                              _buildInsightsSection(),
                              const SizedBox(height: 24),
                              _buildWeakAreasSection(),
                              const SizedBox(height: 24),
                              _buildChapterBreakdown(),
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

  Widget _buildOverallStats() {
    final textColor = ThemeColors.getTextColor(widget.currentTheme);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overall Statistics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                'Questions Answered',
                '$_totalQuestionsAnswered',
                Icons.quiz,
                Colors.blue,
              ),
              _buildStatCard(
                'Accuracy',
                '${(_overallAccuracy * 100).toStringAsFixed(1)}%',
                Icons.trending_up,
                Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                'Time Spent',
                '${(_totalTimeSpent / 60).toStringAsFixed(0)} min',
                Icons.access_time,
                Colors.orange,
              ),
              _buildStatCard(
                'Correct Answers',
                '$_totalQuestionsCorrect',
                Icons.check_circle,
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    final textColor = ThemeColors.getTextColor(widget.currentTheme);
    
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: textColor.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsSection() {
    final textColor = ThemeColors.getTextColor(widget.currentTheme);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.blue, size: 24),
              const SizedBox(width: 8),
              Text(
                'Insights & Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInsightCard(
                  'Study Streak',
                  '$_studyStreak days',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInsightCard(
                  'Trend',
                  _performanceTrend == 'improving'
                      ? 'Improving'
                      : _performanceTrend == 'declining'
                          ? 'Declining'
                          : 'Stable',
                  _performanceTrend == 'improving'
                      ? Icons.trending_up
                      : _performanceTrend == 'declining'
                          ? Icons.trending_down
                          : Icons.trending_flat,
                  _performanceTrend == 'improving'
                      ? Colors.green
                      : _performanceTrend == 'declining'
                          ? Colors.red
                          : Colors.grey,
                ),
              ),
            ],
          ),
          if (_recommendations.isNotEmpty) ...[
            const SizedBox(height: 16),
            ..._recommendations.take(3).map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rec,
                          style: TextStyle(
                            fontSize: 13,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildInsightCard(String label, String value, IconData icon, Color color) {
    final textColor = ThemeColors.getTextColor(widget.currentTheme);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeakAreasSection() {
    final textColor = ThemeColors.getTextColor(widget.currentTheme);
    
    if (_weakAreas.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.green.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Great job! No weak areas identified. Keep up the excellent work!',
                style: TextStyle(
                  fontSize: 14,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
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
              Icon(Icons.warning, color: Colors.red, size: 24),
              const SizedBox(width: 8),
              Text(
                'Areas Needing Practice',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._weakAreas.map((area) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.arrow_right, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        area,
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildChapterBreakdown() {
    final textColor = ThemeColors.getTextColor(widget.currentTheme);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chapter Breakdown',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        ...apCalculusABChapters.map((chapter) {
          final progress = _chapterProgress[chapter.name] ?? {
            'questionsAttempted': 0,
            'questionsCorrect': 0,
            'accuracy': 0.0,
            'masteryLevel': 'Novice',
            'lastStudied': null,
            'timeSpent': 0,
          };
          
          final questionsAttempted = progress['questionsAttempted'] as int? ?? 0;
          final questionsCorrect = progress['questionsCorrect'] as int? ?? 0;
          final accuracy = progress['accuracy'] as double? ?? 0.0;
          final masteryLevel = progress['masteryLevel'] as String? ?? 'Novice';
          final totalQuestions = chapter.questions.length;
          final completionPercent = totalQuestions > 0 ? (questionsAttempted / totalQuestions) : 0.0;
          
          Color masteryColor;
          if (masteryLevel == 'Master') {
            masteryColor = Colors.green;
          } else if (masteryLevel == 'Learning') {
            masteryColor = Colors.orange;
          } else {
            masteryColor = Colors.red;
          }
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: masteryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: masteryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${chapter.unitNumber}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: masteryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chapter.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$questionsAttempted/$totalQuestions questions • ${(accuracy * 100).toStringAsFixed(0)}% accuracy',
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: masteryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        masteryLevel,
                        style: TextStyle(
                          fontSize: 11,
                          color: masteryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: completionPercent,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(masteryColor),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
