import 'package:firebase_core/firebase_core.dart';
import 'package:firebasecommentapp/firebase_options.dart';
import 'package:firebasecommentapp/screens/home_screen.dart';
import 'package:firebasecommentapp/screens/intro_screen.dart';
import 'package:firebasecommentapp/screens/login_screen.dart';
import 'package:firebasecommentapp/screens/music_add_screen.dart';
import 'package:firebasecommentapp/screens/music_player_test_screen.dart';
import 'package:firebasecommentapp/screens/search_test_screen.dart';
import 'package:firebasecommentapp/screens/signin_screen.dart';
import 'package:firebasecommentapp/screens/translate_test_screen.dart';
import 'package:firebasecommentapp/screens/user_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(backgroundColor: Colors.white),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // home: IntroScreen(),
      home: IntroScreen(),
    );
  }
}
