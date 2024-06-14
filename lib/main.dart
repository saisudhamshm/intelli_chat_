import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:intelli_chat/screens/chat_screen.dart';
import 'package:intelli_chat/screens/home_screen.dart';
import 'package:intelli_chat/screens/welcome_screen.dart';
import 'package:intelli_chat/screens/profile_screen.dart';
import 'package:intelli_chat/screens/login_screen.dart';
import 'package:intelli_chat/screens/registration_screen.dart';
import 'package:intelli_chat/screens/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    _updateLastSeen();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {

      _updateLastSeen();
    }
  }

  Future<void> _updateLastSeen() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'lastSeen': Timestamp.now(),
      });
    }
    print("1");
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        primaryTextTheme: TextTheme(
            titleMedium:
            TextStyle(color: Theme.of(context).colorScheme.onBackground)),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 26, 204, 151),
          brightness: Brightness.dark,
          surface: Color.fromARGB(255, 40, 53, 64),
        ),
        scaffoldBackgroundColor: Color.fromARGB(255, 6, 7, 7),
      ),
      routes: {
        WelcomeScreen.id: (context) => const WelcomeScreen(),
        LoginScreen.id: (context) => const LoginScreen(),
        RegistrationScreen.id: (context) => const RegistrationScreen(),
        HomeScreen.id: (context) => HomeScreen(),
        ProfileScreen.id : (context) => const ProfileScreen()
      },
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return splashscreen();
          }
          if (snapshot.hasData) {
            return HomeScreen();
          }
          return WelcomeScreen();
        },
      ),
    );
  }
}
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//
// }
