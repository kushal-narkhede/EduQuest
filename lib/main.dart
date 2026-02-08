import 'package:flutter/material.dart';
import 'screens/portfolio_companies_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as excel;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'helpers/database_helper.dart';
import 'data/questions.dart' as quiz;
import 'package:student_learning_app/screens/quick_play_screen.dart';
import 'package:student_learning_app/ai/bloc/chat_bloc.dart';
import 'package:student_learning_app/ai/models/chat_message_model.dart';
import 'package:student_learning_app/screens/browse_sets_screen.dart';
import 'package:student_learning_app/helpers/frq_manager.dart';
import 'screens/study_set_edit_screen.dart';
import 'screens/modes/lightning_mode_screen.dart';
import 'screens/modes/puzzle_quest_screen.dart';
import 'screens/modes/survival_mode_screen.dart';
import 'screens/modes/memory_master_mode_screen.dart';
import 'screens/modes/treasure_hunt_mode_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:student_learning_app/screens/shop_tab.dart';
import 'package:student_learning_app/screens/inbox_screen.dart';
// import 'package:student_learning_app/utils/config.dart'; // Unused import
import 'package:student_learning_app/widgets/atmospheric/atmospheric.dart';
import 'screens/financial_literacy_screen.dart';
import 'screens/financial_textbook_screen.dart';
import 'screens/ap_course_chapter_selection_screen.dart';
import 'screens/robotics_screen.dart';
import 'screens/review_incorrect_screen.dart';
import 'screens/bookmarked_questions_screen.dart';
import 'helpers/spaced_repetition_helper.dart';
import 'data/ap_course_chapters.dart';
import 'data/ap_calculus_ab_chapters.dart';
import 'data/ap_calculus_bc_chapters.dart';
import 'data/ap_statistics_chapters.dart';
import 'data/ap_physics_1_chapters.dart';
import 'data/ap_physics_2_chapters.dart';
import 'data/ap_chemistry_chapters.dart';
import 'data/ap_computer_science_a_chapters.dart';
import 'data/ap_computer_science_principles_chapters.dart';
import 'data/ap_environmental_science_chapters.dart';
import 'data/ap_biology_chapters.dart';
import 'data/ap_physics_c_mechanics_chapters.dart';
import 'data/ap_english_literature_chapters.dart';
import 'data/ap_us_history_chapters.dart';
import 'data/ap_world_history_chapters.dart';

/**
 * Main entry point for the EduQuest learning application.
 * 
 * This function initializes the Flutter framework, sets the preferred device
 * orientations to portrait mode, and launches the main application.
 * 
 * The application is designed as an educational game platform that combines
 * learning with interactive gameplay elements.
 */
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _loadEnvWithFallback();
  final openRouterKey = dotenv.env['OPENROUTER_API_KEY'];
  final openRouterMasked = (openRouterKey == null || openRouterKey.trim().isEmpty)
      ? '<missing>'
      : '${openRouterKey.trim().substring(0, openRouterKey.trim().length.clamp(0, 4))}***${openRouterKey.trim().substring((openRouterKey.trim().length - 4).clamp(0, openRouterKey.trim().length))}';
  final finnhubKey = dotenv.env['FINNHUB_API_KEY'];
  final finnhubMasked = (finnhubKey == null || finnhubKey.trim().isEmpty)
      ? '<missing>'
      : '${finnhubKey.trim().substring(0, finnhubKey.trim().length.clamp(0, 4))}***${finnhubKey.trim().substring((finnhubKey.trim().length - 4).clamp(0, finnhubKey.trim().length))}';
  print('✓ OPENROUTER_API_KEY present: ${openRouterKey != null && openRouterKey.trim().isNotEmpty} ($openRouterMasked)');
  print('✓ FINNHUB_API_KEY present: ${finnhubKey != null && finnhubKey.trim().isNotEmpty} ($finnhubMasked)');
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const StudentLearningApp());
}

Future<void> _loadEnvWithFallback() async {
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('[Env] dotenv loaded');
  } catch (e) {
    debugPrint('[Env] dotenv load failed: $e');
  }

  if (!dotenv.env.containsKey('FINNHUB_API_KEY') || (dotenv.env['FINNHUB_API_KEY']?.trim().isEmpty ?? true)) {
    try {
      final raw = await rootBundle.loadString('.env');
      debugPrint('[EnvFallback] asset .env length: ${raw.length}');
      final parsed = _parseEnv(raw);
      debugPrint('[EnvFallback] parsed keys: ${parsed.keys.join(', ')}');
      if (parsed.isNotEmpty) {
        final combined = {...dotenv.env, ...parsed};
        final inline = combined.entries.map((e) => '${e.key}=${e.value}').join('\n');
        dotenv.testLoad(fileInput: inline);
        debugPrint('[EnvFallback] merged ${parsed.length} keys from bundled .env');
      } else {
        debugPrint('[EnvFallback] parsed .env but no keys found');
      }
    } catch (e) {
      debugPrint('[EnvFallback] asset .env read failed: $e');
    }
  }

  // Last-resort fallback to hardcoded Finnhub key so the app can run even if assets/env are missing on device.
  final fh = dotenv.env['FINNHUB_API_KEY'];
  if (fh == null || fh.trim().isEmpty) {
    const fallbackKey = 'd4tq9nhr01qnn6lmfqtgd4tq9nhr01qnn6lmfqu0';
    final combined = {...dotenv.env, 'FINNHUB_API_KEY': fallbackKey};
    final inline = combined.entries.map((e) => '${e.key}=${e.value}').join('\n');
    dotenv.testLoad(fileInput: inline);
    debugPrint('[EnvFallback] applied hardcoded Finnhub fallback');
  }
}

Map<String, String> _parseEnv(String raw) {
  final Map<String, String> out = {};
  for (final line in raw.split(RegExp(r'\r?\n'))) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final idx = trimmed.indexOf('=');
    if (idx <= 0) continue;
    final key = trimmed.substring(0, idx).trim();
    final value = trimmed.substring(idx + 1).trim();
    if (key.isEmpty) continue;
    out[key] = value;
  }
  return out;
}
  
class FriendProfileScreen extends StatefulWidget {
  final String friendUsername;
  final String currentTheme;
  final String currentUser;

  const FriendProfileScreen({
    super.key,
    required this.friendUsername,
    required this.currentTheme,
    required this.currentUser,
  });

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  final _dbHelper = DatabaseHelper();
  bool _isLoading = true;
  int _points = 0;
  List<Map<String, dynamic>> _studySets = [];
  List<Map<String, dynamic>> _importedSets = [];
  String _friendTheme = '';

  @override
  void initState() {
    super.initState();
    _loadFriendData();
  }

  Future<void> _loadFriendData() async {
    try {
      final points = await _dbHelper.getUserPoints(widget.friendUsername);
      final sets = await _dbHelper.getUserStudySets(widget.friendUsername);
      final imported = await _dbHelper.getUserImportedSets(widget.friendUsername);
      final theme = await _dbHelper.getCurrentTheme(widget.friendUsername) ?? 'space';
      if (!mounted) return;
      setState(() {
        _points = points;
        _studySets = sets;
        _importedSets = imported;
        _friendTheme = theme;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading friend profile: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('@${widget.friendUsername}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          getBackgroundForTheme(widget.currentTheme),
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildStatsCard(),
                      const SizedBox(height: 16),
                      _buildSection('Study Sets', _studySets),
                      const SizedBox(height: 12),
                      _buildSection('Imported Sets', _importedSets),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FriendChatScreen(
                                friendUsername: widget.friendUsername,
                                currentUser: widget.currentUser,
                                currentTheme: widget.currentTheme,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                        label: const Text(
                          'Chat',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
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

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.white.withOpacity(0.1),
          child: const Icon(Icons.person_outline, color: Colors.white, size: 30),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.friendUsername,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Friend of @${widget.currentUser}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            if (_friendTheme.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.palette_outlined, size: 14, color: Colors.white70),
                    const SizedBox(width: 6),
                    Text(
                      'Theme: ${_friendTheme[0].toUpperCase()}${_friendTheme.substring(1)}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_outline, color: Colors.amber, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Points',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Text(
                _points.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> sets) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (sets.isEmpty)
            const Text(
              'Nothing shared yet.',
              style: TextStyle(color: Colors.white60, fontSize: 13),
            )
          else
            ...sets.map((set) => _buildSetTile(set)).toList(),
        ],
      ),
    );
  }

  Widget _buildSetTile(Map<String, dynamic> set) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          title: Text(
            set['name'] ?? 'Untitled set',
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
          subtitle: Text(
            set['description'] ?? 'No description',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        ),
      ),
    );
  }
}

class FriendChatScreen extends StatefulWidget {
  final String friendUsername;
  final String currentUser;
  final String currentTheme;

  const FriendChatScreen({
    super.key,
    required this.friendUsername,
    required this.currentUser,
    required this.currentTheme,
  });

  @override
  State<FriendChatScreen> createState() => _FriendChatScreenState();
}

class _FriendChatScreenState extends State<FriendChatScreen> {
  final _dbHelper = DatabaseHelper();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _isSending = false;
  List<Map<String, dynamic>> _messages = [];
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadConversation();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _refreshConversation();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadConversation() async {
    setState(() => _isLoading = true);
    await _refreshConversation(initial: true);
  }

  Future<void> _refreshConversation({bool initial = false}) async {
    final msgs = await _dbHelper.getConversation(widget.currentUser, widget.friendUsername);
    if (!mounted) return;
    setState(() {
      _messages = msgs;
      if (initial) _isLoading = false;
    });
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;
    setState(() => _isSending = true);
    final ok = await _dbHelper.sendDirectMessage(widget.currentUser, widget.friendUsername, text);
    if (!mounted) return;
    if (ok) {
      final now = DateTime.now().toIso8601String();
      setState(() {
        _messages.add({
          'id': 'local-${DateTime.now().millisecondsSinceEpoch}',
          'type': 'direct_message',
          'fromUsername': widget.currentUser,
          'content': text,
          'createdAt': now,
          'metadata': {'withUsername': widget.friendUsername, 'direction': 'outgoing'},
        });
        _messageController.clear();
      });
      _scrollToBottom();
      _refreshConversation();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send message')),
      );
    }
    if (mounted) setState(() => _isSending = false);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 48,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with @${widget.friendUsername}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          getBackgroundForTheme(widget.currentTheme),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _messages.isEmpty
                          ? const Center(
                              child: Text(
                                'No messages yet. Say hello!',
                                style: TextStyle(color: Colors.white70),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(12),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                final msg = _messages[index];
                                final isMe = msg['fromUsername'] == widget.currentUser;
                                return Align(
                                  alignment:
                                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    constraints: BoxConstraints(
                                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isMe
                                          ? Colors.blueAccent.withOpacity(0.9)
                                          : Colors.white.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.white12, width: 1),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          msg['content'] ?? '',
                                          style: TextStyle(
                                            color: isMe ? Colors.white : Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _formatTime(msg['createdAt']),
                                          style: TextStyle(
                                            color: isMe
                                                ? Colors.white70
                                                : Colors.white60,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Message @${widget.friendUsername}...',
                            hintStyle: const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.35),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white24),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.blueAccent),
                            ),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: _isSending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send, color: Colors.blueAccent),
                        onPressed: _isSending ? null : _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(dynamic value) {
    try {
      final dt = value is String ? DateTime.parse(value) : (value as DateTime?);
      if (dt == null) return '';
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return '';
    }
  }
}

/**
 * The main application widget for EduQuest.
 * 
 * This class defines the root MaterialApp widget that configures the overall
 * theme, navigation, and initial screen of the application. It sets up a dark
 * theme with custom colors and typography suitable for an educational gaming
 * environment.
 * 
 * The app uses a custom color scheme with a dark background (#0A0E21) and
 * white text for optimal readability and modern aesthetics.
 */
class StudentLearningApp extends StatelessWidget {
  /**
   * Creates a new StudentLearningApp instance.
   * 
   * @param key The widget key for this StatelessWidget
   */
  const StudentLearningApp({super.key});

  /**
   * Builds the main application widget tree.
   * 
   * This method creates the MaterialApp with custom theme configuration,
   * sets the home screen to the SplashScreen, and configures various
   * visual properties like button styles and text themes.
   * 
   * @param context The build context for this widget
   * @return A MaterialApp widget configured for the EduQuest application
   */
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduQuest',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          displayMedium: TextStyle(
              fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 4,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/**
 * A splash screen widget that displays the EduQuest logo and branding.
 * 
 * This widget shows an animated splash screen with the application logo,
 * title, and tagline when the app first launches. It uses fade and scale
 * animations to create an engaging introduction experience.
 * 
 * After a 3-second delay, it automatically navigates to the SignInPage.
 */
class SplashScreen extends StatefulWidget {
  /**
   * Creates a new SplashScreen instance.
   * 
   * @param key The widget key for this StatefulWidget
   */
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

/**
 * The state class for the SplashScreen widget.
 * 
 * This class manages the animation controller and timer for the splash screen.
 * It handles the fade and scale animations for the logo and text elements,
 * and controls the automatic navigation to the sign-in page after the delay.
 */
class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  /** Animation controller for managing splash screen animations */
  late AnimationController _controller;
  /** Fade animation for smooth opacity transitions */
  late Animation<double> _fadeAnimation;
  /** Scale animation for logo and text scaling effects */
  late Animation<double> _scaleAnimation;

  /**
   * Initializes the splash screen state.
   * 
   * This method sets up the animation controller with a 2-second duration
   * and configures fade and scale animations. It also starts a timer to
   * automatically navigate to the sign-in page after 3 seconds.
   */
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Pre-warm the database in the background to avoid delays on first login
    _warmUpDatabase();

    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        this.context,
        PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) =>
              SignInPage(),
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    });
  }

  /// Pre-initialize the database in the background to avoid blocking on first login.
  /// This ensures all tables are created and premade study sets are loaded before
  /// the user reaches the sign-in screen.
  Future<void> _warmUpDatabase() async {
    try {
      final stopwatch = Stopwatch()..start();
      print('DEBUG: Starting database pre-warm...');
      final dbHelper = DatabaseHelper();
      final _ = await dbHelper.database;
      stopwatch.stop();
      print('DEBUG: Database pre-warm completed in ${stopwatch.elapsedMilliseconds}ms');
    } catch (e) {
      print('DEBUG: Database pre-warm failed (non-critical): $e');
    }
  }

  /**
   * Disposes of the animation controller to prevent memory leaks.
   */
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /**
   * Builds the splash screen UI.
   * 
   * This method creates a centered layout with the EduQuest logo, title,
   * and tagline. The elements are animated using the configured fade and
   * scale animations for a polished appearance.
   * 
   * @param context The build context for this widget
   * @return A Scaffold widget containing the animated splash screen content
   */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/eduquest_logo.png',
                      height: 150,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/**
 * A Flappy Bird-style game screen that integrates educational questions.
 * 
 * This widget implements a simplified Flappy Bird game where players control
 * a bird character that must navigate through obstacles. The game periodically
 * pauses to present educational questions to the player, combining entertainment
 * with learning.
 * 
 * The game features:
 * - Physics-based bird movement with gravity and jumping
 * - Randomly generated obstacles with varying heights
 * - Score tracking based on obstacles passed
 * - Educational question integration every 5 points
 * - Collision detection and game over handling
 * 
 * @param username The current user's username for personalization
 * @param currentTheme The current visual theme of the application
 * @param questions A list of educational questions to present during gameplay
 */
class FlappyBirdGameScreen extends StatefulWidget {
  /** The current user's username */
  final String username;
  /** The current visual theme of the application */
  final String currentTheme;
  /** List of educational questions for the game */
  final List<quiz.Question> questions;

  /**
   * Creates a new FlappyBirdGameScreen instance.
   * 
   * @param key The widget key for this StatefulWidget
   * @param username The current user's username
   * @param currentTheme The current visual theme
   * @param questions The list of educational questions
   */
  const FlappyBirdGameScreen({
    super.key,
    required this.username,
    required this.currentTheme,
    required this.questions,
  });

  @override
  _FlappyBirdGameScreenState createState() => _FlappyBirdGameScreenState();
}

/**
 * The state class for the FlappyBirdGameScreen widget.
 * 
 * This class manages the game logic, including bird physics, obstacle generation,
 * collision detection, scoring, and question presentation. It handles the game
 * loop using a Timer and manages the game state transitions.
 */
class _FlappyBirdGameScreenState extends State<FlappyBirdGameScreen> {
  /** Current vertical position of the bird (0 to 1) */
  double birdY = 0.4;
  /** Current vertical velocity of the bird */
  double birdVelocity = 0.0;
  /** Gravity constant affecting bird movement */
  double gravity = 0.0003;
  /** Jump strength when player taps */
  double jumpStrength = -0.01;
  /** X positions of obstacles on screen */
  List<double> obstacleX = [1.0, 2.0, 3.0];
  /** Heights of obstacles (randomly generated) */
  List<double> obstacleHeights = [0.3, 0.4, 0.5];
  /** Width of obstacles */
  double obstacleWidth = 0.2;
  /** Gap between top and bottom obstacles */
  double obstacleGap = 0.3;
  /** Current player score */
  int score = 0;
  /** Whether the game has ended */
  bool isGameOver = false;
  /** Timer for the game loop */
  Timer? gameTimer;
  /** Index of the current question */
  int currentQuestionIndex = 0;
  /** Whether the game is paused for a question */
  bool isPausedForQuestion = false;
  /** Random number generator for obstacle generation */
  Random random = Random();

  /** Minimum distance between obstacles */
  final double minObstacleDistance = 1.0;
  /** Maximum distance between obstacles */
  final double maxObstacleDistance = 1.5;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    // Initialize random obstacle heights
    for (int i = 0; i < obstacleHeights.length; i++) {
      obstacleHeights[i] =
          0.2 + random.nextDouble() * 0.5; // Random height between 0.2 and 0.7
    }

