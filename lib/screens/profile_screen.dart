import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intelli_chat/screens/home_screen.dart';
import 'package:intelli_chat/screens/welcome_screen.dart';
import 'package:timeago/timeago.dart' as timeago;


class ProfileScreen extends StatefulWidget {
  static String id = 'profile_screen';
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _lastController = TextEditingController();
  final TextEditingController _createdController = TextEditingController();
  String? _photo;
  String? email;
  DateTime? last_seen;
  late DateTime created_at;

  File? _image;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await _firestore.collection('users').doc(user.uid).get();
      Map<String, dynamic> userDataMap = userData.data() as Map<String, dynamic>;
      _displayNameController.text = userDataMap['displayName'];
      _statusController.text = userDataMap['status'];
      email=userDataMap['email'];
     _emailController.text=userDataMap['email'];
     //  created_at=userDataMap['createdAt'];
      final Timestamp timestamp = userDataMap['lastSeen'] as Timestamp;
      _lastController.text=timeago.format(timestamp.toDate()).toString();
      final Timestamp timeestamp = userDataMap['createdAt'] as Timestamp;
      _createdController.text=timeago.format(timeestamp.toDate()).toString();
      _photo=await userDataMap['photoURL'];
      print(_photo);

   //  _lastController.text = DateFormat('K:mm:ss').format(dateTime);
    }
  }

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }
 Future<void> _logout() async{
   try {
     await _auth.signOut();
     Navigator.pushNamed(context, WelcomeScreen.id);
   }
   catch(e){
     print(e);
   }
 }
  Future<void> _updateProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String displayName = _displayNameController.text.trim();
      String status = _statusController.text.trim();

      // Update display name and status
      await _firestore.collection('users').doc(user.uid).update({
        'displayName': displayName,
        'status': status,
      });

      // Upload new profile picture if it's selected
      if (_image != null) {

        Reference ref = FirebaseStorage.instance.ref().child('profile_images/${user.uid}');
        UploadTask uploadTask = ref.putFile(_image!);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();

        // Update profile picture URL
        await _firestore.collection('users').doc(user.uid).update({
          'photoURL': downloadUrl,
        });
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile updated successfully')));

      // Refresh user data
      _getUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.blue,

      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _photo != null ? NetworkImage( _photo !) :null ,
                    //child: _photo == null ? Icon(Icons.camera_alt, size: 40) : null,
                  ),
                  SizedBox(height: 10,)
                  ,
                  GestureDetector(
                  onTap: _uploadImage
                  ,child:Text('Edit')
                  )
                ],
              ),
              SizedBox(height: 20),
              TextField(
                controller: _displayNameController,
                decoration: InputDecoration(labelText: 'Display Name'),

              ),
              SizedBox(height: 20),
              TextField(
                controller: _statusController,
                decoration: InputDecoration(labelText: 'Status'),

              ),SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                readOnly: true
              ),
              SizedBox(height: 20),
              TextField(
                  controller: _lastController,
                  decoration: InputDecoration(labelText: 'Last seen'),
                  readOnly: true
              ),
              SizedBox(height: 20),
              TextField(
                  controller: _createdController,
                  decoration: InputDecoration(labelText: 'Joined'),
                  readOnly: true
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                child: Text('Save Changes'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _logout,
                child: Text('Log Out'),
              )

            ],
          ),
        ),
      ),
    );
  }
}





