import 'package:flutter/material.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:timeago/timeago.dart' as timeago;


class ViewProfile extends StatefulWidget {
  static String id = 'profile_screen';
  final String userId;
  ViewProfile({required this.userId});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
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

    if (widget.userId != null) {
      DocumentSnapshot userData = await _firestore.collection('users').doc(widget.userId).get();
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
                ],
              ),
              SizedBox(height: 20),
              TextField(
                controller: _displayNameController,
                decoration: InputDecoration(labelText: 'Display Name'),
                readOnly: true,

              ),
              SizedBox(height: 20),
              TextField(
                controller: _statusController,
                decoration: InputDecoration(labelText: 'Status'),
                readOnly: true,

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


            ],
          ),
        ),
      ),
    );
  }
}





