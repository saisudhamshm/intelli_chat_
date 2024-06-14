import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mlkit_smart_reply/google_mlkit_smart_reply.dart';
class ChatScreen extends StatefulWidget {
  final String chatId;
  final String recipientId;
  final String recipientName;

  ChatScreen({required this.chatId, required this.recipientId, required this.recipientName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final SmartReply _smartReply = SmartReply();
  User? _currentUser;
  String? _editingMessageId;
  List<String> _smartReplies = [];

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
  }
  @override
  void dispose() {
    _smartReply.close();
    super.dispose();
  }
  void _generateSmartReplies() async {
    final response = await _smartReply.suggestReplies();
    setState(() {
      _smartReplies = response.suggestions;
    });
  }
  void _showSmartReplies() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.black,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _smartReplies.map((reply) {
              return ListTile(
                title: Text(reply),
                onTap: () {
                  Navigator.pop(context);
                  _messageController.text=reply;
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      return;
    }

    String message = _messageController.text.trim();
    if (_editingMessageId != null) {
      // Update the existing message
      await _firestore.collection('chats').doc(widget.chatId).collection('messages').doc(_editingMessageId).update({
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {
        _editingMessageId = null;
      });
    } else {
      // Add a new message
      await _firestore.collection('chats').doc(widget.chatId).collection('messages').add({
        'senderUID': _currentUser!.uid,
        'receiverUID': widget.recipientId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'deletedFor': [],
      });

      await _firestore.collection('chats').doc(widget.chatId).set({
        'user1': _currentUser!.uid,
        'user2': widget.recipientId,
        'lastMessage': message,
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    _messageController.clear();
  }

  Future<void> _deleteMessage(String messageId) async {
    DocumentReference messageRef = _firestore.collection('chats').doc(widget.chatId).collection('messages').doc(messageId);
    DocumentSnapshot messageSnapshot = await messageRef.get();
    List<dynamic> deletedFor = messageSnapshot['deletedFor'] ?? [];
    if (!deletedFor.contains(_currentUser!.uid)) {
      deletedFor.add(_currentUser!.uid);
      await messageRef.update({'deletedFor': deletedFor});
    }
  }

  void _startEditingMessage(String messageId, String message) {
    setState(() {
      _editingMessageId = messageId;
      _messageController.text = message;
    });
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    bool isSentByCurrentUser = data['senderUID'] == _currentUser!.uid;
    bool isDeletedForCurrentUser = (data['deletedFor'] as List<dynamic>).contains(_currentUser!.uid);

    if (isDeletedForCurrentUser) {
      return Container(); // Don't display this message
    }

    return GestureDetector(
      onLongPress:  () => _showMessageOptions(context, document.id, data['message']),
      child: Align(
        alignment: isSentByCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: isSentByCurrentUser ? Colors.blueAccent : Colors.grey[300],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            data['message'],
            style: TextStyle(color: isSentByCurrentUser ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }

  void _showMessageOptions(BuildContext context, String messageId, String message) async{
    DocumentReference messageRef = _firestore.collection('chats').doc(widget.chatId).collection('messages').doc(messageId);
    DocumentSnapshot messageSnapshot = await messageRef.get();
    String sent_user=messageSnapshot['senderUID'];

    bool isCurrentUser = sent_user==_currentUser!.uid ? true :false;
    List<dynamic> deletedFor = messageSnapshot['deletedFor'] ?? [];
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            if (isCurrentUser)
              // Check if the message was sent by the current user
                ListTile(
                  title: Text(messageSnapshot['read'] ? 'Read' : 'Not Read'),
                  // Get the status of the message (not read or read)
                  onTap: () {
                    Navigator.pop(context);
                    // Handle status change (if needed)
                  },
                )
              ,
            if (isCurrentUser)
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _startEditingMessage(messageId, message);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _deleteMessage(messageId);
              },
            )

          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.recipientName}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('chats').doc(widget.chatId).collection('messages').orderBy('timestamp',descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;
                messages.forEach((message) {
                  final messageText = message['message'];
                  final messageSenderId = message['senderUID'];
                 final Timestamp?  timestamp = message['timestamp'];

                  if (messageSenderId == _currentUser!.uid&&timestamp!=null) {
                    _smartReply.addMessageToConversationFromLocalUser(messageText, timestamp!.millisecondsSinceEpoch);
                  } else {
                    if(timestamp!=null)_smartReply.addMessageToConversationFromRemoteUser(messageText, timestamp!.microsecondsSinceEpoch, messageSenderId);
                  }
                });
                _generateSmartReplies();
                return ListView.builder(
                 reverse: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return _buildMessageItem(snapshot.data!.docs[index]);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.reply),
                  onPressed: _showSmartReplies,
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
