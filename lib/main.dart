import 'package:expensetracker/pages/homepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  await Firebase.initializeApp();

  // FirebaseAuth.instance.authStateChanges().listen((User? user) {
  //   if (user == null) {
  //     if (kDebugMode) {
  //       print('User is currently not logged in!');
  //     }
  //   } else {
  //     if (kDebugMode) {
  //       print('User is signed in!');
  //     }
  //   }
  // });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.brown,
        fontFamily: GoogleFonts.ptSansCaption().fontFamily
      ),
      home: const HomePage(),
    );
  }
}