    // Game loop: updates bird and obstacle positions
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!isPausedForQuestion && !isGameOver) {
        setState(() {
          // Apply gravity to the bird
          birdVelocity += gravity;
          birdY += birdVelocity;

          // Prevent the bird from going too high
          if (birdY < 0.1) {
            birdY = 0.1;
            birdVelocity = 0.0;
          }

          // Move obstacles to the left
          for (int i = 0; i < obstacleX.length; i++) {
            obstacleX[i] -= 0.008; // Slower obstacle movement
            if (obstacleX[i] < -obstacleWidth) {
              // Reset obstacle position and randomize height
              double previousObstacleX =
                  obstacleX[(i - 1 + obstacleX.length) % obstacleX.length];
              double newX = previousObstacleX +
                  minObstacleDistance +
                  random.nextDouble() *
                      (maxObstacleDistance - minObstacleDistance);
              obstacleX[i] = newX;
              obstacleHeights[i] = 0.2 +
                  random.nextDouble() *
                      0.5; // Random height between 0.2 and 0.7
              score++; // Increase score when passing an obstacle

              // Show a question every 5 points
              if (score % 5 == 0) {
                isPausedForQuestion = true;
                showQuestion();
              }
            }
          }

          // Check for collisions with top or bottom of the screen
          if (birdY < 0 || birdY > 1) {
            endGame(); // End the game if the bird hits the top or bottom
          }

          // Check for collisions with obstacles
          for (int i = 0; i < obstacleX.length; i++) {
            if (obstacleX[i] < 0.2 && obstacleX[i] + obstacleWidth > 0.1) {
              // Bird is within the horizontal range of an obstacle
              if (birdY < obstacleHeights[i] ||
                  birdY > obstacleHeights[i] + obstacleGap) {
                // Bird hits the top or bottom obstacle
                endGame();
              }
            }
          }
        });
      }
    });
  }

  void endGame() {
    setState(() {
      isGameOver = true;
    });
    gameTimer?.cancel(); // Stop the game loop

    // Show game over dialog
    showDialog(
      context: this.context,
      barrierDismissible:
          false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) => Theme(
        data: Theme.of(context).copyWith(
          dialogBackgroundColor: widget.currentTheme == 'beach'
              ? ThemeColors.getSecondaryColor('beach')
              : ThemeColors.getSecondaryColor(widget.currentTheme),
          textTheme: Theme.of(context).textTheme.copyWith(
                titleLarge: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: widget.currentTheme == 'beach'
                      ? Colors.brown.shade800
                      : Colors.white,
                ),
                bodyMedium: TextStyle(
                  fontSize: 22,
                  color: widget.currentTheme == 'beach'
                      ? Colors.brown.shade700
                      : Colors.white,
                ),
              ),
        ),
        child: AlertDialog(
          title: Text(
            'Game Over',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: widget.currentTheme == 'beach'
                  ? Colors.brown.shade800
                  : Colors.white,
            ),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      'Your score: $score',
                      style: TextStyle(
                        fontSize: 22,
                        color: widget.currentTheme == 'beach'
                            ? Colors.brown.shade700
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Return to the home screen
              },
              child: Text(
                'OK',
                style: TextStyle(
                  fontSize: 20,
                  color: widget.currentTheme == 'beach'
                      ? Colors.brown.shade800
                      : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showQuestion() {
    // Show a question dialog
    showDialog(
      context: this.context,
      barrierDismissible:
          false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) => Theme(
        data: Theme.of(context).copyWith(
          dialogBackgroundColor: widget.currentTheme == 'beach'
              ? ThemeColors.getSecondaryColor('beach')
              : ThemeColors.getSecondaryColor(widget.currentTheme),
          textTheme: Theme.of(context).textTheme.copyWith(
                titleLarge: TextStyle(
                  fontSize: 28, // Larger title
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Always black
                ),
                bodyMedium: TextStyle(
                  fontSize: 22, // Larger body text
                  color: Colors.black, // Always black
                ),
              ),
        ),
        child: AlertDialog(
          title: Text(
            'Answer the Question',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: widget.currentTheme == 'beach'
                  ? Colors.brown.shade800
                  : Colors.white,
            ),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      widget.questions[currentQuestionIndex].questionText,
                      style: TextStyle(
                        fontSize: 22,
                        color: widget.currentTheme == 'beach'
                            ? Colors.brown.shade700
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12), // Add spacing
                    ...widget.questions[currentQuestionIndex].options
                        .map((option) => Container(
                              margin: const EdgeInsets.only(
                                  bottom: 10), // Add spacing between buttons
                              child: ElevatedButton(
                                onPressed: () {
                                  if (option ==
                                      widget.questions[currentQuestionIndex]
                                          .correctAnswer) {
                                    // Correct answer: resume the game
                                    setState(() {
                                      isPausedForQuestion = false;
                                      currentQuestionIndex =
                                          (currentQuestionIndex + 1) %
                                              widget.questions.length;
                                    });
                                    Navigator.pop(context); // Close the dialog
                                  } else {
                                    // Incorrect answer: end the game
                                    Navigator.pop(
                                        context); // Close the question dialog
                                    endGame(); // Show the game over dialog
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      widget.currentTheme == 'beach'
                                          ? ThemeColors.getButtonColor('beach')
                                          : ThemeColors.getButtonColor(
                                              widget.currentTheme),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel(); // Clean up the game timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.currentTheme == 'beach'
          ? ThemeColors.getPrimaryColor('beach').withOpacity(0.1)
          : ThemeColors.getPrimaryColor(widget.currentTheme),
      body: Stack(
        children: [
          // Background
          getBackgroundForTheme(widget.currentTheme),

          // Bird
          Positioned(
            left: 50,
            top: MediaQuery.of(context).size.height * birdY,
            child: Image.asset(
              'assets/images/bird.png',
              width: 50,
              height: 50,
            ),
          ),

          // Obstacles
          for (int i = 0; i < obstacleX.length; i++) ...[
            // Top obstacle
            Positioned(
              left: MediaQuery.of(context).size.width * obstacleX[i],
              top: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * obstacleWidth,
                height: MediaQuery.of(context).size.height * obstacleHeights[i],
                color: Colors.green,
              ),
            ),
            // Bottom obstacle
            Positioned(
              left: MediaQuery.of(context).size.width * obstacleX[i],
              top: MediaQuery.of(context).size.height *
                  (obstacleHeights[i] + obstacleGap),
              child: Container(
                width: MediaQuery.of(context).size.width * obstacleWidth,
                height: MediaQuery.of(context).size.height *
                    (1 - obstacleHeights[i] - obstacleGap),
                color: Colors.green,
              ),
            ),
          ],

          // Score
          Positioned(
            top: 50,
            left: 20,
            child: Text(
              '${ThemeCopy.getScoreLabel(widget.currentTheme)}: $score',
              style: TextStyle(
                fontSize: 24,
                color: widget.currentTheme == 'beach'
                    ? Colors.brown.shade900
                    : Colors.white,
                fontWeight: FontWeight.bold,
                shadows: widget.currentTheme == 'beach'
                    ? [
                        Shadow(
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ]
                    : [
                        Shadow(
                          offset: const Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.8),
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

class SpaceBackground extends StatefulWidget {
  const SpaceBackground({super.key});

  @override
  State<SpaceBackground> createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends State<SpaceBackground> {
  static const int _starCount = 90;
  final List<_Star> _stars = [];
  late final AnimationController _controller;
  final Random _rand = Random();

  @override
  void initState() {
    super.initState();
    _seedStars();
    // Animation controller disabled - stars are now static
    // _controller = AnimationController(vsync: this, duration: const Duration(seconds: 8))
    //   ..addListener(_tick)
    //   ..repeat();
  }

  void _seedStars() {
    _stars.clear();
    for (int i = 0; i < _starCount; i++) {
      _stars.add(_Star(
        x: _rand.nextDouble(),
        y: _rand.nextDouble(),
        size: 1.0 + _rand.nextDouble() * 1.5,
        vx: 0, // No movement
        vy: 0, // No movement
        twinkle: _rand.nextDouble() * pi * 2,
        twinkleSpeed: 0, // No twinkle animation
      ));
    }
  }

  // Animation tick disabled - stars are now static
  // void _tick() {
  //   setState(() {
  //     for (final star in _stars) {
  //       star.x += star.vx;
  //       star.y += star.vy;
  //       if (star.x < 0) star.x += 1;
  //       if (star.x > 1) star.x -= 1;
  //       if (star.y > 1) star.y -= 1;
  //       star.twinkle += star.twinkleSpeed;
  //       if (star.twinkle > pi * 2) star.twinkle -= pi * 2;
  //     }
  //   });
  // }

  @override
  void dispose() {
    // _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A0E21), Color(0xFF1D1E33)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          for (final star in _stars)
            Positioned(
              left: star.x * size.width,
              top: star.y * size.height,
              child: Opacity(
                opacity: 0.7, // Fixed opacity - no twinkle animation
                child: Container(
                  width: star.size,
                  height: star.size,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Star {
  double x;
  double y;
  double size;
  double vx;
  double vy;
  double twinkle;
  double twinkleSpeed;

  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.vx,
    required this.vy,
    required this.twinkle,
    required this.twinkleSpeed,
  });
}

class HalloweenBackground extends StatefulWidget {
  const HalloweenBackground({super.key});

  @override
  State<HalloweenBackground> createState() => _HalloweenBackgroundState();
}

class _HalloweenBackgroundState extends State<HalloweenBackground>
    with TickerProviderStateMixin {
  late final AnimationController _moonController;
  late final AnimationController _fogController;
  late final AnimationController _batController;
  late final Listenable _mergedAnimation;
  late final List<_BatParticle> _bats;
  late final List<_LanternParticle> _lanterns;
  late final List<_SparkParticle> _embers;

  @override
  void initState() {
    super.initState();
    final random = Random();
    _moonController =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat(reverse: true);
    _fogController =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..repeat();
    _batController =
        AnimationController(vsync: this, duration: const Duration(seconds: 12))
          ..repeat();

    _mergedAnimation =
        Listenable.merge([_moonController, _fogController, _batController]);

    _bats = List.generate(
      5,
      (index) => _BatParticle(
        phase: random.nextDouble(),
        speed: 0.6 + random.nextDouble() * 0.8,
        startY: 0.1 + random.nextDouble() * 0.4,
        amplitude: 0.02 + random.nextDouble() * 0.06,
        size: 18 + random.nextDouble() * 18,
      ),
    );

    _lanterns = List.generate(
      3,
      (index) => _LanternParticle(
        alignmentX: -0.7 + index * 0.7 + random.nextDouble() * 0.2,
        baseY: 0.58 + index * 0.08,
        delay: random.nextDouble(),
        scale: 0.85 + random.nextDouble() * 0.4,
      ),
    );

    _embers = List.generate(
      28,
      (index) => _SparkParticle(
        startX: random.nextDouble(),
        startY: 0.72 + random.nextDouble() * 0.2,
        speed: 0.3 + random.nextDouble() * 0.5,
        size: 2 + random.nextDouble() * 2,
        seed: random.nextDouble(),
      ),
    );
  }

  @override
  void dispose() {
    _moonController.dispose();
    _fogController.dispose();
    _batController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _mergedAnimation,
      builder: (context, _) {
        final size = MediaQuery.of(context).size;
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF030008),
                Color(0xFF12061C),
                Color(0xFF210A2F),
                Color(0xFF3A0E3E),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _HalloweenSkyPainter(
                    moonGlow: _moonController.value,
                    fogShift: _fogController.value,
                  ),
                ),
              ),
              ..._buildEmbers(size),
              ..._buildBats(size),
              ..._buildLanterns(size),
              Positioned.fill(
                child: CustomPaint(
                  painter: _HalloweenForegroundPainter(
                    fogShift: _fogController.value,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildBats(Size size) {
    return _bats.map((bat) {
      final travel = (_batController.value * bat.speed + bat.phase) % 1.0;
      final dx = size.width * (1 - travel);
      final dy =
          size.height * (bat.startY + sin(travel * 2 * pi) * bat.amplitude);
      final flap = sin(travel * 2 * pi);

      return Positioned(
        left: dx,
        top: dy,
        child: Transform.rotate(
          angle: flap * 0.15,
          child: Opacity(
            opacity: 0.45 + 0.55 * flap.abs(),
            child: CustomPaint(
              size: Size(bat.size, bat.size * 0.45),
              painter: const _BatPainter(color: Color(0xFFF8E1FF)),
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildLanterns(Size size) {
    return _lanterns.map((lantern) {
      final sway = sin((_moonController.value + lantern.delay) * 2 * pi) * 0.1;
      final floatOffset =
          sin((_fogController.value + lantern.delay) * 2 * pi) * 10;
      final dx = size.width * 0.5 + lantern.alignmentX * size.width * 0.45;
      final dy = size.height * lantern.baseY + floatOffset;

      return Positioned(
        left: dx,
        top: dy,
        child: Transform.rotate(
          angle: sway,
          child: Container(
            width: 46 * lantern.scale,
            height: 58 * lantern.scale,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF3B0), Color(0xFFFF7500)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFA000).withOpacity(0.6),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
              border: Border.all(
                color: Colors.deepPurple.shade900,
                width: 1.2,
              ),
            ),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 8 * lantern.scale,
                height: 16 * lantern.scale,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D112B),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildEmbers(Size size) {
    return _embers.map((ember) {
      final travel = (_fogController.value * ember.speed + ember.seed) % 1.0;
      final clamped = (ember.startY - travel * 0.35).clamp(0.45, 0.92);
      final y = size.height * clamped;
      final x =
          size.width * ember.startX + sin((travel + ember.seed) * 2 * pi) * 24;

      return Positioned(
        left: x,
        top: y,
        child: Opacity(
          opacity: (1 - travel).clamp(0.25, 1.0),
          child: Container(
            width: ember.size,
            height: ember.size * 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF59D), Color(0xFFFF7043)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

class _BatParticle {
  final double phase;
  final double speed;
  final double startY;
  final double amplitude;
  final double size;

  _BatParticle({
    required this.phase,
    required this.speed,
    required this.startY,
    required this.amplitude,
    required this.size,
  });
}

class _LanternParticle {
  final double alignmentX;
  final double baseY;
  final double delay;
  final double scale;

  _LanternParticle({
    required this.alignmentX,
    required this.baseY,
    required this.delay,
    required this.scale,
  });
}

class _SparkParticle {
  final double startX;
  final double startY;
  final double speed;
  final double size;
  final double seed;

  _SparkParticle({
    required this.startX,
    required this.startY,
    required this.speed,
    required this.size,
    required this.seed,
  });
}

class _BatPainter extends CustomPainter {
  final Color color;

  const _BatPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    final path = Path()
      ..moveTo(0, size.height * 0.8)
      ..quadraticBezierTo(
          size.width * 0.15, 0, size.width * 0.35, size.height * 0.65)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.95,
          size.width * 0.5, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.6, size.height * 0.95,
          size.width * 0.65, size.height * 0.65)
      ..quadraticBezierTo(size.width * 0.85, 0, size.width, size.height * 0.8)
      ..quadraticBezierTo(
          size.width * 0.7, size.height * 0.95, size.width * 0.5, size.height)
      ..quadraticBezierTo(
          size.width * 0.3, size.height * 0.95, 0, size.height * 0.8)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BatPainter oldDelegate) =>
      color != oldDelegate.color;
}

class _HalloweenSkyPainter extends CustomPainter {
  final double moonGlow;
  final double fogShift;

  const _HalloweenSkyPainter({
    required this.moonGlow,
    required this.fogShift,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset moonCenter = Offset(size.width * 0.78, size.height * 0.18);
    final double moonRadius = size.width * 0.18;

    final Paint moonPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFF8E1).withOpacity(0.7 + moonGlow * 0.3),
          const Color(0xFFFFD180).withOpacity(0.35),
          Colors.transparent,
        ],
        stops: const [0, 0.45, 1],
      ).createShader(Rect.fromCircle(center: moonCenter, radius: moonRadius));
    canvas.drawCircle(moonCenter, moonRadius, moonPaint);

    final Paint craterPaint = Paint()
      ..color = const Color(0xFFE4C17A).withOpacity(0.6);
    for (int i = 0; i < 4; i++) {
      final double angle = (i / 4) * 2 * pi;
      canvas.drawCircle(
        moonCenter.translate(
          cos(angle) * moonRadius * 0.35,
          sin(angle) * moonRadius * 0.25,
        ),
        moonRadius * (0.08 + i * 0.02),
        craterPaint,
      );
    }

    final Path ridge = Path()
      ..moveTo(0, size.height * 0.58)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.52,
          size.width * 0.35, size.height * 0.58)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.64,
          size.width * 0.65, size.height * 0.54)
      ..quadraticBezierTo(
          size.width * 0.8, size.height * 0.5, size.width, size.height * 0.6)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final Paint ridgePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF0E0316).withOpacity(0.9),
          const Color(0xFF1C0725).withOpacity(0.7),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(
          Rect.fromLTWH(0, size.height * 0.45, size.width, size.height * 0.4));
    canvas.drawPath(ridge, ridgePaint);

    final Paint fogPaint = Paint()
      ..color = const Color(0xFFB39DDB).withOpacity(0.05);
    for (int i = 0; i < 3; i++) {
      final double shift = (fogShift + i * 0.25) % 1.0;
      final Rect fogRect = Rect.fromLTWH(
        -size.width + shift * size.width * 2,
        size.height * (0.32 + i * 0.08),
        size.width * 1.9,
        size.height * 0.25,
      );
      canvas.drawOval(fogRect, fogPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HalloweenSkyPainter oldDelegate) {
    return moonGlow != oldDelegate.moonGlow || fogShift != oldDelegate.fogShift;
  }
}

class _HalloweenForegroundPainter extends CustomPainter {
  final double fogShift;

  const _HalloweenForegroundPainter({required this.fogShift});

  @override
  void paint(Canvas canvas, Size size) {
    final Path hill = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.78)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.65,
          size.width * 0.35, size.height * 0.78)
      ..quadraticBezierTo(size.width * 0.55, size.height * 0.9,
          size.width * 0.7, size.height * 0.74)
      ..quadraticBezierTo(
          size.width * 0.85, size.height * 0.68, size.width, size.height * 0.8)
      ..lineTo(size.width, size.height)
      ..close();

    final Paint hillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF0D0214),
          const Color(0xFF1A0322),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(
          Rect.fromLTWH(0, size.height * 0.6, size.width, size.height * 0.4));
    canvas.drawPath(hill, hillPaint);

    final Paint glowPaint = Paint()
      ..color = const Color(0xFFFF6D00)
          .withOpacity(0.2 + 0.15 * sin(fogShift * 2 * pi));
    for (int i = 0; i < 4; i++) {
      final double x = size.width * (0.15 + i * 0.25);
      final double y = size.height * 0.82;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: 60, height: 28),
        glowPaint,
      );
    }

    final Paint mistPaint = Paint()
      ..color = const Color(0xFFB388FF).withOpacity(0.05);
    for (int i = 0; i < 2; i++) {
      final double shift = (fogShift + i * 0.3) % 1.0;
      final Rect mistRect = Rect.fromLTWH(
        -size.width + shift * size.width * 2,
        size.height * (0.74 + i * 0.06),
        size.width * 1.8,
        size.height * 0.2,
      );
      canvas.drawOval(mistRect, mistPaint);
    }

    final Paint runePaint = Paint()
      ..color = const Color(0xFFFFC400)
          .withOpacity(0.25 + 0.2 * sin((fogShift + 0.3) * 2 * pi))
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Path rune = Path()
      ..moveTo(size.width * 0.1, size.height * 0.86)
      ..cubicTo(
        size.width * 0.22,
        size.height * (0.82 - 0.03 * sin(fogShift * 2 * pi)),
        size.width * 0.38,
        size.height * 0.9,
        size.width * 0.5,
        size.height * 0.83,
      )
      ..cubicTo(
        size.width * 0.62,
        size.height * 0.78,
        size.width * 0.82,
        size.height * 0.9,
        size.width * 0.9,
        size.height * 0.86,
      );
    canvas.drawPath(rune, runePaint);
  }

  @override
  bool shouldRepaint(covariant _HalloweenForegroundPainter oldDelegate) =>
      fogShift != oldDelegate.fogShift;
}

class BeachBackground extends StatelessWidget {
  const BeachBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/beach.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        // Optional overlay for better text readability
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }
}

// Generic image background widget used by image-based themes
class _ImageBackground extends StatelessWidget {
  final String assetPath;
  const _ImageBackground(this.assetPath);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(assetPath),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        // Soft overlay to improve text contrast on bright images
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.05),
              Colors.black.withOpacity(0.15),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    );
  }
}

// Theme helper function
Widget getBackgroundForTheme(String theme) {
  switch (theme) {
    case 'beach':
      return const BeachBackground();
    case 'forest':
      return const _ImageBackground('assets/images/forest.png');
    case 'arctic':
      return const _ImageBackground('assets/images/arctic.png');
    case 'crystal':
      return const _ImageBackground('assets/images/glass.png');
    case 'halloween':
      return const HalloweenBackground();
    case 'space':
    default:
      return const SpaceBackground();
  }
}

// Theme colors helper
class ThemeColors {
  static final List<List<Color>> _halloweenCardPalettes = [
    [const Color(0xFF2B0A3D), const Color(0xFF120424)],
    [const Color(0xFF3F0E4F), const Color(0xFF0B0016)],
    [const Color(0xFF1C0027), const Color(0xFF0C0016)],
  ];

  static SystemUiOverlayStyle getOverlayStyle(String theme) {
    // For bright backgrounds, use dark icons; for dark/image backgrounds, use light icons
    switch (theme) {
      case 'beach':
      case 'arctic':
      case 'crystal':
        return SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        );
      case 'forest':
      case 'halloween':
      case 'space':
      default:
        return SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        );
    }
  }

  static Color getPrimaryColor(String theme) {
    switch (theme) {
      case 'beach':
        return const Color(0xFF4DD0E1); // Turquoise from ocean
      case 'forest':
        return const Color(0xFF2E7D32);
      case 'halloween':
        return const Color(0xFF1A0B2E); // Midnight violet
      case 'arctic':
        return const Color(0xFF81D4FA); // Icy blue
      case 'crystal':
        return const Color(0xFF80DEEA); // Glassy teal
      case 'space':
      default:
        return const Color(0xFF0A0E21);
    }
  }

  static Color getSecondaryColor(String theme) {
    switch (theme) {
      case 'beach':
        return const Color(0xFFF5E6D3); // Sandy beige
      case 'forest':
        return const Color(0xFF4CAF50);
      case 'halloween':
        return const Color(0xFFFF6F00); // Pumpkin glow
      case 'arctic':
        return const Color(0xFFB3E5FC); // Pale ice
      case 'crystal':
        return const Color(0xFFE0F7FA); // Light aqua
      case 'space':
      default:
        return const Color(0xFF1D1E33);
    }
  }

  static Color getTextColor(String theme) {
    switch (theme) {
      case 'beach':
        return const Color(0xFF2E2E2E); // Dark gray for readability
      case 'arctic':
        return Colors.white; // Arctic: use white text per request
      case 'crystal':
        return Colors.white; // Crystal: use white text per request
      case 'forest':
        // Use a warm off-white for forest so text pops over green image
        return const Color(0xFFF1F8EE);
      case 'halloween':
        return const Color(0xFFF8E1FF);
      case 'space':
      default:
        return Colors.white;
    }
  }

  // Translucent backdrop behind TabBar for better readability across themes
  static Color getTabBackdropColor(String theme) {
    switch (theme) {
      case 'beach':
      case 'arctic':
      case 'crystal':
        return Colors.black.withOpacity(0.20);
      case 'forest':
        // Slightly darker translucent backdrop for forest to improve readability
        return Colors.black.withOpacity(0.35);
      case 'halloween':
        return const Color(0xFF1B0035).withOpacity(0.65);
      case 'space':
      default:
        return Colors.white.withOpacity(0.20);
    }
  }

  // Pill color for the selected tab indicator
  static Color getTabPillColor(String theme) {
    switch (theme) {
      case 'beach':
      case 'arctic':
      case 'crystal':
        return Colors.black.withOpacity(0.30);
      case 'forest':
        // Greenish pill for forest
        return const Color(0xFF2E7D32).withOpacity(0.45);
      case 'halloween':
        return const Color(0xFFFFA000).withOpacity(0.45);
      case 'space':
      default:
        return Colors.white.withOpacity(0.30);
    }
  }

  // Selected label color for maximum contrast on the pill
  static Color getTabSelectedLabelColor(String theme) {
    switch (theme) {
      case 'beach':
      case 'arctic':
      case 'crystal':
        return Colors.white;
      case 'forest':
        return Colors.white;
      case 'halloween':
        return Colors.white;
      case 'space':
      default:
        return getTextColor(theme);
    }
  }

  static Color getButtonColor(String theme) {
    switch (theme) {
      case 'beach':
        return const Color(0xFF26C6DA); // Bright turquoise
      case 'forest':
        return const Color(0xFF66BB6A);
      case 'halloween':
        return const Color(0xFFFF6D00);
      case 'arctic':
        return const Color(
            0xFF1F2937); // Dark slate for better contrast per request
      case 'crystal':
        return const Color(0xFF4DD0E1);
      case 'space':
      default:
        return Colors.blueAccent;
    }
  }

  // Additional colors for beach theme
  static Color getCardColor(String theme) {
    switch (theme) {
      case 'beach':
        return const Color(0xFFF5F5DC)
            .withOpacity(0.9); // Beige/cream card background
      case 'arctic':
        return const Color(0xFFFFFFFF).withOpacity(0.85);
      case 'crystal':
        return const Color(0xFFE0F7FA).withOpacity(0.85);
      case 'forest':
        // Use a subtle dark-green translucent card to contrast the forest image
        return const Color(0xFF04260F).withOpacity(0.55);
      case 'halloween':
        return const Color(0xFF120323).withOpacity(0.75);
      case 'space':
      default:
        return Colors.white.withOpacity(0.1); // Dark cards for space
    }
  }

  // Beach card gradient
  static LinearGradient getBeachCardGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFF5F5DC).withOpacity(0.95), // Light beige
        const Color(0xFFE6D3A3).withOpacity(0.9), // Warm sand
      ],
    );
  }

  static Color getAccentColor(String theme) {
    switch (theme) {
      case 'beach':
        return const Color(0xFFFF8A65); // Coral from tropical flowers
      case 'halloween':
        return const Color(0xFFFFC400);
      case 'arctic':
        return const Color(0xFF81D4FA);
      case 'crystal':
        return const Color(0xFF80DEEA);
      case 'forest':
        // Brighter lime for accents on forest
        return const Color(0xFF8BC34A);
      case 'space':
      default:
        return Colors.blueAccent;
    }
  }

  static Color getTropicalGreen(String theme) {
    switch (theme) {
      case 'beach':
        return const Color(0xFF4CAF50); // Tropical green from palm leaves
      case 'space':
      default:
        return const Color(0xFF81C784);
    }
  }

  // Beach-appropriate gradients
  static List<Color> getBeachGradient1() {
    return [const Color(0xFF4DD0E1), const Color(0xFF26C6DA)]; // Ocean blues
  }

  static List<Color> getBeachGradient2() {
    return [
      const Color(0xFF4CAF50),
      const Color(0xFF66BB6A)
    ]; // Tropical greens
  }

  static List<Color> getBeachGradient3() {
    return [const Color(0xFFFF8A65), const Color(0xFFFFAB91)]; // Coral tones
  }

  static List<Color> getBeachGradient4() {
    return [const Color(0xFFFFD54F), const Color(0xFFFFE082)]; // Sandy yellows
  }

  static List<Color> getBeachGradient5() {
    return [const Color(0xFF81C784), const Color(0xFFA5D6A7)]; // Palm greens
  }

  // Get appropriate gradient for beach theme
  static List<Color> getBeachGradientForIndex(int index) {
    switch (index % 5) {
      case 0:
        return getBeachGradient1();
      case 1:
        return getBeachGradient2();
      case 2:
        return getBeachGradient3();
      case 3:
        return getBeachGradient4();
      case 4:
      default:
        return getBeachGradient5();
    }
  }

  static LinearGradient getHalloweenCardGradient(int variant) {
    final palette =
        _halloweenCardPalettes[variant % _halloweenCardPalettes.length];
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: palette,
    );
  }

  static LinearGradient? getCardGradient(String theme, {int variant = 0}) {
    switch (theme) {
      case 'halloween':
        return getHalloweenCardGradient(variant);
      case 'beach':
        return getBeachCardGradient();
      default:
        return null;
    }
  }

  static LinearGradient? getButtonGradient(String theme) {
    switch (theme) {
      case 'halloween':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF6F00),
            Color(0xFFFF8F3F),
          ],
        );
      default:
        return null;
    }
  }

  static List<BoxShadow> getButtonShadows(String theme) {
    switch (theme) {
      case 'halloween':
        return [
          BoxShadow(
            color: const Color(0xFFFF6F00).withOpacity(0.45),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF120323).withOpacity(0.6),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ];
      default:
        return [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ];
    }
  }
}

class ThemeCopy {
  static String getGreeting(String theme, String username) {
    if (theme == 'halloween') {
      return 'Welcome to the Haunted Archives, $username!';
    }
    return 'Welcome, $username!';
  }

  static String getGreetingSubtitle(String theme) {
    if (theme == 'halloween') {
      return 'Summon spectral knowledge tonight.';
    }
    return "Let's learn something new today!";
  }

  static String getScoreLabel(String theme) {
    if (theme == 'halloween') {
      return 'Spooky Score';
    }
    return 'Score';
  }

  static String getStoreSubtitle(String theme) {
    if (theme == 'halloween') {
      return 'Stock up on enchanted\ncurios for nightfall studies';
    }
    return 'Enhance your learning experience';
  }

  static String getStoreTitle(String theme) {
    if (theme == 'halloween') {
      return 'Haunted Curio Market';
    }
    return 'EduQuest Store';
  }
}

class GameButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isSelected;
  final bool? isCorrect;
  final String currentTheme;

  const GameButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isSelected = false,
    this.isCorrect,
    required this.currentTheme,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = ThemeColors.getCardColor(currentTheme);
    Color borderColor = ThemeColors.getButtonColor(currentTheme);
    Color textColor = ThemeColors.getTextColor(currentTheme);
    final bool isHalloween = currentTheme == 'halloween';

    if (currentTheme == 'beach') {
      backgroundColor = Colors.white.withOpacity(0.9);
      borderColor = ThemeColors.getButtonColor('beach');
      textColor = ThemeColors.getTextColor('beach');
    }

    if (isSelected && isCorrect != null) {
      backgroundColor = isCorrect!
          ? ThemeColors.getTropicalGreen(currentTheme)
          : ThemeColors.getAccentColor(currentTheme);
      borderColor = isCorrect!
          ? ThemeColors.getTropicalGreen(currentTheme)
          : ThemeColors.getAccentColor(currentTheme);
      textColor = currentTheme == 'beach' ? Colors.white : Colors.white;
    } else if (isCorrect == true) {
      backgroundColor = ThemeColors.getTropicalGreen(currentTheme);
      borderColor = ThemeColors.getTropicalGreen(currentTheme);
      textColor = Colors.white;
    }

    final bool hasStateColor =
        (isSelected && isCorrect != null) || isCorrect == true;
    final bool useSpookySkin = isHalloween && !hasStateColor;
    final borderRadius = BorderRadius.circular(10);

    final button = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: useSpookySkin ? Colors.transparent : backgroundColor,
        shadowColor: useSpookySkin ? Colors.transparent : null,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: borderColor, width: 2),
        ),
        elevation: useSpookySkin ? 0 : 5,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: useSpookySkin
          ? BoxDecoration(
              gradient: ThemeColors.getButtonGradient(currentTheme),
              borderRadius: borderRadius,
              boxShadow: ThemeColors.getButtonShadows(currentTheme),
              border: Border.all(
                color: ThemeColors.getAccentColor(currentTheme).withOpacity(
                  isSelected ? 0.9 : 0.4,
                ),
                width: isSelected ? 2 : 1,
              ),
            )
          : null,
      child: button,
    );
  }
}

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> with TickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dbHelper = DatabaseHelper();
  bool _obscurePassword = true;
  bool _isFormValid = false;
  bool _rememberAccount = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  late AnimationController _animationController;
  late AnimationController _ambientController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;
  bool _developerMode = false;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_updateFormState);
    _passwordController.addListener(_updateFormState);

    // Initialize controllers first before any async operations that might trigger rebuilds
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _ambientController = AnimationController(
      duration: const Duration(seconds: 18),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();

    // Load saved data after controllers are initialized
    _loadSavedCredentials();
    _loadDeveloperState();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _usernameController.text = prefs.getString('saved_username') ?? '';
      _passwordController.text = prefs.getString('saved_password') ?? '';
      _rememberAccount = prefs.getBool('remember_account') ?? false;
    });
  }

  Future<void> _loadDeveloperState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _developerMode = prefs.getBool('developer_mode') ?? false;
    });
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberAccount) {
      await prefs.setString('saved_username', _usernameController.text);
      await prefs.setString('saved_password', _passwordController.text);
      await prefs.setBool('remember_account', true);
    } else {
      await prefs.remove('saved_username');
      await prefs.remove('saved_password');
      await prefs.setBool('remember_account', false);
    }
  }

  @override
  void dispose() {
    _usernameController.removeListener(_updateFormState);
    _passwordController.removeListener(_updateFormState);
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  void _updateFormState() {
    setState(() {
      _isFormValid = _usernameController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty;
    });
  }

  Future<void> _signIn() async {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.mediumImpact();

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (username.isEmpty || password.isEmpty) {
        throw Exception('Please fill in all fields');
      }

      final isAuthenticated =
          await _dbHelper.authenticateUser(username, password);

      if (isAuthenticated) {
        await _saveCredentials(); // Save credentials if remember is checked
        HapticFeedback.heavyImpact();
        if (!mounted) return;
        Navigator.pushReplacement(
          this.context,
          CustomPageRoute(
            page: MainScreen(username: username),
            routeName: '/home',
          ),
        );
      } else {
        HapticFeedback.vibrate();
        if (!mounted) return;
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 6),
                const Text('Invalid username or password'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error during sign-in: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(
            content: Text('Google sign in was cancelled'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      HapticFeedback.heavyImpact();
      if (!mounted) return;
      Navigator.pushReplacement(
        this.context,
        CustomPageRoute(
          page: MainScreen(username: googleUser.email),
          routeName: '/home',
        ),
      );
    } catch (e) {
      debugPrint('Error during Google Sign-In: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign in with Google: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showDeveloperPassDialog() async {
    // Directly log into developer account without password
    setState(() {
      _isLoading = true;
    });

    try {
      // Ensure demo account exists, then log into it
      final exists = await _dbHelper.usernameExists('EduQuest');
      if (!exists) {
        await _dbHelper.addUser('EduQuest', 'demo@eduquest.app', 'eduquest');
        // Optionally give starter points to demo account
        await _dbHelper.updateUserPoints('EduQuest', 999999);
      }
      if (!mounted) return;

      HapticFeedback.heavyImpact();
      // Navigate straight to MainScreen as demo
      Navigator.pushReplacement(
        this.context,
        CustomPageRoute(
          page: MainScreen(username: 'EduQuest'),
          routeName: '/home',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Text('Demo login failed: $e'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0B0F1A),
                  Color(0xFF111827),
                  Color(0xFF0B0F1A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _ambientController,
            builder: (context, child) {
              final wave = sin(_ambientController.value * 2 * pi);
              final drift = cos(_ambientController.value * 2 * pi);
              return Stack(
                children: [
                  Positioned(
                    top: -140 + wave * 30,
                    left: -100 + drift * 40,
                    child: const _AuthGlowBlob(
                      size: 280,
                      color: Color(0xFF38BDF8),
                      opacity: 0.35,
                    ),
                  ),
                  Positioned(
                    bottom: -160 + drift * 20,
                    right: -120 + wave * 30,
                    child: const _AuthGlowBlob(
                      size: 320,
                      color: Color(0xFF6366F1),
                      opacity: 0.3,
                    ),
                  ),
                  Positioned(
                    top: 120 + drift * 25,
                    right: -60 + wave * 20,
                    child: const _AuthGlowBlob(
                      size: 180,
                      color: Color(0xFF22D3EE),
                      opacity: 0.25,
                    ),
                  ),
                ],
              );
            },
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF1E293B),
                              Color(0xFF0B1220),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(1.2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 28,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.08),
                                  ),
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF0F172A).withOpacity(0.92),
                                      const Color(0xFF111827).withOpacity(0.7),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Image.asset(
                                      'assets/images/eduquest_logo.png',
                                      height: 96,
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Welcome back',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Sign in to continue to EduQuest.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    TextFormField(
                                      controller: _usernameController,
                                      style: const TextStyle(
                                          color: Color(0xFFE2E8F0)),
                                      decoration: InputDecoration(
                                        labelText: 'Username',
                                        labelStyle: const TextStyle(
                                            color: Color(0xFF94A3B8)),
                                        prefixIcon: const Icon(
                                          Icons.person,
                                          color: Color(0xFF64748B),
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFF111827),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF1F2937)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF1F2937)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF38BDF8)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      style: const TextStyle(
                                          color: Color(0xFFE2E8F0)),
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        labelStyle: const TextStyle(
                                            color: Color(0xFF94A3B8)),
                                        prefixIcon: const Icon(
                                          Icons.lock,
                                          color: Color(0xFF64748B),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: const Color(0xFF64748B),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFF111827),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF1F2937)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF1F2937)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF38BDF8)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      children: [
                                        Checkbox(
                                          value: _rememberAccount,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              _rememberAccount = value ?? false;
                                            });
                                          },
                                          activeColor:
                                              const Color(0xFF2563EB),
                                        ),
                                        const Text(
                                          'Remember this account',
                                          style: TextStyle(
                                            color: Color(0xFFCBD5F5),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      onPressed: _isFormValid && !_isLoading
                                          ? _signIn
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF2563EB),
                                        disabledBackgroundColor:
                                            const Color(0xFF1E293B),
                                        minimumSize:
                                            const Size(double.infinity, 52),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child:
                                                  CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  Colors.white,
                                                ),
                                              ),
                                            )
                                          : const Text(
                                              'Sign In',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                    const SizedBox(height: 16),
                                    OutlinedButton.icon(
                                      onPressed: _isLoading
                                          ? null
                                          : _signInWithGoogle,
                                      icon: Image.asset(
                                        'assets/images/google_icon.png',
                                        height: 22,
                                      ),
                                      label:
                                          const Text('Continue with Google'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor:
                                            const Color(0xFFE2E8F0),
                                        backgroundColor:
                                            const Color(0xFF0F172A),
                                        minimumSize:
                                            const Size(double.infinity, 52),
                                        side: const BorderSide(
                                            color: Color(0xFF1F2937)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          CustomPageRoute(
                                            page: SignUpPage(),
                                            routeName: '/signup',
                                          ),
                                        );
                                      },
                                      child: RichText(
                                        text: const TextSpan(
                                          style: TextStyle(
                                              color: Color(0xFF94A3B8)),
                                          children: [
                                            TextSpan(
                                                text:
                                                    'Don\'t have an account? '),
                                            TextSpan(
                                              text: 'Create one',
                                              style: TextStyle(
                                                color: Color(0xFF38BDF8),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    OutlinedButton.icon(
                                      onPressed: _showDeveloperPassDialog,
                                      icon: Icon(
                                        Icons.developer_mode,
                                        color: _developerMode
                                            ? const Color(0xFF22C55E)
                                            : const Color(0xFFFBBF24),
                                        size: 20,
                                      ),
                                      label: Text(
                                        _developerMode
                                            ? 'Developer mode active'
                                            : 'Developer access',
                                        style: TextStyle(
                                          color: _developerMode
                                              ? const Color(0xFF22C55E)
                                              : const Color(0xFFFBBF24),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: _developerMode
                                              ? const Color(0xFF22C55E)
                                              : const Color(0xFFFBBF24),
                                          width: 1.3,
                                        ),
                                        minimumSize:
                                            const Size(double.infinity, 46),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  final _usernameController = TextEditingController();
  // final _emailController = TextEditingController(); // REMOVED: Email no longer required
  final _passwordController = TextEditingController();
  final _dbHelper = DatabaseHelper();
  bool _obscurePassword = true;
  bool _isFormValid = false;
  bool _isLoading = false;
  bool _agreeToPrivacyPolicy = false;
  late AnimationController _animationController;
  late AnimationController _ambientController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_updateFormState);
    // _emailController.addListener(_updateFormState); // REMOVED
    _passwordController.addListener(_updateFormState);

    // Initialize controllers first before any async operations that might trigger rebuilds
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _ambientController = AnimationController(
      duration: const Duration(seconds: 18),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _usernameController.removeListener(_updateFormState);
    // _emailController.removeListener(_updateFormState); // REMOVED
    _passwordController.removeListener(_updateFormState);
    _usernameController.dispose();
    // _emailController.dispose(); // REMOVED
    _passwordController.dispose();
    _animationController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  void _updateFormState() {
    setState(() {
      _isFormValid = _usernameController.text.isNotEmpty &&
          // _emailController.text.isNotEmpty && // REMOVED: Email not required
          _passwordController.text.isNotEmpty &&
          _agreeToPrivacyPolicy;
    });
  }

  Future<void> _signUp() async {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
    });

    final username = _usernameController.text.trim();
    // final email = _emailController.text.trim(); // REMOVED
    final password = _passwordController.text.trim();

    try {
      if (username.isEmpty || password.isEmpty) {
        throw Exception('Please fill in all fields');
      }

      // Basic email validation - REMOVED
      // if (!email.contains('@') || !email.contains('.')) {
      //   throw Exception('Please enter a valid email address');
      // }

      print('DEBUG: Checking if username exists: $username');
      final userExists = await _dbHelper.usernameExistsForRegistration(username);
      print('DEBUG: Username exists check result: $userExists');

      if (userExists) {
        throw Exception('Username already exists. Please choose another.');
      }

      print('DEBUG: Creating user account...');
      // Create user account without email
      await _dbHelper.createUser(username, password);
      
      if (!mounted) return;
      
      // Navigate to sign in page
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! Please sign in.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('Error during sign-up: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // REMOVED: Email verification no longer needed
  // Future<void> _showEmailVerificationDialog(String username, String email, String password) async {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Verify Your Email'),
  //       content: const Text(
  //         'A verification code has been sent to your email. Check your inbox to complete registration.',
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('OK'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0B0F1A),
                  Color(0xFF111827),
                  Color(0xFF0B0F1A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _ambientController,
            builder: (context, child) {
              final wave = sin(_ambientController.value * 2 * pi);
              final drift = cos(_ambientController.value * 2 * pi);
              return Stack(
                children: [
                  Positioned(
                    top: -140 + wave * 30,
                    left: -100 + drift * 40,
                    child: const _AuthGlowBlob(
                      size: 280,
                      color: Color(0xFF38BDF8),
                      opacity: 0.35,
                    ),
                  ),
                  Positioned(
                    bottom: -160 + drift * 20,
                    right: -120 + wave * 30,
                    child: const _AuthGlowBlob(
                      size: 320,
                      color: Color(0xFF6366F1),
                      opacity: 0.3,
                    ),
                  ),
                  Positioned(
                    top: 120 + drift * 25,
                    right: -60 + wave * 20,
                    child: const _AuthGlowBlob(
                      size: 180,
                      color: Color(0xFF22D3EE),
                      opacity: 0.25,
                    ),
                  ),
                ],
              );
            },
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF1E293B),
                              Color(0xFF0B1220),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(1.2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 28,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.08),
                                  ),
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF0F172A).withOpacity(0.92),
                                      const Color(0xFF111827).withOpacity(0.7),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Image.asset(
                                      'assets/images/eduquest_logo.png',
                                      height: 96,
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Create your account',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Join EduQuest to track progress and save your work.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    TextFormField(
                                      controller: _usernameController,
                                      style: const TextStyle(
                                          color: Color(0xFFE2E8F0)),
                                      decoration: InputDecoration(
                                        labelText: 'Username',
                                        labelStyle: const TextStyle(
                                            color: Color(0xFF94A3B8)),
                                        prefixIcon: const Icon(
                                          Icons.person,
                                          color: Color(0xFF64748B),
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFF111827),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF1F2937)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF1F2937)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF38BDF8)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      style: const TextStyle(
                                          color: Color(0xFFE2E8F0)),
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        labelStyle: const TextStyle(
                                            color: Color(0xFF94A3B8)),
                                        prefixIcon: const Icon(
                                          Icons.lock,
                                          color: Color(0xFF64748B),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: const Color(0xFF64748B),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFF111827),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF1F2937)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF1F2937)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF38BDF8)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Checkbox(
                                          value: _agreeToPrivacyPolicy,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              _agreeToPrivacyPolicy =
                                                  value ?? false;
                                              _updateFormState();
                                            });
                                          },
                                          activeColor:
                                              const Color(0xFF2563EB),
                                          checkColor: Colors.white,
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 12.0),
                                            child: RichText(
                                              text: const TextSpan(
                                                style: TextStyle(
                                                  color: Color(0xFF94A3B8),
                                                  fontSize: 14,
                                                ),
                                                children: [
                                                  TextSpan(
                                                      text: 'I agree to the '),
                                                  TextSpan(
                                                    text: 'Privacy Policy',
                                                    style: TextStyle(
                                                      color: Color(0xFF38BDF8),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      decoration:
                                                          TextDecoration
                                                              .underline,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                      text: ' of EduQuest'),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      onPressed: _isLoading
                                          ? null
                                          : (_isFormValid ? _signUp : null),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF2563EB),
                                        disabledBackgroundColor:
                                            const Color(0xFF1E293B),
                                        minimumSize:
                                            const Size(double.infinity, 52),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child:
                                                  CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  Colors.white,
                                                ),
                                              ),
                                            )
                                          : const Text(
                                              'Create account',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: RichText(
                                        text: const TextSpan(
                                          style: TextStyle(
                                              color: Color(0xFF94A3B8)),
                                          children: [
                                            TextSpan(
                                                text:
                                                    'Already have an account? '),
                                            TextSpan(
                                              text: 'Sign in',
                                              style: TextStyle(
                                                color: Color(0xFF38BDF8),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0B0F1A),
                  Color(0xFF111827),
                  Color(0xFF0B0F1A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _ambientController,
            builder: (context, child) {
              final wave = sin(_ambientController.value * 2 * pi);
              final drift = cos(_ambientController.value * 2 * pi);
              return Stack(
                children: [
                  Positioned(
                    top: -140 + wave * 30,
                    left: -100 + drift * 40,
                    child: const _AuthGlowBlob(
                      size: 280,
                      color: Color(0xFF38BDF8),
                      opacity: 0.35,
                    ),
                  ),
                  Positioned(
                    bottom: -160 + drift * 20,
                    right: -120 + wave * 30,
                    child: const _AuthGlowBlob(
                      size: 320,
                      color: Color(0xFF6366F1),
                      opacity: 0.3,
                    ),
                  ),
                  Positioned(
                    top: 120 + drift * 25,
                    right: -60 + wave * 20,
                    child: const _AuthGlowBlob(
                      size: 180,
                      color: Color(0xFF22D3EE),
                      opacity: 0.25,
                    ),
                  ),
                ],
              );
            },
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF1E293B),
                              Color(0xFF0B1220),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(1.2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 28,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.08),
                                  ),
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF0F172A).withOpacity(0.92),
                                      const Color(0xFF111827).withOpacity(0.7),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Image.asset(
                                      'assets/images/eduquest_logo.png',
                                      height: 96,
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Create your account',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Join EduQuest to track progress and save your work.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    TextFormField(
                                      controller: _usernameController,
                                      style: const TextStyle(
                                          color: Color(0xFFE2E8F0)),
                                      decoration: InputDecoration(
                                        labelText: 'Username',
                                        labelStyle: const TextStyle(
                                            color: Color(0xFF94A3B8)),
                                        prefixIcon: const Icon(
                                          Icons.person,
                                          color: Color(0xFF64748B),
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFF111827),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF1F2937)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF1F2937)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF38BDF8)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      style: const TextStyle(
                                          color: Color(0xFFE2E8F0)),
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        labelStyle: const TextStyle(
                                            color: Color(0xFF94A3B8)),
                                        prefixIcon: const Icon(
                                          Icons.lock,
                                          color: Color(0xFF64748B),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: const Color(0xFF64748B),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                        ),
                                        filled: true,
                                        fillColor: const Color(0xFF111827),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF1F2937)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF1F2937)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF38BDF8)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Checkbox(
                                          value: _agreeToPrivacyPolicy,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              _agreeToPrivacyPolicy =
                                                  value ?? false;
                                              _updateFormState();
                                            });
                                          },
                                          activeColor:
                                              const Color(0xFF2563EB),
                                          checkColor: Colors.white,
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 12.0),
                                            child: RichText(
                                              text: const TextSpan(
                                                style: TextStyle(
                                                  color: Color(0xFF94A3B8),
                                                  fontSize: 14,
                                                ),
                                                children: [
                                                  TextSpan(
                                                      text: 'I agree to the '),
                                                  TextSpan(
                                                    text: 'Privacy Policy',
                                                    style: TextStyle(
                                                      color: Color(0xFF38BDF8),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      decoration:
                                                          TextDecoration
                                                              .underline,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                      text: ' of EduQuest'),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      onPressed: _isLoading
                                          ? null
                                          : (_isFormValid ? _signUp : null),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF2563EB),
                                        disabledBackgroundColor:
                                            const Color(0xFF1E293B),
                                        minimumSize:
                                            const Size(double.infinity, 52),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child:
                                                  CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  Colors.white,
                                                ),
                                              ),
                                            )
                                          : const Text(
                                              'Create account',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: RichText(
                                        text: const TextSpan(
                                          style: TextStyle(
                                              color: Color(0xFF94A3B8)),
                                          children: [
                                            TextSpan(
                                                text:
                                                    'Already have an account? '),
                                            TextSpan(
                                              text: 'Sign in',
                                              style: TextStyle(
                                                color: Color(0xFF38BDF8),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  ),
),
        ],
      ),
    );
  }
  */
}

