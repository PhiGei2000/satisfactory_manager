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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Satisfactory Manager',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Colors.orange, brightness: Brightness.light, primary: Colors.orange),
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
