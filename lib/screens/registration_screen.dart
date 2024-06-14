import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intelli_chat/components/rounded_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intelli_chat/screens/home_screen.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationScreen extends StatefulWidget {
  static String id = 'registration_screen';

  const RegistrationScreen({super.key});
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late String password;
  late String email;
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime createdAt = DateTime.now();
  bool showSpinner = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ModalProgressHUD(
          inAsyncCall: showSpinner,
          child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      alignment: Alignment.topLeft,
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              SizedBox(
                                height:
                                MediaQuery.of(context).size.height * 0.16,
                              ),
                              Hero(
                                tag: 'logo',
                                child: SizedBox(
                                  height: 150.0,
                                  child: Image.asset('images/split.jpg'),
                                ),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              TextField(
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value) {
                                  //Do something with the user input.
                                  email = value;
                                },
                                decoration: InputDecoration(
                                  labelStyle: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                  ),
                                  hintText: 'Enter your email',
                                  hintStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 20.0),
                                  border: const OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.7),
                                        width: 1.0),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8.0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.7),
                                        width: 1.0),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8.0)),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              TextField(
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                obscureText: true,
                                onChanged: (value) {
                                  //Do something with the user input.
                                  password = value;
                                },
                                decoration: InputDecoration(
                                  labelStyle: Theme.of(context)
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                  ),
                                  hintText: 'Enter your password',
                                  hintStyle: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 20.0),
                                  border: const OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.7),
                                        width: 1.0),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8.0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.7),
                                        width: 1.0),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8.0)),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 24.0,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                    MediaQuery.of(context).size.width *
                                        0.16),
                                child: RoundedButton(
                                    text: 'Register',
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.7),
                                    onClick: () async {
                                      setState(() {
                                        showSpinner = true;
                                      });

                                      try {
                                        final newUser = await _auth
                                            .createUserWithEmailAndPassword(
                                            email: email,
                                            password: password);
                                        await _firestore.collection('users').doc(newUser.user!.uid).set({
                                          'createdAt': createdAt,
                                          'displayName': 'temporary', // Add other profile fields as needed
                                          'email': newUser.user!.email,
                                          'photoURL':  'gs://intelli-chat-prash.appspot.com/profile_images/blank.png',
                                          'status': 'Hey there, I\'m using Intelli-Chat!',
                                          'lastSeen': createdAt, // Initialize lastSeen with createdAt timestamp
                                        });

                                        Navigator.pushNamed(
                                            context, HomeScreen.id);
                                      }
                                      catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                                'Invalid Username or Password',
                                                textAlign: TextAlign.center),
                                            duration: const Duration(
                                                milliseconds: 1500),
                                            width: 250.0,
                                            // Width of the SnackBar.
                                            padding: const EdgeInsets.symmetric(
                                              horizontal:
                                              8.0, // Inner padding for SnackBar content.
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(10.0),
                                            ),
                                          ),
                                        );
                                        print(e);
                                      }
                                      setState(() {
                                        showSpinner = false;
                                      });
                                    }



                                    ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.arrow_back))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
