import 'package:flutter/material.dart';
import '../main.dart' show getBackgroundForTheme, ThemeColors;
import '../helpers/database_helper.dart';
import '../data/ap_calculus_ab_chapters.dart';

/// Screen for creating and tracking study plans
class StudyPlanScreen extends StatefulWidget {
  final String username;
  final String currentTheme;
  final String course;

  const StudyPlanScreen({
    super.key,
    required this.username,
    required this.currentTheme,
    required this.course,
  });

  @override
  State<StudyPlanScreen> createState() => _StudyPlanScreenState();
}

class _StudyPlanScreenState extends State<StudyPlanScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  DateTime? _examDate;
  List<String> _selectedChapters = [];
  int _chaptersPerWeek = 2;
  Map<String, bool> _completedChapters = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudyPlan();
  }

  Future<void> _loadStudyPlan() async {
    // Load existing study plan from database or create default
    setState(() {
      _isLoading = false;
      // Initialize with all chapters
      _selectedChapters = apCalculusABChapters.map((ch) => ch.name).toList();
      _completedChapters = {
        for (var ch in apCalculusABChapters) ch.name: false,
      };
    });
  }

  List<Map<String, dynamic>> _getSchedule() {
    if (_examDate == null || _selectedChapters.isEmpty) return [];
    
    final now = DateTime.now();
    final examDate = _examDate!;
    final daysUntilExam = examDate.difference(now).inDays;
    final weeksUntilExam = (daysUntilExam / 7).ceil();
    
    if (weeksUntilExam <= 0) return [];
    
    final schedule = <Map<String, dynamic>>[];
    final chaptersPerWeek = (_selectedChapters.length / weeksUntilExam).ceil();
    var currentWeek = 1;
    var chapterIndex = 0;
    
    while (chapterIndex < _selectedChapters.length && currentWeek <= weeksUntilExam) {
      final weekChapters = _selectedChapters.skip(chapterIndex).take(chaptersPerWeek).toList();
      final weekStartDate = now.add(Duration(days: (currentWeek - 1) * 7));
      
      schedule.add({
        'week': currentWeek,
        'chapters': weekChapters,
        'startDate': weekStartDate,
        'isCompleted': weekChapters.every((ch) => _completedChapters[ch] == true),
      });
      
      chapterIndex += chaptersPerWeek;
      currentWeek++;
    }
    
    return schedule;
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
                              'Study Plan',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: ThemeColors.getTextColor(widget.currentTheme),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.course,
                              style: TextStyle(
                                fontSize: 16,
                                color: ThemeColors.getTextColor(widget.currentTheme)
                                    .withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: ThemeColors.getTextColor(widget.currentTheme),
                        ),
                        onPressed: () => _showEditPlanDialog(),
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
                      : _examDate == null
                          ? _buildSetupScreen()
                          : _buildScheduleScreen(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupScreen() {
    final textColor = ThemeColors.getTextColor(widget.currentTheme);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: textColor),
            const SizedBox(height: 24),
            Text(
              'Create Your Study Plan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Set your exam date and we\'ll create a personalized study schedule',
              style: TextStyle(
                fontSize: 16,
                color: textColor.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 90)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _examDate = date;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text(
                'Set Exam Date',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleScreen() {
    final textColor = ThemeColors.getTextColor(widget.currentTheme);
    final schedule = _getSchedule();
    final daysUntilExam = _examDate!.difference(DateTime.now()).inDays;
    final completedCount = _completedChapters.values.where((v) => v).length;
    final totalChapters = _selectedChapters.length;
    final progress = totalChapters > 0 ? (completedCount / totalChapters) : 0.0;
    
    return Column(
      children: [
        // Progress summary
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Days Until Exam',
                    style: TextStyle(color: textColor),
                  ),
                  Text(
                    '$daysUntilExam',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: TextStyle(color: textColor),
                  ),
                  Text(
                    '$completedCount / $totalChapters chapters',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
        // Schedule
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: schedule.length,
            itemBuilder: (context, index) {
              final week = schedule[index];
              return _buildWeekCard(week);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWeekCard(Map<String, dynamic> week) {
    final textColor = ThemeColors.getTextColor(widget.currentTheme);
    final weekNum = week['week'] as int;
    final chapters = week['chapters'] as List<String>;
    final startDate = week['startDate'] as DateTime;
    final isCompleted = week['isCompleted'] as bool;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted ? Colors.green : Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Week $weekNum',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const Spacer(),
              if (isCompleted)
                Icon(Icons.check_circle, color: Colors.green, size: 24),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${startDate.month}/${startDate.day} - ${startDate.add(const Duration(days: 6)).month}/${startDate.add(const Duration(days: 6)).day}',
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          ...chapters.map((chapter) {
            final isChapterCompleted = _completedChapters[chapter] == true;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Checkbox(
                    value: isChapterCompleted,
                    onChanged: (value) {
                      setState(() {
                        _completedChapters[chapter] = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      chapter,
                      style: TextStyle(
                        color: isChapterCompleted
                            ? textColor.withOpacity(0.5)
                            : textColor,
                        decoration: isChapterCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showEditPlanDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Study Plan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Exam Date'),
              trailing: TextButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _examDate ?? DateTime.now().add(const Duration(days: 90)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _examDate = date;
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text(_examDate != null
                    ? '${_examDate!.month}/${_examDate!.day}/${_examDate!.year}'
                    : 'Set Date'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
