import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../ai/bloc/chat_bloc.dart';
import '../ai/models/chat_message_model.dart';
import '../helpers/robotics_assets_loader.dart';
import '../helpers/robotics_repository.dart';
import '../main.dart' show getBackgroundForTheme, ThemeColors;

/// Robotics Course Screen
/// Displays comprehensive Robotics content from assets with specialized UI
class RoboticsScreen extends StatefulWidget {
  const RoboticsScreen({
    super.key,
    required this.username,
    required this.onQuizComplete,
    required this.currentTheme,
    required this.onMcqSelected,
  });

  final String username;
  final VoidCallback onQuizComplete;
  final String currentTheme;
  final VoidCallback onMcqSelected;

  @override
  State<RoboticsScreen> createState() => _RoboticsScreenState();
}

class _RoboticsScreenState extends State<RoboticsScreen> {
  late Future<List<Map<String, dynamic>>> _questionsLoader;
  late RoboticsRepository _roboticsRepository;
  final ChatBloc _chatBloc = ChatBloc();
  int currentQuestionIndex = 0;
  Map<int, int> submittedAnswers = {};
  bool showResults = false;
  bool showWelcome = true;
  String _activeMode = 'MCQ';
  int _questionTarget = 100;
  bool _isGeneratingAi = false;

  @override
  void initState() {
    super.initState();
    _roboticsRepository = RoboticsRepository();
    _questionsLoader = Future.value(<Map<String, dynamic>>[]);
  }

