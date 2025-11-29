import 'dart:async';
import 'package:flutter/material.dart';
import '../../helpers/database_helper.dart';
import '../../main.dart' show getBackgroundForTheme, GameButton, ThemeColors;
import '../../widgets/atmospheric/atmospheric.dart';
import '../../widgets/atmospheric/glow_wrapper.dart';
import '../../widgets/atmospheric/floating_wrapper.dart';
import '../../widgets/atmospheric/dynamic_shadow_wrapper.dart';
import '../../widgets/atmospheric/wisp_burst.dart';
import '../../widgets/atmospheric/ghost_mascot.dart';
import '../../widgets/atmospheric/atmospheric_theme_config.dart';

class MemoryMasterModeScreen extends StatefulWidget {
  final String username;
  final String currentTheme;
  final int studySetId;
  final int questionCount;

  const MemoryMasterModeScreen({
    super.key,
    required this.username,
    required this.currentTheme,
    required this.studySetId,
    required this.questionCount,
  });

  @override
  State<MemoryMasterModeScreen> createState() => _MemoryMasterModeScreenState();
}

class _MemoryMasterModeScreenState extends State<MemoryMasterModeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _questions = [];
  int _index = 0;
  bool _memorizePhase = true;
  String? _selected;
  bool _showAnswer = false;
  int _score = 0;
  int _answeredCount = 0;
  
  // Wisp burst for correct answers
  bool _showWispBurst = false;
  Offset _wispBurstOrigin = Offset.zero;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final raw = await _dbHelper.getStudySetQuestions(widget.studySetId);
    final int limit = (widget.questionCount > 0)
        ? (raw.length < widget.questionCount ? raw.length : widget.questionCount)
        : raw.length;
    setState(() {
      _questions = raw.take(limit).toList();
    });
    _startMemorizePhase();
  }

  void _startMemorizePhase() {
    setState(() {
      _memorizePhase = true;
      _showAnswer = true; // briefly reveal correct
    });
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _memorizePhase = false;
        _showAnswer = false;
      });
    });
  }

  void _onSelect(String option) {
    if (_memorizePhase || _showAnswer) return;
    final q = _questions[_index];
    final correct = q['correct_answer'] as String;
    setState(() {
      _selected = option;
      _showAnswer = true;
      if (option == correct) {
        _score += 10;
        // Trigger wisp burst for correct answer
        _showWispBurst = true;
        _wispBurstOrigin = Offset(
          MediaQuery.of(context).size.width / 2,
          MediaQuery.of(context).size.height / 2,
        );
      }
    });
    Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      _answeredCount++;
      if (_answeredCount >= _questions.length) {
        _showCompleted();
      } else {
        setState(() {
          if (_index < _questions.length - 1) {
            _index++;
          }
          _selected = null;
        });
        _startMemorizePhase();
      }
    });
  }

  void _showCompleted() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('All done!'),
        content: Text('You completed ${_questions.length} questions.\nScore: $_score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        body: Stack(children: [
          getBackgroundForTheme(widget.currentTheme),
          const Center(child: CircularProgressIndicator()),
        ]),
      );
    }

    final q = _questions[_index];
    final options = (q['options'] as String).split('|');
    final correct = q['correct_answer'] as String;
    
    // Determine ghost state based on answer
    GhostState ghostState = GhostState.idle;
    if (_showAnswer && _selected != null) {
      final isCorrect = _selected == correct;
      ghostState = isCorrect ? GhostState.celebrating : GhostState.encouraging;
    }

    return Scaffold(
      body: AtmosphericScaffold(
        showGhost: true,
        showFog: true,
        showEmbers: true,
        intensity: AtmosphericIntensity.normal,
        ghostState: ghostState,
        ghostAlignment: Alignment.topRight,
        autoHideGhost: true,
        child: Stack(
          children: [
            getBackgroundForTheme(widget.currentTheme),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Memory Master', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Row(children: [
                          const Icon(Icons.score, color: Colors.amber),
                          const SizedBox(width: 6),
                          Text('$_score', style: const TextStyle(color: Colors.white, fontSize: 18)),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _memorizePhase ? 'Memorize the answer...' : 'Choose the correct answer',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FloatingWrapper(
                      amplitude: 6.0,
                      duration: const Duration(seconds: 3),
                      child: DynamicShadowWrapper(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            q['question_text'] as String,
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (final opt in options)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: GlowWrapper(
                          glowIntensity: _selected == opt ? 0.8 : 0.5,
                          child: GameButton(
                            text: opt,
                            currentTheme: widget.currentTheme,
                            isSelected: _selected == opt,
                            isCorrect: _showAnswer ? (opt == correct) : null,
                            onPressed: _memorizePhase ? null : () => _onSelect(opt),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Wisp burst overlay for correct answers
            if (_showWispBurst)
              Positioned.fill(
                child: IgnorePointer(
                  child: WispBurst(
                    origin: _wispBurstOrigin,
                    particleCount: 25,
                    onComplete: () {
                      if (mounted) {
                        setState(() {
                          _showWispBurst = false;
                        });
                      }
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
