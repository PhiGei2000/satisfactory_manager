import 'package:flutter/material.dart';
import 'package:satisfactory_manager/screens/factoryScreen.dart';
import 'package:satisfactory_manager/screens/logisticsScreen.dart';

class FactoryManagerBottomNavigationBar extends StatelessWidget {
  final int selectedTab;

  static const List<String> routeNames = [FactoryScreen.routeName, LogisticsScreen.routeName];

  const FactoryManagerBottomNavigationBar(this.selectedTab, {super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedTab,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.factory), label: "Factories"),
        BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: "Logistics"),
      ],
      onTap: (index) => Navigator.popAndPushNamed(context, routeNames[index]),
    );
  }
}
