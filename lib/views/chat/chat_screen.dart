import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../profile/public_profile_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.receiverId,
    this.postId = '',
    this.receiverName,
  });

  final String receiverId;
  final String postId;
  final String? receiverName;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  String getChatId(String user1, String user2) {
    final ids = [user1, user2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<void> sendMessage() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final chatId = getChatId(currentUser.uid, widget.receiverId);

    final chatRef =
        FirebaseFirestore.instance.collection('chats').doc(chatId);

    await chatRef.set({
      'users': [currentUser.uid, widget.receiverId],
      'postId': widget.postId,
      'lastMessage': text,
      'lastMessageTime': Timestamp.now(),
    }, SetOptions(merge: true));

    await chatRef.collection('messages').add({
      'senderId': currentUser.uid,
      'text': text,
      'createdAt': Timestamp.now(),
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (authProvider.isGuestMode || currentUser == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F0E8),
        appBar: AppBar(
          title: const Text('Chat'),
          backgroundColor: const Color(0xFFF5F0E8),
          foregroundColor: const Color(0xFF25180F),
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 56, color: Color(0xFF775242)),
                const SizedBox(height: 16),
                const Text(
                  'Sign in to start chatting',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF25180F),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Guest users can browse the app, but messaging is only available to signed-in accounts.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF775242)),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text('Create account'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final chatId = getChatId(currentUser.uid, widget.receiverId);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PublicProfileScreen(userId: widget.receiverId),
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.receiverName ?? 'Chat'),
              if (widget.receiverName != null)
                const Text(
                  'View profile',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFFF5F0E8),
        foregroundColor: const Color(0xFF25180F),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('createdAt')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final data =
                        messages[index].data() as Map<String, dynamic>;

                    final isMe = data['senderId'] == currentUser.uid;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe
                              ? const Color(0xFF775242)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          data['text'] ?? '',
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(Icons.send),
                  color: const Color(0xFF775242),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}