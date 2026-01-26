import 'dart:math';

/// Helper class for spaced repetition algorithm (SM-2 simplified)
/// Based on SuperMemo 2 algorithm
class SpacedRepetitionHelper {
  /// Calculate next review date based on performance
  /// Returns updated ease factor, interval, and next review date
  static Map<String, dynamic> calculateNextReview({
    required double currentEaseFactor,
    required int currentInterval,
    required int repetitions,
    required bool isCorrect,
  }) {
    double newEaseFactor = currentEaseFactor;
    int newInterval = currentInterval;
    int newRepetitions = repetitions;
    
    if (isCorrect) {
      // Correct answer: increase ease factor slightly
      newEaseFactor = currentEaseFactor + (0.1 - (5 - 3) * (0.08 + (5 - 3) * 0.02));
      newEaseFactor = newEaseFactor.clamp(1.3, 2.5); // Keep within reasonable bounds
      
      // Increase interval based on repetitions
      if (repetitions == 0) {
        newInterval = 1; // First review: next day
      } else if (repetitions == 1) {
        newInterval = 6; // Second review: 6 days
      } else {
        newInterval = (currentInterval * newEaseFactor).round();
      }
      
      newRepetitions = repetitions + 1;
    } else {
      // Incorrect answer: reset
      newEaseFactor = max(currentEaseFactor, 1.3);
      newInterval = 1; // Review again tomorrow
      newRepetitions = 0;
    }
    
    // Calculate next review date
    final nextReviewDate = DateTime.now().add(Duration(days: newInterval));
    
    return {
      'easeFactor': newEaseFactor,
      'interval': newInterval,
      'repetitions': newRepetitions,
      'reviewDate': nextReviewDate.toIso8601String(),
    };
  }
  
  /// Get questions due for review today
  static List<Map<String, dynamic>> getQuestionsDueToday(
    List<Map<String, dynamic>> questionHistory,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return questionHistory.where((item) {
      final reviewDateStr = item['reviewDate']?.toString();
      if (reviewDateStr == null) return false;
      
      try {
        final reviewDate = DateTime.parse(reviewDateStr);
        final reviewDay = DateTime(reviewDate.year, reviewDate.month, reviewDate.day);
        return reviewDay.isBefore(today) || reviewDay.isAtSameMomentAs(today);
      } catch (e) {
        return false;
      }
    }).toList();
  }
  
  /// Get overdue questions (past due date)
  static List<Map<String, dynamic>> getOverdueQuestions(
    List<Map<String, dynamic>> questionHistory,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return questionHistory.where((item) {
      final reviewDateStr = item['reviewDate']?.toString();
      if (reviewDateStr == null) return false;
      
      try {
        final reviewDate = DateTime.parse(reviewDateStr);
        final reviewDay = DateTime(reviewDate.year, reviewDate.month, reviewDate.day);
        return reviewDay.isBefore(today);
      } catch (e) {
        return false;
      }
    }).toList();
  }
  
  /// Get questions due today (not overdue)
  static List<Map<String, dynamic>> getQuestionsDueTodayOnly(
    List<Map<String, dynamic>> questionHistory,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return questionHistory.where((item) {
      final reviewDateStr = item['reviewDate']?.toString();
      if (reviewDateStr == null) return false;
      
      try {
        final reviewDate = DateTime.parse(reviewDateStr);
        final reviewDay = DateTime(reviewDate.year, reviewDate.month, reviewDate.day);
        return reviewDay.isAtSameMomentAs(today);
      } catch (e) {
        return false;
      }
    }).toList();
  }
}
