import 'package:flutter/material.dart';
import '../main.dart' show getBackgroundForTheme, ThemeColors, PracticeModeScreen;
import '../helpers/database_helper.dart';

/// Screen for viewing and practicing bookmarked questions
class BookmarkedQuestionsScreen extends StatefulWidget {
  final String username;
  final String currentTheme;
  final String? course; // Optional: filter by course

  const BookmarkedQuestionsScreen({
    super.key,
    required this.username,
    required this.currentTheme,
    this.course,
  });

  @override
  State<BookmarkedQuestionsScreen> createState() => _BookmarkedQuestionsScreenState();
}

class _BookmarkedQuestionsScreenState extends State<BookmarkedQuestionsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<String> _bookmarkedQuestionIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    setState(() => _isLoading = true);
    try {
      final bookmarks = await _dbHelper.getBookmarkedQuestions(widget.username);
      setState(() {
        _bookmarkedQuestionIds = bookmarks;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading bookmarks: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _removeBookmark(String questionId) async {
    await _dbHelper.removeBookmark(widget.username, questionId);
    _loadBookmarks();
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
                              'Bookmarked Questions',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: ThemeColors.getTextColor(widget.currentTheme),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_bookmarkedQuestionIds.length} questions saved',
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
                      : _bookmarkedQuestionIds.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.bookmark_border,
                                    size: 64,
                                    color: ThemeColors.getTextColor(widget.currentTheme)
                                        .withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No bookmarked questions yet',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: ThemeColors.getTextColor(widget.currentTheme)
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Bookmark questions while practicing to review them later',
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
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: _bookmarkedQuestionIds.length,
                              itemBuilder: (context, index) {
                                final questionId = _bookmarkedQuestionIds[index];
                                return _buildBookmarkCard(questionId);
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

  Widget _buildBookmarkCard(String questionId) {
    final textColor = ThemeColors.getTextColor(widget.currentTheme);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.bookmark, color: Colors.blue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ID: ${questionId.split('_').last.substring(0, 8)}...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to practice',
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _removeBookmark(questionId),
          ),
        ],
      ),
    );
  }
}
