import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_provider.dart';
import 'screens/company_list_screen.dart';

void main() => runApp(
      ChangeNotifierProvider(
        create: (_) => AppProvider()..loadCompanies(),
        child: const MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Vista Test',
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        home: const CompanyListScreen(),
      );
}