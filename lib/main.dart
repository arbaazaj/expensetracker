import 'package:expensetracker/blocs/balance/balance_bloc.dart';
import 'package:expensetracker/pages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'blocs/authentication/auth_bloc.dart';
import 'blocs/expense/expense_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: dotenv.env['PROJECT_URL']!,
    anonKey: dotenv.env['ANON_KEY']!,
  );
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.brown,
          fontFamily: GoogleFonts.ptSansCaption().fontFamily,
        ),
        initialRoute: '/',
        home: const HomePage(),
      ),
    );
  }
}
