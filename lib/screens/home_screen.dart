import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intelli_chat/screens/profile_screen.dart';
import 'package:intelli_chat/screens/chat_screen.dart';// Make sure to import ChatScreen
import 'package:intelli_chat/screens/view_profile.dart';
class HomeScreen extends StatefulWidget {
  static String id='home_screen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();

  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
  }

  Future<void> _addFriend() async {
    String email = _emailController.text.trim();
    if (email.isEmpty) return;

    try {
      QuerySnapshot userSnapshot = await _firestore.collection('users').where('email', isEqualTo: email).get();
      if (userSnapshot.docs.isNotEmpty) {
        String friendId = userSnapshot.docs[0].id;
        await _firestore.collection('users').doc(_currentUser!.uid).collection('friends').doc(friendId).set({
          'friendId': friendId,
          'addedAt': FieldValue.serverTimestamp(),
        });
        await _firestore.collection('users').doc(friendId).collection('friends').doc(_currentUser!.uid).set({
          'friendId': _currentUser!.uid,
          'addedAt': FieldValue.serverTimestamp(),
        });
        _emailController.clear();
      } else {
        // Handle user not found
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User not found')));
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding friend')));
    }
  }

  String _getChatId(String userId1, String userId2) {
    return userId1.compareTo(userId2) < 0 ? '${userId1}_${userId2}' : '${userId2}_${userId1}';
  }

  void _navigateToChatScreen(String friendId, String friendName) {
    String chatId = _getChatId(_currentUser!.uid, friendId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatId: chatId,
          recipientId: friendId,
          recipientName: friendName,
        ),
      ),
    );
  }
  void _navigatetoview(String friendId) {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewProfile(
         userId: friendId
        ),
      ),
    );
  }

  Widget _buildFriendItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    String friendId = data['friendId'];

    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('users').doc(friendId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return ListTile(title: Text('Loading...'));
        }

        var friendData = snapshot.data!.data() as Map<String, dynamic>;
        String friendName = friendData['displayName'];

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(friendData['photoURL']),
          ),
          title: Text(friendName),
          onTap: () => _navigateToChatScreen(friendId, friendName),
          onLongPress: ()=>_navigatetoview(friendId),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()), // Ensure you have a ProfileScreen
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Enter friend\'s email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addFriend,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('users').doc(_currentUser!.uid).collection('friends').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return _buildFriendItem(snapshot.data!.docs[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