  @override
  void dispose() {
    _chatBloc.close();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _loadRoboticsItems(String mode,
      {int? limit}) async {
    try {
      await _roboticsRepository.load();
      final List<Map<String, dynamic>> items = [];

      if (mode == 'MCQ') {
        final mcqBank = _roboticsRepository.getMCQBank();
        if (mcqBank['items'] is List) {
          final target = limit ?? 40;
          for (final item in (mcqBank['items'] as List).take(target)) {
            if (item is Map) {
              items.add({
                'question': item['prompt'] ?? item['question'] ?? 'No question',
                'options': List<String>.from(
                  (item['options'] as List?)?.map((o) => o.toString()) ?? []
                ),
                'correct': item['correct'] ?? item['correct_index'] ?? 0,
                'explanation': (item['rationale'] is Map)
                    ? (item['rationale']['correct'] ?? '')
                    : (item['rationale'] ?? item['explanation'] ?? ''),
                'difficulty': item['difficulty'] ?? 'Intermediate',
                'type': 'MCQ',
              });
            }
          }
        }
      } else if (mode == 'FRQ') {
        final frqBank = _roboticsRepository.getFRQBank();
        if (frqBank['items'] is List) {
          final target = limit ?? 20;
          for (final item in (frqBank['items'] as List).take(target)) {
            if (item is Map) {
              items.add({
                'question': item['prompt'] ?? 'FRQ prompt missing',
                'rubric': item['rubric'] ?? {},
                'difficulty': item['difficulty'] ?? 'Intermediate',
                'type': 'FRQ',
              });
            }
          }
        }
      } else if (mode == 'Labs') {
        final labs = _roboticsRepository.getLabs();
        if (labs['items'] is List) {
          final target = limit ?? 20;
          for (final item in (labs['items'] as List).take(target)) {
            if (item is Map) {
              items.add({
                'question': item['title'] ?? 'Lab activity',
                'materials': item['materials'] ?? [],
                'procedure': item['procedure'] ?? [],
                'difficulty': item['difficulty'] ?? 'Intermediate',
                'type': 'Lab',
              });
            }
          }
        }
      } else if (mode == 'Concept Checks') {
        final cc = _roboticsRepository.getConceptChecks();
        if (cc['items'] is List) {
          final target = limit ?? 40;
          for (final item in (cc['items'] as List).take(target)) {
            if (item is Map) {
              items.add({
                'question': item['prompt'] ?? 'Concept check',
                'answer': item['answer'] ?? '',
                'difficulty': item['difficulty'] ?? 'Beginner',
                'type': 'ConceptCheck',
              });
            }
          }
        }
      }

      return items.isEmpty ? _getFallbackQuestions() : items;
    } catch (e) {
      print('Error loading Robotics questions: $e');
      return _getFallbackQuestions();
    }
  }

  List<Map<String, dynamic>> _getFallbackQuestions() {
    // Fallback sample questions if assets can't be loaded
    return [
      {
        'question': 'Which gear setup increases torque?',
        'options': ['High gear ratio', 'Low gear ratio', 'Direct drive', 'Belt drive'],
        'correct': 0,
        'explanation': 'A high gear ratio increases torque at the expense of speed.',
        'difficulty': 'Beginner',
        'type': 'MCQ',
      },
      {
        'question': 'What happens to speed when torque increases (keeping power constant)?',
        'options': ['Speed decreases', 'Speed increases', 'Speed stays same', 'Speed oscillates'],
        'correct': 0,
        'explanation': 'Power = Torque × Speed, so if torque increases with constant power, speed must decrease.',
        'difficulty': 'Intermediate',
        'type': 'MCQ',
      },
      {
        'question': 'Which configuration best minimizes backlash?',
        'options': ['Planetary gearbox', 'Spur gears with loose mesh', 'Chain drive', 'Belt drive'],
        'correct': 0,
        'explanation': 'Planetary gearboxes have minimal backlash due to their design.',
        'difficulty': 'Intermediate',
        'type': 'MCQ',
      },
      {
        'question': 'A motor stalls when load torque is...',
        'options': ['Greater than max motor torque', 'Less than max motor torque', 'Equal to speed', 'Zero'],
        'correct': 0,
        'explanation': 'Motor stalling occurs when the load torque exceeds the motor\'s maximum torque output.',
        'difficulty': 'Advanced',
        'type': 'MCQ',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (showWelcome) {
      return _buildWelcomeScreen();
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _questionsLoader,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Stack(
              children: [
                getBackgroundForTheme(widget.currentTheme),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading Robotics Content...',
                        style: TextStyle(
                          color: ThemeColors.getTextColor(widget.currentTheme),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Stack(
              children: [
                getBackgroundForTheme(widget.currentTheme),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading Robotics content: ${snapshot.error}',
                        style: TextStyle(
                          color: ThemeColors.getTextColor(widget.currentTheme),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        final questions = snapshot.data ?? [];
        if (questions.isEmpty) {
          return Scaffold(
            body: Stack(
              children: [
                getBackgroundForTheme(widget.currentTheme),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orange, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'No Robotics questions available',
                        style: TextStyle(
                          color: ThemeColors.getTextColor(widget.currentTheme),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        if (showResults) {
          return _buildResultsScreen(questions);
        }

        if (currentQuestionIndex >= questions.length) {
          return Center(
            child: Text(
              'Quiz complete!',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          );
        }

        return _buildQuizScreen(questions);
      },
    );
  }

  Widget _buildQuizScreen(List<Map<String, dynamic>> questions) {
    final currentQuestion = questions[currentQuestionIndex];
    final isSubmitted = submittedAnswers.containsKey(currentQuestionIndex);

    final scheme = Theme.of(context).colorScheme;
    final onBg = scheme.onBackground;

    return Scaffold(
      body: Stack(
        children: [
          getBackgroundForTheme(widget.currentTheme),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.arrow_back,
                              color: Colors.white),
                        ),
                      ),
                      Text(
                        'Q${currentQuestionIndex + 1}/${questions.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Robotics 🚀',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const SizedBox(height: 8),

                  // Difficulty badge
                  if (currentQuestion['difficulty'] != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(
                            currentQuestion['difficulty']).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${currentQuestion['difficulty']}'.toUpperCase(),
                        style: TextStyle(
                          color: _getDifficultyColor(
                              currentQuestion['difficulty']),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Question text
                  Text(
                    currentQuestion['question'] ?? 'No question',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Content renderer based on mode
                  Expanded(
                    child: _activeMode == 'MCQ'
                        ? _buildMCQOptions(currentQuestion, isSubmitted)
                        : _activeMode == 'FRQ'
                            ? _buildFRQView(currentQuestion)
                            : _activeMode == 'Labs'
                                ? _buildLabView(currentQuestion)
                                : _buildConceptCheckView(currentQuestion),
                  ),

                  // Submit/Next button
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        final isMcq = _activeMode == 'MCQ';
                        if (isMcq) {
                          if (!isSubmitted) {
                            if (submittedAnswers
                                .containsKey(currentQuestionIndex)) {
                              setState(() {});
                            }
                          } else {
                            if (currentQuestionIndex < questions.length - 1) {
                              setState(() {
                                currentQuestionIndex++;
                              });
                            } else {
                              setState(() {
                                showResults = true;
                              });
                            }
                          }
                        } else {
                          if (currentQuestionIndex < questions.length - 1) {
                            setState(() {
                              currentQuestionIndex++;
                            });
                          } else {
                            setState(() {
                              showResults = true;
                            });
                          }
                        }
                      },
                      child: Text(
                        _activeMode == 'MCQ'
                            ? (!isSubmitted
                                ? 'Submit'
                                : (currentQuestionIndex < questions.length - 1
                                    ? 'Next Question'
                                    : 'View Results'))
                            : (currentQuestionIndex < questions.length - 1
                                ? 'Next'
                                : 'Finish'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isGeneratingAi)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.35),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _modeChip(String mode) {
    final selected = _activeMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeMode = mode;
          currentQuestionIndex = 0;
          submittedAnswers.clear();
          showResults = false;
          _questionsLoader = _loadRoboticsItems(_activeMode);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.green : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? Colors.green : Colors.white24),
        ),
        child: Text(
          mode,
          style: TextStyle(
            color: Colors.white,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildMCQOptions(Map<String, dynamic> currentQuestion, bool isSubmitted) {
    return ListView.builder(
      itemCount: (currentQuestion['options'] as List?)?.length ?? 0,
      itemBuilder: (context, index) {
        final options = currentQuestion['options'] as List;
        final option = options[index];
        final isSelected = submittedAnswers[currentQuestionIndex] == index;
        final isCorrect = index == (currentQuestion['correct'] ?? 0);
        final showCorrect = isSubmitted && isCorrect;
        final showIncorrect = isSubmitted && isSelected && !isCorrect;

        return GestureDetector(
          onTap: isSubmitted
              ? null
              : () {
                  setState(() {
                    submittedAnswers[currentQuestionIndex] = index;
                  });
                },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: showCorrect
                  ? Colors.green.withOpacity(0.3)
                  : showIncorrect
                      ? Colors.red.withOpacity(0.3)
                      : isSelected
                          ? Colors.blue.withOpacity(0.3)
                          : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: showCorrect
                    ? Colors.green
                    : showIncorrect
                        ? Colors.red
                        : isSelected
                            ? Colors.blue
                            : Colors.white30,
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
                    border: Border.all(
                      color: showCorrect
                          ? Colors.green
                          : showIncorrect
                              ? Colors.red
                              : isSelected
                                  ? Colors.blue
                                  : Colors.white30,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: showCorrect
                                  ? Colors.green
                                  : showIncorrect
                                      ? Colors.red
                                      : Colors.blue,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (showCorrect)
                  const Icon(Icons.check_circle, color: Colors.green)
                else if (showIncorrect)
                  const Icon(Icons.cancel, color: Colors.red),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFRQView(Map<String, dynamic> currentQuestion) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Free Response', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            currentQuestion['question'] ?? 'FRQ',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 16),
          if (currentQuestion['rubric'] != null)
            Text(
              'Rubric: ${(currentQuestion['rubric'] as Map).keys.join(', ')}',
              style: const TextStyle(color: Colors.white70),
            ),
        ],
      ),
    );
  }

  Widget _buildLabView(Map<String, dynamic> currentQuestion) {
    final materials = (currentQuestion['materials'] as List?)?.join(', ') ?? '—';
    final procedure = (currentQuestion['procedure'] as List?)?.join('\n• ') ?? '—';
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lab Activity', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text(currentQuestion['question'] ?? 'Lab',
                style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 12),
            Text('Materials: $materials',
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            Text('Procedure:\n• $procedure',
                style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildConceptCheckView(Map<String, dynamic> currentQuestion) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Concept Check', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            currentQuestion['question'] ?? 'Prompt',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 12),
          if (currentQuestion['answer'] != null)
            Text('Answer: ${currentQuestion['answer']}',
                style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    final scheme = Theme.of(context).colorScheme;
    final onBg = ThemeColors.getTextColor(widget.currentTheme);

    return Scaffold(
      body: Stack(
        children: [
          getBackgroundForTheme(widget.currentTheme),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: onBg.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: onBg.withOpacity(0.2)),
                          ),
                          child: Icon(Icons.close, color: onBg),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: scheme.secondaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: scheme.secondary.withOpacity(0.4)),
                        ),
                        child: Text(
                          'Robotics Lab',
                          style: TextStyle(
                            color: scheme.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Welcome, Engineer!',
                    style: TextStyle(
                      color: onBg,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Removed tracking slider below the welcome header
                  const SizedBox(height: 12),
                  Text(
                    'Pick your practice track for today. We\'ll load the right Robotics assets (MCQs, FRQs, Labs, Concept Checks) and keep your progress synced.',
                    style: TextStyle(color: onBg.withOpacity(0.8), fontSize: 15),
                  ),
                  const SizedBox(height: 24),

                  _welcomeCard(
                    icon: Icons.quiz_outlined,
                    title: 'MCQ Drill',
                    subtitle: 'Quick checks with rationales and difficulty tags.',
                    onTap: _isGeneratingAi ? null : () => _startMode('MCQ'),
                  ),
                  const SizedBox(height: 12),
                  _welcomeCard(
                    icon: Icons.description_outlined,
                    title: 'FRQ Practice',
                    subtitle: 'Free-response with rubrics and AI grader hints.',
                    onTap: () => _startMode('FRQ'),
                  ),
                  const SizedBox(height: 12),
                  _welcomeCard(
                    icon: Icons.science_outlined,
                    title: 'Labs & Builds',
                    subtitle: 'Hands-on labs with materials, procedures, and troubleshooting.',
                    onTap: () => _startMode('Labs'),
                  ),
                  const SizedBox(height: 12),
                  _welcomeCard(
                    icon: Icons.flash_on_outlined,
                    title: 'Concept Checks',
                    subtitle: 'Short prompts to reinforce fundamentals.',
                    onTap: () => _startMode('Concept Checks'),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.shield_moon_outlined, color: onBg.withOpacity(0.6), size: 18),
                      const SizedBox(width: 8),
                      Text('Offline-first, synced when online',
                          style: TextStyle(color: onBg.withOpacity(0.6))),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _welcomeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    final bg = Colors.white.withOpacity(0.08);
    final border = Colors.white24;
    final iconBg = Colors.white.withOpacity(0.12);
    const textColor = Colors.white;
    final subText = Colors.white.withOpacity(0.8);
    final arrow = Colors.white.withOpacity(0.7);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: textColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(color: subText, fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: arrow, size: 16),
          ],
        ),
      ),
    );
  }

  void _startMode(String mode) {
    if (mode == 'MCQ') {
      widget.onMcqSelected();
      return;
    }

    setState(() {
      _activeMode = mode;
      showWelcome = false;
      currentQuestionIndex = 0;
      submittedAnswers.clear();
      showResults = false;
      _questionsLoader = _loadRoboticsItems(mode, limit: _questionTarget);
    });
  }

  Future<List<Map<String, dynamic>>> _generateAiQuestions() async {
    final prompt = '''Generate exactly $_questionTarget multiple choice questions about robotics, automation, sensors, motion control, embedded systems, and practical build tradeoffs.
Each question must be in this exact format with square brackets and five comma-separated fields:
[question text, option A, option B, option C, option D, correct answer]
Do not add numbering, explanations, or any extra text. Randomize correct answers. Keep the content at high-school robotics competition level.''';

    setState(() {
      _isGeneratingAi = true;
    });

    final completer = Completer<List<Map<String, dynamic>>>();
    late final StreamSubscription sub;
    sub = _chatBloc.stream.listen((state) async {
      if (state is ChatSuccessState) {
        final lastMessage = state.messages.lastWhere(
          (m) => m.role == 'model',
          orElse: () => ChatMessageModel(role: '', parts: []),
        );

        if (lastMessage.role.isNotEmpty && lastMessage.parts.isNotEmpty) {
          final parsed = _parseAiQuestions(lastMessage.parts.first.text);
          if (parsed.isNotEmpty) {
            completer.complete(parsed);
            await sub.cancel();
            return;
          }
        }

        // Fallback if parsing failed
        final fallback = await _loadRoboticsItems('MCQ', limit: _questionTarget);
        completer.complete(fallback);
        await sub.cancel();
      } else if (state is ChatErrorState) {
        final fallback = await _loadRoboticsItems('MCQ', limit: _questionTarget);
        completer.complete(fallback);
        await sub.cancel();
      }
    });

    _chatBloc.add(ChatClearHistoryEvent());
    _chatBloc.add(ChatGenerationNewTextMessageEvent(inputMessage: prompt));

    try {
      final questions = await completer.future;
      return questions;
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingAi = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _parseAiQuestions(String aiResponse) {
    List<String> lines = aiResponse.split('\n');
    List<String> questionLines = [];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('[') && trimmed.contains(']')) {
        questionLines.add(trimmed);
      }
    }

    List<Map<String, dynamic>> parsed = [];
    for (final qLine in questionLines) {
      final parsedQ = _parseBracketFormat(qLine);
      if (parsedQ != null) parsed.add(parsedQ);
    }

    if (parsed.length < _questionTarget) {
      // Try splitting by double newlines as a fallback
      final blocks = aiResponse.split('\n\n');
      for (final block in blocks) {
        final parsedQ = _parseBracketFormat(block.trim());
        if (parsedQ != null) parsed.add(parsedQ);
      }
    }

    if (parsed.length > _questionTarget) {
      parsed = parsed.sublist(0, _questionTarget);
    }

    return parsed;
  }

  Map<String, dynamic>? _parseBracketFormat(String line) {
    try {
      String cleanLine = line.endsWith(',')
          ? line.substring(0, line.length - 1)
          : line;

      if (!cleanLine.startsWith('[') || !cleanLine.endsWith(']')) {
        return null;
      }

      String content = cleanLine.substring(1, cleanLine.length - 1);

      List<String> parts = [];
      StringBuffer current = StringBuffer();
      bool inQuotes = false;

      for (int i = 0; i < content.length; i++) {
        final char = content[i];
        if (char == '"') {
          inQuotes = !inQuotes;
          current.write(char);
        } else if (char == ',' && !inQuotes) {
          parts.add(current.toString().trim());
          current.clear();
        } else {
          current.write(char);
        }
      }
      parts.add(current.toString().trim());

      for (int i = 0; i < parts.length; i++) {
        if (parts[i].startsWith('"') && parts[i].endsWith('"')) {
          parts[i] = parts[i].substring(1, parts[i].length - 1);
        }
      }

      if (parts.length == 6) {
        final options = [parts[1], parts[2], parts[3], parts[4]];
        final correctAnswer = parts[5];
        final correctIndex = options.indexWhere(
          (o) => o.trim().toLowerCase() == correctAnswer.trim().toLowerCase(),
        );

        return {
          'question': parts[0],
          'options': options,
          'correct': correctIndex >= 0 ? correctIndex : 0,
          'explanation': '',
          'difficulty': 'Intermediate',
          'type': 'MCQ',
        };
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Widget _buildResultsScreen(List<Map<String, dynamic>> questions) {
    int correctCount = 0;
    for (var entry in submittedAnswers.entries) {
      final questionIndex = entry.key;
      final selectedOptionIndex = entry.value;
      final question = questions[questionIndex];
      final correctAnswer = question['correct'];
      if (selectedOptionIndex == correctAnswer) {
        correctCount++;
      }
    }
    final answered = submittedAnswers.isEmpty ? questions.length : submittedAnswers.length;
    final percentage = ((correctCount / answered) * 100).toStringAsFixed(1);

    return Scaffold(
      body: Stack(
        children: [
          getBackgroundForTheme(widget.currentTheme),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.celebration, color: Colors.green, size: 80),
                    const SizedBox(height: 24),
                    Text(
                      'Robotics Challenge Complete! 🚀',
                      style: TextStyle(
                        color: ThemeColors.getTextColor(widget.currentTheme),
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$correctCount / ${submittedAnswers.length}',
                            style: TextStyle(
                              color: ThemeColors.getTextColor(widget.currentTheme),
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Score: $percentage%',
                            style: TextStyle(
                              color: ThemeColors.getTextColor(widget.currentTheme).withOpacity(0.8),
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          widget.onQuizComplete();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Return to Browse Sets',
                            style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isGeneratingAi)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.35),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
