import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:satisfactory_manager/data/database.dart';
import 'package:satisfactory_manager/data/factory.dart';
import 'package:satisfactory_manager/widgets/bottomNavigationBar.dart';
import 'package:satisfactory_manager/widgets/factoryItemList.dart';
import 'package:satisfactory_manager/widgets/factoryList.dart';
import 'package:satisfactory_manager/widgets/itemDialog.dart';
import 'package:satisfactory_manager/widgets/textDialog.dart';

class FactoryScreen extends StatefulWidget {
  static const String routeName = "/factoryScreen";

  const FactoryScreen({super.key});

  @override
  State<StatefulWidget> createState() => FactoryScreenState();
}

class FactoryScreenState extends State<FactoryScreen> {
  String selectedFactoryName = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Factories"),
        leading: const Icon(Icons.factory),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: FactoryList((name) => setState(() {
                    selectedFactoryName = name;
                  })),
            ),
            const VerticalDivider(),
            Expanded(
                child: FactoryItemList(
              factoryName: selectedFactoryName,
            ))
          ],
        ),
      ),
      bottomNavigationBar: const FactoryManagerBottomNavigationBar(0),
    );
  }
}
