import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:satisfactory_manager/data/factory.dart';
import 'package:satisfactory_manager/widgets/textDialog.dart';

import '../data/database.dart';
import '../screens/factoryScreen.dart';

class FactoryList extends StatelessWidget {
  final void Function(String) onFactorySelected;

  const FactoryList(this.onFactorySelected, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<FactoryDatabase>(builder: (BuildContext context, FactoryDatabase database, Widget? child) {
        final colorScheme = Theme.of(context).colorScheme;
        final factories = database.factories;

        return ListView.builder(
          itemBuilder: (BuildContext context, int index) => GestureDetector(
            child: Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(vertical: 5),
              color: colorScheme.primary,
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                  factories[index].name,
                  style: TextStyle(color: colorScheme.onPrimary),
                ),
                IconButton(
                    onPressed: () => renameFactory(context, factories[index].name), icon: const Icon(Icons.edit)),
              ]),
            ),
            onTap: () => onFactorySelected(factories[index].name),
          ),
          itemCount: factories.length,
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => createFactory(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void createFactory(BuildContext context) async {
    final factoryName = await showDialog<String>(
        context: context, builder: (BuildContext context) => const TextDialog(title: "New Factory"));

    if (factoryName == null) {
      return;
    }

    if (context.mounted) {
      Provider.of<FactoryDatabase>(context, listen: false).addFactory(Factory(factoryName));
    }
  }

  void renameFactory(BuildContext context, String factoryName) async {
    final newName = await showDialog<String>(
        context: context, builder: (context) => TextDialog(initialText: factoryName, title: "Rename \"$factoryName\""));

    if (newName == null) {
      return;
    }

    if (context.mounted) {
      Provider.of<FactoryDatabase>(context, listen: false).renameFactory(factoryName, newName);
    }
  }
}
