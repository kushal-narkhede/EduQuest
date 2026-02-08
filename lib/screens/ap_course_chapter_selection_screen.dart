import 'package:flutter/material.dart';
import '../data/ap_course_chapters.dart';
import '../helpers/database_helper.dart';
import '../helpers/frq_manager.dart';
import '../main.dart' show getBackgroundForTheme, ThemeColors, PracticeModeScreen;
import 'bookmarked_questions_screen.dart';
import 'mock_exam_screen.dart';
import 'study_plan_screen.dart';
import 'study_statistics_screen.dart';

/// Generic chapter selection and study hub for AP courses.
class APCourseChapterSelectionScreen extends StatefulWidget {
  final String username;
  final String currentTheme;
  final Map<String, dynamic> studySet;
  final String courseName;
  final List<APCourseChapter> chapters;

  const APCourseChapterSelectionScreen({
    super.key,
    required this.username,
    required this.currentTheme,
    required this.studySet,
    required this.courseName,
    required this.chapters,
  });

  @override
  State<APCourseChapterSelectionScreen> createState() => _APCourseChapterSelectionScreenState();
}

class _APCourseChapterSelectionScreenState extends State<APCourseChapterSelectionScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, Map<String, dynamic>> _chapterProgress = {};
  bool _isLoadingProgress = true;
  List<String> _weakAreas = [];
  String _filterType = 'All';
  String _sortType = 'Progress';

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() => _isLoadingProgress = true);
    try {
      final courseProgress = await _dbHelper.getCourseProgress(widget.username, widget.courseName);
      final chapters = courseProgress['chapters'] as Map<String, dynamic>? ?? {};

      final progressMap = <String, Map<String, dynamic>>{};
      for (final chapter in widget.chapters) {
        final chapterData = chapters[chapter.name] as Map<String, dynamic>?;
        if (chapterData != null) {
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

      final weakAreas = await _dbHelper.getWeakAreas(widget.username, widget.courseName);
      if (mounted) {
        setState(() {
          _chapterProgress = progressMap;
          _weakAreas = weakAreas;
          _isLoadingProgress = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading progress: $e');
      if (mounted) {
        setState(() => _isLoadingProgress = false);
      }
    }
  }

  List<APCourseChapter> _getFilteredChapters() {
    var chapters = List<APCourseChapter>.from(widget.chapters);

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
          } catch (_) {
            return false;
          }
        }).toList();
        break;
    }

    chapters.sort((a, b) {
      final progressA = _chapterProgress[a.name];
      final progressB = _chapterProgress[b.name];

      switch (_sortType) {
        case 'Progress':
          final accuracyAValue = progressA?['accuracy'];
          final accuracyBValue = progressB?['accuracy'];
          final accuracyA = accuracyAValue is double
              ? accuracyAValue
              : (accuracyAValue is int ? accuracyAValue.toDouble() : 0.0);
          final accuracyB = accuracyBValue is double
              ? accuracyBValue
              : (accuracyBValue is int ? accuracyBValue.toDouble() : 0.0);
          return accuracyB.compareTo(accuracyA);
        case 'Last Studied':
          final lastA = progressA?['lastStudied'];
          final lastB = progressB?['lastStudied'];
          if (lastA == null && lastB == null) return 0;
          if (lastA == null) return 1;
          if (lastB == null) return -1;
          try {
            final dateA = DateTime.parse(lastA.toString());
            final dateB = DateTime.parse(lastB.toString());
            return dateB.compareTo(dateA);
          } catch (_) {
            return 0;
          }
        case 'Difficulty':
          return a.unitNumber.compareTo(b.unitNumber);
        default:
          return 0;
      }
    });

    return chapters;
  }

  void _navigateToChapter(APCourseChapter chapter) {
    final questions = chapter.questions.map((q) {
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
    ).then((_) => _loadProgress());
  }

  String _formatLastStudied(dynamic lastStudied) {
    if (lastStudied == null) return 'Never';
    try {
      final date = DateTime.parse(lastStudied.toString());
      final days = DateTime.now().difference(date).inDays;
      if (days == 0) return 'Today';
      if (days == 1) return 'Yesterday';
      return '$days days ago';
    } catch (_) {
      return 'Unknown';
    }
  }

  Widget _buildChapterCard(BuildContext context, APCourseChapter chapter, int index) {
    final progress = _chapterProgress[chapter.name] ?? {};
    final questionsAttempted = progress['questionsAttempted'] as int? ?? 0;
    final questionsCorrect = progress['questionsCorrect'] as int? ?? 0;
    final accuracy = progress['accuracy'] as double? ?? 0.0;
    final masteryLevel = progress['masteryLevel'] as String? ?? 'Novice';
    final lastStudied = progress['lastStudied'];
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

    final List<List<Color>> gradientColors = [
      [const Color(0xFF667eea), const Color(0xFF764ba2)],
      [const Color(0xFFf093fb), const Color(0xFFf5576c)],
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
      [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
      [const Color(0xFFfa709a), const Color(0xFFfee140)],
      [const Color(0xFF30cfd0), const Color(0xFF330867)],
    ];

    final bool isSpookySkin = widget.currentTheme == 'halloween';
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
          onTap: () => _navigateToChapter(chapter),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chapter.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        chapter.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.85),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: completionPercent.clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '$questionsCorrect/$totalQuestions correct',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: masteryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: masteryColor.withOpacity(0.6)),
                            ),
                            child: Text(
                              masteryLevel,
                              style: TextStyle(
                                color: masteryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(accuracy * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatLastStudied(lastStudied),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.7),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final bool isCsa = widget.courseName == 'AP Computer Science A';
    final bool isCsp = widget.courseName == 'AP Computer Science Principles';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _weakAreas.isNotEmpty
                  ? () {
                      final weakest = _weakAreas.first;
                      final chapter = widget.chapters.firstWhere((ch) => ch.name == weakest);
                      _navigateToChapter(chapter);
                    }
                  : null,
              icon: const Icon(Icons.warning, size: 18, color: Colors.white),
              label: const Text(
                'Study Weakest',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.15),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (isCsa) ...[
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FRQManager(
                        studySet: widget.studySet,
                        username: widget.username,
                        currentTheme: widget.currentTheme,
                        frqCount: 7,
                        title: 'AP CSA FRQ Practice',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('FRQ Practice'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.withOpacity(0.15),
                  foregroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
          if (isCsp) ...[
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FRQManager(
                        studySet: widget.studySet,
                        username: widget.username,
                        currentTheme: widget.currentTheme,
                        frqCount: 4,
                        title: 'AP CSP FRQ Practice',
                        questionIds: const ['Q1', 'Q2', 'Q3', 'Q4'],
                        questionPointValues: const {
                          'Q1': 6,
                          'Q2': 6,
                          'Q3': 6,
                          'Q4': 6,
                        },
                        questionsAssetPath: 'assets/apfrq/APCompSciPrinciples2024.txt',
                        answersAssetPath: 'assets/apcsp_2024_frq_answers.txt',
                        graderPrompt:
                            'You are an AP Computer Science Principles FRQ grader. Please grade the following student answers according to the official rubric.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('FRQ Practice'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.withOpacity(0.15),
                  foregroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilters() {
    const whiteStyle = TextStyle(color: Colors.white);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _filterType,
              decoration: InputDecoration(
                labelText: 'Filter',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              dropdownColor: const Color(0xFF2C2C2C),
              style: whiteStyle,
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All', style: whiteStyle)),
                DropdownMenuItem(value: 'Unmastered', child: Text('Unmastered', style: whiteStyle)),
                DropdownMenuItem(value: 'Weak', child: Text('Weak Areas', style: whiteStyle)),
                DropdownMenuItem(value: 'Needs Review', child: Text('Needs Review', style: whiteStyle)),
              ],
              onChanged: (value) => setState(() => _filterType = value ?? 'All'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _sortType,
              decoration: InputDecoration(
                labelText: 'Sort',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              dropdownColor: const Color(0xFF2C2C2C),
              style: whiteStyle,
              items: const [
                DropdownMenuItem(value: 'Progress', child: Text('Progress', style: whiteStyle)),
                DropdownMenuItem(value: 'Last Studied', child: Text('Last Studied', style: whiteStyle)),
                DropdownMenuItem(value: 'Difficulty', child: Text('Difficulty', style: whiteStyle)),
              ],
              onChanged: (value) => setState(() => _sortType = value ?? 'Progress'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = ThemeColors.getTextColor(widget.currentTheme);
    final filteredChapters = _getFilteredChapters();

    return Scaffold(
      body: Stack(
        children: [
          getBackgroundForTheme(widget.currentTheme),
          SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: textColor, size: 20),
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
                              widget.courseName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Select a chapter',
                              style: TextStyle(
                                fontSize: 13,
                                color: textColor.withOpacity(0.8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.analytics, color: textColor, size: 18),
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
                                course: widget.courseName,
                                chapters: widget.chapters,
                              ),
                            ),
                          ).then((_) => _loadProgress());
                        },
                      ),
                      const SizedBox(width: 2),
                      IconButton(
                        icon: Icon(Icons.bookmark, color: textColor, size: 18),
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
                                course: widget.courseName,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 2),
                      IconButton(
                        icon: Icon(Icons.quiz, color: textColor, size: 18),
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
                                course: widget.courseName,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 2),
                      IconButton(
                        icon: Icon(Icons.event_note, color: textColor, size: 18),
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
                                course: widget.courseName,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                _buildQuickActions(),
                _buildFilters(),
                Expanded(
                  child: _isLoadingProgress
                      ? Center(
                          child: CircularProgressIndicator(color: textColor),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadProgress,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                            itemCount: filteredChapters.length,
                            itemBuilder: (context, index) {
                              final chapter = filteredChapters[index];
                              return _buildChapterCard(context, chapter, index);
                            },
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
}
