import 'package:flutter/material.dart';
import '../data/ap_calculus_ab_chapters.dart';
import '../main.dart' show getBackgroundForTheme, ThemeColors, PracticeModeScreen;
import '../helpers/database_helper.dart';
import 'study_statistics_screen.dart';
import 'bookmarked_questions_screen.dart';
import 'mock_exam_screen.dart';
import 'study_plan_screen.dart';

/// Screen for selecting which AP Calculus AB chapter to study
class APCalculusABChapterSelectionScreen extends StatefulWidget {
  final String username;
  final String currentTheme;
  final Map<String, dynamic> studySet;

  const APCalculusABChapterSelectionScreen({
    super.key,
    required this.username,
    required this.currentTheme,
    required this.studySet,
  });

  @override
  State<APCalculusABChapterSelectionScreen> createState() => _APCalculusABChapterSelectionScreenState();
}

class _APCalculusABChapterSelectionScreenState extends State<APCalculusABChapterSelectionScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, Map<String, dynamic>> _chapterProgress = {};
  bool _isLoadingProgress = true;
  List<String> _weakAreas = [];
  String _filterType = 'All'; // All, Unmastered, Weak, Needs Review
  String _sortType = 'Progress'; // Progress, Last Studied, Difficulty

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() => _isLoadingProgress = true);
    try {
      final courseProgress = await _dbHelper.getCourseProgress(widget.username, 'AP Calculus AB');
      final chapters = courseProgress['chapters'] as Map<String, dynamic>? ?? {};
      
      final progressMap = <String, Map<String, dynamic>>{};
      for (final chapter in apCalculusABChapters) {
        final chapterData = chapters[chapter.name] as Map<String, dynamic>?;
        if (chapterData != null) {
          // Normalize accuracy to double (handles both int and double from database)
          final accuracyValue = chapterData['accuracy'];
          final normalizedAccuracy = accuracyValue is double 
              ? accuracyValue 
              : (accuracyValue is int ? accuracyValue.toDouble() : 0.0);
          
          progressMap[chapter.name] = {
            ...chapterData,
            'accuracy': normalizedAccuracy,
          };
        } else {
          progressMap[chapter.name] = {
            'questionsAttempted': 0,
            'questionsCorrect': 0,
            'accuracy': 0.0,
            'masteryLevel': 'Novice',
            'lastStudied': null,
            'timeSpent': 0,
          };
        }
      }
      
      final weakAreas = await _dbHelper.getWeakAreas(widget.username, 'AP Calculus AB');
      
      if (mounted) {
        setState(() {
          _chapterProgress = progressMap;
          _weakAreas = weakAreas;
          _isLoadingProgress = false;
        });
      }
    } catch (e) {
      print('Error loading progress: $e');
      if (mounted) {
        setState(() => _isLoadingProgress = false);
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
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: ThemeColors.getTextColor(widget.currentTheme),
                              size: 20,
                            ),
                            iconSize: 20,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AP Calculus AB',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: ThemeColors.getTextColor(widget.currentTheme),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Select a chapter',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: ThemeColors.getTextColor(widget.currentTheme)
                                        .withOpacity(0.8),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          // Statistics button
                          IconButton(
                            icon: Icon(
                              Icons.analytics,
                              color: ThemeColors.getTextColor(widget.currentTheme),
                              size: 18,
                            ),
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudyStatisticsScreen(
                                    username: widget.username,
                                    currentTheme: widget.currentTheme,
                                    course: 'AP Calculus AB',
                                  ),
                                ),
                              ).then((_) => _loadProgress());
                            },
                          ),
                          const SizedBox(width: 2),
                          // Bookmarked questions button
                          IconButton(
                            icon: Icon(
                              Icons.bookmark,
                              color: ThemeColors.getTextColor(widget.currentTheme),
                              size: 18,
                            ),
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookmarkedQuestionsScreen(
                                    username: widget.username,
                                    currentTheme: widget.currentTheme,
                                    course: 'AP Calculus AB',
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 2),
                          // Mock exam button
                          IconButton(
                            icon: Icon(
                              Icons.quiz,
                              color: ThemeColors.getTextColor(widget.currentTheme),
                              size: 18,
                            ),
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MockExamScreen(
                                    username: widget.username,
                                    currentTheme: widget.currentTheme,
                                    course: 'AP Calculus AB',
                                  ),
                                ),
                              ).then((_) => _loadProgress());
                            },
                          ),
                          const SizedBox(width: 2),
                          // Study plan button
                          IconButton(
                            icon: Icon(
                              Icons.calendar_today,
                              color: ThemeColors.getTextColor(widget.currentTheme),
                              size: 18,
                            ),
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudyPlanScreen(
                                    username: widget.username,
                                    currentTheme: widget.currentTheme,
                                    course: 'AP Calculus AB',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Quick Actions
                if (!_isLoadingProgress) _buildQuickActions(),
                
                // Filter and Sort
                if (!_isLoadingProgress) _buildFilterSortBar(),
                
                // Chapters List
                Expanded(
                  child: _isLoadingProgress
                      ? Center(
                          child: CircularProgressIndicator(
                            color: ThemeColors.getTextColor(widget.currentTheme),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _getFilteredChapters().length,
                          itemBuilder: (context, index) {
                            final chapter = _getFilteredChapters()[index];
                            final originalIndex = apCalculusABChapters.indexOf(chapter);
                            return _buildChapterCard(context, chapter, originalIndex);
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

  Widget _buildChapterCard(
      BuildContext context, APCalculusABChapter chapter, int index) {
    final bool isSpookySkin = widget.currentTheme == 'halloween';
    final Color textColor = ThemeColors.getTextColor(widget.currentTheme);
    final progress = _chapterProgress[chapter.name] ?? {
      'questionsAttempted': 0,
      'questionsCorrect': 0,
      'accuracy': 0.0,
      'masteryLevel': 'Novice',
      'lastStudied': null,
      'timeSpent': 0,
    };
    
    final questionsAttempted = progress['questionsAttempted'] as int? ?? 0;
    // Safely convert accuracy to double (handles both int and double)
    final accuracyValue = progress['accuracy'];
    final accuracy = accuracyValue is double 
        ? accuracyValue 
        : (accuracyValue is int ? accuracyValue.toDouble() : 0.0);
    final masteryLevel = progress['masteryLevel'] as String? ?? 'Novice';
    final totalQuestions = chapter.questions.length;
    final completionPercent = totalQuestions > 0 ? (questionsAttempted / totalQuestions) : 0.0;
    
    // Determine card color based on mastery
    Color masteryColor;
    if (masteryLevel == 'Master') {
      masteryColor = Colors.green;
    } else if (masteryLevel == 'Learning') {
      masteryColor = Colors.orange;
    } else {
      masteryColor = Colors.red;
    }
    
    // Different gradient colors for each chapter
    final List<List<Color>> gradientColors = [
      [const Color(0xFF667eea), const Color(0xFF764ba2)], // Unit 1
      [const Color(0xFFf093fb), const Color(0xFFf5576c)], // Unit 2
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)], // Unit 3
      [const Color(0xFF43e97b), const Color(0xFF38f9d7)], // Unit 4
      [const Color(0xFFfa709a), const Color(0xFFfee140)], // Unit 5
      [const Color(0xFF30cfd0), const Color(0xFF330867)], // Unit 6
    ];

    final colors = gradientColors[index % gradientColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isSpookySkin
            ? ThemeColors.getCardGradient(widget.currentTheme, variant: index)
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
        boxShadow: isSpookySkin
            ? ThemeColors.getButtonShadows(widget.currentTheme)
            : [
                BoxShadow(
                  color: colors[0].withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Convert chapter questions to the format expected by PracticeModeScreen
            final questions = chapter.questions.map((q) {
              // Convert correct index to correct_answer string
              final correctAnswer = q.options[q.correctIndex];
              return {
                'question': q.questionText,
                'options': q.options,
                'correct_answer': correctAnswer,
                'explanation': q.explanation,
              };
            }).toList();

            final chapterStudySet = {
              ...widget.studySet,
              'name': '${widget.studySet['name']} - ${chapter.name}',
              'questions': questions,
            };

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PracticeModeScreen(
                  studySet: chapterStudySet,
                  username: widget.username,
                  currentTheme: widget.currentTheme,
                ),
              ),
            ).then((_) {
              // Reload progress after returning from practice
              _loadProgress();
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Chapter Number Badge
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${chapter.unitNumber}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Chapter Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chapter.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                          if (_weakAreas.contains(chapter.name))
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Weak',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red.shade300,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        chapter.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: completionPercent,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(masteryColor),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.quiz,
                            size: 14,
                            color: textColor.withOpacity(0.8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$questionsAttempted/$totalQuestions questions',
                            style: TextStyle(
                              fontSize: 11,
                              color: textColor.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: masteryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              masteryLevel,
                              style: TextStyle(
                                fontSize: 10,
                                color: masteryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (questionsAttempted > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              '${(accuracy * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 11,
                                color: textColor.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: textColor.withOpacity(0.7),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<APCalculusABChapter> _getFilteredChapters() {
    var chapters = List<APCalculusABChapter>.from(apCalculusABChapters);
    
    // Apply filter
    switch (_filterType) {
      case 'Unmastered':
        chapters = chapters.where((ch) {
          final progress = _chapterProgress[ch.name];
          final masteryLevel = progress?['masteryLevel'] as String? ?? 'Novice';
          return masteryLevel != 'Master';
        }).toList();
        break;
      case 'Weak':
        chapters = chapters.where((ch) => _weakAreas.contains(ch.name)).toList();
        break;
      case 'Needs Review':
        chapters = chapters.where((ch) {
          final progress = _chapterProgress[ch.name];
          final lastStudied = progress?['lastStudied'];
          if (lastStudied == null) return true;
          try {
            final date = DateTime.parse(lastStudied.toString());
            return DateTime.now().difference(date).inDays > 7;
          } catch (e) {
            return false;
          }
        }).toList();
        break;
    }
    
    // Apply sort
    chapters.sort((a, b) {
      final progressA = _chapterProgress[a.name];
      final progressB = _chapterProgress[b.name];
      
      switch (_sortType) {
        case 'Progress':
          // Safely convert accuracy to double (handles both int and double)
          final accuracyAValue = progressA?['accuracy'];
          final accuracyBValue = progressB?['accuracy'];
          final accuracyA = accuracyAValue is double 
              ? accuracyAValue 
              : (accuracyAValue is int ? accuracyAValue.toDouble() : 0.0);
          final accuracyB = accuracyBValue is double 
              ? accuracyBValue 
              : (accuracyBValue is int ? accuracyBValue.toDouble() : 0.0);
          return accuracyA.compareTo(accuracyB);
        case 'Last Studied':
          final lastA = progressA?['lastStudied'];
          final lastB = progressB?['lastStudied'];
          if (lastA == null && lastB == null) return 0;
          if (lastA == null) return 1;
          if (lastB == null) return -1;
          try {
            final dateA = DateTime.parse(lastA.toString());
            final dateB = DateTime.parse(lastB.toString());
            return dateB.compareTo(dateA); // Most recent first
          } catch (e) {
            return 0;
          }
        case 'Difficulty':
          // Sort by unit number (lower = easier)
          return a.unitNumber.compareTo(b.unitNumber);
        default:
          return 0;
      }
    });
    
    return chapters;
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _weakAreas.isNotEmpty
                  ? () {
                      // Navigate to weakest chapter
                      final weakest = _weakAreas.first;
                      final chapter = apCalculusABChapters.firstWhere((ch) => ch.name == weakest);
                      _navigateToChapter(chapter);
                    }
                  : null,
              icon: const Icon(Icons.warning, size: 18),
              label: const Text('Study Weakest'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.2),
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Find chapter with most recent study or first unstudied
                final sorted = _getFilteredChapters();
                if (sorted.isNotEmpty) {
                  _navigateToChapter(sorted.first);
                }
              },
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text('Continue'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.withOpacity(0.2),
                foregroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSortBar() {
    final textColor = ThemeColors.getTextColor(widget.currentTheme);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list, color: textColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<String>(
              value: _filterType,
              isExpanded: true,
              underline: const SizedBox(),
              style: TextStyle(color: textColor, fontSize: 14),
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All Chapters')),
                DropdownMenuItem(value: 'Unmastered', child: Text('Unmastered')),
                DropdownMenuItem(value: 'Weak', child: Text('Weak Areas')),
                DropdownMenuItem(value: 'Needs Review', child: Text('Needs Review')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _filterType = value);
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          Icon(Icons.sort, color: textColor, size: 18),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _sortType,
            underline: const SizedBox(),
            style: TextStyle(color: textColor, fontSize: 14),
            items: const [
              DropdownMenuItem(value: 'Progress', child: Text('Progress')),
              DropdownMenuItem(value: 'Last Studied', child: Text('Last Studied')),
              DropdownMenuItem(value: 'Difficulty', child: Text('Difficulty')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _sortType = value);
              }
            },
          ),
        ],
      ),
    );
  }

  void _navigateToChapter(APCalculusABChapter chapter) {
    final questions = chapter.questions.map((q) {
      // Convert correct index to correct_answer string
      final correctAnswer = q.options[q.correctIndex];
      return {
        'question': q.questionText,
        'options': q.options,
        'correct_answer': correctAnswer,
        'explanation': q.explanation,
      };
    }).toList();

    final chapterStudySet = {
      ...widget.studySet,
      'name': '${widget.studySet['name']} - ${chapter.name}',
      'questions': questions,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PracticeModeScreen(
          studySet: chapterStudySet,
          username: widget.username,
          currentTheme: widget.currentTheme,
        ),
      ),
    ).then((_) {
      _loadProgress();
    });
  }
}
