import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:satisfactory_manager/data/database.dart';
import 'package:satisfactory_manager/screens/factoryScreen.dart';
import 'package:satisfactory_manager/screens/logisticsScreen.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  if (Platform.isWindows) {
    sqfliteFfiInit();
  }

  databaseFactory = databaseFactoryFfi;
  runApp(ChangeNotifierProvider(create: (context) => FactoryDatabase(), child: const App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSwatch(
        primarySwatch: Colors.orange, brightness: Brightness.dark, backgroundColor: Colors.grey.shade900);

    return MaterialApp(
      title: 'Satisfactory Manager',
      theme: ThemeData(
        colorScheme: colorScheme,
        appBarTheme: AppBarTheme(backgroundColor: colorScheme.primary),
        bottomNavigationBarTheme:
            BottomNavigationBarThemeData(backgroundColor: colorScheme.surface, selectedItemColor: colorScheme.primary),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      ),
      initialRoute: FactoryScreen.routeName,
      routes: {
        FactoryScreen.routeName: (context) => const FactoryScreen(),
        LogisticsScreen.routeName: (context) => const LogisticsScreen(),
      },
    );
  }
}
