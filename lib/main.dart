import 'package:expensetracker/pages/homepage.dart';
import 'package:expensetracker/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.brown,
          fontFamily: GoogleFonts.ptSansCaption().fontFamily),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const HomePage()),
        GetPage(
            name: '/login',
            page: () => const LoginPage(),
            transition: Transition.circularReveal)
      ],
      home: const HomePage(),
    );
  }
}
