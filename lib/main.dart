import 'package:expensetracker/blocs/balance/balance_bloc.dart';
import 'package:expensetracker/pages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'blocs/authentication/auth_bloc.dart';
import 'blocs/expense/expense_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: dotenv.env['PROJECT_URL']!,
    anonKey: dotenv.env['ANON_KEY']!,
  );
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(MyApp(isDarkMode: isDarkMode));
}

class MyApp extends StatelessWidget {
  final bool isDarkMode;

  const MyApp({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(),
        ),
        BlocProvider(
          create: (context) => BalanceBloc(),
        ),
        BlocProvider(
          create: (context) => ExpenseBloc(context.read<BalanceBloc>()),
        ),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Expense Tracker',
        theme: isDarkMode ? ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.brown,
          fontFamily: GoogleFonts.ptSansCaption().fontFamily,
        ) : ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.brown,
          fontFamily: GoogleFonts.ptSansCaption().fontFamily,
        ),
        initialRoute: '/',
        home: const HomePage(),
      ),
    );
  }
}
