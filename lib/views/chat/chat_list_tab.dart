import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'chat_screen.dart';

class ChatListTab extends StatelessWidget {
  const ChatListTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = FirebaseAuth.instance.currentUser;
    final isGuest = authProvider.isGuestMode || currentUser == null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: const Color(0xFFF5F0E8),
        foregroundColor: const Color(0xFF25180F),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F0E8),
      body: isGuest
          ? _GuestMessagesState(
              onCreateAccount: () {
                Navigator.pushNamed(context, '/signup');
              },
              onSignIn: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(initialMode: AuthMode.login),
                  ),
                );
              },
            )
          : _MessagesInbox(
              currentUserId: currentUser.uid,
            ),
    );
  }
}

class _MessagesInbox extends StatelessWidget {
  const _MessagesInbox({required this.currentUserId});

  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final chatsQuery = FirebaseFirestore.instance
        .collection('chats')
        .where('users', arrayContains: currentUserId);

    return StreamBuilder<QuerySnapshot>(
      stream: chatsQuery.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _EmptyState(
            icon: Icons.error_outline,
            title: 'Messages unavailable',
            subtitle: 'We could not load your inbox right now.',
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs.toList()
          ..sort((left, right) {
            final leftTime = (left.data() as Map<String, dynamic>)['lastMessageTime'];
            final rightTime = (right.data() as Map<String, dynamic>)['lastMessageTime'];
            final leftMillis = leftTime is Timestamp ? leftTime.millisecondsSinceEpoch : 0;
            final rightMillis = rightTime is Timestamp ? rightTime.millisecondsSinceEpoch : 0;
            return rightMillis.compareTo(leftMillis);
          });

        if (docs.isEmpty) {
          return const _EmptyState(
            icon: Icons.chat_bubble_outline,
            title: 'No conversations yet',
            subtitle: 'Chats will appear here when someone messages you.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final users = List<String>.from(data['users'] ?? const []);
            final otherUserId = users.firstWhere(
              (id) => id != currentUserId,
              orElse: () => '',
            );
            final postId = data['postId'] as String? ?? '';
            final lastMessage = data['lastMessage'] as String? ?? '';
            final lastMessageTime = data['lastMessageTime'] as Timestamp?;

            return _ConversationTile(
              currentUserId: currentUserId,
              otherUserId: otherUserId,
              postId: postId,
              lastMessage: lastMessage,
              lastMessageTime: lastMessageTime,
            );
          },
        );
      },
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.currentUserId,
    required this.otherUserId,
    required this.postId,
    required this.lastMessage,
    required this.lastMessageTime,
  });

  final String currentUserId;
  final String otherUserId;
  final String postId;
  final String lastMessage;
  final Timestamp? lastMessageTime;

  @override
  Widget build(BuildContext context) {
    if (otherUserId.isEmpty) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<Map<String, String>>(
      future: _loadConversationPreview(),
      builder: (context, snapshot) {
        final preview = snapshot.data ?? const <String, String>{};
        final title = preview['title'] ?? 'Conversation';
        final subtitle = preview['subtitle'] ?? 'Tap to open chat';
        final avatarText = _avatarText(title);

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    receiverId: otherUserId,
                    postId: postId,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFEBE1D2),
                    child: Text(
                      avatarText,
                      style: const TextStyle(
                        color: Color(0xFF775242),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF25180F),
                                ),
                              ),
                            ),
                            if (lastMessageTime != null)
                              Text(
                                _formatTime(lastMessageTime!),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9A7A66),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF775242),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          lastMessage.isEmpty ? 'No messages yet' : lastMessage,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF25180F),
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
      },
    );
  }

  Future<Map<String, String>> _loadConversationPreview() async {
    final userSnap = await FirebaseFirestore.instance.collection('users').doc(otherUserId).get();
    final userData = userSnap.data() ?? const <String, dynamic>{};

    final displayName = _displayName(userData, otherUserId);
    final postPreview = await _loadPostPreview();

    return {
      'title': displayName,
      'subtitle': postPreview.isEmpty ? 'Open conversation' : 'About $postPreview',
    };
  }

  Future<String> _loadPostPreview() async {
    if (postId.isEmpty) {
      return '';
    }

    final postSnap = await FirebaseFirestore.instance.collection('posts').doc(postId).get();
    final postData = postSnap.data();
    if (postData == null) {
      return '';
    }

    final postName = postData['name'] as String? ?? '';
    final location = postData['location'] as String? ?? '';

    if (postName.isEmpty && location.isEmpty) {
      return '';
    }

    if (postName.isNotEmpty && location.isNotEmpty) {
      return '$postName · $location';
    }

    return postName.isNotEmpty ? postName : location;
  }

  String _displayName(Map<String, dynamic> userData, String fallbackId) {
    final displayName = (userData['displayName'] as String? ?? '').trim();
    final name = (userData['name'] as String? ?? '').trim();
    final username = (userData['username'] as String? ?? userData['userName'] as String? ?? '').trim();

    if (displayName.isNotEmpty) {
      return displayName;
    }
    if (name.isNotEmpty) {
      return name;
    }
    if (username.isNotEmpty) {
      return '@$username';
    }
    return fallbackId;
  }

  String _avatarText(String label) {
    final trimmed = label.trim();
    if (trimmed.isEmpty) {
      return '?';
    }

    final parts = trimmed.split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }

    final first = parts.first.characters.first.toUpperCase();
    final second = parts[1].characters.first.toUpperCase();
    return '$first$second';
  }

  String _formatTime(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    final now = DateTime.now();

    if (dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day) {
      final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    }

    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}';
  }
}

class _GuestMessagesState extends StatelessWidget {
  const _GuestMessagesState({required this.onCreateAccount, required this.onSignIn});

  final VoidCallback onCreateAccount;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 56, color: Color(0xFF775242)),
            const SizedBox(height: 16),
            const Text(
              'Messages are for signed-in users',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF25180F),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You can browse as a guest, but the inbox and chat threads are disabled until you sign in.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF775242)),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onCreateAccount,
              child: const Text('Create account'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: onSignIn,
              child: const Text('Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: const Color(0xFF775242).withOpacity(0.8)),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF25180F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF775242)),
            ),
          ],
        ),
      ),
    );
  }
}