import 'package:dio/dio.dart';
import '../utils/config.dart';

class RemoteApiClient {
  final Dio _dio;
  final String _base;

  RemoteApiClient()
      : _dio = Dio(
          BaseOptions(
            // Extended timeouts for MongoDB Atlas cloud latency
            // Cloud database operations can take 30-120 seconds depending on load
            connectTimeout: const Duration(seconds: 90),
            receiveTimeout: const Duration(seconds: 120),
            sendTimeout: const Duration(seconds: 90),
            // Don't throw on non-2xx; let us handle status codes
            validateStatus: (_) => true,
          ),
        ),
        _base = AppConfig.baseUrl;

  // AUTH
  Future<bool> login(String username, String password) async {
    try {
      final res = await _dio.post('$_base/auth/login', data: {
        'username': username,
        'password': password,
      });
      return res.statusCode == 200 && 
             res.data is Map && 
             res.data['ok'] == true;
    } catch (e) {
      print('Remote login exception: $e');
      return false;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    try {
      final res = await _dio.post('$_base/auth/register', data: {
        'username': username,
        'email': email,
        'password': password,
      });
      print('Remote register response: status=${res.statusCode}, data=${res.data}');
      // 200 = success, 409 = user exists (fail gracefully)
      if (res.statusCode == 200 && res.data is Map && res.data['ok'] == true) {
        return true;
      }
      if (res.statusCode == 409) {
        print('Remote register: user already exists');
      }
      return false;
    } catch (e) {
      print('Remote register exception: $e');
      return false;
    }
  }

  // Check if username exists (for registration validation only)
  Future<bool> usernameExistsForRegistration(String username) async {
    try {
      final res = await _dio.get('$_base/auth/username-exists/$username');
      if (res.statusCode == 200 && res.data is Map) {
        return res.data['exists'] == true;
      }
      return false;
    } catch (e) {
      print('Username check error: $e');
      return false; // On error, assume doesn't exist to allow registration attempt
    }
  }

  // POINTS
  Future<int> getUserPoints(String username) async {
    final res = await _dio.get('$_base/users/$username/points');
    if (res.statusCode != 200 || res.data is! Map) {
      throw Exception('User not found or error retrieving points');
    }
    return (res.data['points'] as num?)?.toInt() ?? 0;
  }

  Future<void> setUserPoints(String username, int points) async {
    await _dio.put('$_base/users/$username/points', data: {
      'points': points,
    });
  }

  // THEME
  Future<String?> getCurrentTheme(String username) async {
    final res = await _dio.get('$_base/users/$username/theme');
    return res.data['theme'] as String?;
  }

  Future<void> setCurrentTheme(String username, String theme) async {
    await _dio.put('$_base/users/$username/theme', data: {
      'theme': theme,
    });
  }

  Future<List<String>> getUserOwnedThemes(String username) async {
    final res = await _dio.get('$_base/users/$username/themes');
    final list = (res.data['themes'] as List<dynamic>).cast<String>();
    return list;
  }

  Future<void> purchaseTheme(String username, String theme) async {
    await _dio.post('$_base/users/$username/themes/purchase', data: {
      'theme': theme,
    });
  }

  // POWERUPS
  Future<Map<String, int>> getUserPowerups(String username) async {
    final res = await _dio.get('$_base/users/$username/powerups');
    final map = <String, int>{};
    final data = res.data['powerups'] as Map<String, dynamic>;
    data.forEach((k, v) => map[k] = (v as num).toInt());
    return map;
  }

  Future<void> purchasePowerup(String username, String powerupId) async {
    await _dio.post('$_base/users/$username/powerups/purchase', data: {
      'powerupId': powerupId,
    });
  }

  Future<void> usePowerup(String username, String powerupId) async {
    await _dio.post('$_base/users/$username/powerups/use', data: {
      'powerupId': powerupId,
    });
  }

  // IMPORTED SETS (by name)
  Future<List<Map<String, dynamic>>> getUserImportedSets(String username) async {
    final res = await _dio.get('$_base/users/$username/imported-sets');
    final list = (res.data['sets'] as List).cast<Map<String, dynamic>>();
    return list;
  }

  Future<void> addImportedSet(String username, String setName, {int? studySetId}) async {
    await _dio.post('$_base/users/$username/imported-sets', data: {
      'setName': setName,
      if (studySetId != null) 'studySetId': studySetId,
    });
  }

  Future<void> removeImportedSet(String username, String setName) async {
    await _dio.delete('$_base/users/$username/imported-sets/$setName');
  }

  // FRIENDS & MESSAGING
  Future<List<String>> getFriends(String username) async {
    final res = await _dio.get('$_base/users/$username/friends');
    if (res.statusCode == 200 && res.data is Map && res.data['friends'] is List) {
      return (res.data['friends'] as List).cast<String>();
    }
    return [];
  }

  Future<void> sendFriendRequest(String username, String toUsername) async {
    print('DEBUG: POST $_base/users/$username/friend-request with toUsername=$toUsername');
    final res = await _dio.post('$_base/users/$username/friend-request', data: {
      'toUsername': toUsername,
    });
    print('DEBUG: Friend request response: status=${res.statusCode}, data=${res.data}');
    if (res.statusCode != 200) {
      final error = (res.data is Map) 
          ? (res.data['error'] ?? 'Failed to send friend request')
          : 'Failed to send friend request';
      throw Exception(error);
    }
  }

  Future<List<Map<String, dynamic>>> getFriendRequests(String username) async {
    final res = await _dio.get('$_base/users/$username/friend-requests');
    if (res.statusCode == 200 && res.data is Map && res.data['requests'] is List) {
      return (res.data['requests'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> acceptFriendRequest(String username, String fromUsername) async {
    await _dio.post('$_base/users/$username/friend-request/accept', data: {
      'fromUsername': fromUsername,
    });
  }

  Future<void> declineFriendRequest(String username, String fromUsername) async {
    await _dio.post('$_base/users/$username/friend-request/decline', data: {
      'fromUsername': fromUsername,
    });
  }

  Future<List<Map<String, dynamic>>> getInbox(String username) async {
    final res = await _dio.get('$_base/users/$username/inbox');
    if (res.statusCode == 200 && res.data is Map && res.data['messages'] is List) {
      return (res.data['messages'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> markMessageRead(String username, String messageId) async {
    await _dio.put('$_base/users/$username/inbox/$messageId/read');
  }

  Future<void> archiveMessage(String username, String messageId) async {
    await _dio.put('$_base/users/$username/inbox/$messageId/archive');
  }

  Future<void> deleteMessage(String username, String messageId) async {
    await _dio.delete('$_base/users/$username/inbox/$messageId');
  }

  // DIRECT MESSAGING
  Future<List<Map<String, dynamic>>> getConversation(String username, String peer) async {
    final res = await _dio.get('$_base/users/$username/conversations/$peer');
    if (res.statusCode == 200 && res.data is Map && res.data['messages'] is List) {
      return (res.data['messages'] as List).cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> sendDirectMessage(String username, String peer, String message) async {
    final res = await _dio.post('$_base/users/$username/conversations/$peer', data: {
      'message': message,
    });
    if (res.statusCode != 200) {
      final error = (res.data is Map) ? res.data['error'] : 'Failed to send message';
      throw Exception(error);
    }
  }

  Future<void> blockUser(String username, String blockUsername) async {
    await _dio.post('$_base/users/$username/block', data: {
      'blockUsername': blockUsername,
    });
  }

  Future<void> unblockUser(String username, String blockUsername) async {
    await _dio.delete('$_base/users/$username/block/$blockUsername');
  }

  // FINANCIAL LITERACY TEXTBOOK
  /// Fetch a specific Financial Literacy textbook unit with all chapters.
  Future<Response> fetchFinancialTextbookUnit(int unitNumber) async {
    try {
      final res = await _dio.get(
        '$_base/financial-literacy/textbook/unit/$unitNumber',
      );
      return res;
    } catch (e) {
      print('Error fetching textbook unit $unitNumber: $e');
      return Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 500,
      );
    }
  }

  // ROBOTICS CONTENT
  Future<Map<String, dynamic>?> getRoboticsCourse() async {
    try {
      final res = await _dio.get('$_base/robotics/courses/robotics');
      if (res.statusCode == 200 && res.data is Map) {
        return res.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error fetching Robotics course: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getRoboticsModules(
    String courseId, {
    String? difficulty,
    List<String>? tags,
    List<String>? modes,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final params = <String, dynamic>{'page': page, 'pageSize': pageSize};
      if (difficulty != null) params['difficulty'] = difficulty;
      if (tags != null && tags.isNotEmpty) params['tags'] = tags.join(',');
      if (modes != null && modes.isNotEmpty) params['modes'] = modes.join(',');

      final res = await _dio.get('$_base/robotics/modules/$courseId', queryParameters: params);
      if (res.statusCode == 200 && res.data is List) {
        return List<Map<String, dynamic>>.from(res.data);
      }
      return [];
    } catch (e) {
      print('Error fetching Robotics modules: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRoboticsAssessments(
    String moduleId, {
    String? type,
    String? difficulty,
    List<String>? tags,
    List<String>? modes,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final params = <String, dynamic>{'page': page, 'pageSize': pageSize};
      if (type != null) params['type'] = type;
      if (difficulty != null) params['difficulty'] = difficulty;
      if (tags != null && tags.isNotEmpty) params['tags'] = tags.join(',');
      if (modes != null && modes.isNotEmpty) params['modes'] = modes.join(',');

      final res = await _dio.get('$_base/robotics/assessments/$moduleId', queryParameters: params);
      if (res.statusCode == 200 && res.data is List) {
        return List<Map<String, dynamic>>.from(res.data);
      }
      return [];
    } catch (e) {
      print('Error fetching Robotics assessments: $e');
      return [];
    }
  }

  Future<bool> syncRobotics(Map<String, dynamic> payload) async {
    try {
      final res = await _dio.post('$_base/robotics/sync/robotics', data: payload);
      return res.statusCode == 200 && res.data is Map && res.data['ok'] == true;
    } catch (e) {
      print('Error syncing Robotics content: $e');
      return false;
    }
  }
}