class _AuthGlowBlob extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _AuthGlowBlob({
    required this.size,
    required this.color,
    this.opacity = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(opacity),
            color.withOpacity(0.0),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final String username;

  const MainScreen({
    super.key,
    required this.username,
  });

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String _currentTheme = 'space';
  int _userPoints = 0;
  bool _developerMode = false;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  // ignore: unused_field
  List<Map<String, dynamic>> _studySets = [];
  // ignore: unused_field
  List<Map<String, dynamic>> _premadeStudySets = [];
  // ignore: unused_field
  bool _isLoading = true;
  int _learnTabIndex = 0; // Add this line to track the Learn tab index

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadStudySets();
  }

  Future<void> _loadUserData() async {
    final points = await _dbHelper.getUserPoints(widget.username);
    final theme = await _dbHelper.getCurrentTheme(widget.username);
    setState(() {
      _userPoints = points;
      _currentTheme = theme ?? 'space';
      _developerMode = widget.username == 'EduQuest';
    });
  }

  Future<void> _loadStudySets() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final userSets = await _dbHelper.getUserStudySets(widget.username);
    final importedSets = await _dbHelper.getUserImportedSets(widget.username);
    if (mounted) {
      setState(() {
        _studySets = userSets;
        _premadeStudySets = importedSets;
        _isLoading = false;
      });
    }
  }

  void _onTabTapped(int index) async {
    // Check if user is trying to navigate away from Learn tab (which contains Quick Play)
    if (_currentIndex == 0 && index != 0) {
      // Check if we're on the Quick Play tab (index 2 within the Learn tab)
      if (_learnTabIndex == 2) {
        // Show confirmation dialog
        bool shouldNavigate = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: _currentTheme == 'beach'
                      ? ThemeColors.getCardColor('beach')
                      : const Color(0xFF2A2D3E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: _currentTheme == 'beach'
                            ? ThemeColors.getAccentColor('beach')
                            : Colors.orange,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Discard Changes?',
                        style: TextStyle(
                          color: _currentTheme == 'beach'
                              ? ThemeColors.getTextColor('beach')
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  content: Text(
                    'You have unsaved changes in Quick Play. Are you sure you want to navigate away?',
                    style: TextStyle(
                      color: _currentTheme == 'beach'
                          ? ThemeColors.getTextColor('beach').withOpacity(0.8)
                          : Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: _currentTheme == 'beach'
                              ? ThemeColors.getPrimaryColor('beach')
                              : Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentTheme == 'beach'
                            ? ThemeColors.getAccentColor('beach')
                            : Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Discard',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ) ??
            false;

        if (!shouldNavigate) {
          return; // Don't navigate if user cancels
        }
      }
    }

    setState(() {
      _currentIndex = index;
    });
  }

  void _updatePoints(int newPoints) {
    setState(() {
      _userPoints = newPoints;
    });
  }

  void _updateTheme(String newTheme) {
    setState(() {
      _currentTheme = newTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _children = [
      LearnTab(
        username: widget.username,
        userPoints: _userPoints,
        currentTheme: _currentTheme,
        developerMode: _developerMode,
        onPointsUpdated: _updatePoints,
        onTabChanged: (index) {
          // Add this callback
          setState(() {
            _learnTabIndex = index;
          });
        },
      ),
      ShopTab(
        username: widget.username,
        userPoints: _userPoints,
        currentTheme: _currentTheme,
        developerMode: _developerMode,
        onPointsUpdated: _updatePoints,
        onThemeChanged: _updateTheme,
      ),
      ProfileTab(
        username: widget.username,
        userPoints: _userPoints,
        currentTheme: _currentTheme,
      ),
    ];

    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onTabTapped,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: _currentTheme == 'beach'
            ? ThemeColors.getPrimaryColor('beach').withOpacity(0.95)
            : const Color(0xFF1D1E33),
        selectedItemColor:
            _currentTheme == 'beach' ? Colors.white : Colors.blueAccent,
        unselectedItemColor: _currentTheme == 'beach'
            ? Colors.white.withOpacity(0.8)
            : Colors.white70,
        elevation: 20,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: (_currentIndex == 0 &&
              _learnTabIndex == 0) // Show only on My Sets tab
          ? Padding(
              padding: const EdgeInsets.only(bottom: 16.0, left: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: _currentTheme == 'beach'
                          ? LinearGradient(
                              colors: ThemeColors.getBeachGradient2(),
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: _currentTheme == 'beach'
                              ? ThemeColors.getBeachGradient2()[0]
                                  .withOpacity(0.3)
                              : const Color(0xFF667eea).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StudySetCreationOptionsScreen(
                              username: widget.username,
                              onStudySetCreated: _loadStudySets,
                              currentTheme: _currentTheme,
                            ),
                          ),
                        );
                      },
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Create Set',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

class LearnTab extends StatefulWidget {
  final String username;
  final int userPoints;
  final String currentTheme;
  final bool developerMode;
  final Function(int) onPointsUpdated;
  final Function(int) onTabChanged; // Add this callback

  const LearnTab({
    super.key,
    required this.username,
    required this.userPoints,
    required this.currentTheme,
    required this.developerMode,
    required this.onPointsUpdated,
    required this.onTabChanged, // Add this parameter
  });

  @override
  _LearnTabState createState() => _LearnTabState();
}

class _LearnTabState extends State<LearnTab>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _studySets = [];
  List<Map<String, dynamic>> _premadeStudySets = [];
  bool _isLoading = true;
  late TabController _tabController;
  final TextEditingController _importedSearchController =
      TextEditingController();
  String _importedSearchQuery = '';
  int _unreadInboxCount = 0;
  Timer? _unreadCountTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadStudySets();
    _loadUnreadCount();
    // Poll for new unread messages every 5 seconds
    _unreadCountTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _loadUnreadCount();
    });
    _tabController = TabController(
        length: 3, vsync: this, initialIndex: 0); // Set initial tab to My Sets
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        widget.onTabChanged(_tabController.index);
      }
    });
    _importedSearchController.addListener(() {
      setState(() {
        _importedSearchQuery = _importedSearchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _importedSearchController.dispose();
    _tabController.dispose();
    _unreadCountTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await _dbHelper.getUnreadMessageCount(widget.username);
      if (mounted) {
        setState(() {
          _unreadInboxCount = count;
        });
      }
    } catch (e) {
      debugPrint('Error loading unread count: $e');
    }
  }

  void _showPointsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ThemeColors.getCardColor(widget.currentTheme),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.diamond, color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Points',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Current Points: ${widget.userPoints}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.maxFinite,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Coming soon! 🚀'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Buy Points'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.maxFinite,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showRedeemCodeDialog();
                    },
                    icon: const Icon(Icons.card_giftcard),
                    label: const Text('Redeem Code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRedeemCodeDialog() {
    String redeemCode = '';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: ThemeColors.getCardColor(widget.currentTheme),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Redeem Code',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter your redemption code:',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (value) {
                    redeemCode = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter code',
                    hintStyle: const TextStyle(color: Colors.white30),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.white30),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.white30),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.amber),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (redeemCode.toLowerCase() == 'eduquestkushal') {
                  // Valid code - add 1000 points
                  int newPoints = widget.userPoints + 1000;
                  await _dbHelper.updateUserPoints(widget.username, newPoints);
                  widget.onPointsUpdated(newPoints);
                  
                  Navigator.pop(context); // Close redeem dialog
                  Navigator.pop(context); // Close points dialog
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✨ Code redeemed! +1000 points!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );
                  
                  // Update UI
                  setState(() {});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid code. Please check and try again.'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              child: const Text('Redeem'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadStudySets() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final userSets = await _dbHelper.getUserStudySets(widget.username);
    final importedSets = await _dbHelper.getUserImportedSets(widget.username);
    if (mounted) {
      setState(() {
        _studySets = userSets;
        _premadeStudySets = importedSets;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    try {
      final points = await _dbHelper.getUserPoints(widget.username);
      // Trigger parent update
      widget.onPointsUpdated(points);
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: ThemeColors.getOverlayStyle(widget.currentTheme),
      child: AtmosphericScaffold(
        showGhost: false,
        showFog: widget.currentTheme == 'halloween',
        showEmbers: false,
        intensity: AtmosphericIntensity.normal,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              getBackgroundForTheme(widget.currentTheme),
              SafeArea(
              child: Column(
                children: [
                  // Header with points and inbox
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ThemeCopy.getGreeting(
                                  widget.currentTheme,
                                  widget.username,
                                ),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: ThemeColors.getTextColor(
                                      widget.currentTheme),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                ThemeCopy.getGreetingSubtitle(
                                    widget.currentTheme),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: ThemeColors.getTextColor(
                                          widget.currentTheme)
                                      .withOpacity(0.8),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Inbox button with badge
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => InboxScreen(
                                      username: widget.username,
                                      currentTheme: widget.currentTheme,
                                    ),
                                  ),
                                ).then((_) {
                                  // Set unread count to 0 when returning from inbox
                                  setState(() {
                                    _unreadInboxCount = 0;
                                  });
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: ThemeColors.getPrimaryColor(
                                          widget.currentTheme)
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  Icons.mail_outline,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            if (_unreadInboxCount > 0)
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _unreadInboxCount > 99
                                        ? '99+'
                                        : '$_unreadInboxCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _showPointsDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.amber, Colors.orange],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.diamond,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 6),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    widget.developerMode
                                        ? '∞'
                                        : '${widget.userPoints}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Add vertical space
                  const SizedBox(height: 12),
                  // Study Sets Content
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Column(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 0),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 6),
                                child: TabBar(
                                  controller: _tabController,
                                  labelColor:
                                      ThemeColors.getTabSelectedLabelColor(
                                          widget.currentTheme),
                                  labelStyle: TextStyle(
                                    fontWeight: widget.currentTheme == 'forest'
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                  ),
                                  unselectedLabelColor:
                                      ThemeColors.getTextColor(
                                              widget.currentTheme)
                                          .withOpacity(0.7),
                                  unselectedLabelStyle: TextStyle(
                                    fontWeight: widget.currentTheme == 'forest'
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                  indicator: BoxDecoration(
                                    color: ThemeColors.getTabPillColor(
                                        widget.currentTheme),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  indicatorPadding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 2),
                                  tabs: const [
                                    Tab(text: 'My Sets'),
                                    Tab(text: 'Browse'),
                                    Tab(text: 'Quick Play'),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: TabBarView(
                                  controller: _tabController,
                                  children: [
                                    _buildMyStudySets(),
                                    _buildBrowseTab(),
                                    _buildQuickPlayTab(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildMyStudySets() {
    final allSets = [..._studySets, ..._premadeStudySets];
    // When searching, only filter imported sets (premade) by query
    final bool searching = _importedSearchQuery.isNotEmpty;
    final List<Map<String, dynamic>> visibleSets = searching
        ? _premadeStudySets
            .where((s) => (s['name']?.toString().toLowerCase() ?? '')
                .contains(_importedSearchQuery.toLowerCase()))
            .toList()
        : allSets;

    if (visibleSets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 80,
              color: widget.currentTheme == 'beach'
                  ? ThemeColors.getTextColor('beach').withOpacity(0.5)
                  : Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                searching
                    ? (widget.currentTheme == 'halloween'
                        ? 'No cursed tomes found in the archives...'
                        : 'No imported sets match your search.')
                    : (widget.currentTheme == 'halloween'
                        ? 'Summon your first study set or discover ancient tomes!'
                        : 'Create your first study set or import a premade one!'),
                style: TextStyle(
                  fontSize: 16,
                  color: widget.currentTheme == 'beach'
                      ? ThemeColors.getTextColor('beach').withOpacity(0.5)
                      : Colors.white.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            Builder(builder: (context) {
              final bool isSpooky = widget.currentTheme == 'halloween';
              Widget browseButton = ElevatedButton.icon(
                onPressed: () {
                  _tabController.animateTo(1);
                },
                icon: const Icon(Icons.download),
                label: Text(
                    isSpooky ? 'Explore Ancient Tomes' : 'Browse Premade Sets'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isSpooky ? Colors.transparent : Colors.blueAccent,
                  shadowColor: isSpooky ? Colors.transparent : null,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              );
              if (isSpooky) {
                browseButton = Container(
                  decoration: BoxDecoration(
                    gradient: ThemeColors.getButtonGradient('halloween'),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: ThemeColors.getButtonShadows('halloween'),
                  ),
                  child: browseButton,
                );
              }
              return browseButton;
            }),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            controller: _importedSearchController,
            style: TextStyle(
              color: widget.currentTheme == 'beach'
                  ? ThemeColors.getTextColor('beach')
                  : Colors.white,
            ),
            decoration: InputDecoration(
              hintText: widget.currentTheme == 'halloween'
                  ? 'Search the haunted archives...'
                  : 'Search imported sets...',
              hintStyle: TextStyle(
                color: widget.currentTheme == 'beach'
                    ? ThemeColors.getTextColor('beach').withOpacity(0.6)
                    : Colors.white70,
              ),
              prefixIcon: Icon(Icons.search,
                  color: widget.currentTheme == 'beach'
                      ? ThemeColors.getTextColor('beach').withOpacity(0.8)
                      : Colors.white70),
              filled: true,
              fillColor: widget.currentTheme == 'beach'
                  ? Colors.white.withOpacity(0.9)
                  : Colors.white.withOpacity(0.08),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: widget.currentTheme == 'beach'
                      ? ThemeColors.getButtonColor('beach')
                      : Colors.blueAccent,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: visibleSets.length,
            itemBuilder: (BuildContext context, int index) {
              final studySet = visibleSets[index];
              final isImported =
                  _premadeStudySets.any((s) => s['id'] == studySet['id']);
              
              // Use questionCount from the set if available (for imported sets),
              // otherwise fetch from database
              final hasQuestionCount = studySet['questionCount'] != null;
              
              return FutureBuilder<int>(
                future: hasQuestionCount 
                    ? Future.value(studySet['questionCount'] as int)
                    : _dbHelper.getStudySetQuestionCount(studySet['id']),
                builder: (context, snapshot) {
                  final questionCount = snapshot.data ?? studySet['questionCount'] ?? 0;
                  final gradient = widget.currentTheme == 'beach'
                      ? ThemeColors.getBeachCardGradient()
                      : (ThemeColors.getCardGradient(widget.currentTheme,
                              variant: index) ??
                          LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF2A2D3E).withOpacity(0.9),
                              const Color(0xFF1D1E33),
                            ],
                          ));
                  final Border? cardBorder = widget.currentTheme == 'halloween'
                      ? Border.all(
                          color: ThemeColors.getAccentColor('halloween')
                              .withOpacity(0.4),
                          width: 1.2,
                        )
                      : null;
                  final List<BoxShadow> cardShadows =
                      widget.currentTheme == 'halloween'
                          ? ThemeColors.getButtonShadows('halloween')
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    elevation: 10,
                    shadowColor: Colors.transparent,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: gradient,
                        borderRadius: BorderRadius.circular(16),
                        border: cardBorder,
                        boxShadow: cardShadows,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: widget.currentTheme == 'halloween'
                                        ? const Color(0xFF2A0538)
                                        : Colors.blueAccent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    _getSubjectIcon(studySet['name']),
                                    color: widget.currentTheme == 'halloween'
                                        ? ThemeColors.getAccentColor(
                                            'halloween')
                                        : Colors.blueAccent,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        studySet['name'],
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: ThemeColors.getTextColor(
                                              widget.currentTheme),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        studySet['description'] ?? '',
                                        style: TextStyle(
                                          color: ThemeColors.getTextColor(
                                                  widget.currentTheme)
                                              .withOpacity(0.7),
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '$questionCount question${questionCount == 1 ? '' : 's'}',
                                        style: TextStyle(
                                          color: ThemeColors.getTextColor(
                                                  widget.currentTheme)
                                              .withOpacity(0.8),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isImported)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      'Imported',
                                      style: TextStyle(
                                        color: widget.currentTheme == 'beach'
                                            ? ThemeColors.getTextColor('beach')
                                                .withOpacity(0.7)
                                            : Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                // Edit button moved to top right, only pencil icon
                                if (!isImported) ...[
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () => _editStudySet(studySet),
                                    icon: const Icon(Icons.edit, size: 20),
                                    style: IconButton.styleFrom(
                                      backgroundColor:
                                          Colors.orange.withOpacity(0.8),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.all(8),
                                    ),
                                    tooltip: 'Edit',
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Created: ${_formatDate(studySet['created_at'])}',
                              style: TextStyle(
                                color: widget.currentTheme == 'beach'
                                    ? ThemeColors.getTextColor('beach')
                                        .withOpacity(0.5)
                                    : Colors.white.withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      _deleteStudySet(studySet['id']),
                                  icon: const Icon(Icons.delete, size: 18),
                                  label: const Text('Delete'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.redAccent.withOpacity(0.8),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Builder(builder: (context) {
                                  final isSpooky =
                                      widget.currentTheme == 'halloween';
                                  Widget button = ElevatedButton.icon(
                                    onPressed: () => _startPractice(studySet),
                                    icon:
                                        const Icon(Icons.play_arrow, size: 18),
                                    label: Text(
                                        isSpooky ? 'Begin Ritual' : 'Practice'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isSpooky
                                          ? Colors.transparent
                                          : widget.currentTheme == 'beach'
                                              ? ThemeColors.getTropicalGreen(
                                                      'beach')
                                                  .withOpacity(0.8)
                                              : Colors.green.withOpacity(0.8),
                                      shadowColor:
                                          isSpooky ? Colors.transparent : null,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                  if (isSpooky) {
                                    button = Container(
                                      decoration: BoxDecoration(
                                        gradient: ThemeColors.getButtonGradient(
                                            'halloween'),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: ThemeColors.getButtonShadows(
                                            'halloween'),
                                      ),
                                      child: button,
                                    );
                                  }
                                  return button;
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBrowseTab() {
    return MCQManager(
      username: widget.username,
      onSetImported: _loadStudySets,
      studySet: {}, // Empty map for browse tab
      currentTheme: widget.currentTheme,
    );
  }

  Widget _buildQuickPlayTab() {
    return HomePage(
      username: widget.username,
      currentTheme: widget.currentTheme,
      onPointsUpdated: (newPoints) {
        widget.onPointsUpdated(newPoints);
      },
    );
  }

  // ignore: unused_element
  Widget _buildQuickPlay() {
    // This method has been removed - quiz configuration moved to home_page.dart
    return Container();
  }

  IconData _getSubjectIcon(String setName) {
    if (setName.toLowerCase().contains('math')) {
      return Icons.calculate;
    } else if (setName.toLowerCase().contains('physics')) {
      return Icons.science;
    } else if (setName.toLowerCase().contains('computer')) {
      return Icons.computer;
    } else if (setName.toLowerCase().contains('chemistry')) {
      return Icons.science;
    } else {
      return Icons.school;
    }
  }

  // ignore: unused_element
  Widget _buildQuizArea(
    Map<String, dynamic> question,
    int currentIndex,
    int totalQuestions,
    String? selectedAnswer,
    bool showAnswer,
    VoidCallback submitAnswer,
    VoidCallback nextQuestion,
    VoidCallback selectOption1,
    VoidCallback selectOption2,
    VoidCallback selectOption3,
    VoidCallback selectOption4,
  ) {
    return Builder(
      builder: (BuildContext context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Question ${currentIndex + 1}/$totalQuestions',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (currentIndex + 1) / totalQuestions,
                backgroundColor: Colors.white24,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 32),

            // Question
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Text(
                question['question'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),

            // Answer options
            Expanded(
              child: ListView.builder(
                itemCount: question['options'].length,
                itemBuilder: (context, index) {
                  final option = question['options'][index];
                  final isSelected = selectedAnswer == option;
                  final isCorrect =
                      showAnswer && option == question['correct_answer'];
                  final isWrong = showAnswer && isSelected && !isCorrect;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? Colors.green.withOpacity(0.2)
                            : isWrong
                                ? Colors.red.withOpacity(0.2)
                                : isSelected
                                    ? Colors.blueAccent.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCorrect
                              ? Colors.green
                              : isWrong
                                  ? Colors.red
                                  : isSelected
                                      ? Colors.blueAccent
                                      : Colors.white.withOpacity(0.1),
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        title: Text(
                          option,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: showAnswer
                            ? Icon(
                                isCorrect
                                    ? Icons.check_circle
                                    : isWrong
                                        ? Icons.cancel
                                        : null,
                                color: isCorrect ? Colors.green : Colors.red,
                              )
                            : null,
                        onTap: showAnswer
                            ? null
                            : () {
                                switch (index) {
                                  case 0:
                                    selectOption1();
                                    break;
                                  case 1:
                                    selectOption2();
                                    break;
                                  case 2:
                                    selectOption3();
                                    break;
                                  case 3:
                                    selectOption4();
                                    break;
                                }
                              },
                      ),
                    ),
                  );
                },
              ),
            ),

            // Navigation Buttons
            if (!showAnswer && selectedAnswer != null)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: submitAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Submit Answer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
            else if (showAnswer)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentIndex < totalQuestions - 1
                          ? Colors.blueAccent
                          : Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      currentIndex < totalQuestions - 1
                          ? 'Next Question'
                          : 'Finish Quiz',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ignore: unused_element
  Widget _buildScoreSummary(
    List<bool> answeredCorrectly,
    int totalQuestions,
    String subject,
    VoidCallback restartQuiz,
    VoidCallback returnToConfig,
  ) {
    int correctAnswers = answeredCorrectly.where((correct) => correct).length;
    double accuracy = (correctAnswers / totalQuestions) * 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade800.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Quiz Completed!",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Your Score:",
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "$correctAnswers / $totalQuestions",
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Accuracy: ${accuracy.toStringAsFixed(1)}%",
            style: TextStyle(
              fontSize: 20,
              color: accuracy > 70
                  ? Colors.green
                  : accuracy > 40
                      ? Colors.orange
                      : Colors.red,
            ),
          ),
          const SizedBox(height: 30),
          Column(
            children: [
              // Enhanced Retry Quiz Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667eea).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: restartQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  label: const Text(
                    "Try Again",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Enhanced New Quiz Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFf093fb).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: returnToConfig,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(
                    Icons.quiz_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  label: const Text(
                    "New Quiz",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Enhanced Return Home Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF11998e).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(this.context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(
                    Icons.home_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  label: const Text(
                    "Return Home",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return '';
    try {
      final String s = dateValue is String ? dateValue : dateValue.toString();
      if (s.isEmpty) return '';
      final date = DateTime.parse(s);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return '';
    }
  }

  void _startPractice(Map<String, dynamic> studySet) {
    // Validate studySet has a name
    if (!studySet.containsKey('name')) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(
          content: Text('Invalid study set. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Check if this is exactly AP Computer Science A
    String studySetName = studySet['name']?.toString() ?? '';
    bool isSATReadingWriting = studySetName == 'SAT Reading & Writing';
    // bool isFinancialLiteracy = studySetName == 'Financial Literacy'; // Disabled for now
    bool isRobotics = studySetName.startsWith('Robotics');

    final Map<String, List<APCourseChapter>> apCourseChapters = {
      'AP Calculus AB': apCalculusABChapters,
      'AP Calculus BC': apCalculusBCChapters,
      'AP Statistics': apStatisticsChapters,
      'AP Physics 1': apPhysics1Chapters,
      'AP Physics 2': apPhysics2Chapters,
      'AP Chemistry': apChemistryChapters,
      'AP Computer Science A': apComputerScienceAChapters,
      'AP Computer Science Principles': apComputerSciencePrinciplesChapters,
      'AP Environmental Science': apEnvironmentalScienceChapters,
      'AP Biology': apBiologyChapters,
      'AP Physics C: Mechanics': apPhysicsCMechanicsChapters,
      'AP English Literature': apEnglishLiteratureChapters,
      'AP US History': apUSHistoryChapters,
      'AP World History': apWorldHistoryChapters,
    };

    final apChapters = apCourseChapters[studySetName];

    if (apChapters != null) {
      // Show chapter selection for AP courses
      Navigator.push(
        this.context,
        MaterialPageRoute(
          builder: (context) => APCourseChapterSelectionScreen(
            studySet: studySet,
            username: widget.username,
            currentTheme: widget.currentTheme,
            courseName: studySetName,
            chapters: apChapters,
          ),
        ),
      ).then((_) {
        // Refresh points when returning from practice
        _loadUserData();
      });
    } else if (isSATReadingWriting) {
      // Show topic selection for SAT Reading & Writing
      _showSATTopicSelection(studySet);
    // Financial Literacy disabled for now
    // } else if (isFinancialLiteracy) {
    //   // Show the dedicated Financial Literacy chooser
    //   Navigator.push(
    //     this.context,
    //     MaterialPageRoute(
    //       builder: (context) => FinancialLiteracyScreen(
    //         currentTheme: widget.currentTheme,
    //         onTextBook: () {
    //           Navigator.of(context).pop();
    //           Navigator.push(
    //             this.context,
    //             MaterialPageRoute(
    //               builder: (context) => FinancialTextbookScreen(
    //                 currentTheme: widget.currentTheme,
    //               ),
    //             ),
    //           );
    //         },
    //         onQuestionBank: () {
    //           Navigator.of(context).pop();
    //           Navigator.push(
    //             this.context,
    //             MaterialPageRoute(
    //               builder: (context) => PracticeModeScreen(
    //                 studySet: studySet,
    //                 username: widget.username,
    //                 currentTheme: widget.currentTheme,
    //               ),
    //             ),
    //           ).then((_) {
    //             _loadUserData();
    //           });
    //         },
    //         onPortfolio: () {
    //           Navigator.of(context).pop();
    //           Navigator.push(
    //             this.context,
    //             MaterialPageRoute(
    //               builder: (context) => PortfolioCompaniesScreen(
    //                 currentTheme: widget.currentTheme,
    //               ),
    //             ),
    //           );
    //         },
    //       ),
    //     ),
    //   ).then((_) {
    //     // Refresh points when returning from practice
    //     _loadUserData();
    //   });
    } else if (isRobotics) {
      // Show the dedicated Robotics quiz screen
      Navigator.push(
        this.context,
        MaterialPageRoute(
          builder: (context) => RoboticsScreen(
            username: widget.username,
            currentTheme: widget.currentTheme,
            onQuizComplete: () {
              _loadUserData();
            },
            onMcqSelected: () {
              Navigator.push(
                this.context,
                MaterialPageRoute(
                  builder: (context) => PracticeModeScreen(
                    studySet: studySet,
                    username: widget.username,
                    currentTheme: widget.currentTheme,
                  ),
                ),
              ).then((_) {
                _loadUserData();
              });
            },
          ),
        ),
      ).then((_) {
        // Refresh points when returning from practice
        _loadUserData();
      });
    } else {
      // Go directly to MCQ practice for all other courses
      Navigator.push(
        this.context,
        MaterialPageRoute(
          builder: (context) => PracticeModeScreen(
            studySet: studySet,
            username: widget.username,
            currentTheme: widget.currentTheme,
          ),
        ),
      ).then((_) {
        // Refresh points when returning from practice
        _loadUserData();
      });
    }
  }

  void _showSATTopicSelection(Map<String, dynamic> studySet) {
    showDialog<void>(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.menu_book,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Choose SAT Topic',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: const Text(
            'Which SAT Reading & Writing topic would you like to practice?\n\n'
            '• Information and Ideas: Main ideas, supporting details, and text analysis\n'
            '• Craft and Structure: Author\'s purpose, text structure, and rhetorical devices\n'
            '• Expression of Ideas: Writing style, word choice, and sentence structure\n'
            '• Standard English Conventions: Grammar, punctuation, and usage',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _startSATTopicPractice(
                              studySet, 'Information and Ideas');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF667eea),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Information and Ideas',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _startSATTopicPractice(
                              studySet, 'Craft and Structure');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF764ba2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Craft and Structure',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _startSATTopicPractice(
                              studySet, 'Expression of Ideas');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF43e97b),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Expression of Ideas',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _startSATTopicPractice(
                              studySet, 'Standard English Conventions');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFfa709a),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Standard English Conventions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _startSATTopicPractice(Map<String, dynamic> studySet, String topic) {
    // Navigate to practice mode screen with topic information
    Navigator.push(
      this.context,
      MaterialPageRoute(
        builder: (context) => PracticeModeScreen(
          studySet: studySet,
          username: widget.username,
          currentTheme: widget.currentTheme,
          satTopic: topic, // Pass the topic information
        ),
      ),
    ).then((_) {
      // Refresh points when returning from practice
      _loadUserData();
    });
  }

  void _deleteStudySet(int studySetId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: ThemeColors.getCardColor(widget.currentTheme),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Delete Study Set',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this study set?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _dbHelper.removeImportedSet(widget.username, studySetId);
              Navigator.pop(dialogContext);
              _loadStudySets();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editStudySet(Map<String, dynamic> studySet) {
    Navigator.push(
      this.context,
      MaterialPageRoute(
        builder: (context) => StudySetEditScreen(
          studySet: studySet,
          username: widget.username,
          currentTheme: widget.currentTheme,
          onStudySetUpdated: _loadStudySets,
        ),
      ),
    );
  }
}

class ProfileTab extends StatefulWidget {
  final String username;
  final int userPoints;
  final String currentTheme;

  const ProfileTab({
    super.key,
    required this.username,
    required this.userPoints,
    required this.currentTheme,
  });

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab>
    with AutomaticKeepAliveClientMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, dynamic>? _userStats;
  File? _profileImage;
  // ignore: unused_field
  File? _userProfileImage; // Add profile image state
  List<String> _friendsList = [];
  // ignore: unused_field
  List<Map<String, dynamic>> _friendRequests = [];
  TextEditingController _friendSearchController = TextEditingController();
  // ignore: unused_field
  bool _isLoadingFriends = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
    _loadProfileImage();
    _loadUserProfileImage(); // Load profile image on init
    _loadFriends();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh profile image when screen becomes visible
    _refreshUserProfileImage();
  }

  Future<void> _loadUserStats() async {
    final userSets = await _dbHelper.getUserStudySets(widget.username);
    setState(() {
      _userStats = {
        'studySetsCreated': userSets.length,
        'totalQuestions': 0, // You can implement this if needed
        'averageScore': 0, // You can implement this if needed
      };
    });
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_${widget.username}');
    if (path != null && path.isNotEmpty) {
      setState(() {
        _profileImage = File(path);
      });
    }
  }

  Future<void> _loadUserProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_${widget.username}');
    if (path != null && path.isNotEmpty) {
      setState(() {
        _userProfileImage = File(path);
      });
    }
  }

  void _refreshUserProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_${widget.username}');
    setState(() {
      _userProfileImage = path != null && path.isNotEmpty ? File(path) : null;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await showModalBottomSheet<XFile?>(
      context: this.context,
      builder: (BuildContext context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () async {
                final photo =
                    await picker.pickImage(source: ImageSource.camera);
                Navigator.pop(context, photo);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () async {
                final gallery =
                    await picker.pickImage(source: ImageSource.gallery);
                Navigator.pop(context, gallery);
              },
            ),
          ],
        ),
      ),
    );
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'profile_image_${widget.username}', pickedFile.path);
    }
  }

  Future<void> _loadFriends() async {
    if (!mounted) return;
    setState(() => _isLoadingFriends = true);
    try {
      final friends = await _dbHelper.getFriends(widget.username);
      final requests = await _dbHelper.getFriendRequests(widget.username);
      if (mounted) {
        setState(() {
          _friendsList = friends;
          _friendRequests = requests;
          _isLoadingFriends = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading friends: $e');
      if (mounted) {
        setState(() => _isLoadingFriends = false);
      }
    }
  }

  Future<void> _sendFriendRequest(String toUsername) async {
    // Validate recipient exists first
    final recipientExists = await _dbHelper.usernameExists(toUsername);
    if (!recipientExists) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User "$toUsername" does not exist')),
        );
      }
      return;
    }

    final success =
        await _dbHelper.sendFriendRequest(widget.username, toUsername);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend request sent to $toUsername')),
      );
      _friendSearchController.clear();
      _loadFriends();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send friend request')),
      );
    }
  }

  // ignore: unused_element
  Future<void> _acceptFriendRequest(String fromUsername) async {
    final success =
        await _dbHelper.acceptFriendRequest(widget.username, fromUsername);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added $fromUsername as friend')),
      );
      _loadFriends();
    }
  }

  // ignore: unused_element
  Future<void> _declineFriendRequest(String fromUsername) async {
    final success =
        await _dbHelper.declineFriendRequest(widget.username, fromUsername);
    if (success && mounted) {
      _loadFriends();
    }
  }

  @override
  void dispose() {
    _friendSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Stack(
        children: [
          getBackgroundForTheme(widget.currentTheme),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Profile Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4facfe).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                backgroundImage: _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : null,
                                child: _profileImage == null
                                    ? Text(
                                        widget.username.isNotEmpty
                                            ? widget.username[0].toUpperCase()
                                            : 'U',
                                        style: const TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 4,
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: const Icon(Icons.camera_alt,
                                        color: Colors.white, size: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.username,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.diamond,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  '${widget.userPoints}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Stats Section
                    if (_userStats != null) ...[
                      Card(
                        elevation: 4,
                        color: Colors.white.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Statistics',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem(
                                    'Study Sets',
                                    '${_userStats!['studySetsCreated']}',
                                    Icons.school,
                                    Colors.blue,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: _buildStatItem(
                                      'Points',
                                      widget.userPoints.toString(),
                                      Icons.diamond,
                                      Colors.amber,
                                    ),
                                  ),
                                  _buildStatItem(
                                    'Current Theme',
                                    widget.currentTheme.toUpperCase(),
                                    Icons.palette,
                                    Colors.purple,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Friends Section
                    Card(
                      elevation: 4,
                      color: Colors.white.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Friends',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            // Add Friend Input
                            TextFormField(
                              controller: _friendSearchController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Search username...',
                                hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.6)),
                                prefixIcon: const Icon(Icons.person_add,
                                    color: Colors.white70),
                                suffixIcon: _friendSearchController.text
                                        .isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.check,
                                            color: Colors.greenAccent),
                                        onPressed: () {
                                          if (_friendSearchController
                                              .text.isNotEmpty) {
                                            _sendFriendRequest(
                                                _friendSearchController.text);
                                          }
                                        },
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: Colors.white24),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: Colors.white24),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: Colors.blueAccent),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                            const SizedBox(height: 16),
                            // Friends List
                            const Text(
                              'Your Friends',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_friendsList.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  'No friends yet. Add one using the search box above.',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            else
                              ..._friendsList.map((friend) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => FriendProfileScreen(
                                            friendUsername: friend,
                                            currentTheme: widget.currentTheme,
                                            currentUser: widget.username,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color: Colors.white12, width: 1),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.person_outline,
                                            color: Colors.blueAccent,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              friend,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          const Icon(
                                            Icons.chevron_right,
                                            color: Colors.white54,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Account Settings
                    Card(
                      elevation: 4,
                      color: Colors.white.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
                              child: Text(
                                'Account Settings',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            _buildSettingsItem(
                              'Change Password',
                              Icons.lock,
                              Colors.orange,
                              () => _showChangePasswordDialog(),
                            ),
                            const Divider(
                                color: Colors.white24,
                                indent: 20,
                                endIndent: 20),
                            _buildSettingsItem(
                              'About App',
                              Icons.info,
                              Colors.blue,
                              () => _showAboutDialog(),
                            ),
                            const Divider(
                                color: Colors.white24,
                                indent: 20,
                                endIndent: 20),
                            _buildSettingsItem(
                              'Share App',
                              Icons.share,
                              Colors.green,
                              () => _shareApp(),
                            ),
                            const Divider(
                                color: Colors.white24,
                                indent: 20,
                                endIndent: 20),
                            _buildSettingsItem(
                              'Sign Out',
                              Icons.logout,
                              Colors.red,
                              () => _showSignOutDialog(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
      onTap: onTap,
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: this.context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.currentTheme == 'beach'
            ? ThemeColors.getCardColor('beach')
            : const Color(0xFF2A2D3E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Change Password',
          style: TextStyle(
            color: ThemeColors.getTextColor(widget.currentTheme),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              style: TextStyle(
                color: ThemeColors.getTextColor(widget.currentTheme),
              ),
              decoration: InputDecoration(
                labelText: 'Current Password',
                labelStyle: TextStyle(
                  color: ThemeColors.getTextColor(widget.currentTheme).withOpacity(0.7),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: ThemeColors.getAccentColor(widget.currentTheme),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: ThemeColors.getAccentColor(widget.currentTheme),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              style: TextStyle(
                color: ThemeColors.getTextColor(widget.currentTheme),
              ),
              decoration: InputDecoration(
                labelText: 'New Password',
                labelStyle: TextStyle(
                  color: ThemeColors.getTextColor(widget.currentTheme).withOpacity(0.7),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: ThemeColors.getAccentColor(widget.currentTheme),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: ThemeColors.getAccentColor(widget.currentTheme),
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              style: TextStyle(
                color: ThemeColors.getTextColor(widget.currentTheme),
              ),
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                labelStyle: TextStyle(
                  color: ThemeColors.getTextColor(widget.currentTheme).withOpacity(0.7),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: ThemeColors.getAccentColor(widget.currentTheme),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: ThemeColors.getAccentColor(widget.currentTheme),
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: ThemeColors.getAccentColor(widget.currentTheme),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement password change logic
              Navigator.pop(context);
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(
                  content: const Text('Password change feature coming soon!'),
                  backgroundColor: ThemeColors.getAccentColor(widget.currentTheme),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.getAccentColor(widget.currentTheme),
            ),
            child: Text(
              'Change',
              style: TextStyle(
                color: widget.currentTheme == 'beach'
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: this.context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.currentTheme == 'beach'
            ? ThemeColors.getCardColor('beach')
            : const Color(0xFF2A2D3E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'About EduQuest',
          style: TextStyle(
            color: ThemeColors.getTextColor(widget.currentTheme),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'EduQuest v1.0.0',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ThemeColors.getTextColor(widget.currentTheme),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'A gamified learning platform designed to make education fun and engaging.',
              style: TextStyle(
                color: ThemeColors.getTextColor(widget.currentTheme),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Features:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ThemeColors.getTextColor(widget.currentTheme),
              ),
            ),
            Text(
              '• Create custom study sets',
              style: TextStyle(
                color: ThemeColors.getTextColor(widget.currentTheme),
              ),
            ),
            Text(
              '• Practice with interactive quizzes',
              style: TextStyle(
                color: ThemeColors.getTextColor(widget.currentTheme),
              ),
            ),
            Text(
              '• Earn points and unlock themes',
              style: TextStyle(
                color: ThemeColors.getTextColor(widget.currentTheme),
              ),
            ),
            Text(
              '• Track your learning progress',
              style: TextStyle(
                color: ThemeColors.getTextColor(widget.currentTheme),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                color: ThemeColors.getAccentColor(widget.currentTheme),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareApp() {
    Share.share(
        'Check out EduQuest - the fun way to learn! Download now and start your learning journey.');
  }

  void _showSignOutDialog() {
    showDialog(
      context: this.context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.currentTheme == 'beach'
            ? ThemeColors.getCardColor('beach')
            : const Color(0xFF2A2D3E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Sign Out',
          style: TextStyle(
            color: ThemeColors.getTextColor(widget.currentTheme),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: TextStyle(
            color: ThemeColors.getTextColor(widget.currentTheme),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: ThemeColors.getAccentColor(widget.currentTheme),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => SignInPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
            child: Text(
              'Sign Out',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StudySetCreationOptionsScreen extends StatelessWidget {
  final String username;
  final VoidCallback onStudySetCreated;
  final String currentTheme;

  const StudySetCreationOptionsScreen({
    super.key,
    required this.username,
    required this.onStudySetCreated,
    required this.currentTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Study Set',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1D1E33),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Stack(
        children: [
          getBackgroundForTheme(currentTheme),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose Creation Method',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'How would you like to build your set?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildOptionCard(
                          context,
                          'Import from Quizlet',
                          'Use a public Quizlet set URL',
                          Icons.link,
                          const [Color(0xFF16A085), Color(0xFF1ABC9C)],
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizletImportScreen(
                                username: username,
                                onStudySetCreated: onStudySetCreated,
                                currentTheme: currentTheme,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildOptionCard(
                          context,
                          'Import from Spreadsheet',
                          'Upload an Excel (.xlsx) file',
                          Icons.upload_file,
                          const [Color(0xFF2980B9), Color(0xFF3498DB)],
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SpreadsheetImportScreen(
                                username: username,
                                onStudySetCreated: onStudySetCreated,
                                currentTheme: currentTheme,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildOptionCard(
                          context,
                          'Create Questions Manually',
                          'Add questions one-by-one',
                          Icons.edit_note,
                          const [Color(0xFF8E44AD), Color(0xFF9B59B6)],
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ManualQuestionCreationScreen(
                                username: username,
                                onStudySetCreated: onStudySetCreated,
                                currentTheme: currentTheme,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    List<Color> colors,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PracticeModeScreen extends StatefulWidget {
  final Map<String, dynamic> studySet;
  final String username;
  final String currentTheme;
  final String? satTopic; // Optional parameter for SAT topics

  const PracticeModeScreen({
    super.key,
    required this.studySet,
    required this.username,
    required this.currentTheme,
    this.satTopic, // Make it optional
  });

  @override
  _PracticeModeScreenState createState() => _PracticeModeScreenState();
}

class _PracticeModeScreenState extends State<PracticeModeScreen>
    with AutomaticKeepAliveClientMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ChatBloc _chatBloc = ChatBloc();
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  List<Map<String, dynamic>> _questions = [];
  int _questionCount = 5;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String _selectedMode = 'classic';
  bool _showModeSelection = true;
  bool _showGameModeSelection = false;
  bool _showQuizArea = false;
  bool _showScoreSummary = false;
  bool _showChat = false;
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  String? _selectedAnswer;
  bool _showAnswer = false;
  File? _userProfileImage;

  // Derived flags
  bool get isRobotics {
    try {
      final name = widget.studySet['name']?.toString() ?? '';
      return name.startsWith('Robotics');
    } catch (_) {
      return false;
    }
  }

  // SAT question parsing variables
  String? _aiResponse;
  bool _showParseButton = false;

  // Points and powerups
  int _currentPoints = 0;
  Map<String, int> _userPowerups = {};
  // ignore: unused_field
  bool _isLoadingPowerups = false;

  // Powerup states
  bool _skipUsed = false;
  bool _fiftyFiftyUsed = false;
  bool _doublePointsActive = false;
  bool _extraTimeUsed = false;
  List<String> _removedOptions = [];
  String informationAndIdeasPrompt = '';
  
  // Progress tracking
  DateTime? _questionStartTime;
  List<Map<String, dynamic>> _sessionAttempts = []; // Track attempts in this session

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _loadUserProfileImage();
    _loadUserData();

    // Check if this is an SAT topic and open chat for "Information and Ideas"
    if (widget.satTopic == 'Information and Ideas') {
      // Load the prompt first, then open chat
      _loadSATPromptAndOpenChat();
    } else {
      // Load prompt for other cases
      _loadSATPrompt();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshUserProfileImage();
  }

  Future<void> _loadSATPrompt() async {
    try {
      final promptContent = await rootBundle
          .loadString('assets/SATPrompts/Information_and_Ideas_Prompt');
      setState(() {
        informationAndIdeasPrompt = promptContent;
      });
    } catch (e) {
      // If file loading fails, use a fallback prompt
      setState(() {
        informationAndIdeasPrompt =
            'You are an expert in SAT Reading and Writing Section. Please help me practice Information and Ideas questions for the SAT.';
      });
      print('Error loading SAT prompt: $e');
    }
  }

  Future<void> _loadSATPromptAndOpenChat() async {
    try {
      final promptContent = await rootBundle
          .loadString('assets/SATPrompts/Information_and_Ideas_Prompt');
      setState(() {
        informationAndIdeasPrompt = promptContent;
      });

      // Delay to ensure the screen is fully loaded, then open chat
      Future.delayed(const Duration(milliseconds: 500), () {
        _openQuestAIChat(informationAndIdeasPrompt);
      });
    } catch (e) {
      // If file loading fails, use a fallback prompt
      setState(() {
        informationAndIdeasPrompt =
            'You are an expert in SAT Reading and Writing Section. Please help me practice Information and Ideas questions for the SAT.';
      });
      print('Error loading SAT prompt: $e');

      // Still open chat with fallback prompt
      Future.delayed(const Duration(milliseconds: 500), () {
        _openQuestAIChat(informationAndIdeasPrompt);
      });
    }
  }

  void _openQuestAIChat(String initialMessage) {
    // Clear previous chat history
    _chatBloc.add(ChatClearHistoryEvent());

    // Show the chat interface (no loading state initially)
    setState(() {
      _showChat = true;
      _isLoading = false;
    });

    // Send the initial message to the chat
    _chatBloc
        .add(ChatGenerationNewTextMessageEvent(inputMessage: initialMessage));

    // Add listener for chat responses to parse SAT questions
    _chatBloc.stream.listen((state) {
      if (state is ChatSuccessState && state.messages.isNotEmpty) {
        final lastMessage = state.messages.last;
        if (lastMessage.role == "model") {
          // Check if this is an SAT Information and Ideas response
          if (widget.satTopic == 'Information and Ideas') {
            // Show a button to parse and display questions
            _showParseQuestionsButton(lastMessage.parts.first.text);
          }
        }
      } else if (state is ChatErrorState) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${state.message}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

    // Auto-scroll to bottom after a short delay to ensure the chat interface is rendered
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Function to show a button to parse questions after AI response
  void _showParseQuestionsButton(String aiResponse) {
    setState(() {
      _aiResponse = aiResponse; // Store the AI response
      _showParseButton = true; // Show the parse button
    });
  }

  // Function to parse SAT questions from AI response
  void _parseAndDisplaySATQuestions(String aiResponse) {
    try {
      print('=== START OF AI RESPONSE ===');
      print(aiResponse);
      print('=== END OF AI RESPONSE ===');
      print('Response length: ${aiResponse.length}');
      print('Contains %: ${aiResponse.contains('%')}');
      print('Contains [: ${aiResponse.contains('[')}');
      print('Contains ]: ${aiResponse.contains(']')}');

      List<Map<String, dynamic>> parsedQuestions = [];

      // Split the AI response into sections by looking for bracketed content
      RegExp questionPattern = RegExp(r'\[([^\]]+)\]');
      Iterable<RegExpMatch> matches = questionPattern.allMatches(aiResponse);

      for (RegExpMatch match in matches) {
        String bracketContent = match.group(1) ?? '';
        print('Found bracket content: $bracketContent');

        // Split the bracket content by % to see how many parts we have
        List<String> bracketParts = bracketContent.split('%');
        print('Bracket parts: $bracketParts (${bracketParts.length} parts)');

        // We expect the format: [question%choiceA%choiceB%choiceC%choiceD%correct_letter%explanation]
        // So we need to find the question text that comes BEFORE the brackets
        if (bracketParts.length >= 6) {
          // Find the text before these brackets
          String textBeforeBrackets =
              aiResponse.substring(0, match.start).trim();
          print('Text before brackets: "$textBeforeBrackets"');

          // Look for the last question in the text before brackets
          String questionText = '';
          String passage = '';

          // Split by lines and find the question
          List<String> lines = textBeforeBrackets.split('\n');
          for (int i = lines.length - 1; i >= 0; i--) {
            String line = lines[i].trim();
            if (line.isNotEmpty) {
              // Check if this line looks like a question
              if (line.contains('Which') ||
                  line.contains('What') ||
                  line.contains('How') ||
                  line.contains('The author') ||
                  line.contains('purpose is to') ||
                  line.contains('most directly') ||
                  line.contains('best states') ||
                  line.contains('suggests about') ||
                  line.endsWith('?')) {
                questionText = line;
                // Everything before this line is the passage
                if (i > 0) {
                  passage = lines.sublist(0, i).join('\n').trim();
                }
                break;
              }
            }
          }

          // If we couldn't find a question, use the last non-empty line
          if (questionText.isEmpty) {
            for (int i = lines.length - 1; i >= 0; i--) {
              if (lines[i].trim().isNotEmpty) {
                questionText = lines[i].trim();
                if (i > 0) {
                  passage = lines.sublist(0, i).join('\n').trim();
                }
                break;
              }
            }
          }

          print('Extracted question: "$questionText"');
          print('Extracted passage: "$passage"');

          // Now parse the bracket content - expecting 6 parts
          if (bracketParts.length >= 6) {
            String passageAndQuestion = bracketParts[0].trim();
            String optionA = bracketParts[1].trim();
            String optionB = bracketParts[2].trim();
            String optionC = bracketParts[3].trim();
            String optionD = bracketParts[4].trim();
            String correctLetter = bracketParts[5].trim().toUpperCase();
            String explanation = bracketParts.length > 6
                ? bracketParts.sublist(6).join('%').trim()
                : '';

            // Print all 6 parts to debug console
            print('=== PARSED 6 PARTS ===');
            print('1. Passage + Question: "$passageAndQuestion"');
            print('2. Choice A: "$optionA"');
            print('3. Choice B: "$optionB"');
            print('4. Choice C: "$optionC"');
            print('5. Choice D: "$optionD"');
            print('6. Answer Letter: "$correctLetter"');
            print('7. Explanation: "$explanation"');
            print('=== END PARSED PARTS ===');

            // Map the correct letter to the actual answer text
            String correctAnswer;
            switch (correctLetter) {
              case 'A':
                correctAnswer = optionA;
                break;
              case 'B':
                correctAnswer = optionB;
                break;
              case 'C':
                correctAnswer = optionC;
                break;
              case 'D':
                correctAnswer = optionD;
                break;
              default:
                correctAnswer = optionA;
                print(
                    'Unknown correct letter: $correctLetter, defaulting to A');
            }

            // Create the question object
            Map<String, dynamic> questionObj = {
              'question_text': optionA, // The actual question is now Choice A
              'passage':
                  passageAndQuestion, // The first part contains passage + question
              'options': '$optionA|$optionB|$optionC|$optionD',
              'correct_answer': correctAnswer,
              'correct_letter': correctLetter,
              'explanation': explanation,
            };

            parsedQuestions.add(questionObj);
            print(
                'Successfully parsed SAT question: ${questionObj['question_text']}');
            print('With passage: ${questionObj['passage']}');
          }
        }
      }

      // If no questions found with regex, try line-by-line parsing
      if (parsedQuestions.isEmpty) {
        print('No questions found with regex, trying line-by-line parsing');
        List<String> lines = aiResponse.split('\n');

        for (String line in lines) {
          String trimmedLine = line.trim();
          if (trimmedLine.startsWith('[') && trimmedLine.endsWith(']')) {
            // Parse the line directly
            String content = trimmedLine.substring(1, trimmedLine.length - 1);
            List<String> parts = content.split('%');

            if (parts.length >= 6) {
              String passageAndQuestion = parts[0].trim();
              String optionA = parts[1].trim();
              String optionB = parts[2].trim();
              String optionC = parts[3].trim();
              String optionD = parts[4].trim();
              String correctLetter = parts[5].trim().toUpperCase();
              String explanation =
                  parts.length > 6 ? parts.sublist(6).join('%').trim() : '';

              // Print all 6 parts to debug console
              print('=== FALLBACK PARSED 6 PARTS ===');
              print('1. Passage + Question: "$passageAndQuestion"');
              print('2. Choice A: "$optionA"');
              print('3. Choice B: "$optionB"');
              print('4. Choice C: "$optionC"');
              print('5. Choice D: "$optionD"');
              print('6. Answer Letter: "$correctLetter"');
              print('7. Explanation: "$explanation"');
              print('=== END FALLBACK PARSED PARTS ===');

              // Map the correct letter to the actual answer text
              String correctAnswer;
              switch (correctLetter) {
                case 'A':
                  correctAnswer = optionA;
                  break;
                case 'B':
                  correctAnswer = optionB;
                  break;
                case 'C':
                  correctAnswer = optionC;
                  break;
                case 'D':
                  correctAnswer = optionD;
                  break;
                default:
                  correctAnswer = optionA;
                  print(
                      'Unknown correct letter: $correctLetter, defaulting to A');
              }

              // Create the question object
              Map<String, dynamic> questionObj = {
                'question_text': optionA, // The actual question is now Choice A
                'passage':
                    passageAndQuestion, // The first part contains passage + question
                'options': '$optionA|$optionB|$optionC|$optionD',
                'correct_answer': correctAnswer,
                'correct_letter': correctLetter,
                'explanation': explanation,
              };

              parsedQuestions.add(questionObj);
              print(
                  'Successfully parsed SAT question from bracketed line: ${questionObj['question_text']}');
            }
          }
        }
      }

      // If still no questions found, try to find any text with % separators
      if (parsedQuestions.isEmpty) {
        print(
            'Still no questions found, trying to find any text with % separators');
        List<String> lines = aiResponse.split('\n');

        for (String line in lines) {
          String trimmedLine = line.trim();
          // Look for any line that contains % separators and has enough parts
          if (trimmedLine.contains('%')) {
            List<String> parts = trimmedLine.split('%');
            if (parts.length >= 6) {
              String passageAndQuestion = parts[0].trim();
              String optionA = parts[1].trim();
              String optionB = parts[2].trim();
              String optionC = parts[3].trim();
              String optionD = parts[4].trim();
              String correctLetter = parts[5].trim().toUpperCase();
              String explanation =
                  parts.length > 6 ? parts.sublist(6).join('%').trim() : '';

              // Print all 6 parts to debug console
              print('=== FINAL FALLBACK PARSED 6 PARTS ===');
              print('1. Passage + Question: "$passageAndQuestion"');
              print('2. Choice A: "$optionA"');
              print('3. Choice B: "$optionB"');
              print('4. Choice C: "$optionC"');
              print('5. Choice D: "$optionD"');
              print('6. Answer Letter: "$correctLetter"');
              print('7. Explanation: "$explanation"');
              print('=== END FINAL FALLBACK PARSED PARTS ===');

              // Map the correct letter to the actual answer text
              String correctAnswer;
              switch (correctLetter) {
                case 'A':
                  correctAnswer = optionA;
                  break;
                case 'B':
                  correctAnswer = optionB;
                  break;
                case 'C':
                  correctAnswer = optionC;
                  break;
                case 'D':
                  correctAnswer = optionD;
                  break;
                default:
                  correctAnswer = optionA;
                  print(
                      'Unknown correct letter: $correctLetter, defaulting to A');
              }

              // Create the question object
              Map<String, dynamic> questionObj = {
                'question_text': optionA, // The actual question is now Choice A
                'passage':
                    passageAndQuestion, // The first part contains passage + question
                'options': '$optionA|$optionB|$optionC|$optionD',
                'correct_answer': correctAnswer,
                'correct_letter': correctLetter,
                'explanation': explanation,
              };

              parsedQuestions.add(questionObj);
              print(
                  'Successfully parsed SAT question from line with % separators: ${questionObj['question_text']}');
            }
          }
        }
      }

      if (parsedQuestions.isNotEmpty) {
        setState(() {
          _questions = parsedQuestions;
          _showQuizArea = true;
          _showChat = false; // Hide chat and show quiz
          _currentQuestionIndex = 0;
          _selectedAnswer = null;
          _showAnswer = false;
          _isLoading = false; // Stop loading indicator
          _showParseButton = false; // Hide parse button
          _aiResponse = null; // Clear AI response
          // Initialize question timer and session tracking
          _questionStartTime = DateTime.now();
          _sessionAttempts = [];
        });

        print('Successfully loaded ${parsedQuestions.length} SAT questions');

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Successfully loaded ${parsedQuestions.length} SAT questions!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        print('No SAT questions found in AI response');
        setState(() {
          _isLoading = false;
          _showParseButton = false; // Hide parse button
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('No questions found in AI response. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error parsing SAT questions: $e');
      setState(() {
        _isLoading = false;
        _showParseButton = false; // Hide parse button
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error parsing questions: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _chatController.dispose();
    _chatScrollController.dispose();
    _chatBloc.close();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      List<Map<String, dynamic>> questions;
      
      // Check if studySet has questions directly (from imported sets)
      if (widget.studySet.containsKey('questions') && widget.studySet['questions'] != null) {
        // Convert the questions from the studySet
        final rawQuestions = widget.studySet['questions'] as List;
        questions = rawQuestions.map((q) {
          if (q is Map<String, dynamic>) {
            return Map<String, dynamic>.from(q);
          } else if (q is Map) {
            return Map<String, dynamic>.from(q.cast<String, dynamic>());
          }
          return <String, dynamic>{};
        }).toList();
      } else if (widget.studySet.containsKey('id') && widget.studySet['id'] != null) {
        // Try to get questions from database using id
        questions = await _dbHelper.getStudySetQuestions(widget.studySet['id']);
      } else {
        throw Exception('Study set has no questions or id');
      }
      
      if (questions.isEmpty) {
        throw Exception('No questions available for this study set');
      }

      // Create a deep copy of questions to make them mutable
      final shuffledQuestions = questions.map((question) {
        return Map<String, dynamic>.from(question);
      }).toList();

      // Randomize the questions
      shuffledQuestions.shuffle();

      // Randomize the options for each question to prevent answer always being A
      for (var question in shuffledQuestions) {
        // Normalize field names - handle both 'question_text'/'question' and 'correct_answer'/'correctAnswer'
        if (question.containsKey('question') && !question.containsKey('question_text')) {
          question['question_text'] = question['question'];
        }
        if (question.containsKey('correctAnswer') && !question.containsKey('correct_answer')) {
          question['correct_answer'] = question['correctAnswer'];
        }
        
        // Handle both 'options' and 'correct_answer' or 'correctAnswer' keys
        final optionsKey = question.containsKey('options') ? 'options' : null;
        // Also handle 'correct' as an index - convert to 'correct_answer'
        if (question.containsKey('correct') && !question.containsKey('correct_answer') && !question.containsKey('correctAnswer')) {
          // 'correct' is an index, need to get the actual answer from options
          final options = question['options'];
          if (options is List && options.isNotEmpty) {
            final correctIndex = question['correct'] as int?;
            if (correctIndex != null && correctIndex >= 0 && correctIndex < options.length) {
              question['correct_answer'] = options[correctIndex].toString();
            }
          }
        }
        final correctAnswerKey = question.containsKey('correct_answer') ? 'correct_answer' :
                                 question.containsKey('correctAnswer') ? 'correctAnswer' : null;
        
        if (optionsKey == null || correctAnswerKey == null) {
          print('WARNING: Question missing options or correct answer: $question');
          continue;
        }
        
        // Ensure question_text exists
        if (!question.containsKey('question_text') || question['question_text'] == null) {
          question['question_text'] = 'Question text missing';
        }
        
        // Handle options - could be String or List
        List<String> options;
        if (question[optionsKey] is String) {
          options = (question[optionsKey] as String).split('|');
        } else if (question[optionsKey] is List) {
          options = (question[optionsKey] as List).map((e) => e.toString()).toList();
        } else {
          print('WARNING: Invalid options format: ${question[optionsKey]}');
          continue;
        }
        
        final correctAnswer = question[correctAnswerKey]?.toString() ?? options.first;

        // Create a list of option indices
        List<int> optionIndices = List.generate(options.length, (i) => i);
        optionIndices.shuffle();

        // Reorder options and update correct answer index
        List<String> shuffledOptions = [];
        String newCorrectAnswer = correctAnswer;

        for (int i = 0; i < optionIndices.length; i++) {
          final originalIndex = optionIndices[i];
          final option = options[originalIndex];
          shuffledOptions.add(option);

          // If this was the original correct answer, update the new correct answer
          if (option == correctAnswer) {
            newCorrectAnswer = option;
          }
        }

        // Update the question with shuffled options and new correct answer
        question['options'] = shuffledOptions.join('|');
        question['correct_answer'] = newCorrectAnswer;
      }

      setState(() {
        _questions = shuffledQuestions;
        _questionCount = _questions.isNotEmpty 
            ? (_questions.length < 5 ? _questions.length : 5) 
            : 1;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    try {
      final points = await _dbHelper.getUserPoints(widget.username);
      final powerups = await _dbHelper.getUserPowerups(widget.username);
      setState(() {
        _currentPoints = points;
        _userPowerups = powerups;
      });
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  void _loadUserProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_${widget.username}');
    if (path != null && path.isNotEmpty) {
      setState(() {
        _userProfileImage = File(path);
      });
    }
  }

  void _refreshUserProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_${widget.username}');
    setState(() {
      _userProfileImage = path != null && path.isNotEmpty ? File(path) : null;
    });
  }

  Future<void> _updatePoints(int pointsToAdd) async {
    final newPoints = _currentPoints + pointsToAdd;
    await _dbHelper.updateUserPoints(widget.username, newPoints);
    setState(() {
      _currentPoints = newPoints;
    });
  }

  Future<void> _usePowerup(String powerupId) async {
    if ((_userPowerups[powerupId] ?? 0) > 0) {
      await _dbHelper.usePowerup(widget.username, powerupId);
      setState(() {
        _userPowerups[powerupId] = (_userPowerups[powerupId] ?? 1) - 1;
      });

      // Apply powerup effect
      switch (powerupId) {
        case 'skip_question':
          _useSkipQuestion();
          break;
        case 'fifty_fifty':
          _useFiftyFifty();
          break;
        case 'double_points':
          _useDoublePoints();
          break;
        case 'extra_time':
          _useExtraTime();
          break;
        case 'hint':
          _useHint();
          break;
      }
    }
  }

  void _useSkipQuestion() {
    setState(() {
      _skipUsed = true;
    });
    _continueToNext();
    ScaffoldMessenger.of(this.context).showSnackBar(
      const SnackBar(
        content: Text('Question skipped! No penalty applied.'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _useFiftyFifty() {
    if (_showAnswer) return;

    final currentQuestion = _questions[_currentQuestionIndex];
    final optionsStr = currentQuestion['options']?.toString() ?? '';
    if (optionsStr.isEmpty) return;
    
    final options = optionsStr.split('|').where((o) => o.isNotEmpty).toList();
    final correctAnswer = currentQuestion['correct_answer']?.toString() ?? '';

    // Find incorrect options
    final incorrectOptions =
        options.where((opt) => opt != correctAnswer).toList();
    incorrectOptions.shuffle();

    // Remove 2 incorrect options
    final optionsToRemove = incorrectOptions.take(2).toList();

    setState(() {
      _fiftyFiftyUsed = true;
      _removedOptions = optionsToRemove;
    });

    ScaffoldMessenger.of(this.context).showSnackBar(
      const SnackBar(
        content: Text('50/50 used! Two incorrect answers removed.'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _useDoublePoints() {
    setState(() {
      _doublePointsActive = true;
    });
    ScaffoldMessenger.of(this.context).showSnackBar(
      const SnackBar(
        content: Text(
            'Double Points activated! Next correct answer worth 30 points.'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  void _useExtraTime() {
    setState(() {
      _extraTimeUsed = true;
    });
    ScaffoldMessenger.of(this.context).showSnackBar(
      const SnackBar(
        content: Text('Extra Time activated! +30 seconds added.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _useHint() async {
    final currentQuestion = _questions[_currentQuestionIndex];
    final questionText = currentQuestion['question_text']?.toString() ?? 'Question';
    final optionsStr = currentQuestion['options']?.toString() ?? '';
    if (optionsStr.isEmpty) return;
    final options = optionsStr.split('|').where((o) => o.isNotEmpty).toList();

    // Create the prompt for AI
    String prompt =
        "Question: $questionText\nOptions: ${options.join(', ')}\n\nGive a helpful hint for this question. Only provide the hint, no other text.";

    // Show loading dialog
    showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Generating AI Hint...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      // Send message to AI
      _chatBloc.add(ChatGenerationNewTextMessageEvent(
        inputMessage: prompt,
      ));

      // Wait for the response using a one-time listener
      bool responseReceived = false;
      StreamSubscription<ChatState>? subscription;

      subscription = _chatBloc.stream.listen((state) {
        if (!responseReceived) {
          if (state is ChatSuccessState && state.messages.isNotEmpty) {
            final lastMessage = state.messages.last;
            if (lastMessage.role == "model") {
              responseReceived = true;
              subscription?.cancel();
              Navigator.of(this.context).pop(); // Close loading dialog
              final hintText = lastMessage.parts.first.text;
              _showHintDialog(hintText);
            }
          } else if (state is ChatErrorState) {
            responseReceived = true;
            subscription?.cancel();
            Navigator.of(this.context).pop(); // Close loading dialog
            _showHintDialog(
                "Sorry, I couldn't generate a hint right now. Please try again.");
          }
        }
      });

      // Add timeout
      Timer(const Duration(seconds: 30), () {
        if (!responseReceived) {
          subscription?.cancel();
          Navigator.of(this.context).pop(); // Close loading dialog
          _showHintDialog(
              "Sorry, the hint request timed out. Please try again.");
        }
      });
    } catch (e) {
      Navigator.of(this.context).pop(); // Close loading dialog
      _showHintDialog(
          "Sorry, I couldn't generate a hint right now. Please try again.");
    }
  }

  void _showHintDialog(String hintText) {
    showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.lightbulb,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'AI Hint',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Hint content
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    hintText,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                // Close button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF667eea),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _startPractice(BuildContext context) {
    if (_selectedMode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a practice mode')),
      );
      return;
    }

    // Handle different game modes
    switch (_selectedMode) {
      case 'classic':
        // Standard quiz mode; for Robotics, generate AI questions first
        if (isRobotics) {
          _startRoboticsAiMcq(context);
        } else {
          setState(() {
            _showModeSelection = false;
            _showQuizArea = true;
            _showScoreSummary = false;
            _currentQuestionIndex = 0;
            _correctAnswers = 0;
            // Reset powerup states for new session
            _skipUsed = false;
            _fiftyFiftyUsed = false;
            _doublePointsActive = false;
            _extraTimeUsed = false;
            _removedOptions = [];
            // Initialize question timer and session tracking
            _questionStartTime = DateTime.now();
            _sessionAttempts = [];
          });
        }
        break;
      case 'timed':
        // Navigate to Lightning Mode screen
        _startLightningMode(context);
        break;

      case 'puzzle':
        _startPuzzleQuest(context);
        break;

      case 'memory':
        _startMemoryMaster(context);
        break;

      case 'survival':
        _startSurvivalMode(context);
        break;

      case 'treasure':
        _startTreasureHunt(context);
        break;

      default:
        setState(() {
          _showModeSelection = false;
          _showQuizArea = true;
          _showScoreSummary = false;
          _currentQuestionIndex = 0;
          _correctAnswers = 0;
          // Reset powerup states for new session
          _skipUsed = false;
          _fiftyFiftyUsed = false;
          _doublePointsActive = false;
          _extraTimeUsed = false;
          _removedOptions = [];
          // Initialize question timer and session tracking
          _questionStartTime = DateTime.now();
          _sessionAttempts = [];
        });
    }
  }

  void _startRoboticsAiMcq(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                SizedBox(height: 12),
                Text('Generating questions...', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        );
      },
    );

    try {
      final questions = await _generateRoboticsAiQuestions();
      Navigator.of(context).pop();
      if (questions.isNotEmpty) {
        setState(() {
          _questions = questions;
          // Set count bounded by generated list and selected slider
          _questionCount = questions.length < _questionCount ? questions.length : _questionCount;
          _showModeSelection = false;
          _showQuizArea = true;
          _showScoreSummary = false;
          _currentQuestionIndex = 0;
          _correctAnswers = 0;
          _skipUsed = false;
          _fiftyFiftyUsed = false;
          _doublePointsActive = false;
          _extraTimeUsed = false;
          _removedOptions = [];
          // Initialize question timer and session tracking
          _questionStartTime = DateTime.now();
          _sessionAttempts = [];
        });
      } else {
        // Fallback: keep existing behavior
        setState(() {
          _showModeSelection = false;
          _showQuizArea = true;
          _showScoreSummary = false;
          // Initialize question timer and session tracking
          _questionStartTime = DateTime.now();
          _sessionAttempts = [];
        });
      }
    } catch (e) {
      Navigator.of(context).pop();
      // Fallback to default behavior
      setState(() {
        _showModeSelection = false;
        _showQuizArea = true;
        _showScoreSummary = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _generateRoboticsAiQuestions() async {
    final count = _questionCount.clamp(1, 100);
    final prompt = 'Generate exactly $count multiple choice questions about robotics, automation, sensors, motion control, embedded systems, and practical build tradeoffs.\nEach question must be in this exact format with square brackets and six comma-separated fields:\n[question text, option A, option B, option C, option D, correct answer]\nDo not add numbering, explanations, or any extra text. Randomize correct answers. Keep the content at high-school robotics competition level.';

    // Helper to request questions and parse
    Future<List<Map<String, dynamic>>> request(String p, int target) async {
      _chatBloc.add(ChatClearHistoryEvent());
      final completer = Completer<List<Map<String, dynamic>>>();
      late final StreamSubscription sub;
      sub = _chatBloc.stream.listen((state) async {
        if (state is ChatSuccessState && state.messages.isNotEmpty) {
          final last = state.messages.lastWhere(
            (m) => m.role == 'model',
            orElse: () => ChatMessageModel(role: '', parts: []),
          );
          if (last.role.isNotEmpty && last.parts.isNotEmpty) {
            final parsed = _parseRoboticsAiResponse(last.parts.first.text, target);
            completer.complete(parsed);
            await sub.cancel();
            return;
          }
        }
        if (state is ChatErrorState) {
          completer.complete(<Map<String, dynamic>>[]);
          await sub.cancel();
        }
      });
      _chatBloc.add(ChatGenerationNewTextMessageEvent(inputMessage: p));
      return completer.future.timeout(const Duration(seconds: 45), onTimeout: () => <Map<String, dynamic>>[]);
    }

    // Try up to 3 attempts to reach requested count
    List<Map<String, dynamic>> all = await request(prompt, count);
    int attempts = 1;
    while (all.length < count && attempts < 3) {
      final remaining = count - all.length;
      final followUp = 'You generated ${all.length} questions. Now generate exactly $remaining more in the SAME bracketed format without repeating previous questions.\nFormat reminder: [question text, option A, option B, option C, option D, correct answer]. No numbering or explanations.';
      final more = await request(followUp, remaining);
      // Deduplicate on question_text
      final existing = all.map((q) => q['question_text']?.toString() ?? '').toSet();
      for (final q in more) {
        final qt = q['question_text']?.toString() ?? '';
        if (!existing.contains(qt)) {
          all.add(q);
          existing.add(qt);
        }
        if (all.length >= count) break;
      }
      attempts++;
    }
    return all.length > count ? all.sublist(0, count) : all;
  }

  List<Map<String, dynamic>> _parseRoboticsAiResponse(String aiResponse, int target) {
    final lines = aiResponse.split('\n');
    final questionLines = <String>[];
    for (final raw in lines) {
      final line = raw.trim();
      if (line.startsWith('[') && line.endsWith(']')) {
        questionLines.add(line);
      }
    }

    final parsed = <Map<String, dynamic>>[];
    for (final q in questionLines) {
      final map = _parseBracketQuestion(q);
      if (map != null) parsed.add(map);
      if (parsed.length >= target) break;
    }

    if (parsed.isEmpty) {
      // Try double-newline blocks
      for (final block in aiResponse.split('\n\n')) {
        final map = _parseBracketQuestion(block.trim());
        if (map != null) parsed.add(map);
        if (parsed.length >= target) break;
      }
    }

    if (parsed.length > target) {
      return parsed.sublist(0, target);
    }
    return parsed;
  }

  Map<String, dynamic>? _parseBracketQuestion(String line) {
    try {
      String clean = line.endsWith(',') ? line.substring(0, line.length - 1) : line;
      if (!clean.startsWith('[') || !clean.endsWith(']')) return null;
      final content = clean.substring(1, clean.length - 1);
      final parts = <String>[];
      final buf = StringBuffer();
      bool inQuotes = false;
      for (int i = 0; i < content.length; i++) {
        final ch = content[i];
        if (ch == '"') {
          inQuotes = !inQuotes;
          buf.write(ch);
        } else if (ch == ',' && !inQuotes) {
          parts.add(buf.toString().trim());
          buf.clear();
        } else {
          buf.write(ch);
        }
      }
      parts.add(buf.toString().trim());

      for (int i = 0; i < parts.length; i++) {
        if (parts[i].startsWith('"') && parts[i].endsWith('"')) {
          parts[i] = parts[i].substring(1, parts[i].length - 1);
        }
      }

      if (parts.length == 6) {
        final questionText = parts[0];
        final options = [parts[1], parts[2], parts[3], parts[4]];
        final correct = parts[5];
        return {
          'question_text': questionText,
          'options': options.join('|'),
          'correct_answer': correct,
        };
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  List<Color> _getGradientForMode(String mode) {
    switch (mode) {
      case 'classic':
        return widget.currentTheme == 'beach'
            ? ThemeColors.getBeachGradient1()
            : [Color(0xFF667eea), Color(0xFF764ba2)];
      case 'timed':
        return widget.currentTheme == 'beach'
            ? ThemeColors.getBeachGradient3()
            : [Color(0xFFf093fb), Color(0xFFf5576c)];
      case 'puzzle':
        return widget.currentTheme == 'beach'
            ? ThemeColors.getBeachGradient4()
            : [Color(0xFF4facfe), Color(0xFF00f2fe)];
      case 'memory':
        return widget.currentTheme == 'beach'
            ? ThemeColors.getBeachGradient5()
            : [Color(0xFF11998e), Color(0xFF38ef7d)];
      case 'survival':
        return widget.currentTheme == 'beach'
            ? [ThemeColors.getBeachGradient3()[0], Color(0xFFFF6B6B)]
            : [Color(0xFFff6b6b), Color(0xFFee5a6f)];
      case 'treasure':
        return widget.currentTheme == 'beach'
            ? [Color(0xFFFFD700), ThemeColors.getBeachGradient4()[1]]
            : [Color(0xFFffd700), Color(0xFFffed4e)];
      default:
        return [Colors.grey, Colors.grey.shade600];
    }
  }

  IconData _getIconForMode(String mode) {
    switch (mode) {
      case 'classic':
        return Icons.school;
      case 'timed':
        return Icons.flash_on;
      case 'puzzle':
        return Icons.extension;
      case 'memory':
        return Icons.psychology;
      case 'survival':
        return Icons.favorite;
      case 'treasure':
        return Icons.diamond;
      default:
        return Icons.help_outline;
    }
  }

  String _getTitleForMode(String mode) {
    switch (mode) {
      case 'classic':
        return 'Classic Mode';
      case 'timed':
        return 'Lightning Mode';
      case 'puzzle':
        return 'Puzzle Quest';
      case 'memory':
        return 'Memory Master';
      case 'survival':
        return 'Survival Mode';
      case 'treasure':
        return 'Treasure Hunt';
      default:
        return 'Unknown Mode';
    }
  }

  String _getDescriptionForMode(String mode) {
    switch (mode) {
      case 'classic':
        return 'Take your time and learn';
      case 'timed':
        return 'Race against time';
      case 'puzzle':
        return 'Solve puzzles first';
      case 'memory':
        return 'Match questions & answers';
      case 'survival':
        return '3 strikes and you\'re out!';
      case 'treasure':
        return 'Find hidden treasures';
      default:
        return 'Select a game mode';
    }
  }

  void _startPuzzleQuest(BuildContext context) {
    _showGameModeDialog(
      context,
      'Puzzle Quest',
      'Solve word puzzles and riddles to unlock quiz questions! Each correct puzzle reveals the next question.',
      Icons.extension,
      () {
        // Convert Map<String, dynamic> questions to List<Question> objects
        List<quiz.Question> questionObjects = _questions.map((q) {
          return quiz.Question(
            questionText: q['question_text'] ?? '',
            options: (q['options'] ?? '').toString().split('|'),
            correctAnswer: q['correct_answer'] ?? '',
          );
        }).toList();

        // Navigate to Puzzle Quest screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PuzzleQuestScreen(
              questions: questionObjects,
              currentTheme: widget.currentTheme,
              userPowerups: _userPowerups,
            ),
          ),
        );
      },
    );
  }

  void _startMemoryMaster(BuildContext context) {
    _showGameModeDialog(
      context,
      'Memory Master',
      'Test your memory! Questions and answers will be shown briefly, then you must match them correctly.',
      Icons.psychology,
      () {
        final dynamic sid = widget.studySet['id'];
        final int studySetId =
            sid is int ? sid : int.tryParse(sid?.toString() ?? '') ?? 0;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MemoryMasterModeScreen(
              username: widget.username,
              currentTheme: widget.currentTheme,
              studySetId: studySetId,
              questionCount: _questionCount,
            ),
          ),
        );
      },
    );
  }

  void _startSurvivalMode(BuildContext context) {
    _showGameModeDialog(
      context,
      'Survival Mode',
      'You have 3 lives! Each wrong answer costs a life. How long can you survive?',
      Icons.favorite,
      () {
        final dynamic sid = widget.studySet['id'];
        final int studySetId =
            sid is int ? sid : int.tryParse(sid?.toString() ?? '') ?? 0;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SurvivalModeScreen(
              username: widget.username,
              currentTheme: widget.currentTheme,
              studySetId: studySetId,
              questionCount: _questionCount,
            ),
          ),
        );
      },
    );
  }

  void _startTreasureHunt(BuildContext context) {
    _showGameModeDialog(
      context,
      'Treasure Hunt',
      'Find hidden treasures by answering questions correctly! Collect gems and unlock special rewards.',
      Icons.diamond,
      () {
        final dynamic sid = widget.studySet['id'];
        final int studySetId =
            sid is int ? sid : int.tryParse(sid?.toString() ?? '') ?? 0;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TreasureHuntModeScreen(
              username: widget.username,
              currentTheme: widget.currentTheme,
              studySetId: studySetId,
              questionCount: _questionCount,
            ),
          ),
        );
      },
    );
  }

  void _startLightningMode(BuildContext context) {
    // Convert Map<String, dynamic> questions to List<Question> objects
    List<quiz.Question> questionObjects = _questions.map((q) {
      return quiz.Question(
        questionText: q['question_text'] ?? '',
        options: (q['options'] ?? '').toString().split('|'),
        correctAnswer: q['correct_answer'] ?? '',
      );
    }).toList();

    // Navigate to Lightning Mode screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LightningModeScreen(
          questions: questionObjects,
          currentTheme: widget.currentTheme,
          userPowerups: _userPowerups,
        ),
      ),
    );
  }

  void _showGameModeDialog(BuildContext context, String title,
      String description, IconData icon, VoidCallback onStart) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: widget.currentTheme == 'beach'
                ? BoxDecoration(
                    gradient: ThemeColors.getBeachCardGradient(),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.black.withOpacity(0.1),
                      width: 1,
                    ),
                  )
                : BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2A2D3E),
                        Color(0xFF1D1E33),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.currentTheme == 'beach'
                          ? ThemeColors.getBeachGradient1()
                          : [Colors.blueAccent, Colors.blue],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: widget.currentTheme == 'beach'
                        ? ThemeColors.getTextColor('beach')
                        : Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    color: widget.currentTheme == 'beach'
                        ? ThemeColors.getTextColor('beach').withOpacity(0.8)
                        : Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: widget.currentTheme == 'beach'
                              ? LinearGradient(
                                  colors: [
                                    Colors.grey.shade400,
                                    Colors.grey.shade600,
                                  ],
                                )
                              : const LinearGradient(
                                  colors: [
                                    Color(0xFF6C7B7F),
                                    Color(0xFF9CA3AF),
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          label: const Text(
                            'Back',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: widget.currentTheme == 'beach'
                              ? LinearGradient(
                                  colors: ThemeColors.getBeachGradient2(),
                                )
                              : const LinearGradient(
                                  colors: [
                                    Color(0xFF4facfe),
                                    Color(0xFF00f2fe),
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onStart();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon:
                              const Icon(Icons.play_arrow, color: Colors.white),
                          label: const Text(
                            'Start',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _checkAnswer(String selectedAnswer) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final correctAnswer = currentQuestion['correct_answer']?.toString() ?? 
                         (currentQuestion['options'] is List 
                          ? (currentQuestion['options'] as List)[currentQuestion['correct'] as int? ?? 0].toString()
                          : '');
    final isCorrect = selectedAnswer == correctAnswer;
    
    // Calculate time spent
    final timeSpent = _questionStartTime != null 
        ? DateTime.now().difference(_questionStartTime!).inSeconds 
        : 0;
    
    // Extract course and chapter from study set name
    String course = 'AP Calculus AB';
    String chapter = 'Unknown';
    
    final studySetName = widget.studySet['name']?.toString() ?? '';
    if (studySetName.contains(' - ')) {
      final parts = studySetName.split(' - ');
      if (parts.length >= 2) {
        course = parts[0];
        chapter = parts[1];
      }
    } else if (studySetName.contains('AP Calculus AB')) {
      course = 'AP Calculus AB';
      // Try to extract chapter from name
      for (final ch in ['Limits and Continuity', 'Derivatives', 'Applications of Derivatives', 
                        'Integrals', 'Applications of Integrals', 'Differential Equations']) {
        if (studySetName.contains(ch)) {
          chapter = ch;
          break;
        }
      }
    }
    
    // Generate question ID
    final questionText = currentQuestion['question_text']?.toString() ?? '';
    final questionId = '${course}_${chapter}_q${_currentQuestionIndex}_${questionText.hashCode}';
    
    // Track attempt
    _sessionAttempts.add({
      'questionId': questionId,
      'course': course,
      'chapter': chapter,
      'isCorrect': isCorrect,
      'timeSpent': timeSpent,
    });
    
    // Track attempt in session
    _sessionAttempts.add({
      'questionId': questionId,
      'course': course,
      'chapter': chapter,
      'isCorrect': isCorrect,
      'timeSpent': timeSpent,
    });
    
    // Save to database (async, don't wait)
    _dbHelper.saveQuestionAttempt(
      widget.username,
      questionId,
      course,
      chapter,
      isCorrect,
      timeSpent: timeSpent,
    );
    
    // Calculate and update spaced repetition data (async)
    // Get existing history to find current values
    _dbHelper.getQuestionHistory(widget.username, course: course, chapter: chapter).then((history) {
      final existingItem = history.firstWhere(
        (h) => h['questionId'] == questionId,
        orElse: () => {},
      );
      
      final currentEaseFactor = existingItem['easeFactor'] as double? ?? 2.5;
      final currentInterval = existingItem['interval'] as int? ?? 1;
      final currentRepetitions = existingItem['repetitions'] as int? ?? 0;
      
      final spacedRepData = SpacedRepetitionHelper.calculateNextReview(
        currentEaseFactor: currentEaseFactor,
        currentInterval: currentInterval,
        repetitions: currentRepetitions,
        isCorrect: isCorrect,
      );
      
      // Update spaced repetition data
      _dbHelper.updateQuestionReview(
        widget.username,
        questionId,
        isCorrect: isCorrect,
        easeFactor: spacedRepData['easeFactor'] as double,
        interval: spacedRepData['interval'] as int,
        reviewDate: DateTime.parse(spacedRepData['reviewDate'] as String),
      );
    });
    
    setState(() {
      _selectedAnswer = selectedAnswer;
      _showAnswer = true;
      if (isCorrect) {
        _correctAnswers++;
        // Award points for correct answer
        int pointsToAward = _doublePointsActive ? 30 : 15;
        _updatePoints(pointsToAward);

        // Reset double points after use
        if (_doublePointsActive) {
          _doublePointsActive = false;
        }
      } else {
        // Deduct points for wrong answer
        _updatePoints(-5);
      }
    });
  }

  void _continueToNext() {
    final int totalQuestions =
        _questions.length < _questionCount ? _questions.length : _questionCount;
    if (_currentQuestionIndex < totalQuestions - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _showAnswer = false;
        // Reset question-specific powerup states
        _fiftyFiftyUsed = false;
        _removedOptions = [];
        _skipUsed = false;
        // Reset timer for next question
        _questionStartTime = DateTime.now();
      });
    } else {
      setState(() {
        _showQuizArea = false;
        _showScoreSummary = true;
      });
    }
  }

  void _answerWithAI() {
    // Get current question data
    final currentQuestion = _questions[_currentQuestionIndex];
    final questionText = currentQuestion['question_text'];
    final options = currentQuestion['options'].split('|');

    // Create the prompt with question and options
    String prompt = "Question: $questionText\n\nOptions:\n";
    for (int i = 0; i < options.length; i++) {
      prompt += "${String.fromCharCode(65 + i)}. ${options[i]}\n";
    }
    prompt +=
        "\nPlease help me understand this question and explain the correct answer.";

    // Refresh profile image before showing chat
    _refreshUserProfileImage();

    // Clear previous chat history
    _chatBloc.add(ChatClearHistoryEvent());

    // Show the chat interface
    setState(() {
      _showChat = true;
    });

    // Send the message to the chat
    _chatBloc.add(ChatGenerationNewTextMessageEvent(inputMessage: prompt));

    // Auto-scroll to bottom after a short delay to ensure the chat interface is rendered
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Stack(
        children: [
          getBackgroundForTheme(widget.currentTheme),
          SafeArea(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    ),
                  )
                : _hasError
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red.withOpacity(0.8),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF667eea),
                                    Color(0xFF764ba2)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF667eea)
                                        .withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: _loadQuestions,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                label: const Text(
                                  'Try Again',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _showModeSelection
                        ? SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(Icons.arrow_back,
                                            color: Colors.white),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.studySet['name'] ??
                                                'Practice Mode',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            '${_questions.length} questions available',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color:
                                                  Colors.white.withOpacity(0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Points display
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Colors.amber, Colors.orange],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.amber.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.diamond,
                                              color: Colors.white, size: 18),
                                          const SizedBox(width: 6),
                                          Text(
                                            '$_currentPoints',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                const Text(
                                  'Choose Your Challenge',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Pick a mode that suits your learning style',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Selected Game Mode Box with Extension
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.all(20),
                                  decoration: widget.currentTheme == 'beach'
                                      ? BoxDecoration(
                                          gradient: ThemeColors
                                              .getBeachCardGradient(),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            width: 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: _showGameModeSelection
                                                  ? 20
                                                  : 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        )
                                      : BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white.withOpacity(0.15),
                                              Colors.white.withOpacity(0.05),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            width: 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.white.withOpacity(0.1),
                                              blurRadius: _showGameModeSelection
                                                  ? 20
                                                  : 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.blueAccent
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.games,
                                              color: Colors.blueAccent,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            _showGameModeSelection
                                                ? 'Game Modes'
                                                : 'Selected Game Mode',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: widget.currentTheme ==
                                                      'beach'
                                                  ? ThemeColors.getTextColor(
                                                      'beach')
                                                  : Colors.white,
                                            ),
                                          ),
                                          if (_showGameModeSelection) ...[
                                            const Spacer(),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: widget.currentTheme ==
                                                          'beach'
                                                      ? [
                                                          const Color(
                                                              0xFF4DD0E1),
                                                          const Color(
                                                              0xFF26C6DA)
                                                        ]
                                                      : [
                                                          Colors.amber,
                                                          Colors.orange
                                                        ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: const Text(
                                                '6 Modes',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          onTap: () {
                                            setState(() {
                                              _showGameModeSelection =
                                                  !_showGameModeSelection;
                                            });
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 250),
                                            padding: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              gradient: _selectedMode.isNotEmpty
                                                  ? LinearGradient(
                                                      colors:
                                                          _getGradientForMode(
                                                              _selectedMode),
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    )
                                                  : widget.currentTheme ==
                                                          'beach'
                                                      ? LinearGradient(
                                                          colors: [
                                                            ThemeColors.getBeachGradient1()[
                                                                    0]
                                                                .withOpacity(
                                                                    0.3),
                                                            ThemeColors.getBeachGradient1()[
                                                                    1]
                                                                .withOpacity(
                                                                    0.1),
                                                          ],
                                                        )
                                                      : LinearGradient(
                                                          colors: [
                                                            Colors.blueAccent
                                                                .withOpacity(
                                                                    0.2),
                                                            Colors.indigo
                                                                .withOpacity(
                                                                    0.1),
                                                          ],
                                                        ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: _selectedMode.isNotEmpty
                                                    ? Colors.white
                                                        .withOpacity(0.4)
                                                    : Colors.white
                                                        .withOpacity(0.2),
                                                width: 2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: _selectedMode
                                                          .isNotEmpty
                                                      ? _getGradientForMode(
                                                              _selectedMode)[0]
                                                          .withOpacity(0.2)
                                                      : Colors.blueAccent
                                                          .withOpacity(0.1),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                                AnimatedContainer(
                                                  duration: const Duration(
                                                      milliseconds: 250),
                                                  padding:
                                                      const EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: _selectedMode
                                                              .isNotEmpty
                                                          ? [
                                                              Colors.white
                                                                  .withOpacity(
                                                                      0.3),
                                                              Colors.white
                                                                  .withOpacity(
                                                                      0.1),
                                                            ]
                                                          : [
                                                              Colors.white
                                                                  .withOpacity(
                                                                      0.2),
                                                              Colors.white
                                                                  .withOpacity(
                                                                      0.05),
                                                            ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.1),
                                                        blurRadius: 8,
                                                        offset:
                                                            const Offset(0, 4),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    _getIconForMode(
                                                        _selectedMode),
                                                    color: Colors.white,
                                                    size: 28,
                                                  ),
                                                ),
                                                const SizedBox(width: 20),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        _selectedMode.isEmpty
                                                            ? 'Choose Your Game Mode'
                                                            : _getTitleForMode(
                                                                _selectedMode),
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Text(
                                                        _selectedMode.isEmpty
                                                            ? 'Tap to explore different learning styles'
                                                            : _getDescriptionForMode(
                                                                _selectedMode),
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.white
                                                              .withOpacity(0.9),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                AnimatedRotation(
                                                  duration: const Duration(
                                                      milliseconds: 250),
                                                  turns: _showGameModeSelection
                                                      ? 0.5
                                                      : 0,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: const Icon(
                                                      Icons
                                                          .keyboard_arrow_down_rounded,
                                                      color: Colors.white,
                                                      size: 24,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (_showGameModeSelection) ...[
                                        const SizedBox(height: 20),
                                        GridView.count(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 12,
                                          childAspectRatio: 1.1,
                                          children: [
                                            _buildCompactModeCard(
                                              'classic',
                                              'Classic Mode',
                                              'Take your time and learn',
                                              Icons.school,
                                              widget.currentTheme == 'beach'
                                                  ? ThemeColors
                                                      .getBeachGradient1()
                                                  : [
                                                      Color(0xFF667eea),
                                                      Color(0xFF764ba2)
                                                    ],
                                            ),
                                            _buildCompactModeCard(
                                              'timed',
                                              'Lightning Mode',
                                              'Race against time',
                                              Icons.flash_on,
                                              widget.currentTheme == 'beach'
                                                  ? ThemeColors
                                                      .getBeachGradient3()
                                                  : [
                                                      Color(0xFFf093fb),
                                                      Color(0xFFf5576c)
                                                    ],
                                            ),
                                            _buildCompactModeCard(
                                              'puzzle',
                                              'Puzzle Quest',
                                              'Solve puzzles first',
                                              Icons.extension,
                                              widget.currentTheme == 'beach'
                                                  ? ThemeColors
                                                      .getBeachGradient4()
                                                  : [
                                                      Color(0xFF4facfe),
                                                      Color(0xFF00f2fe)
                                                    ],
                                            ),
                                            _buildCompactModeCard(
                                              'memory',
                                              'Memory Master',
                                              'Match questions & answers',
                                              Icons.psychology,
                                              widget.currentTheme == 'beach'
                                                  ? ThemeColors
                                                      .getBeachGradient5()
                                                  : [
                                                      Color(0xFF11998e),
                                                      Color(0xFF38ef7d)
                                                    ],
                                            ),
                                            _buildCompactModeCard(
                                              'survival',
                                              'Survival Mode',
                                              '3 strikes and you\'re out!',
                                              Icons.favorite,
                                              widget.currentTheme == 'beach'
                                                  ? [
                                                      ThemeColors
                                                          .getBeachGradient3()[0],
                                                      Color(0xFFFF6B6B)
                                                    ]
                                                  : [
                                                      Color(0xFFff6b6b),
                                                      Color(0xFFee5a6f)
                                                    ],
                                            ),
                                            _buildCompactModeCard(
                                              'treasure',
                                              'Treasure Hunt',
                                              'Find hidden treasures',
                                              Icons.diamond,
                                              widget.currentTheme == 'beach'
                                                  ? [
                                                      Color(0xFFFFD700),
                                                      ThemeColors
                                                          .getBeachGradient4()[1]
                                                    ]
                                                  : [
                                                      Color(0xFFffd700),
                                                      Color(0xFFffed4e)
                                                    ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: widget.currentTheme == 'beach'
                                      ? BoxDecoration(
                                          gradient: ThemeColors
                                              .getBeachCardGradient(),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            width: 1,
                                          ),
                                        )
                                      : BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.amber.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.quiz,
                                              color: Colors.amber,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Question Count',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: widget.currentTheme ==
                                                      'beach'
                                                  ? ThemeColors.getTextColor(
                                                      'beach')
                                                  : Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Center(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blueAccent
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                          child: Text(
                                            '$_questionCount Questions',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: widget.currentTheme ==
                                                      'beach'
                                                  ? ThemeColors.getTextColor(
                                                      'beach')
                                                  : Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      SliderTheme(
                                        data: SliderThemeData(
                                          activeTrackColor: Colors.blueAccent,
                                          inactiveTrackColor:
                                              Colors.white.withOpacity(0.3),
                                          thumbColor: Colors.white,
                                          thumbShape:
                                              const RoundSliderThumbShape(
                                            enabledThumbRadius: 12,
                                          ),
                                          overlayColor: Colors.blueAccent
                                              .withOpacity(0.2),
                                          valueIndicatorColor:
                                              Colors.blueAccent,
                                          valueIndicatorTextStyle:
                                              const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        child: Slider(
                                          value: _questionCount
                                              .clamp(1, isRobotics ? 100 : _questions.length)
                                              .toDouble(),
                                          min: 1.0,
                                          max: isRobotics ? 100.0 : _questions.length.toDouble(),
                                          divisions: (isRobotics ? 100 : _questions.length) > 1
                                              ? (isRobotics ? 100 : _questions.length) - 1
                                              : 1,
                                          label: '$_questionCount',
                                          onChanged: (value) {
                                            setState(() {
                                              _questionCount = value.round();
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 40),
                                // Start Practice button
                                Container(
                                  width: double.infinity,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: widget.currentTheme == 'beach'
                                        ? LinearGradient(
                                            colors:
                                                ThemeColors.getBeachGradient2(),
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : const LinearGradient(
                                            colors: [
                                              Color(0xFF4facfe),
                                              Color(0xFF00f2fe)
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: widget.currentTheme == 'beach'
                                            ? ThemeColors.getBeachGradient2()[0]
                                                .withOpacity(0.4)
                                            : const Color(0xFF4facfe)
                                                .withOpacity(0.4),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () => _startPractice(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Start Practice',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _showScoreSummary
                            ? Center(
                                child: Container(
                                  padding: const EdgeInsets.all(32),
                                  margin: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        const Color(0xFF2A2D3E),
                                        const Color(0xFF1D1E33)
                                            .withOpacity(0.9),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.emoji_events,
                                        size: 64,
                                        color: Colors.amber,
                                      ),
                                      const SizedBox(height: 24),
                                      const Text(
                                        'Quiz Complete!',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Score: $_correctAnswers/$_questionCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Colors.amber,
                                              Colors.orange
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.diamond,
                                                color: Colors.white, size: 18),
                                            const SizedBox(width: 6),
                                            Text(
                                              '$_currentPoints',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 32),

                                      // Share Button
                                      Container(
                                        width: double.infinity,
                                        margin:
                                            const EdgeInsets.only(bottom: 16),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF4facfe),
                                              Color(0xFF00f2fe)
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF4facfe)
                                                  .withOpacity(0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            double accuracy = (_correctAnswers /
                                                    _questionCount) *
                                                100;
                                            String shareText =
                                                "🎯 Just completed a quiz on EduQuest!\n"
                                                "📊 Score: $_correctAnswers/$_questionCount\n"
                                                "📈 Accuracy: ${accuracy.toStringAsFixed(1)}%\n"
                                                "🔥 Challenge yourself with EduQuest and test your knowledge!";
                                            Share.share(shareText);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.share,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          label: const Text(
                                            'Share Results',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      // Review Incorrect Button (only show if there are incorrect answers)
                                      if (_sessionAttempts.any((a) => a['isCorrect'] == false))
                                        Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.only(bottom: 16),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFFf5576c),
                                                Color(0xFFf093fb)
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFFf5576c).withOpacity(0.3),
                                                blurRadius: 12,
                                                offset: const Offset(0, 6),
                                              ),
                                            ],
                                          ),
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              // Extract course and chapter from study set
                                              String course = 'AP Calculus AB';
                                              String? chapter;
                                              final studySetName = widget.studySet['name']?.toString() ?? '';
                                              if (studySetName.contains(' - ')) {
                                                final parts = studySetName.split(' - ');
                                                if (parts.length >= 2) {
                                                  course = parts[0];
                                                  chapter = parts[1];
                                                }
                                              }
                                              
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ReviewIncorrectScreen(
                                                    username: widget.username,
                                                    currentTheme: widget.currentTheme,
                                                    course: course,
                                                    chapter: chapter,
                                                  ),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                            ),
                                            icon: const Icon(
                                              Icons.error_outline,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                            label: Text(
                                              'Review Incorrect (${_sessionAttempts.where((a) => a['isCorrect'] == false).length})',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),

                                      // Enhanced Try Again Button
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          gradient: widget.currentTheme ==
                                                  'beach'
                                              ? LinearGradient(
                                                  colors: ThemeColors
                                                      .getBeachGradient1(),
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                )
                                              : const LinearGradient(
                                                  colors: [
                                                    Color(0xFF667eea),
                                                    Color(0xFF764ba2)
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: widget.currentTheme ==
                                                      'beach'
                                                  ? ThemeColors
                                                              .getBeachGradient1()[
                                                          0]
                                                      .withOpacity(0.3)
                                                  : const Color(0xFF667eea)
                                                      .withOpacity(0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            setState(() {
                                              _showModeSelection = true;
                                              _showQuizArea = false;
                                              _showScoreSummary = false;
                                              // Reset all quiz state variables to prevent auto-answering
                                              _selectedAnswer = null;
                                              _showAnswer = false;
                                              _showChat = false;
                                              _currentQuestionIndex = 0;
                                              _correctAnswers = 0;
                                              // Reset powerup states
                                              _skipUsed = false;
                                              _fiftyFiftyUsed = false;
                                              _doublePointsActive = false;
                                              _extraTimeUsed = false;
                                              _removedOptions = [];
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.refresh_rounded,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          label: const Text(
                                            'Try Again',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // Enhanced Return Home Button
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          gradient: widget.currentTheme ==
                                                  'beach'
                                              ? LinearGradient(
                                                  colors: ThemeColors
                                                      .getBeachGradient2(),
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                )
                                              : const LinearGradient(
                                                  colors: [
                                                    Color(0xFF11998e),
                                                    Color(0xFF38ef7d)
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: widget.currentTheme ==
                                                      'beach'
                                                  ? ThemeColors
                                                              .getBeachGradient2()[
                                                          0]
                                                      .withOpacity(0.3)
                                                  : const Color(0xFF11998e)
                                                      .withOpacity(0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          icon: const Icon(
                                            Icons.home_rounded,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          label: const Text(
                                            'Return Home',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        // Always show the quiz content
                                        SingleChildScrollView(
                                          padding: const EdgeInsets.only(
                                              bottom:
                                                  120), // Increased from 100 to provide more space for powerup bar
                                          child: _buildQuizContent(),
                                        ),
                                        // Show the chat overlay covering 3/4 of the screen from the bottom
                                        if (_showChat)
                                          Align(
                                            alignment: Alignment.bottomCenter,
                                            child: FractionallySizedBox(
                                              heightFactor: 0.9,
                                              widthFactor: 1.0,
                                              child: _buildChatInterface(),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Powerup bar at bottom
                                  if (_showQuizArea) _buildPowerupBar(),
                                ],
                              ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerupBar() {
    List<Widget> powerupButtons = [
      _buildPowerupButton(
        'skip_question',
        Icons.skip_next,
        'Skip',
        const Color(0xFF4CAF50),
        _skipUsed,
      ),
      _buildPowerupButton(
        'fifty_fifty',
        Icons.filter_2,
        '50/50',
        const Color(0xFF2196F3),
        _fiftyFiftyUsed,
      ),
      _buildPowerupButton(
        'double_points',
        Icons.star,
        '2x Points',
        const Color(0xFFFFD700),
        _doublePointsActive,
      ),
    ];

    if (_selectedMode == 'timed') {
      powerupButtons.add(
        _buildPowerupButton(
          'extra_time',
          Icons.access_time,
          '+Time',
          const Color(0xFFFF9800),
          _extraTimeUsed,
        ),
      );
    }

    powerupButtons.add(
      _buildPowerupButton(
        'hint',
        Icons.lightbulb,
        'Hint',
        const Color(0xFF9C27B0),
        false, // Hint can be used multiple times
      ),
    );

    return Container(
      height: 70, // Reduced from 90
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16), // Reduced bottom margin
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 6), // Reduced vertical padding
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2A2D3E).withOpacity(0.95),
            const Color(0xFF1D1E33).withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(16), // Reduced from 25
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF4facfe).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: powerupButtons,
      ),
    );
  }

  Widget _buildPowerupButton(
      String powerupId, IconData icon, String label, Color color, bool used) {
    final count = _userPowerups[powerupId] ?? 0;
    final canUse = count > 0 && !used && !_showAnswer;

    return GestureDetector(
      onTap: canUse ? () => _usePowerup(powerupId) : null,
      child: Container(
        width: 52, // Reduced from 58
        height: 58, // Reduced from 70
        padding: const EdgeInsets.symmetric(
            vertical: 6, horizontal: 4), // Reduced vertical padding
        decoration: BoxDecoration(
          gradient: canUse
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [color, color.withOpacity(0.8)],
                )
              : LinearGradient(
                  colors: [Colors.grey.shade700, Colors.grey.shade800],
                ),
          borderRadius: BorderRadius.circular(14), // Reduced from 16
          border: Border.all(
            color: canUse ? color.withOpacity(0.6) : Colors.grey.shade600,
            width: 1.5,
          ),
          boxShadow: canUse
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 20, // Reduced from 22
                  ),
                  const SizedBox(height: 3), // Reduced from 4
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8, // Reduced from 9
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (count > 0)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 16, // Reduced from 18
                  height: 16, // Reduced from 18
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                    ),
                    borderRadius: BorderRadius.circular(8), // Reduced from 9
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9, // Reduced from 10
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            if (used)
              Container(
                width: 52, // Reduced from 58
                height: 58, // Reduced from 70
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(14), // Reduced from 16
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 24, // Reduced from 28
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactModeCard(
    String mode,
    String title,
    String subtitle,
    IconData icon,
    List<Color> gradientColors,
  ) {
    final isSelected = _selectedMode == mode;
    final bool isSpooky = widget.currentTheme == 'halloween';
    final Gradient? spookyGradient = isSpooky
        ? ThemeColors.getCardGradient('halloween', variant: mode.hashCode.abs())
        : null;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMode = mode;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : widget.currentTheme == 'beach'
                  ? ThemeColors.getBeachCardGradient()
                  : spookyGradient,
          color: isSelected ||
                  widget.currentTheme == 'beach' ||
                  spookyGradient != null
              ? null
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: gradientColors.first.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : (spookyGradient != null
                  ? ThemeColors.getButtonShadows('halloween')
                  : [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.08),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ]),
          border: Border.all(
            color: isSelected
                ? Colors.white.withOpacity(0.3)
                : isSpooky
                    ? ThemeColors.getAccentColor('halloween').withOpacity(0.35)
                    : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(isSelected ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.white
                    : widget.currentTheme == 'beach'
                        ? ThemeColors.getTextColor('beach')
                        : Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? Colors.white.withOpacity(0.8)
                      : widget.currentTheme == 'beach'
                          ? ThemeColors.getTextColor('beach').withOpacity(0.7)
                          : Colors.white.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1.5,
                ),
                color: isSelected ? Colors.white : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: gradientColors.first,
                      size: 10,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildEnhancedModeCard(
    String mode,
    String title,
    String subtitle,
    IconData icon,
    Gradient gradient,
  ) {
    final isSelected = _selectedMode == mode;
    final bool isSpooky = widget.currentTheme == 'halloween';
    final Gradient? spookyGradient = isSpooky
        ? ThemeColors.getCardGradient('halloween', variant: mode.hashCode.abs())
        : null;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMode = mode;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isSelected
              ? gradient
              : widget.currentTheme == 'beach'
                  ? ThemeColors.getBeachCardGradient()
                  : spookyGradient,
          color: isSelected
              ? null
              : widget.currentTheme == 'beach' || spookyGradient != null
                  ? null
                  : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: gradient.colors.first.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : (spookyGradient != null
                  ? ThemeColors.getButtonShadows('halloween')
                  : [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ]),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(isSelected ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : widget.currentTheme == 'beach'
                              ? ThemeColors.getTextColor('beach')
                              : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : widget.currentTheme == 'beach'
                              ? ThemeColors.getTextColor('beach')
                                  .withOpacity(0.7)
                              : Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                color: isSelected ? Colors.white : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Color(0xFF302B63),
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizContent() {
    final int totalQuestions =
        _questions.length < _questionCount ? _questions.length : _questionCount;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header with progress
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Back button with fixed width
              SizedBox(
                width: 48,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded,
                        color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _showModeSelection = true;
                        _showQuizArea = false;
                        _showScoreSummary = false;
                      });
                    },
                  ),
                ),
              ),
              // Centered question counter
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF667eea).withOpacity(0.8),
                          const Color(0xFF764ba2).withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF667eea).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Text(
                      'Q${_currentQuestionIndex + 1}/$totalQuestions',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              // Points display with flexible width
              Container(
                constraints: const BoxConstraints(minWidth: 70, maxWidth: 100),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFF8F00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.diamond, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '$_currentPoints',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20), // Reduced from 24
        LayoutBuilder(
          builder: (context, constraints) {
            final double minHeight =
                MediaQuery.of(context).size.height * 0.12; // Reduced from 0.14
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              constraints: BoxConstraints(minHeight: minHeight),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24), // Reduced from 28
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4facfe).withOpacity(0.22),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.13),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20), // Increased horizontal padding
                decoration: BoxDecoration(
                  gradient: widget.currentTheme == 'beach'
                      ? ThemeColors.getBeachCardGradient()
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF2A2D3E),
                            const Color(0xFF1D1E33),
                            const Color(0xFF16213E).withOpacity(0.9),
                          ],
                        ),
                  borderRadius: BorderRadius.circular(24), // Reduced from 28
                  border: Border.all(
                    color: Colors.white.withOpacity(0.10),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display passage if it exists (for SAT questions)
                    if (_questions[_currentQuestionIndex]['passage'] != null &&
                        _questions[_currentQuestionIndex]['passage']
                            .toString()
                            .isNotEmpty) ...[
                      Text(
                        _questions[_currentQuestionIndex]['passage'].toString(),
                        style: TextStyle(
                          color: widget.currentTheme == 'beach'
                              ? ThemeColors.getTextColor('beach')
                              : Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          height: 1.5,
                          letterSpacing: 0.1,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 16),
                      // Divider between passage and question
                      Container(
                        height: 1,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Display the actual question
                    Text(
                      (_questions[_currentQuestionIndex]['question_text'] ?? 'Question not available').toString(),
                      style: TextStyle(
                        color: widget.currentTheme == 'beach'
                            ? ThemeColors.getTextColor('beach')
                            : Colors.white,
                        fontSize: 24, // Reduced from 26
                        fontWeight: FontWeight.bold,
                        height: 1.4, // Reduced from 1.5
                        letterSpacing: 0.2, // Reduced from 0.3
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24), // Reduced from 32
        ...(_questions[_currentQuestionIndex]['options']?.toString() ?? '')
            .split('|')
            .where((opt) => opt.isNotEmpty)
            .toList()
            .asMap()
            .entries
            .where((e) => !_removedOptions
                .contains(e.value)) // Filter out removed options
            .map((e) {
          final opt = e.value;
          final sel = _selectedAnswer == opt;
          final cor = _showAnswer &&
              opt == (_questions[_currentQuestionIndex]['correct_answer']?.toString() ?? '');
          final wrg = _showAnswer && sel && !cor;
          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 4), // Reduced vertical padding
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: cor
                    ? LinearGradient(
                        colors: widget.currentTheme == 'beach'
                            ? ThemeColors.getBeachGradient2()
                            : [Color(0xFF43e97b), Color(0xFF38f9d7)])
                    : wrg
                        ? LinearGradient(
                            colors: widget.currentTheme == 'beach'
                                ? ThemeColors.getBeachGradient3()
                                : [Color(0xFFf5576c), Color(0xFFf093fb)])
                        : sel
                            ? LinearGradient(
                                colors: widget.currentTheme == 'beach'
                                    ? ThemeColors.getBeachGradient1()
                                    : [Color(0xFF4facfe), Color(0xFF00f2fe)])
                            : widget.currentTheme == 'beach'
                                ? ThemeColors.getBeachCardGradient()
                                : LinearGradient(colors: [
                                    Color(0xFF23243a),
                                    Color(0xFF23243a)
                                  ]),
                borderRadius: BorderRadius.circular(16), // Reduced from 18
                boxShadow: sel
                    ? [
                        BoxShadow(
                          color: const Color(0xFF4facfe).withOpacity(0.18),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
                border: Border.all(
                  color: cor
                      ? Colors.greenAccent.withOpacity(0.7)
                      : wrg
                          ? Colors.redAccent.withOpacity(0.7)
                          : Colors.white.withOpacity(0.08),
                  width: 2,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16), // Reduced from 18
                  onTap: _showAnswer ? null : () => _checkAnswer(opt),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20), // Increased horizontal padding
                    child: Center(
                      child: Text(
                        opt,
                        style: TextStyle(
                          color: (cor || wrg || sel)
                              ? Colors.white
                              : widget.currentTheme == 'beach'
                                  ? ThemeColors.getTextColor('beach')
                                  : Colors.white,
                          fontSize: 16, // Reduced from 20
                          fontWeight: FontWeight.w600, // Reduced from w700
                          letterSpacing: 0.1, // Reduced from 0.2
                          height:
                              1.3, // Added line height for better readability
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
        // Show explanation for SAT questions when answer is revealed
        if (_showAnswer &&
            widget.satTopic == 'Information and Ideas' &&
            _questions[_currentQuestionIndex]['explanation'] != null) ...[
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF667eea).withOpacity(0.1),
                  const Color(0xFF764ba2).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF667eea).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: const Color(0xFF667eea),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Explanation',
                      style: TextStyle(
                        color: const Color(0xFF667eea),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  (_questions[_currentQuestionIndex]['explanation'] ?? '').toString(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
        // Bookmark button (shown when answer is revealed)
        if (_showAnswer) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(
                  Icons.bookmark,
                  color: Colors.blue,
                  size: 28,
                ),
                onPressed: () async {
                  final currentQuestion = _questions[_currentQuestionIndex];
                  final questionText = currentQuestion['question_text']?.toString() ?? '';
                  
                  // Extract course and chapter
                  String course = 'AP Calculus AB';
                  String chapter = 'Unknown';
                  final studySetName = widget.studySet['name']?.toString() ?? '';
                  if (studySetName.contains(' - ')) {
                    final parts = studySetName.split(' - ');
                    if (parts.length >= 2) {
                      course = parts[0];
                      chapter = parts[1];
                    }
                  }
                  
                  // Generate question ID
                  final questionId = '${course}_${chapter}_q${_currentQuestionIndex}_${questionText.hashCode}';
                  
                  await _dbHelper.bookmarkQuestion(widget.username, questionId);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Question bookmarked!'),
                      backgroundColor: Colors.blue,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
        if (_showAnswer) ...[
          const SizedBox(height: 24), // Reduced from 32
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                // Ask QuestAI Button
                Expanded(
                  child: Container(
                    height: 52, // Reduced from 56
                    decoration: BoxDecoration(
                      gradient: widget.currentTheme == 'beach'
                          ? LinearGradient(
                              colors: ThemeColors.getBeachGradient3(),
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius:
                          BorderRadius.circular(26), // Reduced from 28
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF667eea).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _answerWithAI,
                      icon: const Icon(Icons.psychology,
                          color: Colors.white, size: 18), // Reduced from 20
                      label: const Text(
                        'Ask QuestAI',
                        style: TextStyle(
                          fontSize: 15, // Reduced from 16
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(26), // Reduced from 28
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14), // Reduced from 16
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Next Question Button
                Expanded(
                  child: Container(
                    height: 52, // Reduced from 56
                    decoration: BoxDecoration(
                      gradient: widget.currentTheme == 'beach'
                          ? LinearGradient(
                              colors: ThemeColors.getBeachGradient1(),
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : const LinearGradient(
                              colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius:
                          BorderRadius.circular(26), // Reduced from 28
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4facfe).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _continueToNext,
                      icon: Icon(
                        _currentQuestionIndex < totalQuestions - 1
                            ? Icons.arrow_forward_rounded
                            : Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 18, // Reduced from 20
                      ),
                      label: Text(
                        _currentQuestionIndex < totalQuestions - 1
                            ? 'Next Question'
                            : 'Finish',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChatInterface() {
    return Container(
      margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Chat header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.psychology, color: Colors.white, size: 24),
                const SizedBox(width: 6),
                const Text(
                  'AI Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showChat = false;
                    });
                  },
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          // Chat messages
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              bloc: _chatBloc,
              builder: (context, state) {
                if (state is ChatSuccessState || state is ChatGeneratingState) {
                  List<ChatMessageModel> messages = [];
                  if (state is ChatSuccessState) {
                    messages = state.messages;
                  } else if (state is ChatGeneratingState) {
                    messages = state.messages;
                  }
                  // Auto-scroll to bottom when new messages arrive
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_chatScrollController.hasClients) {
                      _chatScrollController.animateTo(
                        _chatScrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  });
                  // Additional jump to ensure loading animation is visible
                  if (state is ChatGeneratingState) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Future.delayed(const Duration(milliseconds: 350), () {
                        if (_chatScrollController.hasClients) {
                          _chatScrollController.jumpTo(
                            _chatScrollController.position.maxScrollExtent,
                          );
                        }
                      });
                    });
                  }

                  return ListView.builder(
                    controller: _chatScrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length + (_chatBloc.generating ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_chatBloc.generating && index == messages.length) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Center(
                            child: SizedBox(
                              height: 54,
                              width: 54,
                              child: Lottie.asset('assets/animation/loader.json'),
                            ),
                          ),
                        );
                      }
                      final message = messages[index];
                      final isUser = message.role == 'user';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: isUser
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            if (!isUser) ...[
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF667eea),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.psychology,
                                    color: Colors.white, size: 16),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? const Color(0xFF4facfe)
                                      : Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  message.parts.isNotEmpty
                                      ? message.parts.first.text
                                      : 'No message content',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                              ),
                            ),
                            if (isUser) ...[
                              const SizedBox(width: 6),
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.transparent,
                                backgroundImage: _userProfileImage != null
                                    ? FileImage(_userProfileImage!)
                                    : null,
                                child: _userProfileImage == null
                                    ? Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF4facfe),
                                              Color(0xFF00f2fe)
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF4facfe)
                                                  .withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          widget.username.isNotEmpty
                                              ? widget.username
                                                  .substring(0, 1)
                                                  .toUpperCase()
                                              : 'U',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                } else if (state is ChatErrorState) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Error: ${state.message}',
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                } else {
                  // Initial or empty state
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            color: Colors.white54, size: 48),
                        SizedBox(height: 16),
                        Text(
                          'Ask me anything!',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
          // Parse questions button for SAT Information and Ideas
          if (_showParseButton &&
              widget.satTopic == 'Information and Ideas') ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF43e97b).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_aiResponse != null) {
                      _parseAndDisplaySATQuestions(_aiResponse!);
                    }
                  },
                  icon: const Icon(Icons.quiz, color: Colors.white, size: 20),
                  label: const Text(
                    'Parse & Start Quiz',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
          // Chat input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Ask a follow-up question...',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (_chatController.text.trim().isNotEmpty) {
                      _chatBloc.add(ChatGenerationNewTextMessageEvent(
                          inputMessage: _chatController.text));
                      _chatController.clear();

                      // Auto-scroll to bottom when user sends a message
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (_chatScrollController.hasClients) {
                          _chatScrollController.animateTo(
                            _chatScrollController.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      });
                    }
                  },
                  icon: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomPageRoute extends PageRouteBuilder {
  final Widget page;
  final String routeName;

  CustomPageRoute({
    required this.page,
    required this.routeName,
  }) : super(
          settings: RouteSettings(name: routeName),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}

class QuizScreen extends StatefulWidget {
  final String subject;
  final String username;
  final List<quiz.Question> questions;
  final String currentTheme;
  final String gameMode;
  final int questionCount;

  const QuizScreen({
    super.key,
    required this.subject,
    required this.username,
    required this.questions,
    required this.currentTheme,
    required this.gameMode,
    required this.questionCount,
  });

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  int score = 0;
  bool isAnswered = false;
  String? selectedAnswer;
  Timer? timer;
  double timeLeft = 10.0; // Changed to double
  double timerProgress = 1.0;
  bool showAnswer = false;
  List<bool> answeredCorrectly = [];
  bool showScoreSummary = false;
  bool showQuizArea = true;

  @override
  void initState() {
    super.initState();
    if (widget.gameMode == 'timed') {
      startTimer();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timeLeft = 45.0; // Reset to 45 seconds
    timerProgress = 1.0;
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft -= 0.1;
          timerProgress = timeLeft / 45.0;
        });
      } else {
        nextQuestion();
      }
    });
  }

  void selectAnswer(String answer) {
    if (isAnswered) return;

    setState(() {
      selectedAnswer = answer;
      isAnswered = true;
      showAnswer = true;
    });

    bool correct =
        answer == widget.questions[currentQuestionIndex].correctAnswer;
    answeredCorrectly.add(correct);

    if (correct) {
      setState(() {
        score += 15;
      });
    } else {
      setState(() {
        score -= 5;
      });
    }

    Future.delayed(const Duration(seconds: 2), () {
      nextQuestion();
    });
  }

  void nextQuestion() {
    timer?.cancel();

    if (currentQuestionIndex < widget.questionCount - 1 &&
        currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        isAnswered = false;
        selectedAnswer = null;
        showAnswer = false;
      });

      if (widget.gameMode == 'timed') {
        startTimer();
      }
    } else {
      showResults();
    }
  }

  void showResults() {
    timer?.cancel();
    setState(() {
      showScoreSummary = true;
      showQuizArea = false;
    });
  }

  void _shareResults() {
    int correctAnswers = answeredCorrectly.where((correct) => correct).length;
    double accuracy = (correctAnswers / widget.questionCount) * 100;

    String shareText = "🎯 Just completed a ${widget.subject} quiz!\n"
        "📊 Score: $correctAnswers/${widget.questionCount}\n"
        "📈 Accuracy: ${accuracy.toStringAsFixed(1)}%\n"
        "🔥 Challenge yourself with EduQuest!";

    Share.share(shareText);
  }

  Widget _buildQuizContent() {
    if (showScoreSummary) {
      return _buildResultsCard();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with progress
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(this.context),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Question ${currentQuestionIndex + 1}/${widget.questionCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: (currentQuestionIndex + 1) / widget.questionCount,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 32),

        // Score
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Score: $score',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Question
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Text(
            widget.questions[currentQuestionIndex].questionText,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),

        // Answer options
        Expanded(
          child: ListView.builder(
            itemCount: widget.questions[currentQuestionIndex].options.length,
            itemBuilder: (context, index) {
              final option =
                  widget.questions[currentQuestionIndex].options[index];
              final isSelected = selectedAnswer == option;
              final isCorrect = showAnswer &&
                  option ==
                      widget.questions[currentQuestionIndex].correctAnswer;
              final isWrong = showAnswer && isSelected && !isCorrect;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? Colors.green.withOpacity(0.2)
                        : isWrong
                            ? Colors.red.withOpacity(0.2)
                            : isSelected
                                ? Colors.blueAccent.withOpacity(0.2)
                                : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCorrect
                          ? Colors.green
                          : isWrong
                              ? Colors.red
                              : isSelected
                                  ? Colors.blueAccent
                                  : Colors.white.withOpacity(0.1),
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    title: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: showAnswer
                        ? Icon(
                            isCorrect
                                ? Icons.check_circle
                                : isWrong
                                    ? Icons.cancel
                                    : null,
                            color: isCorrect ? Colors.green : Colors.red,
                          )
                        : null,
                    onTap: isAnswered ? null : () => selectAnswer(option),
                  ),
                ),
              );
            },
          ),
        ),

        // Timer (if in timed mode)
        if (widget.gameMode == 'timed') ...[
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: timerProgress,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Time Left: ${timeLeft.toStringAsFixed(1)}s',
            style: const TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResultsCard() {
    int correctAnswers = answeredCorrectly.where((correct) => correct).length;
    double accuracy = (correctAnswers / widget.questionCount) * 100;

    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2A2D3E),
              Color(0xFF1D1E33),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events,
              size: 64,
              color: Colors.amber,
            ),
            const SizedBox(height: 24),
            const Text(
              'Quiz Complete!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Score: $correctAnswers/${widget.questionCount}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Accuracy: ${accuracy.toStringAsFixed(1)}%',
              style: TextStyle(
                color: accuracy >= 70
                    ? Colors.green
                    : accuracy >= 50
                        ? Colors.orange
                        : Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),

            // Share Button
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4facfe).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _shareResults,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(
                  Icons.share,
                  color: Colors.white,
                  size: 24,
                ),
                label: const Text(
                  'Share Results',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Try Again Button
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667eea).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    currentQuestionIndex = 0;
                    score = 0;
                    isAnswered = false;
                    selectedAnswer = null;
                    showAnswer = false;
                    answeredCorrectly.clear();
                    showScoreSummary = false;
                    showQuizArea = true;
                  });
                  if (widget.gameMode == 'timed') {
                    startTimer();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                label: const Text(
                  'Try Again',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Return Home Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF11998e).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(this.context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(
                  Icons.home_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                label: const Text(
                  'Return Home',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject),
        backgroundColor: const Color(0xFF1D1E33),
        foregroundColor: Colors.white,
        actions: [
          if (widget.gameMode == 'timed' && !showScoreSummary)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      value: timerProgress,
                      strokeWidth: 2,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.blueAccent),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${timeLeft.toStringAsFixed(1)}s',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          getBackgroundForTheme(widget.currentTheme),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _buildQuizContent(),
            ),
          ),
        ],
      ),
    );
  }
}

class QuizletImportScreen extends StatefulWidget {
  final String username;
  final VoidCallback onStudySetCreated;
  final String currentTheme;

  const QuizletImportScreen({
    super.key,
    required this.username,
    required this.onStudySetCreated,
    required this.currentTheme,
  });

  @override
  _QuizletImportScreenState createState() => _QuizletImportScreenState();
}

class _QuizletImportScreenState extends State<QuizletImportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _urlController = TextEditingController();
  final _dbHelper = DatabaseHelper();
  bool _isLoading = false;
  List<Map<String, dynamic>> _questions = [];
  // ignore: unused_field
  bool _hasImported = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _importFromQuizlet() async {
    if (_urlController.text.isEmpty) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a Quizlet URL'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Clean and validate the URL
      String url = _urlController.text.trim();
      if (!url.contains('quizlet.com')) {
        throw Exception('Invalid Quizlet URL');
      }

      // Add protocol if missing
      if (!url.startsWith('http')) {
        url = 'https://$url';
      }

      debugPrint('Fetching Quizlet URL: $url');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to fetch Quizlet set: HTTP ${response.statusCode}');
      }

      final document = html_parser.parse(response.body);
      List<Map<String, dynamic>> parsedQuestions = [];

      debugPrint('Parsing Quizlet HTML...');

      // Method 1: Try to find JSON data in script tags
      final scriptTags = document.getElementsByTagName('script');
      String? jsonData;

      for (var script in scriptTags) {
        final scriptText = script.text;
        if (scriptText.contains('window.Quizlet') ||
            scriptText.contains('__NEXT_DATA__') ||
            scriptText.contains('"word"') &&
                scriptText.contains('"definition"')) {
          debugPrint('Found potential JSON data in script tag');

          // Try to extract JSON
          final start = scriptText.indexOf('{');
          final end = scriptText.lastIndexOf('}');
          if (start != -1 && end != -1 && end > start) {
            jsonData = scriptText.substring(start, end + 1);
            debugPrint('Extracted JSON data (${jsonData.length} characters)');
            break;
          }
        }
      }

      // Method 2: Parse JSON data if found
      if (jsonData != null) {
        try {
          // Look for term patterns in the JSON
          final termPatterns = [
            RegExp(
                r'"word"\s*:\s*"([^"]+)"\s*,\s*"definition"\s*:\s*"([^"]+)"'),
            RegExp(
                r'"term"\s*:\s*"([^"]+)"\s*,\s*"definition"\s*:\s*"([^"]+)"'),
            RegExp(r'"front"\s*:\s*"([^"]+)"\s*,\s*"back"\s*:\s*"([^"]+)"'),
          ];

          for (final pattern in termPatterns) {
            final matches = pattern.allMatches(jsonData);
            debugPrint(
                'Found ${matches.length} matches with pattern: ${pattern.pattern}');

            for (final match in matches) {
              final question = match
                      .group(1)
                      ?.replaceAll('\\u002F', '/')
                      .replaceAll('\\"', '"') ??
                  '';
              final answer = match
                      .group(2)
                      ?.replaceAll('\\u002F', '/')
                      .replaceAll('\\"', '"') ??
                  '';

              if (question.isNotEmpty && answer.isNotEmpty) {
                // Create 4 options with the correct answer as one of them
                List<String> options = [answer];
                // Add some dummy options for now
                while (options.length < 4) {
                  options.add('Option ${options.length}');
                }
                options.shuffle();

                parsedQuestions.add({
                  'question': question,
                  'correct_answer': answer,
                  'options': options,
                });
              }
            }

            if (parsedQuestions.isNotEmpty) break;
          }
        } catch (e) {
          debugPrint('Error parsing JSON data: $e');
        }
      }

      // Method 3: Try to parse HTML elements directly
      if (parsedQuestions.isEmpty) {
        debugPrint('Trying HTML element parsing...');

        // Look for various Quizlet HTML structures
        final selectors = [
          '.SetPageTerm-content',
          '.SetPageTerm',
          '.TermText',
          '[data-testid="term"]',
          '.Term',
        ];

        for (final selector in selectors) {
          final elements = document.querySelectorAll(selector);
          debugPrint(
              'Found ${elements.length} elements with selector: $selector');

          for (var el in elements) {
            String? question;
            String? answer;

            // Try different ways to extract question and answer
            final wordEl = el.querySelector('.SetPageTerm-wordText') ??
                el.querySelector('.TermText') ??
                el.querySelector('[data-testid="word"]');
            final defEl = el.querySelector('.SetPageTerm-definitionText') ??
                el.querySelector('.TermText') ??
                el.querySelector('[data-testid="definition"]');

            if (wordEl != null) question = wordEl.text.trim();
            if (defEl != null) answer = defEl.text.trim();

            // If we still don't have both, try to get them from the element itself
            if (question == null || answer == null) {
              final textContent = el.text.trim();
              if (textContent.contains('\n')) {
                final parts = textContent.split('\n');
                if (parts.length >= 2) {
                  question = parts[0].trim();
                  answer = parts[1].trim();
                }
              }
            }

            if (question != null &&
                answer != null &&
                question.isNotEmpty &&
                answer.isNotEmpty) {
              List<String> options = [answer];
              while (options.length < 4) {
                options.add('Option ${options.length}');
              }
              options.shuffle();

              parsedQuestions.add({
                'question': question,
                'correct_answer': answer,
                'options': options,
              });
            }
          }

          if (parsedQuestions.isNotEmpty) break;
        }
      }

      // Method 4: Try to parse from page title and description
      if (parsedQuestions.isEmpty) {
        debugPrint('Trying to parse from page metadata...');

        final title = document.querySelector('title')?.text ?? '';
        // ignore: unused_local_variable
        final description = document
                .querySelector('meta[name="description"]')
                ?.attributes['content'] ??
            '';

        if (title.isNotEmpty && title.contains('Quizlet')) {
          // Create a basic question from the title
          parsedQuestions.add({
            'question': 'What is this Quizlet set about?',
            'correct_answer': title
                .replaceAll(' | Quizlet', '')
                .replaceAll('Quizlet', '')
                .trim(),
            'options': [
              title
                  .replaceAll(' | Quizlet', '')
                  .replaceAll('Quizlet', '')
                  .trim(),
              'General Knowledge',
              'Study Material',
              'Educational Content'
            ],
          });
        }
      }

      setState(() {
        _questions = parsedQuestions;
        _hasImported = parsedQuestions.isNotEmpty;
        _isLoading = false;
      });

      if (parsedQuestions.isNotEmpty) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(
            content: Text(
                'Successfully imported ${parsedQuestions.length} terms from Quizlet'),
            backgroundColor: Colors.green,
          ),
        );
        debugPrint('Successfully imported ${parsedQuestions.length} questions');
      } else {
        ScaffoldMessenger.of(this.context).showSnackBar(
          const SnackBar(
            content: Text(
                'Could not parse Quizlet set. The set might be private or the format has changed.'),
            backgroundColor: Colors.orange,
          ),
        );
        debugPrint('Failed to parse any questions from Quizlet');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Quizlet import error: $e');
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text('Failed to import from Quizlet: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createStudySet() async {
    if (!_formKey.currentState!.validate()) return;
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(
          content: Text('Please import questions from Quizlet first'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final studySetId = await _dbHelper.createStudySet(
        _nameController.text,
        _descriptionController.text,
        widget.username,
      );

      for (var question in _questions) {
        try {
          await _dbHelper.addQuestionToStudySet(
            studySetId,
            question['question'],
            question['correct_answer'],
            question['options'],
          );
        } catch (e) {
          debugPrint('Error adding question: $e');
          throw Exception('Failed to add question: ${e.toString()}');
        }
      }

      if (!mounted) return;
      _showPostAddDialog(studySetId);
    } catch (e) {
      debugPrint('Error creating study set: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text('Failed to create study set: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showPostAddDialog(int studySetId) {
    showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(widget.currentTheme == 'halloween'
            ? 'Tome Conjured!'
            : 'Study Set Created!'),
        content: Text(widget.currentTheme == 'halloween'
            ? 'Your cursed study set has been added to the archives.'
            : 'Your study set was created successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PracticeModeScreen(
                    studySet: {
                      'id': studySetId,
                      'name': _nameController.text,
                      'description': _descriptionController.text,
                    },
                    username: widget.username,
                    currentTheme: '',
                  ),
                ),
              );
            },
            child: const Text('Practice Now'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _nameController.clear();
                _descriptionController.clear();
                _urlController.clear();
                _questions.clear();
                _hasImported = false;
              });
            },
            child: const Text('Create Another'),
          ),
          TextButton(
            onPressed: () {
              widget.onStudySetCreated();
              Navigator.pop(context);
            },
            child: const Text('Back to My Sets'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from Quizlet'),
        backgroundColor: const Color(0xFF1D1E33),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          getBackgroundForTheme(widget.currentTheme),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFormField(
                            _nameController, 'Study Set Name', 'Enter a name'),
                        const SizedBox(height: 20),
                        _buildFormField(_descriptionController, 'Description',
                            'Enter a description',
                            maxLines: 3),
                        const SizedBox(height: 30),
                        const Text(
                          'Quizlet URL',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildFormField(
                          _urlController,
                          'Paste Quizlet URL here',
                          'Please enter a valid URL',
                          prefixIcon: Icons.link,
                        ),
                        const SizedBox(height: 24),
                        _buildGradientButton(
                          'Import from Quizlet',
                          _importFromQuizlet,
                          Icons.download,
                          const [Color(0xFF16A085), Color(0xFF1ABC9C)],
                        ),
                        if (_questions.isNotEmpty) ...[
                          const SizedBox(height: 30),
                          _buildPreviewSection(),
                        ],
                        const SizedBox(height: 30),
                        _buildGradientButton(
                          'Create Study Set',
                          _questions.isNotEmpty ? _createStudySet : null,
                          Icons.check_circle,
                          const [Color(0xFF2980B9), Color(0xFF3498DB)],
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildFormField(
      TextEditingController controller, String label, String validationMessage,
      {int maxLines = 1, IconData? prefixIcon}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon:
            prefixIcon != null ? Icon(prefixIcon, color: Colors.white70) : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.blueAccent,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMessage;
        }
        return null;
      },
    );
  }

  Widget _buildPreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.greenAccent,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              'Imported ${_questions.length} terms',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Preview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.builder(
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Text('${index + 1}',
                      style: const TextStyle(color: Colors.white)),
                ),
                title: Text(
                  _questions[index]['question'],
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  'Answer: ${_questions[index]['correct_answer']}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGradientButton(
      String text, VoidCallback? onPressed, IconData icon, List<Color> colors) {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              onPressed != null ? colors : [Colors.grey, Colors.grey.shade700],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: colors.first.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class SpreadsheetImportScreen extends StatefulWidget {
  final String username;
  final VoidCallback onStudySetCreated;
  final String currentTheme;

  const SpreadsheetImportScreen({
    super.key,
    required this.username,
    required this.onStudySetCreated,
    required this.currentTheme,
  });

  @override
  _SpreadsheetImportScreenState createState() =>
      _SpreadsheetImportScreenState();
}

class _SpreadsheetImportScreenState extends State<SpreadsheetImportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dbHelper = DatabaseHelper();
  bool _isLoading = false;
  List<Map<String, dynamic>> _questions = [];
  bool _hasFile = false;
  String _fileName = '';

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _fileName = result.files.single.name;
          _hasFile = true;
        });
        await _parseExcelFile(result.files.single.path!);
      }
    } catch (e) {
      debugPrint('File picker error: $e');
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(
          content: Text('Failed to pick file'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _parseExcelFile(String filePath) async {
    try {
      setState(() => _isLoading = true);

      var bytes = await File(filePath).readAsBytes();
      final excelFile = excel.Excel.decodeBytes(bytes);
      var sheet = excelFile.tables.values.first;

      List<Map<String, dynamic>> parsedQuestions = [];

      for (var row in sheet.rows.skip(1)) {
        // Skip header row
        if (row.length < 6) continue;

        String? question = row[0]?.value?.toString();
        String? correct = row[1]?.value?.toString();
        List<String> options = [
          row[2]?.value?.toString() ?? '',
          row[3]?.value?.toString() ?? '',
          row[4]?.value?.toString() ?? '',
          row[5]?.value?.toString() ?? '',
        ];

        if (question != null &&
            correct != null &&
            options.every((o) => o.isNotEmpty)) {
          parsedQuestions.add({
            'question': question,
            'correct_answer': correct,
            'options': options,
          });
        }
      }

      setState(() {
        _questions = parsedQuestions;
        _isLoading = false;
      });

      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text(
              'Parsed ${parsedQuestions.length} questions from spreadsheet'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Excel parsing error: $e');
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(
          content:
              Text('Failed to parse spreadsheet. Please check the format.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createStudySet() async {
    if (!_formKey.currentState!.validate()) return;
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(
          content: Text('Please select a spreadsheet with questions'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final studySetId = await _dbHelper.createStudySet(
        _nameController.text,
        _descriptionController.text,
        widget.username,
      );

      for (var question in _questions) {
        try {
          await _dbHelper.addQuestionToStudySet(
            studySetId,
            question['question'],
            question['correct_answer'],
            question['options'],
          );
        } catch (e) {
          debugPrint('Error adding question: $e');
          throw Exception('Failed to add question: ${e.toString()}');
        }
      }

      if (!mounted) return;
      _showPostAddDialog(studySetId);
    } catch (e) {
      debugPrint('Error creating study set: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text('Failed to create study set: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showPostAddDialog(int studySetId) {
    showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(widget.currentTheme == 'halloween'
            ? 'Tome Conjured!'
            : 'Study Set Created!'),
        content: Text(widget.currentTheme == 'halloween'
            ? 'Your cursed study set has been added to the archives.'
            : 'Your study set was created successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PracticeModeScreen(
                    studySet: {
                      'id': studySetId,
                      'name': _nameController.text,
                      'description': _descriptionController.text,
                    },
                    username: widget.username,
                    currentTheme: '',
                  ),
                ),
              );
            },
            child: const Text('Practice Now'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _nameController.clear();
                _descriptionController.clear();
                _questions.clear();
                _hasFile = false;
                _fileName = '';
              });
            },
            child: const Text('Create Another'),
          ),
          TextButton(
            onPressed: () {
              widget.onStudySetCreated();
              Navigator.pop(context);
            },
            child: const Text('Back to My Sets'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from Spreadsheet'),
        backgroundColor: const Color(0xFF1D1E33),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          getBackgroundForTheme(widget.currentTheme),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildFormField(
                            _nameController, 'Study Set Name', 'Enter a name'),
                        const SizedBox(height: 20),
                        _buildFormField(_descriptionController, 'Description',
                            'Enter a description',
                            maxLines: 3),
                        const SizedBox(height: 30),
                        const Text(
                          'Upload File',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: _pickFile,
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _hasFile
                                        ? Icons.check_circle
                                        : Icons.upload_file,
                                    color: _hasFile
                                        ? Colors.greenAccent
                                        : Colors.white70,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _hasFile
                                        ? _fileName
                                        : 'Tap to select .xlsx file',
                                    style: TextStyle(
                                      color: _hasFile
                                          ? Colors.white
                                          : Colors.white70,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (_questions.isNotEmpty) ...[
                          const SizedBox(height: 30),
                          _buildPreviewSection(),
                        ],
                        const SizedBox(height: 30),
                        _buildGradientButton(
                          'Create Study Set',
                          _questions.isNotEmpty ? _createStudySet : null,
                          Icons.check_circle,
                          const [Color(0xFF2980B9), Color(0xFF3498DB)],
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildFormField(
      TextEditingController controller, String label, String validationMessage,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.blueAccent,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMessage;
        }
        return null;
      },
    );
  }

  Widget _buildPreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.greenAccent,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              'Parsed ${_questions.length} questions',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'Preview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.builder(
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Text('${index + 1}',
                      style: const TextStyle(color: Colors.white)),
                ),
                title: Text(
                  _questions[index]['question'],
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  'Answer: ${_questions[index]['correct_answer']}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGradientButton(
      String text, VoidCallback? onPressed, IconData icon, List<Color> colors) {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              onPressed != null ? colors : [Colors.grey, Colors.grey.shade700],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: colors.first.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class ManualQuestionCreationScreen extends StatefulWidget {
  final String username;
  final VoidCallback onStudySetCreated;
  final String currentTheme;

  const ManualQuestionCreationScreen({
    super.key,
    required this.username,
    required this.onStudySetCreated,
    required this.currentTheme,
  });

  @override
  _ManualQuestionCreationScreenState createState() =>
      _ManualQuestionCreationScreenState();
}

class _ManualQuestionCreationScreenState
    extends State<ManualQuestionCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dbHelper = DatabaseHelper();
  bool _isLoading = false;
  List<Map<String, dynamic>> _questions = [];
  final _questionController = TextEditingController();
  final _correctAnswerController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _questionController.dispose();
    _correctAnswerController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _createStudySet() async {
    if (!_formKey.currentState!.validate()) return;
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one question'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final studySetId = await _dbHelper.createStudySet(
        _nameController.text,
        _descriptionController.text,
        widget.username,
      );

      for (var question in _questions) {
        try {
          await _dbHelper.addQuestionToStudySet(
            studySetId,
            question['question'],
            question['correct_answer'],
            question['options'],
          );
        } catch (e) {
          debugPrint('Error adding question: $e');
          throw Exception('Failed to add question: ${e.toString()}');
        }
      }

      if (!mounted) return;
      _showPostAddDialog(studySetId);
    } catch (e) {
      debugPrint('Error creating study set: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text('Failed to create study set: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ignore: unused_element
  void _addQuestion() {
    if (_questionController.text.isEmpty ||
        _correctAnswerController.text.isEmpty ||
        _optionControllers.any((controller) => controller.text.isEmpty)) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _questions.add({
        'question': _questionController.text,
        'correct_answer': _correctAnswerController.text,
        'options': _optionControllers.map((c) => c.text).toList(),
      });
      _questionController.clear();
      _correctAnswerController.clear();
      for (var controller in _optionControllers) {
        controller.clear();
      }
    });
  }

  void _showPostAddDialog(int studySetId) {
    showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(widget.currentTheme == 'halloween'
            ? 'Tome Conjured!'
            : 'Study Set Created!'),
        content: Text(widget.currentTheme == 'halloween'
            ? 'Your cursed study set has been added to the archives.'
            : 'Your study set was created successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PracticeModeScreen(
                    studySet: {
                      'id': studySetId,
                      'name': _nameController.text,
                      'description': _descriptionController.text,
                    },
                    username: widget.username,
                    currentTheme: '',
                  ),
                ),
              );
            },
            child: const Text('Practice Now'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _nameController.clear();
                _descriptionController.clear();
                _questions.clear();
                for (var c in _optionControllers) c.clear();
              });
            },
            child: const Text('Create Another'),
          ),
          TextButton(
            onPressed: () {
              widget.onStudySetCreated();
              Navigator.pop(context);
            },
            child: const Text('Back to My Sets'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Manually'),
        backgroundColor: const Color(0xFF1D1E33),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          getBackgroundForTheme(widget.currentTheme),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                  ),
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormField(_nameController, 'Study Set Name',
                                'Enter a name'),
                            const SizedBox(height: 20),
                            _buildFormField(_descriptionController,
                                'Description', 'Enter a description',
                                maxLines: 2),
                          ],
                        ),
                      ),
                      const Divider(color: Colors.white24, height: 1),
                      Expanded(
                        child: _questions.isEmpty
                            ? _buildEmptyState()
                            : _buildQuestionList(),
                      ),
                      _buildAddQuestionButton(),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: _buildGradientButton(
                          'Create Study Set',
                          _questions.isNotEmpty ? _createStudySet : null,
                          Icons.check_circle,
                          const [Color(0xFF2980B9), Color(0xFF3498DB)],
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildFormField(
      TextEditingController controller, String label, String validationMessage,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.blueAccent,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMessage;
        }
        return null;
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_task, color: Colors.white38, size: 64),
          const SizedBox(height: 16),
          const Text(
            'No questions yet',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Click the button below to add your first question',
            style:
                TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionList() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _questions.length,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white.withOpacity(0.1),
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Text('${index + 1}',
                  style: const TextStyle(color: Colors.white)),
            ),
            title: Text(
              _questions[index]['question'],
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              'Correct: ${_questions[index]['correct_answer']}',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () {
                setState(() {
                  _questions.removeAt(index);
                });
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddQuestionButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: TextButton.icon(
        onPressed: _showAddQuestionDialog,
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Add Question'),
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.white.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }

  Widget _buildGradientButton(
      String text, VoidCallback? onPressed, IconData icon, List<Color> colors) {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              onPressed != null ? colors : [Colors.grey, Colors.grey.shade700],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: colors.first.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showAddQuestionDialog() {
    final questionController = TextEditingController();
    final correctAnswerController = TextEditingController();
    final optionControllers = List.generate(4, (_) => TextEditingController());

    showDialog(
      context: this.context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        title: const Text('Add a New Question',
            style: TextStyle(color: Colors.white)),
        content: _QuestionInputCard(
          questionController: questionController,
          correctAnswerController: correctAnswerController,
          optionControllers: optionControllers,
          onQuestionAdded: (question) {
            setState(() {
              _questions.add(question);
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

class _QuestionInputCard extends StatefulWidget {
  final Function(Map<String, dynamic>) onQuestionAdded;
  final TextEditingController questionController;
  final TextEditingController correctAnswerController;
  final List<TextEditingController> optionControllers;

  const _QuestionInputCard({
    required this.onQuestionAdded,
    required this.questionController,
    required this.correctAnswerController,
    required this.optionControllers,
  });

  @override
  _QuestionInputCardState createState() => _QuestionInputCardState();
}

class _QuestionInputCardState extends State<_QuestionInputCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueAccent.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Question',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: widget.questionController,
              decoration: InputDecoration(
                labelText: 'Question',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon:
                    const Icon(Icons.help_outline, color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: widget.correctAnswerController,
              decoration: InputDecoration(
                labelText: 'Correct Answer',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.check_circle_outline,
                    color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: widget.optionControllers[index],
                  decoration: InputDecoration(
                    labelText: 'Option ${index + 1}',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Icons.radio_button_unchecked,
                      color: Colors.white70,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  widget.onQuestionAdded({
                    'question': widget.questionController.text,
                    'correct_answer': widget.correctAnswerController.text,
                    'options':
                        widget.optionControllers.map((c) => c.text).toList(),
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Question'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PracticeTypeChoiceScreen extends StatelessWidget {
  final Map<String, dynamic> studySet;
  final String username;
  final String currentTheme;
  const PracticeTypeChoiceScreen({
    super.key,
    required this.studySet,
    required this.username,
    required this.currentTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Space theme background
          getBackgroundForTheme(currentTheme),
          // Additional space elements
          ...List.generate(
            20,
            (index) => Positioned(
              left: (index * 50.0 + 30) % MediaQuery.of(context).size.width,
              top: (index * 80.0 + 50) % MediaQuery.of(context).size.height,
              child: TweenAnimationBuilder(
                duration: Duration(seconds: 4 + (index % 3)),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.5 + (value * 0.5),
                    child: Opacity(
                      opacity: 0.3 + (value * 0.4),
                      child: Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
                onEnd: () {
                  // Restart animation
                },
              ),
            ),
          ),
          // Nebula-like floating orbs
          ...List.generate(
            3,
            (index) => Positioned(
              left: (index * 150.0) % MediaQuery.of(context).size.width,
              top: (index * 200.0 + 100) % MediaQuery.of(context).size.height,
              child: TweenAnimationBuilder(
                duration: Duration(seconds: 8 + index),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(
                      sin(value * 2 * pi) * 30,
                      cos(value * 2 * pi) * 20,
                    ),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF4facfe).withOpacity(0.1),
                            const Color(0xFF667eea).withOpacity(0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
                onEnd: () {
                  // Restart animation
                },
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced header with space theme
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.15),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_rounded,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  studySet['name'] ?? 'Practice',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Select your preferred practice mode',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Select Practice Mode',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Choose how you would like to practice this set.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PracticeModeScreen(
                            studySet: studySet,
                            username: username,
                            currentTheme: currentTheme,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4facfe).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: const [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.quiz_outlined,
                                  color: Colors.white, size: 32),
                              SizedBox(width: 16),
                              Text(
                                'Multiple Choice Practice',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Timed multiple choice questions with instant feedback.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FRQManager(
                            studySet: studySet,
                            username: username,
                            currentTheme: currentTheme,
                            frqCount: 7,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF667eea).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: const [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.code, color: Colors.white, size: 32),
                              SizedBox(width: 16),
                              Text(
                                'Free Response Practice',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Practice free response questions with detailed AI grading.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFF4facfe).withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4facfe).withOpacity(0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Removed the blue accent bar
                        const Icon(Icons.info_outline,
                            color: Color(0xFF4facfe), size: 24),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Tip',
                                style: TextStyle(
                                  color: Color(0xFF4facfe),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'You can switch between practice modes at any time for a comprehensive study experience.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
