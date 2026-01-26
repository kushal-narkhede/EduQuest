import '../data/ap_calculus_ab_chapters.dart';

/// Helper class for analyzing study performance and generating insights
class AnalyticsHelper {
  /// Analyze performance data to identify weak areas
  static List<String> identifyWeakAreas(
    Map<String, Map<String, dynamic>> chapterProgress,
    {double threshold = 0.7}
  ) {
    final weakAreas = <String>[];
    
    chapterProgress.forEach((chapter, progress) {
      final accuracy = progress['accuracy'] as double? ?? 0.0;
      final questionsAttempted = progress['questionsAttempted'] as int? ?? 0;
      
      // Consider weak if accuracy is below threshold and at least 5 questions attempted
      if (accuracy < threshold && questionsAttempted >= 5) {
        weakAreas.add(chapter);
      }
    });
    
    return weakAreas;
  }
  
  /// Generate personalized study recommendations
  static List<String> generateRecommendations(
    Map<String, Map<String, dynamic>> chapterProgress,
    List<Map<String, dynamic>> questionHistory,
  ) {
    final recommendations = <String>[];
    
    // Find weakest chapter
    String? weakestChapter;
    double lowestAccuracy = 1.0;
    int mostMissed = 0;
    
    chapterProgress.forEach((chapter, progress) {
      final accuracy = progress['accuracy'] as double? ?? 0.0;
      final questionsAttempted = progress['questionsAttempted'] as int? ?? 0;
      
      if (questionsAttempted >= 5 && accuracy < lowestAccuracy) {
        lowestAccuracy = accuracy;
        weakestChapter = chapter;
      }
      
      // Count missed questions
      final missed = questionHistory
          .where((h) => h['chapter'] == chapter && h['isCorrect'] == false)
          .length;
      if (missed > mostMissed) {
        mostMissed = missed;
      }
    });
    
    if (weakestChapter != null && lowestAccuracy < 0.7) {
      recommendations.add(
        'Focus on $weakestChapter - ${(lowestAccuracy * 100).toStringAsFixed(0)}% accuracy'
      );
    }
    
    // Check for improvement trends
    final recentHistory = questionHistory
        .where((h) {
          final timestamp = h['timestamp'];
          if (timestamp == null) return false;
          try {
            final date = DateTime.parse(timestamp.toString());
            return DateTime.now().difference(date).inDays <= 7;
          } catch (e) {
            return false;
          }
        })
        .toList();
    
    if (recentHistory.isNotEmpty) {
      final recentCorrect = recentHistory.where((h) => h['isCorrect'] == true).length;
      final recentAccuracy = recentCorrect / recentHistory.length;
      
      // Compare with overall accuracy
      final overallCorrect = questionHistory.where((h) => h['isCorrect'] == true).length;
      final overallAccuracy = questionHistory.isNotEmpty
          ? overallCorrect / questionHistory.length
          : 0.0;
      
      if (recentAccuracy > overallAccuracy + 0.1) {
        recommendations.add(
          'Great progress! Your accuracy improved ${((recentAccuracy - overallAccuracy) * 100).toStringAsFixed(0)}% this week'
        );
      }
    }
    
    // Check for chapters needing review
    final chaptersNeedingReview = <String>[];
    chapterProgress.forEach((chapter, progress) {
      final lastStudied = progress['lastStudied'];
      if (lastStudied != null) {
        try {
          final date = DateTime.parse(lastStudied.toString());
          final daysSince = DateTime.now().difference(date).inDays;
          if (daysSince > 7) {
            chaptersNeedingReview.add(chapter);
          }
        } catch (e) {
          // Ignore parse errors
        }
      }
    });
    
    if (chaptersNeedingReview.isNotEmpty) {
      recommendations.add(
        'Review ${chaptersNeedingReview.take(2).join(' and ')} - haven\'t studied in a while'
      );
    }
    
    // Check if ready for exam
    final masteredChapters = chapterProgress.values
        .where((p) => (p['accuracy'] as double? ?? 0.0) >= 0.8)
        .length;
    final totalChapters = apCalculusABChapters.length;
    
    if (masteredChapters >= totalChapters * 0.8) {
      recommendations.add('Excellent! You\'re ready for the exam!');
    }
    
    return recommendations;
  }
  
  /// Calculate study streak (consecutive days with study activity)
  static int calculateStreak(List<Map<String, dynamic>> questionHistory) {
    if (questionHistory.isEmpty) return 0;
    
    // Get unique study dates
    final studyDates = questionHistory
        .map((h) {
          final timestamp = h['timestamp'];
          if (timestamp == null) return null;
          try {
            return DateTime.parse(timestamp.toString());
          } catch (e) {
            return null;
          }
        })
        .whereType<DateTime>()
        .map((dt) => DateTime(dt.year, dt.month, dt.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // Sort descending
    
    if (studyDates.isEmpty) return 0;
    
    // Check consecutive days starting from today
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    int streak = 0;
    DateTime currentDate = todayDate;
    
    for (final studyDate in studyDates) {
      if (studyDate.isAtSameMomentAs(currentDate) ||
          studyDate.isAtSameMomentAs(currentDate.subtract(const Duration(days: 1)))) {
        if (studyDate.isAtSameMomentAs(currentDate)) {
          streak++;
        } else {
          streak++;
          currentDate = studyDate;
        }
      } else {
        break;
      }
    }
    
    return streak;
  }
  
  /// Get performance trend (improving, declining, stable)
  static String getPerformanceTrend(List<Map<String, dynamic>> questionHistory) {
    if (questionHistory.length < 10) return 'stable';
    
    // Split into two halves
    final sortedHistory = List<Map<String, dynamic>>.from(questionHistory)
      ..sort((a, b) {
        final aTime = a['timestamp']?.toString() ?? '';
        final bTime = b['timestamp']?.toString() ?? '';
        return aTime.compareTo(bTime);
      });
    
    final midPoint = sortedHistory.length ~/ 2;
    final firstHalf = sortedHistory.sublist(0, midPoint);
    final secondHalf = sortedHistory.sublist(midPoint);
    
    final firstAccuracy = firstHalf
            .where((h) => h['isCorrect'] == true)
            .length /
        firstHalf.length;
    final secondAccuracy = secondHalf
            .where((h) => h['isCorrect'] == true)
            .length /
        secondHalf.length;
    
    final difference = secondAccuracy - firstAccuracy;
    
    if (difference > 0.1) {
      return 'improving';
    } else if (difference < -0.1) {
      return 'declining';
    } else {
      return 'stable';
    }
  }
}
