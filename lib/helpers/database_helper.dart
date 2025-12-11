import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/premade_study_sets.dart';
import '../utils/config.dart';
import 'remote_api_client.dart';

/**
 * A singleton database helper class for managing MongoDB Atlas operations.
 * 
 * This class provides a centralized interface using RemoteApiClient exclusively.
 * All data is stored in MongoDB Atlas - no local SQLite database.
 */
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  final RemoteApiClient _remote = RemoteApiClient();
  static const List<String> _baseFreeThemes = ['halloween', 'space'];

  static bool _isBaseTheme(String theme) => _baseFreeThemes.contains(theme);

  // ========== USER AUTHENTICATION ==========
  
  Future<bool> authenticateUser(String username, String password) async {
    print('DEBUG: Authenticating user: $username');
    try {
      final result = await _remote.login(username, password);
      print('DEBUG: Authentication result: ${result != null}');
      return result != null;
    } catch (e) {
      print('DEBUG: Authentication error: $e');
      return false;
    }
  }

  Future<bool> usernameExists(String username) async {
    print('DEBUG: Checking if username exists: $username');
    try {
      // Try to get user points - if user exists, this will succeed
      final points = await _remote.getUserPoints(username);
      print('DEBUG: User $username exists with $points points');
      return true; // If we got here, user exists
    } catch (e) {
      print('DEBUG: Username check error: $e');
      return false; // User doesn't exist or error occurred
    }
  }

  // Check username for registration (uses different endpoint to avoid ensureUser issues)
  Future<bool> usernameExistsForRegistration(String username) async {
    print('DEBUG: Checking if username exists for registration: $username');
    try {
      final exists = await _remote.usernameExistsForRegistration(username);
      print('DEBUG: Username exists (registration check): $exists');
      return exists;
    } catch (e) {
      print('DEBUG: Username registration check error: $e');
      return false;
    }
  }

  Future<bool> createUser(String username, String password) async {
    print('DEBUG: Creating user: $username');
    try {
      final result = await _remote.register(username, '$username@eduquest.app', password);
      print('DEBUG: User creation result: $result');
      return result;
    } catch (e) {
      print('DEBUG: User creation error: $e');
      return false;
    }
  }

  // ========== USER POINTS ==========
  
  Future<int> getUserPoints(String username) async {
    try {
      return await _remote.getUserPoints(username);
    } catch (e) {
      print('DEBUG: Error getting user points: $e');
      return 0;
    }
  }

  Future<void> updateUserPoints(String username, int points) async {
    try {
      await _remote.setUserPoints(username, points);
    } catch (e) {
      print('DEBUG: Error updating points: $e');
    }
  }

  Future<void> addPoints(String username, int pointsToAdd) async {
    try {
      final currentPoints = await getUserPoints(username);
      await updateUserPoints(username, currentPoints + pointsToAdd);
    } catch (e) {
      print('DEBUG: Error adding points: $e');
    }
  }

  // ========== THEMES ==========
  
  Future<String?> getCurrentTheme(String username) async {
    try {
      return await _remote.getCurrentTheme(username) ?? 'halloween';
    } catch (e) {
      print('DEBUG: Error getting theme: $e');
      return 'halloween';
    }
  }

  Future<void> updateCurrentTheme(String username, String theme) async {
    try {
      await _remote.setCurrentTheme(username, theme);
    } catch (e) {
      print('DEBUG: Error updating theme: $e');
    }
  }

  Future<List<String>> getUserOwnedThemes(String username) async {
    try {
      return await _remote.getUserOwnedThemes(username);
    } catch (e) {
      print('DEBUG: Error getting owned themes: $e');
      return _baseFreeThemes;
    }
  }

  Future<void> addPurchasedTheme(String username, String themeName) async {
    try {
      final currentThemes = await getUserOwnedThemes(username);
      if (!currentThemes.contains(themeName)) {
        currentThemes.add(themeName);
        // Update via remote API (you'll need to add this endpoint)
        print('DEBUG: Theme purchased: $themeName');
      }
    } catch (e) {
      print('DEBUG: Error purchasing theme: $e');
    }
  }

  // ========== STUDY SETS ==========
  
  Future<List<Map<String, dynamic>>> getUserStudySets(String username) async {
    try {
      // Return empty list for now - you can implement study sets in MongoDB later
      return [];
    } catch (e) {
      print('DEBUG: Error getting study sets: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUserImportedSets(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final importedSetsJson = prefs.getString('imported_sets_$username') ?? '[]';
      final importedSetNames = List<String>.from(jsonDecode(importedSetsJson) ?? []);
      
      // Get premade sets from repository
      final premadeSets = PremadeStudySetsRepository.getPremadeSets();
      
      // Convert imported set names to map format with questions
      final result = <Map<String, dynamic>>[];
      int idCounter = 1000000; // Use high IDs to avoid conflicts with user sets
      
      for (final setName in importedSetNames) {
        final premadeSet = premadeSets.cast<PremadeStudySet?>().firstWhere(
          (set) => set?.name == setName,
          orElse: () => null,
        );
        if (premadeSet != null) {
          idCounter++;
          result.add({
            'id': idCounter, // Unique ID for the imported set
            'studySetId': idCounter,
            'name': premadeSet.name,
            'description': premadeSet.description,
            'questionCount': premadeSet.questions.length,
            'isCustom': false,
            'isPremade': true,
            'createdAt': DateTime.now().millisecondsSinceEpoch,
            'questions': premadeSet.questions.map((q) => {
              'question': q.questionText,
              'options': q.options,
              'correctAnswer': q.correctAnswer,
            }).toList(),
          });
        }
      }
      return result;
    } catch (e) {
      print('DEBUG: Error getting imported sets: $e');
      return [];
    }
  }

  // ========== FRIENDS ==========
  
  Future<List<String>> getFriends(String username) async {
    try {
      return await _remote.getFriends(username);
    } catch (e) {
      print('DEBUG: Error getting friends: $e');
      return [];
    }
  }

  Future<bool> sendFriendRequest(String fromUsername, String toUsername) async {
    try {
      print('DEBUG: Attempting to send friend request from $fromUsername to $toUsername');
      await _remote.sendFriendRequest(fromUsername, toUsername);
      print('DEBUG: Friend request sent successfully');
      return true;
    } catch (e) {
      print('DEBUG: Error sending friend request: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getFriendRequests(String username) async {
    try {
      return await _remote.getFriendRequests(username);
    } catch (e) {
      print('DEBUG: Error getting friend requests: $e');
      return [];
    }
  }

  Future<bool> acceptFriendRequest(String username, String fromUsername) async {
    try {
      await _remote.acceptFriendRequest(username, fromUsername);
      return true;
    } catch (e) {
      print('DEBUG: Error accepting friend request: $e');
      return false;
    }
  }

  Future<bool> declineFriendRequest(String username, String fromUsername) async {
    try {
      await _remote.declineFriendRequest(username, fromUsername);
      return true;
    } catch (e) {
      print('DEBUG: Error declining friend request: $e');
      return false;
    }
  }

  // ========== INBOX/MESSAGES ==========
  
  Future<List<Map<String, dynamic>>> getInbox(String username) async {
    try {
      return await _remote.getInbox(username);
    } catch (e) {
      print('DEBUG: Error getting inbox: $e');
      return [];
    }
  }

  Future<int> getUnreadMessageCount(String username) async {
    try {
      final messages = await _remote.getInbox(username);
      return messages.where((msg) => msg['read'] != true).length;
    } catch (e) {
      print('DEBUG: Error getting unread count: $e');
      return 0;
    }
  }

  Future<void> markMessageAsRead(String username, String messageId) async {
    try {
      await _remote.markMessageRead(username, messageId);
    } catch (e) {
      print('DEBUG: Error marking message as read: $e');
    }
  }

  Future<void> markAllMessagesAsRead(String username) async {
    try {
      final messages = await _remote.getInbox(username);
      final unreadMessages = messages.where((msg) => msg['read'] != true).toList();
      for (final msg in unreadMessages) {
        final messageId = msg['_id'] as String? ?? msg['id'] as String? ?? '';
        if (messageId.isNotEmpty) {
          await _remote.markMessageRead(username, messageId);
        }
      }
    } catch (e) {
      print('DEBUG: Error marking all messages as read: $e');
    }
  }

  Future<void> archiveMessage(String username, String messageId) async {
    try {
      await _remote.archiveMessage(username, messageId);
    } catch (e) {
      print('DEBUG: Error archiving message: $e');
    }
  }

  Future<void> deleteMessage(String username, String messageId) async {
    try {
      await _remote.deleteMessage(username, messageId);
    } catch (e) {
      print('DEBUG: Error deleting message: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getConversation(String username, String peer) async {
    try {
      return await _remote.getConversation(username, peer);
    } catch (e) {
      print('DEBUG: Error getting conversation: $e');
      return [];
    }
  }

  Future<bool> sendDirectMessage(String username, String peer, String message) async {
    try {
      await _remote.sendDirectMessage(username, peer, message);
      return true;
    } catch (e) {
      print('DEBUG: Error sending direct message: $e');
      return false;
    }
  }

  // ========== POWERUPS ==========
  
  Future<Map<String, int>> getUserPowerups(String username) async {
    try {
      return await _remote.getUserPowerups(username);
    } catch (e) {
      print('DEBUG: Error getting powerups: $e');
      return {};
    }
  }

  Future<void> usePowerup(String username, String powerupId) async {
    try {
      await _remote.usePowerup(username, powerupId);
    } catch (e) {
      print('DEBUG: Error using powerup: $e');
    }
  }

  Future<void> purchasePowerup(String username, String powerupId) async {
    try {
      await _remote.purchasePowerup(username, powerupId);
    } catch (e) {
      print('DEBUG: Error purchasing powerup: $e');
    }
  }

  Future<void> purchaseTheme(String username, String theme) async {
    try {
      await _remote.purchaseTheme(username, theme);
    } catch (e) {
      print('DEBUG: Error purchasing theme: $e');
    }
  }

  Future<void> updateStudySet(int studySetId, String name, String description) async {
    print('DEBUG: updateStudySet stub - not implemented in MongoDB yet');
  }

  Future<void> updateQuestion(int questionId, String question, String answer, List<String>? options) async {
    print('DEBUG: updateQuestion stub - not implemented in MongoDB yet');
  }

  Future<void> deleteQuestion(int questionId) async {
    print('DEBUG: deleteQuestion stub - not implemented in MongoDB yet');
  }

  // ========== STUDY SETS (STUB - NOT IMPLEMENTED IN MONGODB YET) ==========
  
  Future<int> createStudySet(String name, String description, String username) async {
    print('DEBUG: createStudySet stub - not implemented in MongoDB yet');
    return 0; // Return dummy ID
  }

  Future<void> addQuestionToStudySet(int studySetId, String question, String answer, [dynamic options]) async {
    print('DEBUG: addQuestionToStudySet stub - not implemented in MongoDB yet');
  }

  Future<int> getStudySetQuestionCount(int studySetId) async {
    print('DEBUG: getStudySetQuestionCount stub - not implemented in MongoDB yet');
    return 0;
  }

  Future<List<Map<String, dynamic>>> getStudySetQuestions(int studySetId) async {
    print('DEBUG: getStudySetQuestions stub - not implemented in MongoDB yet');
    return [];
  }

  Future<void> removeImportedSet(String username, int studySetId) async {
    print('DEBUG: removeImportedSet stub - not implemented in MongoDB yet');
  }

  // ========== PREMADE STUDY SETS (STUB - NOT IMPLEMENTED) ==========
  
  Future<void> refreshPremadeSets() async {
    print('DEBUG: refreshPremadeSets stub - not implemented in MongoDB yet');
  }

  Future<void> importPremadeSet(String username, int studySetId, {String? setName}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final importedSetsJson = prefs.getString('imported_sets_$username') ?? '[]';
      final importedSetNames = List<String>.from(jsonDecode(importedSetsJson) ?? []);
      
      if (setName != null && !importedSetNames.contains(setName)) {
        importedSetNames.add(setName);
        await prefs.setString('imported_sets_$username', jsonEncode(importedSetNames));
        print('DEBUG: Successfully imported premade set: $setName');
      }
    } catch (e) {
      print('DEBUG: Error importing premade set: $e');
    }
  }

  Future<bool> areAllPremadeSetsLoaded() async {
    print('DEBUG: areAllPremadeSetsLoaded stub - returning false');
    return false;
  }

  Future<List<Map<String, dynamic>>> getPremadeStudySets() async {
    print('DEBUG: getPremadeStudySets stub - returning empty list');
    return [];
  }

  // ========== USER MANAGEMENT ==========
  
  Future<void> addUser(String username, String email, String password) async {
    try {
      await _remote.register(username, email, password);
    } catch (e) {
      print('DEBUG: Error adding user: $e');
    }
  }

  // ========== DATABASE GETTER (FOR COMPATIBILITY) ==========
  
  // This getter is kept for compatibility but returns null since we no longer use local DB
  get database => null;
}
