import 'package:flutter/material.dart';
import '../helpers/database_helper.dart';
import '../main.dart' show getBackgroundForTheme, ThemeColors;

class InboxScreen extends StatefulWidget {
  final String username;
  final String currentTheme;

  const InboxScreen({
    super.key,
    required this.username,
    required this.currentTheme,
  });

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen>
    with AutomaticKeepAliveClientMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late List<Map<String, dynamic>> _messages = [];
  late List<Map<String, dynamic>> _filteredMessages = [];
  String _filterType = 'all'; // all, unread, archived
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    // Mark all messages as read when inbox is opened
    _dbHelper.markAllMessagesAsRead(widget.username);
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      final messages = await _dbHelper.getInbox(widget.username);
      setState(() {
        _messages = messages;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading inbox: $e');
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    if (_filterType == 'unread') {
      _filteredMessages = _messages.where((m) => m['isRead'] == false).toList();
    } else if (_filterType == 'archived') {
      _filteredMessages = _messages.where((m) => m['isArchived'] == true).toList();
    } else {
      _filteredMessages =
          _messages.where((m) => m['isArchived'] != true).toList();
    }
    // Sort by most recent first
    _filteredMessages.sort((a, b) {
      final dateA = DateTime.parse((a['createdAt'] ?? DateTime.now().toString()) as String);
      final dateB = DateTime.parse((b['createdAt'] ?? DateTime.now().toString()) as String);
      return dateB.compareTo(dateA);
    });
  }

  Future<void> _archiveMessage(String messageId) async {
    try {
      await _dbHelper.archiveMessage(widget.username, messageId);
      // Update local state immediately
      setState(() {
        final index = _messages.indexWhere((m) => 
          (m['_id'] == messageId || m['id'] == messageId));
        if (index != -1) {
          _messages[index]['isArchived'] = true;
        }
        _applyFilter();
      });
      // Reload from server to ensure sync
      await _loadMessages();
    } catch (e) {
      debugPrint('Error archiving message: $e');
    }
  }

  Future<void> _deleteMessage(String messageId) async {
    await _dbHelper.deleteMessage(widget.username, messageId);
    _loadMessages();
  }

  String _getMessageIcon(String type) {
    switch (type) {
      case 'friend_request':
        return '👥';
      case 'direct_message':
        return '💬';
      default:
        return '📬';
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Inbox'),
        backgroundColor: ThemeColors.getPrimaryColor(widget.currentTheme),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Stack(
        children: [
          getBackgroundForTheme(widget.currentTheme),
          Column(
            children: [
              // Filter tabs
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: ThemeColors.getPrimaryColor(widget.currentTheme)
                    .withOpacity(0.1),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'All'),
                      _buildFilterChip('unread', 'Unread'),
                      _buildFilterChip('archived', 'Archived'),
                    ],
                  ),
                ),
              ),
              // Messages list
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: ThemeColors.getPrimaryColor(widget.currentTheme),
                        ),
                      )
                    : _filteredMessages.isEmpty
                        ? Center(
                            child: Text(
                              'No messages',
                              style: TextStyle(
                                color: ThemeColors.getTextColor(widget.currentTheme)
                                    .withOpacity(0.6),
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredMessages.length,
                            itemBuilder: (context, index) {
                              final message = _filteredMessages[index];
                              final messageId = message['_id'] as String? ?? message['id'] as String? ?? '';
                              return Dismissible(
                                key: Key(messageId),
                                direction: DismissDirection.horizontal,
                                onDismissed: (direction) {
                                  _deleteMessage(messageId);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Message deleted'),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                background: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(left: 20),
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                secondaryBackground: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                child: _buildMessageTile(message),
                              );
                            },
                          ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _filterType == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _filterType = value;
            _applyFilter();
          });
        },
        backgroundColor: Colors.transparent,
        selectedColor:
            ThemeColors.getPrimaryColor(widget.currentTheme).withOpacity(0.3),
        side: BorderSide(
          color: isSelected
              ? ThemeColors.getPrimaryColor(widget.currentTheme)
              : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        labelStyle: TextStyle(
          color: isSelected
              ? ThemeColors.getPrimaryColor(widget.currentTheme)
              : Colors.grey.shade600,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildMessageTile(Map<String, dynamic> message) {
    final isRead = message['isRead'] == true;
    final type = message['type'] as String;
    final fromUsername = message['fromUsername'] as String? ?? message['from_username'] as String? ?? 'System';
    final subject = message['subject'] as String? ?? 'No subject';
    final content = message['content'] as String? ?? '';
    final messageId = message['_id'] as String? ?? message['id'] as String? ?? '';
    final createdAtStr = message['createdAt'] ?? message['created_at'] ?? DateTime.now().toString();
    final createdAt = DateTime.parse(createdAtStr.toString());

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ThemeColors.getPrimaryColor(widget.currentTheme).withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: ThemeColors.getPrimaryColor(widget.currentTheme)
                .withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              _getMessageIcon(type),
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    subject,
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                      color: ThemeColors.getTextColor(widget.currentTheme),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isRead)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: ThemeColors.getPrimaryColor(widget.currentTheme),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'From: $fromUsername',
              style: TextStyle(
                fontSize: 12,
                color: ThemeColors.getTextColor(widget.currentTheme)
                    .withOpacity(0.6),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: ThemeColors.getTextColor(widget.currentTheme)
                      .withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatDate(createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
              // Add Accept/Decline buttons for friend requests
              if (type == 'friend_request')
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _acceptFriendRequest(fromUsername, messageId),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Accept'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _declineFriendRequest(fromUsername, messageId),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Decline'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.archive_outlined),
          color: Colors.white.withOpacity(0.7),
          onPressed: () async {
            await _archiveMessage(messageId);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Message archived'),
                  backgroundColor: ThemeColors.getPrimaryColor(widget.currentTheme),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _acceptFriendRequest(String fromUsername, String messageId) async {
    try {
      final success = await _dbHelper.acceptFriendRequest(widget.username, fromUsername);
      if (success) {
        // Delete the message after accepting
        await _dbHelper.deleteMessage(widget.username, messageId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You are now friends with $fromUsername')),
          );
        }
        _loadMessages();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to accept friend request')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error accepting friend request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _declineFriendRequest(String fromUsername, String messageId) async {
    try {
      final success = await _dbHelper.declineFriendRequest(widget.username, fromUsername);
      if (success) {
        // Delete the message after declining
        await _dbHelper.deleteMessage(widget.username, messageId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Declined friend request from $fromUsername')),
          );
        }
        _loadMessages();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to decline friend request')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error declining friend request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
